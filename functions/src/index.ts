// Imports do Firebase Admin SDK (módulos específicos)
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging, AndroidConfig } from "firebase-admin/messaging";

// Imports do Firebase Functions v2
import { onCall, HttpsError, onRequest } from 'firebase-functions/v2/https';
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { setGlobalOptions } from "firebase-functions/v2";
import { defineSecret } from "firebase-functions/params";



import axios from "axios";
import { appLogger, generateRequestId, sanitize } from "./logger";

// Logger raiz — cada função cria um child com requestId e action para rastreamento
const logger = appLogger;




// Configurações globais para as funções
setGlobalOptions({
  maxInstances: 10,
  timeoutSeconds: 60,
  memory: '256MiB'
});

// Inicializa o app
const app = initializeApp();

// Obtenha referências aos serviços
const db = getFirestore(app);
const messaging = getMessaging(app);
const PAGBANK_TOKEN_SECRET = defineSecret("PAGBANK_TOKEN");
const PAGBANK_WEBHOOK_TOKEN_SECRET = defineSecret("PAGBANK_WEBHOOK_TOKEN");

function getPagBankAuthorizationHeader(token: string): string {
  return token.startsWith("Bearer ") ? token : `Bearer ${token}`;
}

function sanitizePagBankErrorData(data: any) {
  if (!data) return undefined;

  return {
    message: data.message,
    error: data.error,
    error_messages: Array.isArray(data.error_messages)
      ? data.error_messages.map((item: any) => ({
          code: item?.code,
          description: item?.description || item?.message,
        }))
      : undefined,
  };
}

/**
 * Cloud Function para obter os dados de um usuário autenticado.
 * Essa função é acionada via HTTPS e requer autenticação. Ela busca os dados do usuário no Firestore,
 * utilizando o UID obtido do contexto de autenticação. Se o usuário não estiver autenticado, um erro é retornado.
 * Se o usuário não for encontrado no Firestore, a função retorna null.
 * @param {onCall.CallableRequest} request Objeto contendo os dados da requisição e o contexto de autenticação.
 * @returns {Promise<object>} Um objeto contendo os dados do usuário ou uma mensagem de erro.
 * @throws {HttpsError} Se o usuário não estiver autenticado ou se ocorrer um erro ao buscar os dados.
 */
export const getUserData = onCall({
  timeoutSeconds: 30,
  memory: '128MiB',
}, async (request) => {
  const { data, auth } = request;
  const reqLogger = logger.child({ action: 'getUserData', requestId: generateRequestId() });

  if (!auth) {
    reqLogger.warn('Tentativa de acesso sem autenticação');
    return {
      "data": "Nenhum usuário logado",
    };
  }

  const uid = auth.uid;
  const uidLogger = reqLogger.child({ uid });

  try {
    const snapshot = await db.collection("users").doc(uid).get();

    if (!snapshot.exists) {
      uidLogger.warn('Usuário não encontrado no Firestore');
      return { "data": null };
    }

    // Não logar snapshot.data() — contém dados pessoais (PII)
    uidLogger.info('Dados do usuário recuperados com sucesso');

    return {
      "data": snapshot.data(),
    };
  } catch (error: any) {
    uidLogger.error('Erro ao buscar dados do usuário', { error });
    throw new Error('Falha ao buscar dados do usuário.');
  }
});

/**
 * Cloud Function para adicionar uma mensagem ao Firestore.
 * Essa função é acionada via HTTPS e não requer autenticação. Ela recebe dados de mensagem no corpo da requisição
 * e os adiciona à coleção "messages" no Firestore. A função retorna o ID do documento recém-criado.
 * @param {onCall.CallableRequest} request Objeto contendo os dados da requisição.
 * @returns {Promise<object>} Um objeto contendo o ID da mensagem criada ou uma mensagem de erro.
 * @throws {Error} Se ocorrer um erro ao adicionar a mensagem ao Firestore.
 */
export const addMessage = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Usuário deve estar autenticado');
  }

  const { data } = request;

  if (!data || typeof data !== 'object') {
    throw new HttpsError('invalid-argument', 'Dados inválidos');
  }

  const messageData = {
    ...data,
    userId: request.auth.uid,
    createdAt: FieldValue.serverTimestamp(),
  };

  try {
    const snapshot = await db.collection("messages").add(messageData);
    logger.log('Mensagem adicionada com sucesso com ID:', snapshot.id);
    return { "success": snapshot.id };
  } catch (error: any) {
    logger.error('Erro ao adicionar mensagem:', error);
    throw new HttpsError('internal', 'Falha ao adicionar mensagem.');
  }
});

/**
 * Cloud Function acionada quando um novo pedido é criado no Firestore.
 * Essa função é acionada sempre que um novo documento é criado na coleção "orders".
 * Ela obtém o ID da empresa (companyID) do documento do pedido e envia uma notificação push
 * para todos os administradores associados a essa empresa. A notificação informa sobre a criação do novo pedido.
 * @param {onDocumentCreated.CloudEvent} event Objeto contendo os dados do evento de criação do documento.
 * @returns {Promise<void>}
 */
