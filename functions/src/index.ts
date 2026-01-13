// Imports do Firebase Admin SDK (módulos específicos)
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging, AndroidConfig } from "firebase-admin/messaging";

// Imports do Firebase Functions v2
import { onCall, HttpsError, onRequest } from 'firebase-functions/v2/https';
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { setGlobalOptions } from "firebase-functions/v2";



import { logger } from "firebase-functions/v2";
import axios from "axios";
import { count } from "console";




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

  if (!auth) {
    logger.warn('Usuário não autenticado tentando acessar getUserData.');
    return {
      "data": "Nenhum usuário logado",
    };
  }

  const uid = auth.uid;

  try {
    const snapshot = await db.collection("users").doc(uid).get();

    if (!snapshot.exists) {
      logger.warn(`Usuário com UID ${uid} não encontrado.`);
      return { "data": null };
    }

    logger.log(`Dados do usuário ${uid}:`, snapshot.data());

    return {
      "data": snapshot.data(),
    };
  } catch (error: any) {
    logger.error(`Erro ao buscar dados do usuário ${uid}:`, error);
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
  const { data } = request;
  logger.log('Dados recebidos em addMessage:', data);
  try {
    const snapshot = await db.collection("messages").add(data);
    logger.log('Mensagem adicionada com sucesso com ID:', snapshot.id);
    return { "success": snapshot.id };
  } catch (error: any) {
    logger.error('Erro ao adicionar mensagem:', error);
    throw new Error('Falha ao adicionar mensagem.');
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
  },
  async (request) => {
    logger.info('Iniciando createPagBankSubscription', { data: request.data });
    
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
        logger.error('Dados incompletos recebidos:', request.data);
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

      // IMPORTANTE: Use seu token real aqui
      const pagBankToken = 'eeefc8b5-e621-4d7a-81f0-7c700ccda1fa04a4bb7e4d1cbcc67e0414ee19f32c9675f1-7515-492b-9309-7fac3a1740ed';
      const isSandbox = false;

      const baseUrl = 'https://api.assinaturas.pagseguro.com';

      try {
        // Criar a assinatura com o cartão já criptografado
        logger.info('========== PREPARANDO REQUISIÇÃO DE ASSINATURA ==========');
        
        let subscriptionData: any;
        
        if (companyData.customer_id === null || companyData.customer_id === undefined || companyData.customer_id === '') {
          logger.info('customer_id não encontrado nos dados da empresa. Criando novo cliente PagBank.');
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
          logger.info('customer_id encontrado nos dados da empresa. Usando cliente PagBank existente.');
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

        // === GERAÇÃO DO LOG PARA HOMOLOGAÇÃO COM DADOS COMPLETOS ===
        const requestHeaders = {
          'accept': 'application/json',
          'Authorization': pagBankToken,
          'content-type': 'application/json'
        };

        // === LOG ESTRUTURADO PARA HOMOLOGAÇÃO ===
        logger.info('=== REQUISIÇÃO HTTP PARA PAGBANK - DADOS PARA HOMOLOGAÇÃO ===', {
          timestamp: new Date().toISOString(),
          environment: isSandbox ? 'SANDBOX' : 'PRODUCTION',
          endpoint: {
            url: requestUrl,
            method: 'POST'
          },
          headers: requestHeaders,
          payload: subscriptionData,
          metadata: {
            company_id: companyId,
            plan_id: 'PLAN_633F2BAF-4FE1-4EE7-A1EE-C317E782F086',
            has_existing_customer: !!(companyData.customer_id),
            reference_id: subscriptionData.reference_id
          }
        });

        // === LOG ADICIONAL EM FORMATO CURL PARA FACILITAR TESTES ===
        const curlCommand = `curl -X POST "${requestUrl}" \
  -H "accept: application/json" \
  -H "Authorization: ${pagBankToken}" \
  -H "content-type: application/json" \
  -d '${JSON.stringify(subscriptionData, null, 2)}'`;
        
        logger.info('=== COMANDO CURL EQUIVALENTE ===', {
          curl_command: curlCommand
        });
        // === FIM DA GERAÇÃO DO LOG ===

        logger.info('Enviando requisição para PagBank...');

        const subscriptionResponse = await axios.post(
          requestUrl,
          subscriptionData,
          {
            headers: requestHeaders
          }
        );

        logger.info('========== RESPOSTA DA ASSINATURA ==========');
        logger.info('Status:', subscriptionResponse.status);
        logger.info('Data:', JSON.stringify(subscriptionResponse.data, null, 2));

        // Atualizar empresa com dados da assinatura
        await db.collection('companys').doc(companyId).update({
          subscriptionId: subscriptionResponse.data.id,
          subscriptionStatus: subscriptionResponse.data.status,
          subscriptionPlan: 'PLAN_633F2BAF-4FE1-4EE7-A1EE-C317E782F086',
          customer_id: subscriptionResponse.data.customer.id,
        });

        logger.info('========== ASSINATURA CRIADA COM SUCESSO ==========');

        return { 
          success: true, 
          subscriptionId: subscriptionResponse.data.id,
          status: subscriptionResponse.data.status
        };

      } catch (axiosError: any) {
        logger.error('========== ERRO NA REQUISIÇÃO AXIOS ==========');
        logger.error('Mensagem:', axiosError.message);
        
        if (axiosError.response) {
          logger.error('Status:', axiosError.response.status);
          logger.error('Status Text:', axiosError.response.statusText);
          logger.error('Headers:', JSON.stringify(axiosError.response.headers, null, 2));
          logger.error('Data:', JSON.stringify(axiosError.response.data, null, 2));
          
          // Tratamento específico de erros do PagBank
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
          logger.error('Nenhuma resposta recebida');
          throw new HttpsError('internal', 'Sem resposta do servidor PagBank');
        } else {
          logger.error('Erro ao configurar requisição:', axiosError.message);
          throw new HttpsError('internal', 'Erro ao configurar requisição');
        }
      }

    } catch (error: any) {
      if (error instanceof HttpsError) {
        logger.error('HttpsError:', error.message);
        throw error;
      }
      
      logger.error('========== ERRO GERAL ==========');
      logger.error('Tipo:', typeof error);
      logger.error('Nome:', error.name);
      logger.error('Mensagem:', error.message);
      logger.error('Stack:', error.stack);
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
  },
  async (request) => {
    logger.info('Obtendo chave pública do PagBank');
    
    try {
      // IMPORTANTE: Use seu token real aqui
      const pagBankToken =  'Bearer eeefc8b5-e621-4d7a-81f0-7c700ccda1fa04a4bb7e4d1cbcc67e0414ee19f32c9675f1-7515-492b-9309-7fac3a1740ed';
      const isSandbox = false;

      const baseUrl = 'https://api.assinaturas.pagseguro.com';

      const response = await axios.get(
        `${baseUrl}/public-keys`,
        {
          headers: {
            'accept': 'application/json',
            'Authorization': pagBankToken,
            'Content-Type': 'application/json'
          }
        }
      );

      logger.info('Chave pública obtida com sucesso');
      
      return {
        success: true,
        publicKey: response.data.public_key,
        createdAt: response.data.created_at
      };

    } catch (error: any) {
      logger.error('Erro ao obter chave pública:', error);
      
      if (error.response) {
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
    logger.log(`Tokens do usuário ${uid}:`, tokens);
    return tokens;
  } catch (error: any) {
    logger.error(`Erro ao obter tokens do usuário ${uid}:`, error);
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
      logger.log('Notificações enviadas com sucesso:', response);
      return response;
    } catch (error: any) {
      logger.error('Erro ao enviar notificações:', error);
      return error;
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
  logger.log(userstokens);
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

    logger.log(message);
    try {
      const response = await messaging.sendEachForMulticast(message);
      logger.log('Notificações com imagem enviadas com sucesso:', response);
      return response;
    } catch (error: any) {
      logger.error('Erro ao enviar notificações com imagem:', error);
      return error;
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
  },
  async (request, response) => {
    logger.info('=== WEBHOOK PAGBANK RECEBIDO ===');
    logger.info('Method:', request.method);
    logger.info('Headers:', JSON.stringify(request.headers));
    logger.info('Body:', JSON.stringify(request.body));

    try {
      // Verificar se é POST
      if (request.method !== 'POST') {
        response.status(405).send('Method Not Allowed');
        return;
      }

      // Validar a origem (opcional mas recomendado)
      const token = request.headers['x-webhook-token'];
      if (token !== 'bae6222d6e2ee8be860f727c16f86df0efdaf2d5d07f2411031c5b51a3e65790') {
        response.status(401).send('Unauthorized');
        return;
      }

      const { id, reference_id, status, charges } = request.body;

      if (!id || !status) {
        logger.error('Webhook sem ID ou status');
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
        logger.error('Empresa não encontrada para subscription:', id);
        response.status(404).send('Company not found');
        return;
      }

      const companyDoc = companiesQuery.docs[0];
      const companyId = companyDoc.id;

      logger.info('Empresa encontrada:', companyId);
      logger.info('Atualizando status para:', appStatus);

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

      logger.info('Webhook processado com sucesso');
      response.status(200).send('OK');

    } catch (error: any) {
      logger.error('Erro ao processar webhook:', error);
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
  },
  async (request) => {
    logger.info('=== VERIFICANDO STATUS DA ASSINATURA ===');
    
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

      // Token do PagBank
      const token = 'eeefc8b5-e621-4d7a-81f0-7c700ccda1fa04a4bb7e4d1cbcc67e0414ee19f32c9675f1-7515-492b-9309-7fac3a1740ed';
      
      // URL da API
      const url = `https://api.assinaturas.pagseguro.com/subscriptions/${subscriptionId}`;

      logger.info('Consultando assinatura:', subscriptionId);

      
      // Fazer a requisição
      const response = await axios.get(url, {
        headers: {
          'accept': 'application/json',
          'Authorization': 'eeefc8b5-e621-4d7a-81f0-7c700ccda1fa04a4bb7e4d1cbcc67e0414ee19f32c9675f1-7515-492b-9309-7fac3a1740ed'
        }
      });
      

      logger.info('Resposta do PagBank:', JSON.stringify(response.data));

      // Mapear status
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

      // Atualizar no Firestore
      await db.collection('companys').doc(companyId).update({
        active: companyActive,
        subscriptionStatus: appStatus,
        'subscription.status': response.data.status,
        'subscription.lastCheckedAt': FieldValue.serverTimestamp(),
        'subscription.nextBillingDate': response.data.next_billing_date || null
      });

      return {
        success: true,
        status: appStatus,
        active: companyActive,
        details: response.data
      };

    } catch (error: any) {
      logger.error('Erro ao verificar status:', error);
      
      if (axios.isAxiosError(error)) {
        if (error.response?.status === 404) {
          throw new HttpsError('not-found', 'Assinatura não encontrada');
        }
        throw new HttpsError('internal', error.response?.data?.message || 'Erro ao verificar status');
      }
      
      throw new HttpsError('internal', 'Erro ao verificar status da assinatura');
    }
  }
);

// Cloud Function para criar plano de assinatura no PagBank
export const createPagBankPlan = onCall(
  {
    timeoutSeconds: 60,
    memory: '256MiB',
  },
  async (request) => {
    logger.info('Iniciando createPagBankPlan', { data: request.data });
    
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

      // Token do PagBank - IMPORTANTE: Configure como variável de ambiente
      const pagBankToken = 'eeefc8b5-e621-4d7a-81f0-7c700ccda1fa04a4bb7e4d1cbcc67e0414ee19f32c9675f1-7515-492b-9309-7fac3a1740ed';
      
      const isSandbox =  false;
      
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
        'Authorization': pagBankToken,
        'content-type': 'application/json'
      };

      // === LOG PARA HOMOLOGAÇÃO ===
      logger.info('=== CRIAÇÃO DE PLANO PAGBANK - DADOS PARA HOMOLOGAÇÃO ===', {
        timestamp: new Date().toISOString(),
        environment: 'PRODUCTION',
        endpoint: {
          url: requestUrl,
          method: 'POST'
        },
        headers: requestHeaders,
        payload: planData
      });

      // === COMANDO CURL PARA TESTES ===
      const curlCommand = `curl -X POST "${requestUrl}" \
  -H "accept: application/json" \
  -H "Authorization: ${pagBankToken}" \
  -H "content-type: application/json" \
  -d '${JSON.stringify(planData, null, 2)}'`;
      
      logger.info('=== COMANDO CURL EQUIVALENTE ===', {
        curl_command: curlCommand
      });

      logger.info('Enviando requisição para criar plano no PagBank...');

      try {
        const response = await axios.post(
          requestUrl,
          planData,
          {
            headers: requestHeaders,
            timeout: 30000 // 30 segundos de timeout
          }
        );

        logger.info('========== PLANO CRIADO COM SUCESSO ==========');
        logger.info('Status:', response.status);
        logger.info('Plano criado:', JSON.stringify(response.data, null, 2));

        // // Opcional: Salvar o plano no Firestore para controle interno
        // if (response.data.id) {
        //   try {
        //     await db.collection('pagbank_plans').doc(response.data.id).set({
        //       ...response.data,
        //       created_at: FieldValue.serverTimestamp(),
        //       created_by: request.auth?.uid || 'system',
        //       environment: isSandbox ? 'sandbox' : 'production'
        //     });
        //     logger.info('Plano salvo no Firestore:', response.data.id);
        //   } catch (firestoreError) {
        //     logger.warn('Erro ao salvar plano no Firestore:', firestoreError);
        //     // Não falhar a operação por causa disso
        //   }
        // }

        // return {
        //   success: true,
        //   plan: response.data,
        //   message: 'Plano criado com sucesso'
        // };

      } catch (axiosError: any) {
        logger.error('========== ERRO NA CRIAÇÃO DO PLANO ==========');
        logger.error('Mensagem:', axiosError.message);
        
        if (axiosError.response) {
          logger.error('Status:', axiosError.response.status);
          logger.error('Status Text:', axiosError.response.statusText);
          logger.error('Headers:', JSON.stringify(axiosError.response.headers, null, 2));
          logger.error('Data:', JSON.stringify(axiosError.response.data, null, 2));
          
          // Tratamento específico de erros do PagBank
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
          
          // Mapear códigos de erro específicos
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
          logger.error('Nenhuma resposta recebida do PagBank');
          throw new HttpsError('internal', 'Sem resposta do servidor PagBank');
        } else {
          logger.error('Erro ao configurar requisição:', axiosError.message);
          throw new HttpsError('internal', 'Erro ao configurar requisição para PagBank');
        }
      }

    } catch (error: any) {
      if (error instanceof HttpsError) {
        logger.error('HttpsError:', error.message);
        throw error;
      }
      
      logger.error('========== ERRO GERAL ==========');
      logger.error('Tipo:', typeof error);
      logger.error('Nome:', error.name);
      logger.error('Mensagem:', error.message);
      logger.error('Stack:', error.stack);
      throw new HttpsError('internal', error.message || 'Erro interno ao criar plano');
    }
  }
);

export const cancelPagBankSubscription = onCall(
  {
    timeoutSeconds: 30,
    memory: "128MiB",
  },
  async (request) => {
    logger.info("Iniciando cancelPagBankSubscription", { data: request.data });

    try {
      // Recebe o ID da assinatura via parâmetro
      const { subscriptionId, companyID } = request.data;
      if (!subscriptionId) {
        throw new HttpsError("invalid-argument", "subscriptionId é obrigatório");
      }
      // Recebe o CompanyID da assinatura via parâmetro
      
      if (!companyID) {
        throw new HttpsError("invalid-argument", "CompanyID é obrigatório");
      }

      // Pegue o token da configuração de ambiente do Firebase Functions
      const PAGBANK_TOKEN = 'eeefc8b5-e621-4d7a-81f0-7c700ccda1fa04a4bb7e4d1cbcc67e0414ee19f32c9675f1-7515-492b-9309-7fac3a1740ed';

      if (!PAGBANK_TOKEN) {
        throw new HttpsError(
          "internal",
          "Token PagBank não configurado na variável de ambiente"
        );
      }

      // Monta URL da requisição (sandbox ou produção)
      const baseUrl = "https://api.assinaturas.pagseguro.com";
      const url = `${baseUrl}/subscriptions/${subscriptionId}/cancel`;

      const headers = {
        accept: "application/json",
        Authorization: `Bearer ${PAGBANK_TOKEN}`,
      };

      logger.info("Enviando requisição para cancelamento", {
        url,
        headers,
      });

      // Executa requisição PUT para cancelar assinatura
      const response = await axios.put(url, {}, { headers });

      logger.info("Assinatura cancelada com sucesso!", {
        status: response.status,
        data: response.data,
      });

      // Atualizar no Firestore
      await db.collection('companys').doc(companyID).update({
        active: false,
        subscriptionStatus: 'CANCELED',
        
      });

     

      return {
        success: true,
        status: response.status,
        data: response.data,
        message: "Assinatura cancelada com sucesso",
      };
    } catch (error: any) {
      logger.error("Erro ao cancelar assinatura", {
        erro: error.message,
        ...(error.response && {
          status: error.response.status,
          data: error.response.data,
        }),
      });

      if (error instanceof HttpsError) throw error;

      if (error.response) {
        // Resposta do PagBank com erro
        throw new HttpsError(
          "internal",
          error.response.data?.message ||
            `Erro do PagBank: status ${error.response.status}`,
          error.response.data
        );
      } else {
        // Erro inesperado ou de rede
        throw new HttpsError(
          "internal",
          error.message || "Erro inesperado ao cancelar assinatura"
        );
      }
    }
  }
);