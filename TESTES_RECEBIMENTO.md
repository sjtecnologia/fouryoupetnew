# Documento de testes — Recebimento PagBank

Este roteiro cobre o checkout transacional PagBank, o webhook e os efeitos
colaterais no Firestore. Executar primeiro no Firebase Emulator Suite e depois
em homologação com credenciais sandbox, produtos e usuários de teste.

## Preparação

- [ ] Configurar `PAGBANK_TOKEN` e `PAGBANK_WEBHOOK_TOKEN` no ambiente de
      Functions.
- [ ] Confirmar que o app aponta para o projeto/emuladores corretos.
- [ ] Criar usuário autenticado com nome, e-mail, CPF e telefone válidos.
- [ ] Criar produto com estoque conhecido e adicionar ao carrinho.
- [ ] Confirmar endereço e área de entrega coberta.
- [ ] Conferir no Firestore as coleções `orders`, `products`, `users`,
      `admins`, `notifications` e `points_transactions`.
- [ ] Registrar antes de cada teste: estoque inicial, valor do pedido, cupom,
      saldo/pontos do usuário e identificador do produto.

Nos documentos `orders`, conferir especialmente:

| Campo | Valores esperados |
|---|---|
| `paymentId` / `payId` | ID retornado pelo PagBank |
| `paymentMethod` | `CREDIT_CARD` ou `PIX` |
| `paymentStatus` | `paid`, `pending` ou `failed` |
| `status` | `0` para aprovação; `4` para cancelado |

## 1. Cartão aprovado

| Item | Procedimento |
|---|---|
| Pré-condição | Usuário autenticado; cartão sandbox aprovado; produto disponível; cupom válido aplicado; programa de fidelidade habilitado; administrador com token FCM registrado. |
| Passos | 1. Abrir checkout e selecionar **Cartão de crédito**.<br>2. Informar dados de teste e concluir a criptografia do cartão.<br>3. Confirmar o pedido.<br>4. Aguardar a resposta do `createPaymentOrder`.<br>5. Consultar `orders`, `products`, `notifications` e `points_transactions`. |
| Resultado esperado | O pagamento retorna sucesso; o pedido é criado com `paymentStatus=paid`, `paymentMethod=CREDIT_CARD`, `paymentId/payId` preenchido e `status=0`. O estoque é reduzido; o pedido aparece para o admin; uma notificação push é enviada; o cupom é marcado como usado; os pontos e eventual indicação são creditados. |
| Pós-condição Firestore | Existe exatamente um pedido correspondente ao checkout. O estoque é o inicial menos a quantidade comprada. O cupom está consumido uma vez. Há transação de pontos `earned` vinculada ao `orderId`. O admin recebeu/criou a notificação correspondente. |

## 2. Cartão recusado

| Item | Procedimento |
|---|---|
| Pré-condição | Usuário autenticado; cartão sandbox configurado para recusa; produto com estoque conhecido; nenhum pedido prévio para o teste. |
| Passos | 1. Selecionar cartão de crédito.<br>2. Informar o cartão recusado.<br>3. Confirmar o checkout.<br>4. Verificar a mensagem exibida e consultar o Firestore. |
| Resultado esperado | O cliente vê uma mensagem amigável informando que o pagamento não foi aprovado. O checkout não cria pedido e não baixa estoque. Cupom, pontos, indicação e notificação de venda não são processados. |
| Pós-condição Firestore | Não existe novo documento em `orders` para essa tentativa. O estoque, o cupom e os pontos permanecem inalterados. |

## 3. PIX — criação e retorno do webhook

### 3.1 PIX criado e pago

| Item | Procedimento |
|---|---|
| Pré-condição | Usuário autenticado; produto disponível; área de entrega válida; token do webhook configurado; admin com FCM. |
| Passos | 1. Selecionar **PIX** e confirmar o checkout.<br>2. Validar a tela de confirmação.<br>3. Conferir o pedido no Firestore.<br>4. Simular o webhook `PAID` usando o mesmo `paymentId`/`id` do pedido.<br>5. Aguardar o listener em tempo real e atualizar a tela, se necessário. |
| Resultado esperado | QR Code e copia-e-cola ficam disponíveis. O pedido é criado antes do pagamento com `paymentMethod=PIX`, `paymentStatus=pending`, `paymentId/payId` preenchido e `status=0`. O estoque não é baixado enquanto pendente. O webhook `PAID` atualiza `paymentStatus=paid`, registra `paidAt`, dispara a notificação ao admin e o app detecta a confirmação. |
| Pós-condição Firestore | Pedido único com `paymentStatus=paid`; estoque, cupom e fidelidade são processados uma vez após a confirmação. O QR Code/copia-e-cola permanecem apenas como dados do pedido, se aplicável. |

Payload mínimo para simulação:

```json
{
  "id": "<PAYMENT_ID_DO_PEDIDO>",
  "status": "PAID",
  "charges": [{
    "id": "<PAYMENT_ID_DO_PEDIDO>",
    "status": "PAID"
  }]
}
```

### 3.2 PIX recusado/cancelado