export const onNewOrder = onDocumentCreated("/orders/{orderId}", async (event) => {
  const orderId = event.params.orderId;
  if (!event.data) {
    logger.warn(`Evento de novo pedido ${orderId} sem dados.`);
    return;
  }
  const companyID = event.data.data().companyID;

  logger.info(`Novo pedido criado com ID: ${orderId} para a empresa: ${companyID}`);

  try {
    const querySnapshot = await db.collection("admins").where("companyID", "==", companyID).get();
    const admins = querySnapshot.docs.map((doc) => doc.id);
    let adminsTokens: string[] = [];
    for (let i = 0; i < admins.length; i++) {
      const tokensAdmin: string[] = await getDeviceTokens(admins[i]);
      adminsTokens = adminsTokens.concat(tokensAdmin);
    }
    await sendPushFCM(
      adminsTokens,
      "Novo Pedido",
      "Nova venda realizada. Pedido: " + orderId,
      "",
      ""
    );
  } catch (error: any) {
    logger.error('Erro ao processar novo pedido:', error);
  }
});

/**
 * Cloud Function acionada quando uma nova notificação é criada no Firestore.
 * Essa função é acionada sempre que um novo documento é criado na coleção "notifications".
 * Ela obtém o ID do usuário (userID) do documento da notificação e envia uma notificação push
 * para o dispositivo do usuário. A notificação contém o título, o corpo, a imagem e o tipo da notificação.
 * @param {onDocumentCreated.CloudEvent} event Objeto contendo os dados do evento de criação do documento.
 * @returns {Promise<void>}
 */
export const onNewNotification = onDocumentCreated("/notifications/{id}", async (event) => {
  const userID = event.params.id;
  if (!event.data) {
    logger.warn(`Evento de notificação para o usuário ${userID} sem dados.`);
    return;
  }
  const notificationData = event.data.data();

  if (!notificationData || !notificationData.notifi || notificationData.notifi.length === 0) {
    logger.warn(`Notificação criada para o usuário ${userID} sem conteúdo.`);
    return;
  }

  const index = notificationData.notifi.length;
  const notificationTitle = notificationData.notifi[index - 1].notificationTitle;
  const notificationBody = notificationData.notifi[index - 1].notificationBody;
  const image = notificationData.notifi[index - 1].image;
  const type = notificationData.notifi[index - 1].type;

  logger.info(`Nova notificação para o usuário ${userID}: ${notificationTitle}`);

  try {
    const tokensUser: string[] = await getDeviceTokens(userID);

    await sendPushFCMIMG(
      tokensUser,
      notificationTitle,
      notificationBody,
      image,
      type
    );
  } catch (error: any) {
    logger.error('Erro ao enviar notificação push:', error);
  }
});

/**
 * Cloud Function acionada quando as notificações de um usuário são alteradas no Firestore.
 * Essa função é acionada sempre que um documento na coleção "notifications" é atualizado.
 * Ela compara o número de notificações antes e depois da atualização. Se o número de notificações
 * aumentou, a função envia uma notificação push para o usuário.
 * @param {onDocumentUpdated.CloudEvent} event Objeto contendo os dados do evento de atualização do documento.
 * @returns {Promise<void>}
 */
export const onNotificationsChanged = onDocumentUpdated("/notifications/{id}", async (event) => {
  const userID = event.params.id;

  if (!event.data || !event.data.before || !event.data.after) {
    logger.warn(`Evento de atualização de notificações para o usuário ${userID} sem dados completos.`);
    return;
  }

  const beforeStatus = event.data.before.data().notifi;
  const afterStatus = event.data.after.data().notifi;

  if (beforeStatus.length < afterStatus.length) {
    logger.info(`Notificações alteradas para o usuário ${userID}. Enviando nova notificação.`);
    const tokensUser = await getDeviceTokens(event.data.after.data().id);
    const index = event.data.after.data().notifi.length;
    const notificationTitle = event.data.after.data().notifi[index - 1].notificationTitle;
    const notificationBody = event.data.after.data().notifi[index - 1].notificationBody;
    const image = event.data.after.data().image;
    const type = event.data.after.data().type;

    try {
      await sendPushFCMIMG(
        tokensUser,
        notificationTitle,
        notificationBody,
        image,
        type
      );
    } catch (error: any) {
      logger.error('Erro ao enviar notificação push:', error);
    }
  } else {
    logger.info(`Notificações alteradas para o usuário ${userID}, mas sem novas notificações.`);
  }
});

const orderStatus = new Map([
  [0, "Cancelado"],
  [1, "Em Aprovação"],
  [2, "Em Preparação"],
  [3, "Em Transporte"],
  [4, "Entregue"],
]);

/**
 * Cloud Function acionada quando o status de um pedido é alterado no Firestore.
 * Essa função é acionada sempre que o status de um pedido é alterado na coleção "orders".
 * Ela compara o status do pedido antes e depois da atualização. Se o status foi alterado,
 * a função envia uma notificação push para o usuário informando sobre a alteração.
 * @param {onDocumentUpdated.CloudEvent} event Objeto contendo os dados do evento de atualização do documento.
 * @returns {Promise<void>}
 */
export const onOrderStatusChanged = onDocumentUpdated("/orders/{orderId}", async (event) => {
  const orderId = event.params.orderId;

  if (!event.data || !event.data.before || !event.data.after) {
    logger.warn(`Evento de atualização de pedido ${orderId} sem dados completos.`);
    return;
  }

  const beforeStatus = event.data.before.data().status;
  const afterStatus = event.data.after.data().status;
  const user = event.data.after.data().user;

  if (beforeStatus !== afterStatus) {
    logger.info(`Status do pedido ${orderId} alterado de ${beforeStatus} para ${afterStatus}.`);
    try {
      const tokensUser = await getDeviceTokens(user);
      await sendPushFCM(
        tokensUser,
        "Pedido: " + orderId,
        "Status atualizado para: " + orderStatus.get(afterStatus),
        "",
        ""
      );
    } catch (error: any) {
      logger.error('Erro ao enviar notificação push:', error);
    }
  } else {
    logger.info(`Status do pedido ${orderId} não foi alterado.`);
  }
});

