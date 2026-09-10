# Auditoria dos sites 4YouPet

Análise feita em 2 de setembro de 2026 sobre as páginas públicas
`4youpet.com.br` e `www.4youpet.app`.

## Diagnóstico executivo

Os sites já separam parcialmente os públicos: `.com.br` fala com petshops e
`.app` fala com tutores. O problema é que cada página promete muitas coisas sem
mostrar produto, prova, segurança ou próximo passo confiável. A aquisição perde
força justamente no CTA.

O erro mais urgente está em **“ASSINE JÁ!”** no `.com.br`: o link adiciona um
produto WooCommerce e leva ao carrinho, mas o destino observado exibiu “Seu
carrinho está vazio”. Isso interrompe a conversão e reduz confiança. Até o fluxo
de assinatura estar validado, trocar por “Agendar demonstração” ou “Quero ser
petshop parceiro”, levando a um formulário curto/WhatsApp identificado.

## 4youpet.com.br — petshops

### O que funciona

- Público e intenção comercial reconhecíveis.
- Benefícios fáceis de entender: pedidos, agendamentos, disponibilidade e
  visibilidade.
- CTA aparece mais de uma vez.

### O que prejudica a conversão

- Promessas genéricas como “mais clientes” e “aumento no faturamento” não têm
  números, casos, telas ou depoimentos que as sustentem.
- Blocos “+ Vantagens” aparecem repetidos e consomem espaço sem acrescentar
  informação.
- Não há explicação visual de como cadastro, catálogo, pedido, pagamento e
  repasse funcionam.
- Comissão, integração de pagamento, prazo de ativação e suporte não aparecem
  com clareza.
- O CTA de assinatura cai em um carrinho que apareceu vazio no teste.
- O rodapé da landing mostra 2024, enquanto a página de carrinho mostra 2026 e
  texto padrão do tema WordPress; isso transmite falta de manutenção.
- Links residuais com `{title}` e rótulos em inglês como “Cart” também foram
  encontrados no fluxo.

### Nova estrutura recomendada

1. Hero: “Venda e receba pedidos do seu bairro em um só canal”.
2. CTA primário: “Agendar demonstração de 15 minutos”.
3. Vídeo/telas: pedido, agenda e painel de resultados.
4. Como funciona em quatro passos.
5. Segurança do pagamento e conexão Mercado Pago.
6. Faixas de comissão explicadas de forma simples, com link para termos.
7. Caso real/depoimento verificável.
8. FAQ: prazo, catálogo, entrega, recebimento, suporte e cancelamento.
9. Formulário com nome, cidade, WhatsApp e tipo de operação — nada além do
   necessário para o primeiro contato.

## www.4youpet.app — tutores

### O que funciona

- Frases curtas e memoráveis: “Acessou, pediu, chegou”, “Agendou, reservou” e
  “Registrou, lembrou”.
- Proposta de reunir compra, serviços, carteira de vacinação e prontuário.
- Geolocalização é um benefício concreto para descoberta local.

### O que prejudica a conversão

- “Aplicativo completo” abre muitas frentes, mas não deixa claro qual problema o
  usuário resolve primeiro.
- Não foram encontrados, no conteúdo rastreável, botões claros de App Store e
  Google Play, QR code, preço, cidades atendidas ou prova de lojas disponíveis.
- O link “4YouPet Web” aponta para `app.4youpet.app`; o destino deve ser monitorado
  e ter fallback, porque não pôde ser validado pelo rastreador nesta análise.
- Não há elementos de confiança para a compra: pagamento, política de
  cancelamento, avaliações e identidade do petshop.
- O rodapé ainda exibe copyright 2022, diferente dos outros domínios.
- A página não captura cidade/lista de espera quando o marketplace ainda não tem
  oferta na região.

### Nova estrutura recomendada

1. Hero: “Compre no petshop perto de você e acompanhe tudo pelo app”.
2. CTA por plataforma + “Usar no navegador”.
3. Campo de cidade/CEP para confirmar cobertura antes do cadastro.
4. Petshops reais da região e avaliações verificadas.
5. Fluxo visual: escolher loja, pagar com Mercado Pago, acompanhar pedido.
6. Benefícios de recorrência: recomprar, pontos e lembretes consentidos.
7. Recursos clínicos como benefício secundário, sem competir com o CTA de compra.
8. FAQ e suporte visível.

## Papel de cada domínio

| Domínio | Público | Conversão primária |
|---|---|---|
| `4youpet.com.br` | Donos e gestores de petshops | Demonstração/onboarding de parceiro |
| `4youpet.app` | Tutores | Abrir/instalar o app e fazer primeira compra |

Os dois domínios devem compartilhar identidade, prova e explicação de segurança,
mas não o mesmo CTA. Cada um deve ter um link discreto para o outro público:
“Sou tutor” e “Tenho um petshop”.

## Correções em 72 horas

1. Substituir ou corrigir o CTA quebrado “ASSINE JÁ!”.
2. Atualizar rodapés e remover textos padrão, `{title}` e rótulos em inglês.
3. Colocar WhatsApp/formulário rastreável no site de parceiros.
4. Colocar links reais de instalação/web e cidade atendida no site de tutores.
5. Instalar eventos de analytics para CTA, formulário, WhatsApp, loja e cadastro.
6. Incluir aviso de “pagamento processado pelo Mercado Pago” apenas quando a
   integração estiver homologada.

