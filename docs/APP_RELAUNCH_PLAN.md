# Plano de relançamento 4YouPet

## Posicionamento

**Para petshops:** venda, agenda e relacionamento com clientes locais em um só
canal, com pedido pago e confirmado e comissão que diminui conforme o volume.

**Para tutores:** tudo do pet em um só lugar — lojas próximas, compra segura,
serviços, histórico e benefícios por recorrência.

Evitar o posicionamento amplo “app para pets”. A promessa deve começar por uma
dor concreta: vender e receber com segurança para o petshop; comprar perto, com
confiança e conveniência para o tutor.

## Melhorias priorizadas

### P0 — antes do piloto

1. Remover o logout forçado a cada abertura e preservar a sessão com segurança.
2. Finalizar o fluxo Mercado Pago, estados pendente/aprovado/recusado e tela de
   acompanhamento do pedido.
3. Impedir mistura de petshops no carrinho e explicar a regra no momento em que
   o segundo lojista for escolhido.
4. Mostrar frete, desconto e total final antes do botão de pagamento.
5. Exibir nome, CNPJ/identidade verificada, distância, prazo, avaliações e canais
   de suporte do petshop.
6. Criar onboarding curto para o petshop: cadastro, catálogo, entrega, agenda,
   conexão Mercado Pago e pedido-teste.
7. Instrumentar o funil e erros com Analytics/Crashlytics.

### P1 — durante o piloto

- Recompra em um toque e lembretes baseados no ciclo do produto, com consentimento.
- Favoritos, avaliações verificadas e resposta pública do petshop.
- Recuperação de checkout abandonado sem spam.
- Painel do petshop com pedidos, conversão, ticket médio, clientes recorrentes,
  comissão do mês e faixa provável do mês seguinte.
- Importação assistida do catálogo por planilha/fotos para reduzir o tempo de
  ativação.
- Central de privacidade com consentimentos, exportação e exclusão de dados.

### P2 — após provar retenção

- Assinatura recorrente de itens de consumo.
- Clube de benefícios financiado em conjunto com parceiros.
- Campanhas segmentadas pelo petshop, com frequência limitada e opt-out.
- Integrações com ERP/PDV e logística somente conforme demanda dos pilotos.

## Campanha: “Seu pet perto. Seu negócio mais forte.”

### Oferta para petshops

- Onboarding humano e importação inicial do catálogo sem custo de implantação.
- Selo “Parceiro Fundador” para o grupo piloto.
- Kit físico com QR code para balcão e embalagem.
- Relatório semanal simples com vendas e próximos passos.
- Incentivo comercial de lançamento somente após definir orçamento e registrar o
  regulamento; não prometer isenção de comissão sem aprovação financeira.

### Oferta para tutores

- Cupom de primeira compra com valor máximo e verba previamente definidos.
- Benefício de indicação concedido apenas após a primeira compra aprovada.
- Sorteio ou brinde deve ter regulamento e validação jurídica antes da divulgação.

## Cronograma de 8 semanas

| Semana | Entrega | Critério de avanço |
|---|---|---|
| 1–2 | Segurança, pagamentos sandbox, sessão e analytics | Fluxos críticos testados |
| 3 | 3–5 petshops, catálogos e treinamento | Cada loja conclui pedido-teste |
| 4 | Piloto com 50–100 tutores convidados | Pagamentos e suporte estáveis |
| 5 | Ajustes de funil e prova social | Conversão e recompra mensuráveis |
| 6 | Conteúdo local, QR codes e lista de espera | Oferta suficiente por região |
| 7 | Relançamento por bairros/cidades-piloto | SLA de suporte e lojas ativas |
| 8 | Otimização e expansão controlada | Retenção e economia unitária saudáveis |

Começar por uma área geográfica compacta. Marketplace sem densidade parece vazio;
é melhor dominar dois bairros do que anunciar nacionalmente com pouca oferta.

## Funil e metas do piloto

### Petshops

`lead → reunião → cadastro → Mercado Pago conectado → catálogo publicado → primeiro pedido → recorrente`

Medir tempo até ativação, taxa de conexão OAuth, percentual com catálogo completo,
primeiro pedido em 7 dias, pedidos por loja, cancelamentos e retenção em 30 dias.

### Tutores

`instalação/visita → cadastro → pet criado → produto visto → carrinho → checkout → pagamento aprovado → recompra`

Medir conversão por etapa, aprovação de pagamento, ticket médio, prazo real,
cancelamentos, recompra em 30/60 dias, indicação e satisfação pós-entrega.

## Mensagens prontas

### WhatsApp para prospecção de petshop

Olá, [nome]. A 4YouPet está selecionando petshops da região para um grupo piloto.
A loja recebe uma vitrine digital local, pedidos pagos pelo Mercado Pago e apoio
para publicar o catálogo. A comissão começa na faixa contratual e diminui com o
volume. Posso mostrar em 15 minutos como a operação fica para a sua equipe?

### Anúncio para petshops

Seu petshop já tem clientes no bairro. Falta um canal simples para eles comprarem
de novo. Com a 4YouPet, você publica produtos e serviços, recebe pedidos pagos e
acompanha o relacionamento com os tutores em um só lugar. Entre para o grupo
piloto e receba apoio na configuração inicial.

### Post para tutores

O cuidado que seu pet precisa, mais perto de você. A 4YouPet voltou com uma
experiência renovada para encontrar petshops locais, comprar com segurança,
acompanhar pedidos e reunir a rotina do seu pet em um só lugar. Cadastre-se para
participar do lançamento na sua região.

### Push de relançamento

**Título:** A 4YouPet está de volta 🐾

**Mensagem:** Petshops locais, compra segura e benefícios para cuidar de quem faz
parte da família. Veja o que chegou na sua região.

## Canais

- Petshops: prospecção consultiva por WhatsApp, visitas locais, associações e
  distribuidores; demonstração curta com pedido real.
- Tutores: base própria com consentimento, Instagram local, criadores regionais,
  Google Business dos parceiros, QR code no balcão/embalagem e programa de
  indicação após compra aprovada.
- Conteúdo: demonstrações do produto e histórias reais de parceiros; evitar peças
  genéricas sem cidade, loja ou prova concreta.

## Guardrails

- Nunca divulgar “pagamento garantido”; usar “pagamento processado com Mercado
  Pago” e explicar pendências, estornos e chargebacks.
- Registrar fonte, consentimento e opt-out de toda comunicação.
- Separar cupons financiados pela 4YouPet dos financiados pelo petshop.
- Publicar termos, política de privacidade e aditivo do Split antes da produção.
- Não escalar aquisição enquanto pagamentos, catálogo e suporte do piloto não
  estiverem estáveis.

