import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/page_manager.dart';

class UsertermScreenLoginLogin extends StatefulWidget {
  const UsertermScreenLoginLogin({Key? key}) : super(key: key);

  @override
  State<UsertermScreenLoginLogin> createState() =>
      _UsertermScreenLoginLoginState();
}

class _UsertermScreenLoginLoginState extends State<UsertermScreenLoginLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: const Text('Termos de Uso do App',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Atualizar a página após a navegação estar completa
                Future.microtask(() {
                  if (mounted) {
                    context.read<PageManager>().setPage(0);
                  }
                });
              },
              icon: Icon(Icons.home),
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 111, 0),
                Color.fromARGB(255, 255, 161, 0),
                //Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: RichText(
                      textAlign: TextAlign.justify,
                      strutStyle: StrutStyle(fontSize: 16),
                      text: TextSpan(children: [
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                            text: 'Termos de Uso e Responsabilidades\n\n'),
                        TextSpan(
                            text:
                                'Os presentes termos de uso (“Termos”) representam os termos e condições que regem a prestação dos Serviços pela 4YOUPET MARKETING PLACE E TECNOLOGIA LTDA, doravante denominada 4YouPet, inscrita no CNPJ/MF sob o nº 46.840.224/0001-02, com sede na Cidade de São José do Rio Preto, Estado de São Paulo, na Rua Saldanha Marinho, nº 3884, Sala 01, Vila Santo Antônio, CEP 15014-300, por meio do aplicativo 4YouPet, disponível na App Store e na Google Play (“Plataforma”) para você (“Usuário”).\n\n'),
                        TextSpan(
                            text:
                                'Ao se cadastrar em nossa Plataforma e utilizar os nossos Serviços, você declara estar de acordo com os termos e condições dispostos neste instrumento e declara que aceitou todas as regras, condições e obrigações dispostas neste instrumento e compromete-se a cumpri-las. Portanto, leia estes Termos com atenção.\n\n'),
                        TextSpan(
                            text:
                                'Ressaltamos que poderemos oferecer recursos, serviços e/ou condições especiais que possuirão seus próprios termos e condições que se aplicam concomitantemente a estes Termos, sendo certo que caso haja conflito entre o disposto nos termos específicos e nestes Termos, os primeiros prevalecerão no que forem diferentes do aqui disposto.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '1 - OBJETO\n\n'),
                        TextSpan(
                            text:
                                'Este instrumento tem por objeto estabelecer as regras e condições para a prestação dos Serviços e, consequente, utilização da Plataforma e compra de produtos e serviços pelo Usuário junto aos Fornecedores, conforme definição abaixo.\n\n'),
                        TextSpan(
                            text:
                                'Este aplicativo visa o provimento de mercado on-line para compradores e vendedores de produtos e serviços (marketplace).  Sendo os pedidos realizados através do aplicativo 4YouPet encaminhados através da rede mundial de computadores aos fornecedores previamente cadastrados, gerando um número de pedido com as informações dos produtos/serviços e valores a serem cobrados diretamente pelos fornecedores.\n\n'),
                        TextSpan(
                            text:
                                'As informações dos dados cadastrados pelos usuários consentidas livremente são de única e exclusiva responsabilidade do informante, e estão protegidos pelo sigilo das informações, conforme a Lei Geral de Proteção de Dados (Lei 13.709, de 2018), garantindo aos usuários maior controle sobre suas informações pessoais, podendo serem visualizadas, corrigidas e excluídas a qualquer tempo através de acesso com Login e Senha pessoal e intransferível.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '2 - SERVIÇOS\n\n'),
                        TextSpan(
                            text:
                                'Para fins destes Termos, “Serviços” significarão a prestação de serviços pelo 4YouPet que possibilitará a você, Usuário, a escolha de fornecedores de mercadorias e/ou serviços destinados às atividades de pet shop e/ou outros estabelecimentos similares (“Fornecedores”) para que faça pedidos online de delivery de produtos destinados a animais de estimação, agendamento de serviços de cuidados para animais de estimação, serviços médicos veterinários e outros insumos (“Produtos”) destinados a animais de estimação de acordo com o catálogo de Produtos e/ou Serviços disponibilizado pelos Fornecedores/Prestadores (“Pedidos”).'
                                '\n\n'),
                        TextSpan(
                            text:
                                'O Usuário reconhece e concorda que os Pedidos deverão conter apenas os Produtos para sua utilização própria, não sendo permitida a aquisição dos Produtos para revenda. Os Pedidos que forem feitos para fins de revenda serão cancelados, sem que isso gere qualquer tipo de responsabilidade ou ônus ao 4YouPet.\n\n'),
                        TextSpan(
                            text:
                                'Os Serviços oferecidos pelo 4YouPet se relacionam apenas à intermediação de agendamento de serviços de cuidados para animais de estimação e serviços médicos veterinários pelos Prestadores, e intermediação da comercialização de produtos destinados a animais de estimação e outros insumos (“Produtos”) destinados a animais de estimação pelos Fornecedores, não abarcando confecção, embalagem, disponibilização e entrega física dos produtos, sendo todos os itens de responsabilidade integral do Fornecedor e os serviços de responsabilidade do Prestador e/ou da empresa especializada na prestação de serviços de entrega (“Transportadora”), conforme o caso, a quem deverão ser direcionadas quaisquer reclamações sobre problemas decorrentes dessas atividades.\n\n'),
                        TextSpan(
                            text:
                                'O uso dos Serviços não lhe confere a propriedade ou direito de uso sobre quaisquer de nossos direitos de propriedade intelectual sobre a Plataforma, Serviços ou sobre nosso conteúdo, incluindo, sem limitação, cabeçalhos de página, elementos gráficos personalizados, ícones de botões, sinais distintivos e scripts disponíveis na Plataforma. Você não poderá usar, copiar, imitar, total ou parcialmente, qualquer conteúdo da Plataforma e dos Serviços a menos que obtenha nossa permissão ou a permissão do proprietário de referido conteúdo ou que o faça por algum meio permitido de acordo com a legislação aplicável.\n\n'),
                        TextSpan(
                            text:
                                'Poderá ser exibido, na Plataforma ou em nossos Serviços, alguns conteúdos que não sejam de nossa titularidade, os quais poderão ser revistos por nós para determinar sua legalidade e adequação às nossas políticas.\n\n'),
                        TextSpan(
                            text:
                                'O 4YouPet poderá, a seu exclusivo critério, remover ou se recusar a exibir conteúdo na Plataforma que acredite estar violando as nossas políticas ou legislação aplicável, sem a necessidade de notificação ou aviso prévio aos Usuários.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '3 – CADASTRO E CONTA\n\n'),
                        TextSpan(
                            text:
                                'Ao utilizar a Plataforma e solicitar a prestação dos Serviços, você declara, de acordo com a legislação aplicável, ter capacidade jurídica para praticar atos civis e se compromete a prestar as informações exigidas na Plataforma com exatidão e veracidade, assumindo integral responsabilidade por referidas informações fornecidas em seu cadastro (“Cadastro”). As informações disponibilizadas em seu Cadastro serão utilizadas para a criação de sua conta de Usuário a qual, por meio de login e senha de acesso individuais, lhe garantirá acesso à Plataforma (“Conta”).\n\n'),
                        TextSpan(
                            text:
                                'Cada Usuário poderá criar apenas 1 (uma) Conta, se o 4YouPet desativar sua Conta, independentemente do motivo ou razão, você compromete-se a não criar outra Conta sem a nossa permissão, sendo certo que caso o 4YouPet constate a existência de 2 (duas) Contas poderá suspendê-las ou exclui-las sem a necessidade de envio de notificação ou aviso prévio ao Usuário e que isso implique em qualquer ônus ao 4YouPet.\n\n'),
                        TextSpan(
                            text:
                                'Para proteger sua Conta, o Usuário deverá manter o seu login e senha em sigilo, uma vez que toda e qualquer atividade realizada em sua Conta ou por seu intermédio é de responsabilidade do Usuário. O Usuário não poderá criar Contas por meio não autorizados, incluindo, mas sem limitação, por meio da utilização de dispositivos automáticos, script, bot, spider, rastreador ou scraper.\n\n'),
                        TextSpan(
                            text:
                                'Caso o 4YouPet constate que qualquer informação fornecida em seu Cadastro é incorreta, inverídica e/ou duvidosa, bem como na hipótese de negativa em corrigi-las, o 4YouPet poderá não concluir seu cadastramento como Usuário ou, ainda, bloquear sua Conta e/ou seu Cadastro já existentes.\n\n'),
                        TextSpan(
                            text:
                                'O 4YouPet poderá ainda impedir, a seu exclusivo critério, a realização de novos Cadastros ou cancelar qualquer Conta existente, caso: (a) detecte qualquer anomalia grave no Cadastro e/ou na Conta; (b) verifique qualquer ação e/ou omissão cuja intenção seja burlar o disposto nestes Termos; ou (c) verifique o descumprimento de qualquer obrigação ou disposição destes Termos.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '4 - OFERTAS\n\n'),
                        TextSpan(
                            text:
                                'Além da disponibilização dos Produtos e/ou Serviços na Plataforma, o 4YouPet poderá disponibilizar ofertas com condições comerciais mais favoráveis do que as normalmente praticadas para os Produtos e/ou Serviços. O 4YouPet poderá retirar uma oferta do ar a seu exclusivo critério, por diversos motivos, incluindo, mas sem limitação, solicitação do Fornecedor/Prestador neste sentido ou quando o estoque dos Produtos objeto da Oferta (“Estoque”) for encerrado.\n\n'),
                        TextSpan(
                            text:
                                'O Usuário, ao utilizar a Plataforma, reconhece e concorda que as ofertas estarão sujeitas à quantidade dos Produtos disponíveis em estoque do Fornecedor, sendo certo que, em caso de término do Estoque, os Pedidos de Produtos objetos da Oferta serão cancelados pelo Fornecedor através da Plataforma.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '5 – FORMAS DE PAGAMENTO DOS PEDIDOS\n\n'),
                        TextSpan(
                            text:
                                'O Usuário realizará diretamente o pagamento dos seus Pedidos aos Fornecedores/Prestadores por um dos métodos disponibilizados por estes, para tanto, os quais poderão incluir, cartão de crédito, cartão de débito, e a transferência PIX.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '6 – ENTREGA DOS PEDIDOS\n\n'),
                        TextSpan(
                            text:
                                'O 4YouPet não presta qualquer serviço de transporte de qualquer tipo de carga, sendo o 4YouPet responsável apenas e tão somente pela intermediação entre o Usuário e os Fornecedores/Prestadores.\n\n'),
                        TextSpan(
                            text:
                                'O Usuário reconhece que o tempo de transporte dos Pedidos variará de acordo com diversos fatores, incluindo, mas sem limitação, se é um produto personalizado ou não, os itens que o compõem, estoque, tempo de produção, processo de emissão de nota fiscal, período de agendamento dos serviços, forma de pagamento e a região do destinatário.\n\n'),
                        TextSpan(
                            text:
                                'O prazo para entrega dos Pedidos será informado durante o processo de compra, e será computado em minutos e dias úteis. O Usuário deverá manter-se disponível para receber os Pedidos no prazo estipulado pelos Fornecedores/Prestadores.\n\n'),
                        TextSpan(
                            text:
                                'Na hipótese de a entrega não ser efetivada no horário e data prevista, e caso não seja possível realizar a entrega em possíveis tentativas posteriores, deverá retornar o Pedido ao Fornecedor e seu respectivo centro de distribuição. Nestes casos, o Usuário será responsável por eventuais cobranças referentes a tentativas posteriores de entrega do Pedido.\n\n'),
                        TextSpan(
                            text:
                                'O valor do frete será calculado com base no local de entrega, peso e dimensões dos Produtos e/ou Serviços contratados.\n\n'),
                        TextSpan(
                            text:
                                'O Usuário reconhece e concorda que o Fornecedor/Prestador poderá recusar Pedidos caso o endereço de entrega informado pelo Usuário seja diferente do endereço constante no Cadastro Nacional da Pessoa Jurídica ou fora da área de cobertura territorial do Município do Fornecedor/Prestador.\n\n'),
                        TextSpan(
                            text:
                                'O 4YouPet não poderá ser considerado responsável pela retenção dos Produtos na SEFAZ quando esta se dever exclusivamente a pendências relacionadas ao Usuário, casos em que o Usuário deverá comparecer ao posto fiscal para que a mercadoria seja liberada, tendo em vista que nestes casos as informações referentes a liberações e pagamentos só são passadas aos interessados.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '7 – RECUSA DE PEDIDOS PELO USUÁRIO\n\n'),
                        TextSpan(
                            text:
                                'Os Pedidos deverão ser enviados ao Usuário em ótimo estado de conservação e de acordo com as especificações e características descritas na Plataforma.\n\n'),
                        TextSpan(
                            text:
                                'O Usuário deverá recusar o pedido no ato de recebimento e escrever o motivo da recusa no verso do documento fiscal, caso o Usuário constate que: (a) a embalagem de armazenamento dos Produtos está aberta, rompida, avariada ou apresenta qualquer tipo de defeito que interfira na integridade dos Produtos, impedindo o seu consumo pelo Usuário; (b) o Produto está avariado; e (c) o Produto está em desacordo com as especificidades e características do Pedido.\n\n'),
                        TextSpan(
                            text:
                                'O Fornecedor será responsável pela correção de quaisquer execuções dos Pedidos feitas de forma inadequada ou incompleta, garantindo a qualidade dos Produtos e o atendimento e satisfação dos Usuários.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text:
                                '8 – DEVOLUÇÃO E TROCA DE PRODUTOS COM DEFEITOS\n\n'),
                        TextSpan(
                            text:
                                'O Usuário terá o prazo de até 7 (sete) dias corridos contados a partir da data de recebimento do Pedido para solicitar a troca ou devolução de Produtos em que for constatado vício e/ou defeito, devendo o Usuário comunicar o Fornecedor/Prestador sobre a constatação do vício e/ou defeito, sendo certo que deverá seguir as instruções dadas pelo 4YouPet para que o pedido de troca ou de devolução seja analisado e processado.\n\n'),
                        TextSpan(
                            text:
                                'O 4YouPet não é responsável legal pelos produtos vendidos e/ou serviços prestados por meio do aplicativo 4YouPet, não respondendo por vícios e/ou garantias legais sobre estes produtos e/ou serviços prestados, não sendo o responsável pelas entregas e/ou recebimentos dos pagamentos realizados.\n\n'),
                        TextSpan(
                            text:
                                'Nessas hipóteses, o Fornecedor, único e exclusivo responsável pelos Produtos, caberá a troca dos Produtos defeituosos por outros idênticos, a serem enviados sem a cobrança de nova taxa de entrega ao Usuário.  Caso não seja possível realizar a troca dos Produtos por qualquer motivo, incluindo, mas sem limitação, por indisponibilidade do Produto, caberá ao Fornecedor a restituição do valor do Produto, incluindo o valor pago pelo frete.\n\n'),
                        TextSpan(
                            text:
                                'Nas hipóteses de troca dos Produtos em decorrência da constatação de vício e/ou defeito nos Produtos, o Usuário não arcará com os custos da taxa de entrega da retirada dos Produtos e da eventual nova taxa de entrega para que lhe sejam disponibilizados os Produtos sem defeitos.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '9 – CANCELAMENTO DA COMPRA\n\n'),
                        TextSpan(
                            text:
                                'Caso o Usuário se arrependa de um Pedido por ele efetuado, independente do motivo ou da razão para tanto, poderá exercer o seu direito de arrependimento no prazo de até 7 (sete) dias corridos contados a partir da data de recebimento do Pedido para solicitar a retirada dos Produtos, devendo o Usuário comunicar o Fornecedor sobre o seu arrependimento da compra, sendo certo que deverá seguir as instruções dadas pelo 4YouPet para que o seu pedido seja analisado e processado.\n\n'),
                        TextSpan(
                            text:
                                'O pedido de devolução dos Produtos passará por uma avaliação para que seja verificado se houve utilização, parcial ou total dos Produtos, ou se os Produtos apresentam avarias ou danos significativos que impeçam o seu uso, sendo certo que caso seja constatada a utilização e/ou avarias nos Produtos, a devolução não será possível.\n\n'),
                        TextSpan(
                            text:
                                'Caso o Pedido seja cancelado pelo Usuário após o seu faturamento pelo Fornecedor, caberá ao Usuário arcar com eventuais custos, taxas e despesas decorrentes da entrega. \n\n'),
                        TextSpan(
                            text:
                                'Nas hipóteses de devolução dos Produtos, caberá ao Fornecedor, único e exclusivo responsável pelos Produtos, efetuar a devolução dos valores ao Usuário, o que deverá ocorrer no prazo de até 25 (vinte e cinco) dias úteis contados a partir da solicitação do Usuário nesse sentido. Ademais, o Usuário reconhece e concorda que arcará com os custos da taxa de entrega original dos Produtos e os custos da taxa de retirada dos Produtos para que sejam devolvidos ao Fornecedor.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text:
                                '10 – PROCEDIMENTOS PARA A TROCA E DEVOLUÇÃO DE PRODUTOS COM DEFEITO E CANCELAMENTO DA COMPRA\n\n'),
                        TextSpan(
                            text:
                                'O Usuário deverá comunicar ao 4YouPet toda e qualquer intenção de realizar a troca ou a devolução de Produtos com defeitos ou sobre seu arrependimento quanto a qualquer compra por ele realizada, antes de tomar qualquer outra medida, como, por exemplo, contatar o Fornecedor ou tentar devolver o Produto ao Fornecedor.\n\n'),
                        TextSpan(
                            text:
                                'Para que possa realizar a troca ou devolução de qualquer Produto, o Usuário deverá entrar em contato com o 4YouPet, via chat ou whatsapp, conforme Cláusula 14, abaixo,  fazer a solicitação para a equipe de atendimento e  enviar o  Formulário de Troca, Devolução e Cancelamento disponível em www.4youpet.com.br  devidamente preenchido para o e-mail sac@4youpet.com.br, que será encaminhado ao Fornecedor para as providências cabíveis.\n\n'),
                        TextSpan(
                            text:
                                'A troca e a devolução de Produtos com defeito ou o cancelamento da compra por arrependimento somente serão possíveis se os Produtos: (a) não apresentarem indícios de uso, avaria ou consumo, estando acondicionados na embalagem original em que foram enviados; (b) não forem perecíveis; (c) não forem personalizados/customizados; (c) estiverem acompanhados da 1ª via do documento fiscal que os acompanhava na entrega; e (d) apresentarem, caso demandado, Nota Fiscal de Devolução de Mercadoria.\n\n'),
                        TextSpan(
                            text:
                                'Caso as condições acima sejam satisfeitas, o 4YouPet realizará a intermediação entre o Fornecedor e o Usuário para que o primeiro retire os Produtos junto ao segundo e tome todas as medidas necessárias para realizar a troca ou devolução dos Produtos, conforme o caso.  Não implicando em qualquer responsabilidade legal ao 4YouPet o não cumprimento das obrigações de qualquer uma das partes (Usuário e/ou Fornecedor).\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '11 – FRAUDES EM COMPRAS\n\n'),
                        TextSpan(
                            text:
                                'Na hipótese de o 4YouPet suspeitar e/ou constatar a ocorrência de fraude perpetuada pelo Usuário em seus Pedidos, o 4YouPet poderá cancelar os referidos Pedidos, em até 1 (um) dia útil, e o cancelamento não ensejará quaisquer ônus ou penalidades ao 4YouPet.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text:
                                '12 – OBRIGAÇÕES E DECLARAÇÕES DO USUÁRIO\n\n'),
                        TextSpan(
                            text:
                                'Por meio de sua aceitação aos presentes Termos e da utilização da Plataforma, o Usuário:\n\n'),
                        TextSpan(
                            text:
                                'obriga-se a não divulgar a terceiros seu login e senha de acesso à sua Conta, bem como a não permitir o uso de sua Conta por terceiros, sendo o Usuário o único responsável por quaisquer solicitações de prestação de Serviços que sejam feitas por meio de sua Conta;\n\n'),
                        TextSpan(
                            text:
                                'obriga-se a fornecer informações verídicas e exatas em seu Cadastro, sendo o único e exclusivo responsável pelo conteúdo informado, comprometendo-se, ainda, a manter seu Cadastro atualizado a todo tempo, principalmente em relação ao endereço de entrega;\n\n'),
                        TextSpan(
                            text:
                                'obriga-se a não: (a) interferir nos Serviços; (b) tentar solicitar os Serviços por outro meio que não a Plataforma e/ou em desconformidade com o disposto nestes termos; (c) interferir e/ou interromper os Serviços e/ou servidores e/ou redes conectadas aos Serviços, incluindo, mas sem limitação, por meio de transmissão de worms, vírus, spyware, malware ou qualquer outro código de natureza destrutiva ou disruptiva; e (d) não inserir conteúdo e/ou código ou, então, alterar ou interferir na forma como qualquer página é disponibilizada na Plataforma;\n\n'),
                        TextSpan(
                            text:
                                'obriga-se a não copiar, modificar, distribuir, fazer engenharia reversa, tentar extrair o código fonte, vender e/ou alugar qualquer parte da Plataforma, Serviços ou quaisquer outros softwares, documentos e/ou informações neles disponibilizados, nem poderá fazer engenharia reversa ou tentar extrair o código fonte da Plataforma e/ou dos softwares;\n\n'),
                        TextSpan(
                            text:
                                'expressamente reconhece e concorda que o 4YouPet, a seu exclusivo critério, poderá fornecer a terceiros interessados, a título gratuito ou oneroso, dados e informações gerais obtidos a partir do seu banco de dados, incluindo, sem limitação, informações a respeito de padrões de comportamento, hábitos de consumo e outras estatísticas relacionadas à Plataforma. Referidos dados e informações em nenhuma hipótese indicarão dados e informações que possam ser utilizadas para identificar ou individualizar os Usuários;\n\n'),
                        TextSpan(
                            text:
                                'concorda com a Política de Privacidade do 4YouPet, a qual está disponível em https://4youpet.com.br/institucional/politica-de-privacidade-4youpet; e\n\n'),
                        TextSpan(
                            text:
                                'declara que os dados por ele indicados no momento de seu cadastro são válidos e verdadeiros e autoriza expressamente que as entregas dos Pedidos por ele realizados na Plataforma possam vir a ser realizadas em endereços distintos do que consta no seu cadastro nacional de pessoas jurídicas perante a Receita Federal.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '13 – OBRIGAÇÕES DO 4YouPet\n\n'),
                        TextSpan(
                            text:
                                'O 4YouPet compromete-se a prestar os Serviços e a disponibilizar a Plataforma para que, após a efetiva criação de sua Conta, o Usuário possa fazer Pedidos. O 4YouPet trabalhará ao máximo para que os Serviços e a Plataforma estejam disponíveis o maior tempo possível, entretanto, poderão ocorrer situações em que o Serviços e a Plataforma ficarão momentaneamente indisponíveis pelos mais diversos motivos, incluindo, sem limitação, manutenções agendadas ou de emergência, atualizações, reparos emergenciais, falhas na infraestrutura, servidores, equipamentos ou links de telecomunicação.\n\n'),
                        TextSpan(
                            text:
                                'O 4YouPet assume, por meio destes Termos, a obrigação de proteger, por meio de armazenamento em servidores ou quaisquer outros meios magnéticos de alta segurança, a confidencialidade de todas as informações e cadastros relativos as informações do Usuário, assim como valores atinentes às operações financeiras decorrentes da prestação dos Serviços e dos Pedidos.\n\n'),
                        TextSpan(
                            text:
                                'O 4YouPet não responderá pela reparação de prejuízos que possam ser derivados de apreensão e cooptação de dados por parte de terceiros que, rompendo os sistemas de segurança, consigam acessar as informações na Plataforma.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '14 – CANAL DE COMUNICAÇÃO E DÚVIDAS\n\n'),
                        TextSpan(
                            text:
                                'Se você tiver algum questionamento, solicitações, reclamações ou dúvidas com relação aos Serviços, a estes Termos ou à Política de Privacidade do 4YouPet ou qualquer prática descrita aqui, entre em contato conosco pelo chat em https://4youpet.com.br, nosso número de Whatsapp (17) 3222-2005 (não recebe ligações) ou por meio do e-mail sac@4youpet.com.br.\n\n'),
                        TextSpan(
                            text:
                                'O Usuário se compromete a manter o endereço eletrônico e telefone para contato indicados em seu Cadastro devidamente atualizados, já que ambos serão os meios a serem utilizados para as comunicações entre o Usuário e o 4YouPet.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '15 – ALTERAÇÕES DOS TERMOS DE USO\n\n'),
                        TextSpan(
                            text:
                                'Os presentes Termos poderão ser alterados, no todo ou em parte, pelo 4YouPet a qualquer tempo, podendo ter seu conteúdo modificado para adequações, inserções e/ou exclusões, visando aprimorar os Serviços. Em caso de mudanças relevantes, os Usuários serão avisados por meio da Plataforma e uma nova versão destes Termos será disponibilizada para sua avaliação.\n\n'),
                        TextSpan(
                            text:
                                'Caso tenha alguma objeção à alteração, você deverá manifestar oposição por escrito, o que resultará no cancelamento de sua Conta e na impossibilidade de solicitar nova prestação de Serviços. A continuidade do uso da Plataforma após a publicação do aviso na Plataforma e da nova versão dos Termos e Condições implicará no seu consentimento com as mudanças e aceitação plena da nova versão dos Termos e Condições.\n\n'),
                        TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            text: '16 – LEGISLAÇÃO APLICÁVEL E FORO\n\n'),
                        TextSpan(
                            text:
                                'Os presentes Termos serão regidos e interpretados de acordo com a legislação da República Federativa do Brasil.\n\n'),
                        TextSpan(
                          text:
                              'Fica eleito como foro da comarca de São José do Rio Preto, Estado de São Paulo, como competente para dirimir eventuais dúvidas, controvérsias decorrentes da interpretação e cumprimento destes Termos.',
                          style: TextStyle(color: Colors.white),
                        )
                      ])),
                ),
              ),
            ],
          ),
        ));
  }
}