| Item | Procedimento |
|---|---|
| Pré-condição | Pedido PIX existente com `paymentStatus=pending`; anotar `paymentId`. |
| Passos | 1. Enviar webhook autenticado com status `DECLINED`.<br>2. Repetir com `CANCELED` em outro pedido pending, se disponível.<br>3. Consultar o pedido e a tela de confirmação. |
| Resultado esperado | O pedido é atualizado para `paymentStatus=failed`. Não há baixa de estoque, uso de cupom, crédito de pontos ou notificação de venda aprovada. |
| Pós-condição Firestore | O pedido permanece rastreável com o mesmo `paymentId`, status de pagamento `failed` e estoque/cupom/fidelidade inalterados. |

## 4. Timeout ou falha de rede

| Item | Procedimento |
|---|---|
| Pré-condição | Produto disponível; interromper a rede do app durante ou logo após a chamada de pagamento; manter acesso administrativo ao Firestore. |
| Passos | 1. Iniciar checkout.<br>2. Interromper a rede em momentos diferentes: antes da resposta do PagBank, após o pagamento ser criado e durante a gravação do pedido.<br>3. Verificar a mensagem do app e procurar pedidos por `paymentId`.<br>4. Chamar `checkPaymentStatus` com o ID retornado/conhecido.<br>5. Reconciliar o estado conforme o status oficial retornado pelo PagBank. |
| Resultado esperado | O app não assume pagamento aprovado apenas por timeout. Se não houver `paymentId`, não deve haver pedido nem baixa de estoque. Se houver pagamento criado e gravação incompleta, o status é consultado por `checkPaymentStatus`; um status `PAID` deve permitir reconciliação do pedido, e `DECLINED/CANCELED` deve resultar em `failed`. |
| Pós-condição Firestore | Não existem pedidos duplicados para a mesma tentativa. Todo pagamento confirmado possui pedido identificável por `paymentId`, ou fica registrado para correção operacional. Estoque, cupom e pontos são aplicados no máximo uma vez. |

## 5. Cancelamento de pedido pago

| Item | Procedimento |
|---|---|
| Pré-condição | Pedido com `paymentStatus=paid`, `status=0`, estoque já baixado e pontos de fidelidade creditados. |
| Passos | 1. Abrir o pedido pago.<br>2. Solicitar cancelamento.<br>3. Confirmar a operação.<br>4. Consultar `orders`, `products` e `points_transactions`. |
| Resultado esperado | O pedido passa para `status=4` (`canceled`), o estoque é restaurado na quantidade original e os pontos ganhos pelo pedido são removidos. |
| Pós-condição Firestore | O pedido permanece no Firestore, com `paymentStatus=paid` e status cancelado. O estoque volta ao valor anterior à compra. A transação de pontos de reversão existe e não há pontos líquidos referentes ao pedido. |

## 6. Concorrência de estoque

| Item | Procedimento |
|---|---|
| Pré-condição | Produto com exatamente 1 unidade disponível; dois usuários autenticados, carrinhos independentes e endereços válidos. |
| Passos | 1. Iniciar os dois checkouts quase simultaneamente.<br>2. Confirmar ambos os pagamentos/testes.<br>3. Consultar os pedidos e o produto. |
| Resultado esperado | Apenas uma transação de decremento é concluída. Um checkout cria pedido aprovado; o outro falha por estoque insuficiente e informa erro ao cliente. O estoque nunca fica negativo. |
| Pós-condição Firestore | Há no máximo um pedido aprovado para a unidade. `products/{id}.sizes` registra estoque `0`; não há dupla baixa nem divergência entre quantidade vendida e estoque. |

## 7. Segurança e autenticação

### 7.1 Webhook com token inválido

| Item | Procedimento |
|---|---|
| Pré-condição | Endpoint `pagBankWebhook` ou `pagBankPaymentWebhook` disponível; conhecer apenas um token incorreto. |
| Passos | 1. Enviar `POST` com payload válido e `x-webhook-token: token-incorreto`.<br>2. Repetir sem o header.<br>3. Consultar logs e Firestore. |
| Resultado esperado | A resposta é `401 Unauthorized`. Nenhum pedido é alterado, nenhuma notificação é enviada e nenhum dado sensível aparece nos logs. |
| Pós-condição Firestore | Estado dos pedidos, estoque, cupons e pontos permanece inalterado. |

### 7.2 `createPaymentOrder` sem autenticação

| Item | Procedimento |
|---|---|
| Pré-condição | Cliente sem Firebase Auth válido; payload de pagamento preenchido. |
| Passos | 1. Chamar a função callable `createPaymentOrder` sem contexto de autenticação.<br>2. Repetir com token expirado/inválido. |
| Resultado esperado | A função responde erro `unauthenticated` e não chama o PagBank nem cria pedido. |
| Pós-condição Firestore | Nenhum novo `orders`, baixa de estoque, uso de cupom, pontuação ou notificação. |

## Evidências mínimas

- [ ] Screenshot/JSON da resposta do callable ou webhook.
- [ ] ID do pedido e `paymentId`/`payId`.
- [ ] Antes/depois do estoque.
- [ ] Estado do cupom e transações de pontos.
- [ ] Registro da notificação enviada ao admin.
- [ ] Timestamp e status final do pagamento.
- [ ] Logs sem token, CPF, cartão ou dados completos do cliente.