/**
 * Cloud Function acionada quando um novo evento é criado no Firestore.
 * Essa função é acionada sempre que um novo documento é criado na coleção "events".
 * Ela obtém o ID da empresa (companyID) do documento do evento e envia uma notificação push
 * para todos os administradores associados a essa empresa. A notificação informa sobre o novo evento agendado.
 * @param {onDocumentCreated.CloudEvent} event Objeto contendo os dados do evento de criação do documento.
 * @returns {Promise<void>}
 */
export const onCutEvents = onDocumentCreated("/events/{id}", async (event) => {
  const eventId = event.params.id;
  if (!event.data) {
    logger.warn(`Evento de novo agendamento ${eventId} sem dados.`);
    return;
  }
  const companyID = event.data.data().companyID;

  logger.info(`Novo evento agendado com ID: ${eventId} para a empresa: ${companyID}`);

  try {
    const querySnapshot = await db.collection("admins").where("companyID", "==", companyID).get();
    const admins = querySnapshot.docs.map((doc) => doc.id);
    let adminsTokens: string[] = [];
    for (let i = 0; i < admins.length; i++) {
      const tokensAdmin: string[] = await getDeviceTokens(admins[i]);
      adminsTokens = adminsTokens.concat(tokensAdmin);
    }
    await sendPushFCM(
      adminsTokens,
      "Novo Agendamento de Serviço",
      "Novo Serviço Agendado",
      "",
      ""
    );
  } catch (error: any) {
    logger.error('Erro ao processar novo agendamento:', error);
  }
});



/**
 * Cloud Function para criar assinatura no PagBank
 * Recebe o cartão já criptografado do frontend
 */
