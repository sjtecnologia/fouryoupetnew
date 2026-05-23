// lib/screens/subscription/subscription_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/company/company_manager.dart';
import '../../services/pagbank_service.dart';

class SubscriptionFormScreen extends StatefulWidget {
  @override
  _SubscriptionFormScreenState createState() => _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends State<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pagBankService = PagBankService();

  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();

  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();

  bool _isLoading = false;

  Future<void> _processSubscription() async {
    //if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final companyManager = context.read<CompanyManager>();
      final companyId = companyManager.company?.id;

      if (companyId == null) {
        throw Exception('Empresa não encontrada');
      }

      // 1. Obter chave pública
      final publicKey = await _pagBankService.getPublicKey();

      // 2. Extrair mês e ano da data de validade
      final expiryParts = _expiryDateController.text.split('/');
      final expiryMonth = expiryParts[0];
      final expiryYear = expiryParts[1];

      // 3. Criptografar cartão no frontend
      final encryptedCard = await _pagBankService.encryptCard(
        publicKey: publicKey,
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        cardHolder: _cardHolderController.text.toUpperCase(),
        expiryMonth: expiryMonth,
        expiryYear: expiryYear.length == 2 ? '20$expiryYear' : expiryYear,
        cvv: _cvvController.text,
        context: context,
      );

      // 4. Criar assinatura com cartão criptografado
      // ignore: unused_local_variable
      final result = await _pagBankService.createSubscription(
        companyId: companyId,
        encryptedCard: encryptedCard,
        cardHolder: _cardHolderController.text,
        cpf: _cpfController.text,
        phone: _phoneController.text,
        security_code: _cvvController.text,
        address: {
          'street': _streetController.text,
          'number': _numberController.text,
          'neighborhood': _neighborhoodController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'postalCode': _postalCodeController.text,
        },
      );

      // Mostrar sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assinatura criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Voltar para tela anterior
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assinar Plano Premium',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Dados do Cartão',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Número do cartão
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Número do Cartão',
                        hintText: '0000 0000 0000 0000',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CardNumberFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite o número do cartão';
                        }
                        if (value.replaceAll(' ', '').length != 16) {
                          return 'Número do cartão inválido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Nome no cartão
                    TextFormField(
                      controller: _cardHolderController,
                      decoration: InputDecoration(
                        labelText: 'Nome no Cartão',
                        hintText: 'Como está impresso no cartão',
                        prefixIcon: Icon(Icons.person),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite o nome no cartão';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        // Data de validade
                        Expanded(
                          child: TextFormField(
                            controller: _expiryDateController,
                            decoration: InputDecoration(
                              labelText: 'Validade',
                              hintText: 'MM/AA',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _ExpiryDateFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite a validade';
                              }
                              if (!value.contains('/') || value.length != 5) {
                                return 'Formato inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),

                        // CVV
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite o CVV';
                              }
                              if (value.length < 3) {
                                return 'CVV inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    Text(
                      'Dados Pessoais',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 16),

                    // CPF
                    TextFormField(
                      controller: _cpfController,
                      decoration: InputDecoration(
                        labelText: 'CPF/CNPJ',
                        //hintText: '000.000.000-00',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CpfCnpjFormatter(),
                        LengthLimitingTextInputFormatter(
                            18), // Limita a 14 dígitos
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite o CPF OU CNPJ';
                        }
                        // Remove formatação para validar
                        final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');

                        if (numbers.length == 11) {
                          // Validação de CPF
                          if (!_isValidCPF(numbers)) {
                            return 'CPF inválido';
                          }
                        } else if (numbers.length == 14) {
                          // Validação de CNPJ
                          if (!_isValidCNPJ(numbers)) {
                            return 'CNPJ inválido';
                          }
                        } else {
                          return 'CPF ou CNPJ inválido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Telefone
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                        hintText: '(00) 00000-0000',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _PhoneFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite o telefone';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _processSubscription,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            Colors.orange, //Theme.of(context).primaryColor,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'ASSINAR PLANO - 30 dias grátis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'R\$ 20,00/mês (após período grátis)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Informações de segurança
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Pagamento seguro via PagBank',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }
}

// Formatadores customizados
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length && i < 11; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _CpfCnpjFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove todos os caracteres não numéricos
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();

    // Determina se é CPF (11 dígitos) ou CNPJ (14 dígitos)
    if (text.length <= 11) {
      // Formatação de CPF: 000.000.000-00
      for (int i = 0; i < text.length && i < 11; i++) {
        if (i == 3 || i == 6) buffer.write('.');
        if (i == 9) buffer.write('-');
        buffer.write(text[i]);
      }
    } else {
      // Formatação de CNPJ: 00.000.000/0000-00
      for (int i = 0; i < text.length && i < 14; i++) {
        if (i == 2 || i == 5) buffer.write('.');
        if (i == 8) buffer.write('/');
        if (i == 12) buffer.write('-');
        buffer.write(text[i]);
      }
    }

    // Calcula a posição correta do cursor
    int cursorPosition = buffer.length;

    // Ajusta a posição do cursor se estiver deletando
    if (oldValue.text.length > newValue.text.length) {
      // Se o caractere deletado era um separador, move o cursor uma posição a menos
      final oldChar = oldValue.text.length > 0
          ? oldValue.text[oldValue.selection.baseOffset - 1]
          : '';
      if (oldChar == '.' || oldChar == '-' || oldChar == '/') {
        cursorPosition = cursorPosition > 0 ? cursorPosition - 1 : 0;
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

bool _isValidCPF(String cpf) {
  if (cpf.length != 11) return false;

  // Verifica se todos os dígitos são iguais
  if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

  // Calcula o primeiro dígito verificador
  int sum = 0;
  for (int i = 0; i < 9; i++) {
    sum += int.parse(cpf[i]) * (10 - i);
  }
  int firstDigit = (sum * 10) % 11;
  if (firstDigit == 10) firstDigit = 0;

  if (firstDigit != int.parse(cpf[9])) return false;

  // Calcula o segundo dígito verificador
  sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += int.parse(cpf[i]) * (11 - i);
  }
  int secondDigit = (sum * 10) % 11;
  if (secondDigit == 10) secondDigit = 0;

  return secondDigit == int.parse(cpf[10]);
}

bool _isValidCNPJ(String cnpj) {
  if (cnpj.length != 14) return false;

  // Verifica se todos os dígitos são iguais
  if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;

  // Calcula o primeiro dígito verificador
  List<int> multiplicadores1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  int sum = 0;
  for (int i = 0; i < 12; i++) {
    sum += int.parse(cnpj[i]) * multiplicadores1[i];
  }
  int firstDigit = sum % 11;
  firstDigit = firstDigit < 2 ? 0 : 11 - firstDigit;

  if (firstDigit != int.parse(cnpj[12])) return false;

  // Calcula o segundo dígito verificador
  List<int> multiplicadores2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  sum = 0;
  for (int i = 0; i < 13; i++) {
    sum += int.parse(cnpj[i]) * multiplicadores2[i];
  }
  int secondDigit = sum % 11;
  secondDigit = secondDigit < 2 ? 0 : 11 - secondDigit;

  return secondDigit == int.parse(cnpj[13]);
}
