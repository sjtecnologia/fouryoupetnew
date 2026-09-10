# Mercado Pago Marketplace — implantação segura

Este módulo substitui o checkout que gravava pedido, baixava estoque, consumia
cupom e concedia pontos diretamente no Flutter. O aplicativo agora envia apenas
IDs e quantidades; preço, frete, desconto, comissão, estoque e situação do
pagamento são calculados ou validados nas Cloud Functions.

## Decisões financeiras

- Um checkout contém itens de apenas um petshop (Split 1:1).
- O petshop conecta sua própria conta Mercado Pago por OAuth.
- A comissão do mês corrente é congelada a partir do volume líquido elegível do
  mês anterior, no fuso `America/Sao_Paulo`.
- A base elegível inclui produtos/serviços pagos após descontos e exclui frete,
  cancelamentos, estornos e chargebacks.
- Um petshop sem histórico começa em 5%.
- Todos os valores financeiros persistidos pela nova integração usam centavos
  inteiros; as alíquotas usam pontos-base.

As faixas em `commission.ts` reproduzem a tabela do contrato de 2024, de 5% até
0,4%. A mudança de cobrança mensal para retenção automática por Split exige
aditivo contratual e revisão jurídica/LGPD antes da produção.

## Fluxo

1. O administrador conecta o petshop com `beginMercadoPagoConnection`.
2. O callback troca o código OAuth e guarda os tokens criptografados em
   `companys/{companyId}/private_integrations/mercado_pago`.
3. O tutor chama `createMarketplaceCheckout` com IDs, variações e quantidades.
4. Uma transação Firestore recalcula tudo, reserva o estoque por 30 minutos e
   cria o pedido pendente.
5. A preferência Checkout Pro é criada com o token OAuth do vendedor e a
   `marketplace_fee` da 4YouPet.
6. O webhook assinado consulta o pagamento novamente na API do Mercado Pago.
7. Somente a aprovação confirmada pelo servidor contabiliza comissão, consome o
   cupom e concede pontos. Estornos e chargebacks revertem os valores de forma
   idempotente.

## Parâmetros e segredos

Configure os segredos sem colocá-los no Git:

```bash
firebase functions:secrets:set MERCADO_PAGO_CLIENT_SECRET
firebase functions:secrets:set MERCADO_PAGO_OAUTH_STATE_SECRET
firebase functions:secrets:set MERCADO_PAGO_TOKEN_ENCRYPTION_KEY
firebase functions:secrets:set MERCADO_PAGO_WEBHOOK_SECRET
```

`MERCADO_PAGO_TOKEN_ENCRYPTION_KEY` deve ser uma chave aleatória de 32 bytes em
base64. Exemplo de geração local: `openssl rand -base64 32`.

Defina os parâmetros não secretos durante o deploy (o Firebase CLI pode
gravá-los em `.env.<project-id>`, arquivo que não deve ser commitado):

```dotenv
MERCADO_PAGO_CLIENT_ID=...
MERCADO_PAGO_REDIRECT_URI=https://southamerica-east1-PROJECT_ID.cloudfunctions.net/mercadoPagoOAuthCallback
MERCADO_PAGO_WEBHOOK_URL=https://southamerica-east1-PROJECT_ID.cloudfunctions.net/mercadoPagoPaymentWebhook
MERCADO_PAGO_APP_RETURN_URL=https://www.4youpet.app/pagamento
MERCADO_PAGO_ENVIRONMENT=sandbox
MERCADO_PAGO_ENFORCE_APP_CHECK=false
```

Cadastre exatamente a mesma redirect URI no painel do Mercado Pago. Em produção,
altere `MERCADO_PAGO_ENVIRONMENT=production`. Ative App Check no Android, iOS e
Web, valide as métricas e só então mude
`MERCADO_PAGO_ENFORCE_APP_CHECK=true`.

## Regras Firestore obrigatórias

Não existe um arquivo de regras versionado neste repositório. Antes do deploy,
mescle as proteções de `docs/firestore-marketplace.rules.snippet` nas regras que
já estão publicadas e teste no Emulator Suite. Em especial, nenhum cliente pode
ler tokens, criar pedidos, alterar campos financeiros, confirmar pagamentos,
consumir cupons ou conceder pontos.

## Checklist antes da produção

- Criar a aplicação Marketplace no Mercado Pago e concluir o KYC da 4YouPet.
- Exigir KYC da conta de cada petshop durante o onboarding OAuth.
- Rotacionar todas as credenciais antigas encontradas no histórico do projeto.
- Configurar App Check, Crashlytics e alertas de erro/latência das Functions.
- Testar aprovado, pendente, rejeitado, checkout abandonado, webhook repetido,
  webhook fora de ordem, estorno total e chargeback.
- Fazer reconciliação diária entre pagamentos Mercado Pago, pedidos e
  `commission_periods`.
- Rodar piloto com 3–5 petshops e dinheiro real de baixo valor antes de abrir a
  campanha pública.

## Deploy sugerido

O primeiro deploy deve permanecer em sandbox. Depois do build e dos testes:

```bash
cd functions
npm ci
npm test
firebase deploy --only functions:beginMercadoPagoConnection,functions:mercadoPagoOAuthCallback,functions:createMarketplaceCheckout,functions:mercadoPagoPaymentWebhook,functions:refundMarketplaceOrder,functions:releaseExpiredMarketplaceReservations,functions:notifyApprovedMarketplaceOrder
```

Não faça deploy da integração enquanto as regras, os segredos, o OAuth e a URL
do webhook não estiverem configurados no mesmo projeto Firebase.