export const createPagBankSubscription = onCall(
  {
    timeoutSeconds: 60,
    memory: '256MiB',
    secrets: [PAGBANK_TOKEN_SECRET],
  },
  async (request) => {
    const reqLogger = logger.child({
      action: 'createPagBankSubscription',
      requestId: generateRequestId(),
      uid: request.auth?.uid,
    });
    reqLogger.info('Iniciando createPagBankSubscription');
    
    try {
      const { 
        companyId, 
        encryptedCard, // Cartão já criptografado vindo do frontend
        cardHolder, 
        cpf, 
        phone,
        address,
        security_code,
      } = request.data;

      // Validar dados obrigatórios
      if (!companyId || !encryptedCard || !cardHolder || !cpf || !phone || !address || !security_code) {
        reqLogger.error('Dados obrigatórios ausentes em createPagBankSubscription', {
          hasCompanyId: !!companyId,
          hasEncryptedCard: !!encryptedCard,
          hasCardHolder: !!cardHolder,
          hasCpf: !!cpf,
          hasPhone: !!phone,
          hasAddress: !!address,
          hasSecurityCode: !!security_code,
        });
        throw new HttpsError('invalid-argument', 'Dados incompletos para criar assinatura');
      }

      // Buscar dados da empresa
      const companyDoc = await db.collection('companys').doc(companyId).get();
      if (!companyDoc.exists) {
        throw new HttpsError('not-found', 'Empresa não encontrada');
      }

      const companyData = companyDoc.data();
      if (!companyData) {
        throw new HttpsError('not-found', 'Dados da empresa não encontrados');
      }
      
      // Formatar telefone (remover caracteres especiais)
      const phoneClean = phone.replace(/\D/g, '');

      const pagBankToken = PAGBANK_TOKEN_SECRET.value();
      if (!pagBankToken) {
        throw new HttpsError('internal', 'Token PagBank não configurado');
      }

      const baseUrl = 'https://api.assinaturas.pagseguro.com';

      try {
        // Criar a assinatura com o cartão já criptografado
        let subscriptionData: any;
        
        if (companyData.customer_id === null || companyData.customer_id === undefined || companyData.customer_id === '') {
          reqLogger.info('customer_id não encontrado — criando novo cliente PagBank', { companyId });
          subscriptionData = {
            plan: {
              id: 'PLAN_633F2BAF-4FE1-4EE7-A1EE-C317E782F086'
            },
            customer: {
              billing_info: [
                {
                  card: {
                    encrypted: encryptedCard,
                    security_code: security_code,
                  },
                  type: 'CREDIT_CARD',
                }
              ],
              name: cardHolder.trim(),
              email: companyData.email,
              tax_id: cpf.replace(/\D/g, ''),
              phones: [{
                country: '55', 
                area: phoneClean.substring(0, 2), 
                number: phoneClean.substring(2)
              }],
            },
            payment_method: [{
              type: 'CREDIT_CARD',
              card: {
                security_code: security_code,
                encrypted: encryptedCard,
              },
            }],
            reference_id: `SUB_${companyId}_${Date.now()}`,
          };
        } else {
          reqLogger.info('customer_id existente — usando cliente PagBank já cadastrado', {
            companyId,
            customerId: companyData.customer_id,
          });
          subscriptionData = {
            plan: {
              id: 'PLAN_633F2BAF-4FE1-4EE7-A1EE-C317E782F086'
            },
            customer: {
              id: companyData.customer_id,
              billing_info: [
                {
                  card: {
                    encrypted: encryptedCard,
                    security_code: security_code,
                  },
                  type: 'CREDIT_CARD',
                }
              ],        
            },            
            payment_method: [{
              type: 'CREDIT_CARD',
              card: {
                security_code: security_code,
                encrypted: encryptedCard,
              },
            }],
            reference_id: `SUB_${companyId}_${Date.now()}`,
          };
        }

        const requestUrl = `${baseUrl}/subscriptions`;

        const requestHeaders = {
          'accept': 'application/json',
          'Authorization': getPagBankAuthorizationHeader(pagBankToken),
          'content-type': 'application/json'
        };

        reqLogger.info('Enviando requisição de assinatura ao PagBank', {
          endpoint: requestUrl,
          hasExistingCustomer: !!(companyData.customer_id),
          referenceId: subscriptionData.reference_id,
        });

        const subscriptionResponse = await axios.post(
          requestUrl,
          subscriptionData,
          {
            headers: requestHeaders
          }
        );

        reqLogger.info('Assinatura PagBank criada com sucesso', {
          subscriptionId: subscriptionResponse.data?.id,
          status: subscriptionResponse.data?.status,
          customerId: subscriptionResponse.data?.customer?.id,
        });

        // Atualizar empresa com dados da assinatura
        await db.collection('companys').doc(companyId).update({
          subscriptionId: subscriptionResponse.data.id,
          subscriptionStatus: subscriptionResponse.data.status,
          subscriptionPlan: 'PLAN_633F2BAF-4FE1-4EE7-A1EE-C317E782F086',
          customer_id: subscriptionResponse.data.customer.id,
        });
        reqLogger.info('Empresa atualizada com dados da assinatura', { companyId });

        reqLogger.info('createPagBankSubscription concluído com sucesso', {
          companyId,
          subscriptionId: subscriptionResponse.data.id,
        });

        return { 
          success: true, 
          subscriptionId: subscriptionResponse.data.id,
          status: subscriptionResponse.data.status
        };

      } catch (axiosError: any) {
        // Log estruturado único com todo o contexto do erro Axios
        if (axiosError.response) {
          reqLogger.error('Erro na requisição ao PagBank', {
            httpStatus: axiosError.response.status,
            httpStatusText: axiosError.response.statusText,
            pagbankError: sanitizePagBankErrorData(axiosError.response.data),
          });
          
          const errorData = axiosError.response.data;
          let errorMessage = 'Erro ao processar pagamento';
          
          if (errorData?.error_messages && Array.isArray(errorData.error_messages)) {
            errorMessage = errorData.error_messages
              .map((err: any) => `${err.code}: ${err.description || err.message}`)
              .join(', ');
          } else if (errorData?.message) {
            errorMessage = errorData.message;
          } else if (errorData?.error) {
            errorMessage = errorData.error;
          }
          
          throw new HttpsError('invalid-argument', errorMessage);
        } else if (axiosError.request) {
          reqLogger.error('PagBank não respondeu à requisição', { errorMessage: axiosError.message });
          throw new HttpsError('internal', 'Sem resposta do servidor PagBank');
        } else {
          reqLogger.error('Falha ao montar requisição ao PagBank', { errorMessage: axiosError.message });
          throw new HttpsError('internal', 'Erro ao configurar requisição');
        }
      }

    } catch (error: any) {
      if (error instanceof HttpsError) {
        // Já foi logado no catch interno; apenas repropaga
        throw error;
      }
      
      reqLogger.error('Erro inesperado em createPagBankSubscription', {
        errorName: (error as Error).name,
        errorMessage: (error as Error).message,
      });
      throw new HttpsError('internal', error.message || 'Erro ao criar assinatura');
    }
  }
);

/**
 * Cloud Function para obter chave pública do PagBank
 */
export const getPagBankPublicKey = onCall(
  {
    timeoutSeconds: 30,
    memory: '128MiB',
    secrets: [PAGBANK_TOKEN_SECRET],
  },
  async (request) => {
    const pkLogger = logger.child({
      action: 'getPagBankPublicKey',
      requestId: generateRequestId(),
      uid: request.auth?.uid,
    });
    pkLogger.info('Obtendo chave pública do PagBank');
    
    try {
      const pagBankToken = PAGBANK_TOKEN_SECRET.value();
      if (!pagBankToken) {
        throw new HttpsError('internal', 'Token PagBank não configurado');
      }

      const baseUrl = 'https://api.assinaturas.pagseguro.com';

      const response = await axios.get(
        `${baseUrl}/public-keys`,
        {
          headers: {
            'accept': 'application/json',
            'Authorization': getPagBankAuthorizationHeader(pagBankToken),
            'Content-Type': 'application/json'
          }
        }
      );

      pkLogger.info('Chave pública obtida com sucesso');
      
      return {
        success: true,
        publicKey: response.data.public_key,
        createdAt: response.data.created_at
      };

    } catch (error: any) {
      pkLogger.error('Erro ao obter chave pública do PagBank', {
        hasResponse: !!(error as any).response,
        errorMessage: (error as Error).message,
      });
      
      if ((error as any).response) {
        throw new HttpsError('internal', 'Erro ao obter chave pública do PagBank');
      }
      
      throw new HttpsError('internal', 'Erro ao conectar com PagBank');
    }
  }
);

