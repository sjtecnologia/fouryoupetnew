// screens/subscription/subscription_screen.dart

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/logger.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final logger = Logger();
  // Controladores para os campos
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();

  // Controladores para endereço
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  void _loadCompanyData() {
    final companyManager = context.read<CompanyManager>();
    final company = companyManager.company;

    if (company != null) {
      // Preencher apenas telefone (dados da empresa)
      _phoneController.text = company.phone ?? '';

      // Preencher dados de endereço se existirem
      if (company.address != null) {
        final address = company.address!;
        _streetController.text = address.street ?? '';
        _numberController.text = address.number ?? '';
        _complementController.text = address.complement ?? '';
        _neighborhoodController.text = address.district ?? '';
        _cityController.text = address.city ?? '';
        _stateController.text = address.state ?? '';
        _zipCodeController.text = address.zipCode ?? '';
      }
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
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
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assinatura Premium'),
          centerTitle: true,
        ),
        body: Consumer<CompanyManager>(
          builder: (context, companyManager, _) {
            final company = companyManager.company;
            final hasActiveSubscription =
                company?.subscriptionStatus == 'active';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card de informações do plano
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Plano Premium',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'R\$ 20,00/mês',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Benefícios inclusos:'),
                          const SizedBox(height: 8),
                          _buildBenefit('Produtos ilimitados'),
                          _buildBenefit('Serviços ilimitados'),
                          _buildBenefit('Agendamentos ilimitados'),
                          _buildBenefit('Relatórios avançados'),
                          _buildBenefit('Suporte prioritário'),
                          _buildBenefit('Sem taxas adicionais'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (hasActiveSubscription) ...[
                    // Status da assinatura ativa
                    Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Assinatura Ativa',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ID: ${company?.subscriptionId ?? ''}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _cancelSubscription,
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancelar Assinatura'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Formulário de assinatura
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Dados do Cartão',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // Número do cartão
                          TextFormField(
                            controller: _cardNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Número do Cartão',
                              hintText: '0000 0000 0000 0000',
                              prefixIcon: Icon(Icons.credit_card),
                              border: OutlineInputBorder(),
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
                          const SizedBox(height: 16),

                          // Nome no cartão
                          TextFormField(
                            controller: _cardHolderController,
                            decoration: const InputDecoration(
                              labelText: 'Nome no Cartão',
                              hintText: 'Como está escrito no cartão',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite o nome no cartão';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Validade e CVV
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _expiryDateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Validade',
                                    hintText: 'MM/AA',
                                    prefixIcon: Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(),
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
                                    if (value.length != 5) {
                                      return 'Validade inválida';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _cvvController,
                                  decoration: const InputDecoration(
                                    labelText: 'CVV',
                                    hintText: '123',
                                    prefixIcon: Icon(Icons.lock),
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Digite o CVV';
                                    }
                                    if (value.length != 3) {
                                      return 'CVV inválido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Dados Pessoais',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // CPF
                          TextFormField(
                            controller: _cpfController,
                            decoration: const InputDecoration(
                              labelText: 'CPF do Titular do Cartão',
                              hintText: '000.000.000-00',
                              prefixIcon: Icon(Icons.badge),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CpfInputFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite o CPF';
                              }
                              if (!CPFValidator.isValid(value)) {
                                return 'CPF inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Telefone
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Telefone',
                              hintText: '(00) 00000-0000',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              TelefoneInputFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite o telefone';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Endereço',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // CEP
                          TextFormField(
                            controller: _zipCodeController,
                            decoration: const InputDecoration(
                              labelText: 'CEP',
                              hintText: '00000-000',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CepInputFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite o CEP';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Rua
                          TextFormField(
                            controller: _streetController,
                            decoration: const InputDecoration(
                              labelText: 'Rua',
                              prefixIcon: Icon(Icons.home),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite a rua';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Número e Complemento
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _numberController,
                                  decoration: const InputDecoration(
                                    labelText: 'Número',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Digite o número';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _complementController,
                                  decoration: const InputDecoration(
                                    labelText: 'Complemento',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Bairro
                          TextFormField(
                            controller: _neighborhoodController,
                            decoration: const InputDecoration(
                              labelText: 'Bairro',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Digite o bairro';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Cidade e Estado
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _cityController,
                                  decoration: const InputDecoration(
                                    labelText: 'Cidade',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Digite a cidade';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _stateController,
                                  decoration: const InputDecoration(
                                    labelText: 'UF',
                                    border: OutlineInputBorder(),
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[A-Z]')),
                                    LengthLimitingTextInputFormatter(2),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'UF';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Botão de assinar
                          ElevatedButton(
                            onPressed: _isLoading ? null : _processSubscription,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Assinar Agora',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _processSubscription() async {
    // if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final companyManager = context.read<CompanyManager>();
      final company = companyManager.company!;

      // Preparar dados do endereço
      final addressData = {
        'street': _streetController.text.trim(),
        'number': _numberController.text.trim(),
        'complement': _complementController.text.trim(),
        'neighborhood': _neighborhoodController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipCode': _zipCodeController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      };

      // Preparar dados para assinatura
      final subscriptionData = {
        'companyId': company.id,
        'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
        'cardHolder': _cardHolderController.text.trim().toUpperCase(),
        'expiryDate': _expiryDateController.text,
        'cvv': _cvvController.text,
        'cpf': _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'phone': _phoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'address': addressData,
      };

      debugPrint('Enviando dados para Cloud Function:$subscriptionData');

      // Criar assinatura
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('createPagBankSubscription');
      final result = await callable.call(subscriptionData);

      debugPrint('Resposta da Cloud Function:$result.data');

      if (result.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assinatura realizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception(result.data['error'] ?? 'Erro ao processar assinatura');
      }
    } catch (e) {
      debugPrint('Erro ao processar assinatura:$e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Assinatura'),
        content: const Text(
          'Tem certeza que deseja cancelar sua assinatura? '
          'Você perderá acesso aos recursos premium.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final companyManager = context.read<CompanyManager>();
      final company = companyManager.company!;

      // Cancelar assinatura
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('cancelPagBankSubscription');
      final result = await callable.call({
        'companyId': company.id,
        'subscriptionId': company.subscriptionId,
      });

      if (result.data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assinatura cancelada com sucesso'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        throw Exception(result.data['error'] ?? 'Erro ao cancelar assinatura');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Formatador para número do cartão
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(newText[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

// Formatador para data de validade
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < newText.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(newText[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