/**
 * Obtém os tokens de dispositivo de um usuário.
 * Essa função busca no Firestore os tokens de dispositivo associados a um determinado usuário.
 * Os tokens são armazenados em uma subcoleção chamada "tokens" dentro do documento do usuário.
 * @param {string} uid O UID do usuário.
 * @returns {Promise<string[]>} Uma lista de tokens de dispositivo do usuário.
 */
async function getDeviceTokens(uid: string) {
  try {
    const querySnapshot = await db
      .collection("users").doc(uid).collection("tokens").get();
    const tokens = querySnapshot.docs.map((doc) => doc.id);
    // Não logar os tokens em si — são identificadores de dispositivo (PII)
    logger.info('Tokens de dispositivo recuperados', { uid, count: tokens.length });
    return tokens;
  } catch (error: any) {
    logger.error('Erro ao obter tokens do usuário', { uid, error });
    return [];
  }
}

/**
 * Envia uma notificação push FCM para uma lista de tokens.
 * Essa função envia uma notificação push FCM para uma lista de tokens de dispositivo.
 * A notificação contém um título, uma mensagem, uma imagem e um tipo.
 * @param {string[]} tokens Uma lista de tokens de dispositivo.
 * @param {string} title O título da notificação.
 * @param {string} message A mensagem da notificação.
 * @param {string} image A URL da imagem da notificação.
 * @param {string} type O tipo da notificação.
 * @returns {Promise<any>} A resposta do serviço FCM.
 */
async function sendPushFCM(tokens: string[], title: string, message: string, image: string, type: string) {

  if (tokens.length > 0) {
    let messagem = {
      tokens: tokens,
      notification: {
        title: title,
        body: message,
      },
      data: {
        type: type,
        image: image,
      }
    }
    try {
      const response = await messaging.sendEachForMulticast(messagem);
      // Não logar a resposta completa — contém dados de tokens de dispositivo
      logger.info('Notificações FCM enviadas', {
        successCount: response.successCount,
        failureCount: response.failureCount,
        total: tokens.length,
      });
      return response;
    } catch (error: any) {
      logger.error('Erro ao enviar notificações FCM', { error });
      throw error; // propaga para o chamador detectar a falha
    }
  } else {
    logger.warn('Nenhum token de dispositivo encontrado para enviar a notificação.');
    return;
  }
}

/**
 * Envia uma notificação push FCM com imagem para uma lista de tokens.
 * 
 * Essa função envia uma notificação push FCM com imagem para uma lista de tokens de dispositivo.
 * 
 * A notificação contém um título, um corpo, uma imagem e um tipo.
 * 
 * A função utiliza a configuração AndroidConfig para adicionar a imagem à notificação.
 * 
 * @param {string[]} userstokens Uma lista de tokens de dispositivo.
 * 
 * @param {string} title O título da notificação.
 * 
 * @param {string} body O corpo da notificação.
 * 
 * @param {string} image A URL da imagem da notificação.
 * 
 * @param {string} type O tipo da notificação.
 * 
 * @returns {Promise<any>} A resposta do serviço FCM.
 */
async function sendPushFCMIMG(userstokens: string[], title: string, body: string, image: string, type: string) {
  if (userstokens.length > 0) {
    const androidConfig: AndroidConfig = {
      priority: 'high',

      notification: {
        imageUrl: image,
      }
    };

    const message = {

      notification: {
        title: title,
        body: body,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      tokens: userstokens,
      android: androidConfig,
      apns: {
        payload: {
          aps: {
            'mutable-content': 1,
            contentAvailable: true,
            priority: 'high',
          },
        },
        headers: {

          'apns-priority': '10',

        },
        fcm_options: {
          image: image
        }
      },

    };

    // Não logar o payload completo — contém lista de tokens de dispositivo (PII)
    logger.info('Enviando FCM com imagem', { count: userstokens.length });
    try {
      const response = await messaging.sendEachForMulticast(message);
      logger.info('Notificações FCM com imagem enviadas', {
        successCount: response.successCount,
        failureCount: response.failureCount,
        total: userstokens.length,
      });
      return response;
    } catch (error: any) {
      logger.error('Erro ao enviar notificações FCM com imagem', { error });
      throw error; // propaga para o chamador detectar a falha
    }
  } else {
    logger.warn('Nenhum token de dispositivo encontrado para enviar a notificação com imagem.');
    return;
  }
}

/**
 * Cloud Function para processar webhooks do PagBank
 * Esta função recebe notificações sobre mudanças nas assinaturas
 */
export const pagBankWebhook = onRequest(
  {
    timeoutSeconds: 60,
    memory: '256MiB',
    secrets: [PAGBANK_WEBHOOK_TOKEN_SECRET],
  },
  async (request, response) => {
    const webhookLogger = logger.child({
      action: 'pagBankWebhook',
      requestId: generateRequestId(),
      remoteIp: request.ip,
    });
    webhookLogger.info('Webhook PagBank recebido', { method: request.method });

    try {
      if (request.method !== 'POST') {
        response.status(405).send('Method Not Allowed');
        return;
      }

      // Valida token do webhook — não logar o token em si
      const token = request.headers['x-webhook-token'];
      const webhookToken = PAGBANK_WEBHOOK_TOKEN_SECRET.value();
      if (!webhookToken) {
        webhookLogger.error('Token de webhook do PagBank não configurado');
        response.status(500).send('Webhook token not configured');
        return;
      }

      if (token !== webhookToken) {
        webhookLogger.warn('Token de webhook inválido na requisição');
        response.status(401).send('Unauthorized');
        return;
      }

      const { id, reference_id, status, charges } = request.body;

      if (!id || !status) {
        webhookLogger.error('Webhook recebido sem ID ou status obrigatórios');
        response.status(400).send('Bad Request');
        return;
      }

      // Mapear status do PagBank para o app
      let appStatus = 'INACTIVE';
      let companyActive = false;

      switch (status) {
        case 'ACTIVE':
          appStatus = 'ACTIVE';
          companyActive = true;
          break;
        case 'PAYMENT_METHOD_CHANGE':
        case 'SUSPENDED':
          appStatus = 'SUSPENDED';
          companyActive = true; // Mantém ativa mas com aviso
          break;
        case 'CANCELED':
        case 'EXPIRED':
          appStatus = 'CANCELED';
          companyActive = false;
          break;
        case 'TRIAL':
          appStatus = 'TRIAL';
          companyActive = true;
          break;
        default:
          appStatus = status;
          companyActive = false;
      }

      // Buscar empresa pela subscription ID
      const companiesQuery = await db.collection('companys')
        .where('subscriptionId', '==', id)
        .limit(1)
        .get();

      if (companiesQuery.empty) {
        webhookLogger.error('Empresa não encontrada para subscription', { subscriptionId: id });
        response.status(404).send('Company not found');
        return;
      }

      const companyDoc = companiesQuery.docs[0];
      const companyId = companyDoc.id;

      webhookLogger.info('Processando webhook para empresa', { companyId, newStatus: appStatus });

      // Atualizar status da empresa
      await db.collection('companys').doc(companyId).update({
        active: companyActive,
        subscriptionStatus: appStatus,
        'subscription.status': status,
        'subscription.lastWebhookAt': FieldValue.serverTimestamp(),
        'subscription.lastCharge': charges?.[0] || null
      });

      // Criar notificação para os admins
      const adminsQuery = await db.collection('admins')
        .where('companyID', '==', companyId)
        .get();

      for (const adminDoc of adminsQuery.docs) {
        const notificationData = {
          notifi: FieldValue.arrayUnion({
            notificationTitle: 'Status da Assinatura Atualizado',
            notificationBody: `Sua assinatura foi atualizada para: ${appStatus}`,
            image: '',
            type: 'subscription',
            timestamp: FieldValue.serverTimestamp()
          })
        };

        await db.collection('notifications').doc(adminDoc.id).set(
          notificationData,
          { merge: true }
        );
      }

      webhookLogger.info('Webhook processado com sucesso', { companyId, appStatus });
      response.status(200).send('OK');

    } catch (error: any) {
      webhookLogger.error('Erro ao processar webhook PagBank', {
        errorName: (error as Error).name,
        errorMessage: (error as Error).message,
      });
      response.status(500).send('Internal Server Error');
    }
  }
);

/**
 * Cloud Function para verificar manualmente o status de uma assinatura
 */
export const checkSubscriptionStatus = onCall(
  {
    timeoutSeconds: 30,
    memory: '128MiB',
    secrets: [PAGBANK_TOKEN_SECRET],
  },
  async (request) => {
    const subLogger = logger.child({
      action: 'checkSubscriptionStatus',
      requestId: generateRequestId(),
      uid: request.auth?.uid,
    });
    subLogger.info('Verificando status da assinatura');
    
    try {
      const { companyId } = request.data;

      if (!companyId) {
        throw new HttpsError('invalid-argument', 'ID da empresa é obrigatório');
      }

      // Buscar dados da empresa
      const companyDoc = await db.collection('companys').doc(companyId).get();
      if (!companyDoc.exists) {
        throw new HttpsError('not-found', 'Empresa não encontrada');
      }

      const companyData = companyDoc.data();
      const subscriptionId = companyData?.subscription?.id;

      if (!subscriptionId) {
        throw new HttpsError('not-found', 'Empresa sem assinatura');
      }

      const token = PAGBANK_TOKEN_SECRET.value();
      if (!token) {
        throw new HttpsError('internal', 'Token PagBank não configurado');
      }
      
      const url = `https://api.assinaturas.pagseguro.com/subscriptions/${subscriptionId}`;

      subLogger.info('Consultando assinatura no PagBank', { subscriptionId });

      const response = await axios.get(url, {
        headers: {
          'accept': 'application/json',
          'Authorization': getPagBankAuthorizationHeader(token)
        }
      });

      subLogger.info('Status da assinatura recebido', {
        subscriptionId,
        status: response.data?.status,
      });

      let appStatus = 'INACTIVE';
      let companyActive = false;

      switch (response.data.status) {
        case 'ACTIVE':
          appStatus = 'ACTIVE';
          companyActive = true;
          break;
        case 'PAYMENT_METHOD_CHANGE':
        case 'SUSPENDED':
          appStatus = 'SUSPENDED';
          companyActive = true;
          break;
        case 'CANCELED':
        case 'EXPIRED':
          appStatus = 'CANCELED';
          companyActive = false;
          break;
        case 'TRIAL':
          appStatus = 'TRIAL';
          companyActive = true;
          break;
      }

      await db.collection('companys').doc(companyId).update({
        active: companyActive,
        subscriptionStatus: appStatus,
        'subscription.status': response.data.status,
        'subscription.lastCheckedAt': FieldValue.serverTimestamp(),
        'subscription.nextBillingDate': response.data.next_billing_date || null
      });

      // Não retornar response.data bruto — pode conter dados sensíveis do PagBank
      return {
        success: true,
        status: appStatus,
        active: companyActive,
        nextBillingDate: response.data.next_billing_date || null,
      };

    } catch (error: any) {
      if (error instanceof HttpsError) throw error;

      if (axios.isAxiosError(error)) {
        subLogger.error('Erro Axios ao verificar status da assinatura', {
          httpStatus: error.response?.status,
          errorMessage: error.message,
        });
        if (error.response?.status === 404) {
          throw new HttpsError('not-found', 'Assinatura não encontrada');
        }
        throw new HttpsError('internal', error.response?.data?.message || 'Erro ao verificar status');
      }
      
      subLogger.error('Erro inesperado ao verificar status da assinatura', {
        errorName: (error as Error).name,
        errorMessage: (error as Error).message,
      });
      throw new HttpsError('internal', 'Erro ao verificar status da assinatura');
    }
  }
);

// Cloud Function para criar plano de assinatura no PagBank
export const createPagBankPlan = onCall(
  {
    timeoutSeconds: 60,
    memory: '256MiB',
    secrets: [PAGBANK_TOKEN_SECRET],
  },
  async (request) => {
    const planLogger = logger.child({
      action: 'createPagBankPlan',
      requestId: generateRequestId(),
      uid: request.auth?.uid,
    });
    planLogger.info('Iniciando createPagBankPlan');
    
    try {
      // Verificação de autenticação (opcional - remova se não precisar)
      if (!request.auth) {
        throw new HttpsError('unauthenticated', 'Usuário deve estar autenticado');
      }

      const { 
        name,
        description,
        amount,
        interval,
        trial,
        payment_method,
        editable,
        reference_id
      } = request.data;

      // Validações obrigatórias
      if (!name) {
        throw new HttpsError('invalid-argument', 'Nome do plano é obrigatório');
      }

      if (!amount || !amount.currency || !amount.value) {
        throw new HttpsError('invalid-argument', 'Dados do valor são obrigatórios (currency e value)');
      }

      if (!interval || !interval.unit || !interval.length) {
        throw new HttpsError('invalid-argument', 'Dados do intervalo são obrigatórios (unit e length)');
      }

      // Validar unidade do intervalo
      const validUnits = ['DAY', 'WEEK', 'MONTH', 'YEAR'];
      if (!validUnits.includes(interval.unit)) {
        throw new HttpsError('invalid-argument', `Unidade do intervalo deve ser uma de: ${validUnits.join(', ')}`);
      }

      // Validar valor positivo
      if (amount.value <= 0) {
        throw new HttpsError('invalid-argument', 'Valor deve ser maior que zero');
      }

      // Validar comprimento do intervalo
      if (interval.length <= 0) {
        throw new HttpsError('invalid-argument', 'Comprimento do intervalo deve ser maior que zero');
      }

      const pagBankToken = PAGBANK_TOKEN_SECRET.value();
      if (!pagBankToken) {
        throw new HttpsError('internal', 'Token PagBank não configurado');
      }
      
      const baseUrl = 'https://api.assinaturas.pagseguro.com';

      // Construir payload para o PagBank
      const planData = {
        name: name.trim(),
        description: description || `Plano ${name}`,
        reference_id: reference_id || `PLAN_${Date.now()}`,
        amount: {
          currency: amount.currency.toUpperCase(),
          value: Math.round(amount.value) // Garantir que seja inteiro (centavos)
        },
        interval: {
          unit: interval.unit.toUpperCase(),
          length: parseInt(interval.length)
        },
        trial: trial || {
          enabled: false,
          hold_setup_fee: false,
          days: 0
        },
        payment_method: payment_method || ['CREDIT_CARD'],
        editable: editable !== undefined ? editable : true
      };

      const requestUrl = `${baseUrl}/plans`;
      const requestHeaders = {
        'accept': 'application/json',
        'Authorization': getPagBankAuthorizationHeader(pagBankToken),
        'content-type': 'application/json'
      };

      planLogger.info('Enviando requisição para criar plano no PagBank', {
        endpoint: requestUrl,
        referenceId: planData.reference_id,
        intervalUnit: planData.interval.unit,
        intervalLength: planData.interval.length,
      });

      try {
        const response = await axios.post(
          requestUrl,
          planData,
          {
            headers: requestHeaders,
            timeout: 30000 // 30 segundos de timeout
          }
        );

        planLogger.info('Plano PagBank criado com sucesso', {
          planId: response.data?.id,
          status: response.data?.status,
          referenceId: response.data?.reference_id,
          httpStatus: response.status,
        });

        // FIX: return foi acidentalmente comentado — a função retornava undefined no caminho feliz
        return {
          success: true,
          plan: response.data,
          message: 'Plano criado com sucesso'
        };

      } catch (axiosError: any) {
        if (axiosError.response) {
          planLogger.error('Erro do PagBank ao criar plano', {
            httpStatus: axiosError.response.status,
            httpStatusText: axiosError.response.statusText,
            pagbankError: sanitizePagBankErrorData(axiosError.response.data),
          });
          
          const errorData = axiosError.response.data;
          let errorMessage = 'Erro ao criar plano no PagBank';
          
          if (errorData?.error_messages && Array.isArray(errorData.error_messages)) {
            errorMessage = errorData.error_messages
              .map((err: any) => `${err.code}: ${err.description || err.message}`)
              .join(', ');
          } else if (errorData?.message) {
            errorMessage = errorData.message;
          } else if (errorData?.error) {
            errorMessage = errorData.error;
          }
          
          switch (axiosError.response.status) {
            case 400:
              throw new HttpsError('invalid-argument', `Dados inválidos: ${errorMessage}`);
            case 401:
              throw new HttpsError('unauthenticated', 'Token de autorização inválido');
            case 403:
              throw new HttpsError('permission-denied', 'Acesso negado pelo PagBank');
            case 409:
              throw new HttpsError('already-exists', `Plano já existe: ${errorMessage}`);
            case 422:
              throw new HttpsError('invalid-argument', `Dados não processáveis: ${errorMessage}`);
            default:
              throw new HttpsError('internal', `Erro do PagBank (${axiosError.response.status}): ${errorMessage}`);
          }
        } else if (axiosError.request) {
          planLogger.error('PagBank não respondeu ao criar plano', { errorMessage: axiosError.message });
          throw new HttpsError('internal', 'Sem resposta do servidor PagBank');
        } else {
          planLogger.error('Falha ao montar requisição de criação de plano', { errorMessage: axiosError.message });
          throw new HttpsError('internal', 'Erro ao configurar requisição para PagBank');
        }
      }

    } catch (error: any) {
      if (error instanceof HttpsError) {
        throw error;
      }
      
      planLogger.error('Erro inesperado em createPagBankPlan', {
        errorName: (error as Error).name,
        errorMessage: (error as Error).message,
      });
      throw new HttpsError('internal', error.message || 'Erro interno ao criar plano');
    }
  }
);

/**
 * Cloud Function para enviar notificação de chat via FCM.
 * Substitui o envio direto via chave de service account no cliente.
 * Requer autenticação do usuário.
 */
export const sendChatNotification = onCall(
  {
    timeoutSeconds: 30,
    memory: '128MiB',
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Usuário deve estar autenticado');
    }

    const chatLogger = logger.child({
      action: 'sendChatNotification',
      requestId: generateRequestId(),
      uid: request.auth.uid,
    });

    const { token, title, body, data } = request.data;

    if (!token || typeof token !== 'string' || token.trim() === '') {
      throw new HttpsError('invalid-argument', 'Token FCM inválido');
    }
    if (!title || typeof title !== 'string') {
      throw new HttpsError('invalid-argument', 'Título da notificação inválido');
    }
    if (!body || typeof body !== 'string') {
      throw new HttpsError('invalid-argument', 'Corpo da notificação inválido');
    }

    // Sanitizar data: garantir que todos os valores sejam strings
    const sanitizedData: Record<string, string> = {};
    if (data && typeof data === 'object') {
      for (const [key, value] of Object.entries(data)) {
        sanitizedData[String(key)] = String(value ?? '');
      }
    }

    try {
      await messaging.send({
        token: token.trim(),
        notification: { title, body },
        data: sanitizedData,
      });
      return { success: true };
    } catch (error: any) {
      chatLogger.error('Erro ao enviar notificação de chat FCM', {
        errorName: (error as Error).name,
        errorMessage: (error as Error).message,
      });
      throw new HttpsError('internal', 'Erro ao enviar notificação');
    }
  }
);

export const cancelPagBankSubscription = onCall(
  {
    timeoutSeconds: 30,
    memory: "128MiB",
    secrets: [PAGBANK_TOKEN_SECRET],
  },
  async (request) => {
    const cancelLogger = logger.child({
      action: 'cancelPagBankSubscription',
      requestId: generateRequestId(),
      uid: request.auth?.uid,
    });
    cancelLogger.info('Iniciando cancelamento de assinatura PagBank');

    try {
      const { subscriptionId, companyID } = request.data;
      if (!subscriptionId) {
        throw new HttpsError("invalid-argument", "subscriptionId é obrigatório");
      }
      
      if (!companyID) {
        throw new HttpsError("invalid-argument", "CompanyID é obrigatório");
      }

      const pagBankToken = PAGBANK_TOKEN_SECRET.value();

      if (!pagBankToken) {
        throw new HttpsError(
          "internal",
          "Token PagBank não configurado na variável de ambiente"
        );
      }

      const baseUrl = "https://api.assinaturas.pagseguro.com";
      const url = `${baseUrl}/subscriptions/${subscriptionId}/cancel`;

      const headers = {
        accept: "application/json",
        Authorization: getPagBankAuthorizationHeader(pagBankToken),
      };

      cancelLogger.info('Enviando requisição de cancelamento ao PagBank', { companyID });

      const response = await axios.put(url, {}, { headers });

      cancelLogger.info('Assinatura cancelada com sucesso', {
        companyID,
        httpStatus: response.status,
      });

      await db.collection('companys').doc(companyID).update({
        active: false,
        subscriptionStatus: 'CANCELED',
      });

      return {
        success: true,
        status: response.status,
        message: "Assinatura cancelada com sucesso",
      };
    } catch (error: any) {
      if (error instanceof HttpsError) throw error;

      if (error.response) {
        cancelLogger.error('Erro do PagBank ao cancelar assinatura', {
          httpStatus: error.response.status,
          pagbankError: sanitizePagBankErrorData(error.response.data),
        });
        throw new HttpsError(
          "internal",
          error.response.data?.message ||
            `Erro do PagBank: status ${error.response.status}`
        );
      } else {
        cancelLogger.error('Erro inesperado ao cancelar assinatura', {
          errorMessage: (error as Error).message,
          errorName: (error as Error).name,
        });
        throw new HttpsError(
          "internal",
          error.message || "Erro inesperado ao cancelar assinatura"
        );
      }
    }
  }
);