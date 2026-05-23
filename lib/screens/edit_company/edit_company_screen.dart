// ignore_for_file: deprecated_member_use, unused_field

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:fouryoupet/screens/edit_company/components/celular_field.dart';
import 'package:fouryoupet/screens/edit_company/components/contract_dialog.dart';
import 'package:fouryoupet/services/contract_service.dart';

import 'package:provider/provider.dart';
import 'package:fouryoupet/models/company/company.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:validatorless/validatorless.dart';

import '../../models/page_manager.dart';
import '../../services/pagbank_service.dart';

import '../subscription/subscription_form_screen.dart';

import 'components/address_card.dart';
import 'components/cnpj_field.dart';
import 'components/daysoff_form.dart';
import 'components/documents_form.dart';
import 'components/images_form.dart';

class EditCompanyScreen extends StatefulWidget {
  EditCompanyScreen(Company? c)
      : editing = c != null,
        company = c != null ? c.clone() : Company();

  final Company company;
  final bool editing;

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  late Company _company;

  // ✅ VARIÁVEIS DE ESTADO DA EMPRESA
  bool enabled = false;
  bool cut = false;
  bool ht = false;
  bool shop = false;
  bool vet = false;
  bool delivery = true;
  bool aceite = false;
  String device = '';
  bool _saving = false; // Estado para loading/salvamento
  bool _isLoading = true; // Estado para loading inicial dos dados

  final deviceInfoPlugin = DeviceInfoPlugin();

  final ContractService _contractService = ContractService();
  ContractData? _latestContract; // Para guardar o contrato mais recente

  // ✅ VARIÁVEL PARA CONTROLAR LOADING DOS BOTÕES DE ASSINATURA
  bool _subscriptionLoading = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _company = widget.company.clone();

    // Usar addPostFrameCallback para garantir que o context está pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyData();
    });
  }

  Future<void> _loadCompanyData() async {
    final userManager = context.read<UserManager>();
    final companyId = userManager.userapp?.companyID;

    debugPrint('CompanyID do usuário: $companyId'); // Debug

    // Se a empresa não foi passada como parâmetro, busca do Firestore
    if (_company.id == null && companyId != null && companyId.isNotEmpty) {
      try {
        debugPrint('Buscando empresa com ID: $companyId'); // Debug
        final companyDoc = await FirebaseFirestore.instance
            .collection('companys')
            .doc(companyId)
            .get();

        debugPrint('Documento encontrado: ${companyDoc.exists}'); // Debug
        if (companyDoc.exists) {
          final data = companyDoc.data();
          if (data != null) {
            debugPrint('Dados da empresa: ${data['name']}'); // Debug
            setState(() {
              _company = Company.fromDocument(companyDoc);
              enabled = _company.active ?? false;
              cut = _company.cut ?? false;
              ht = _company.ht ?? false;
              shop = _company.shop ?? false;
              vet = _company.vet ?? false;
              delivery = _company.delivery ?? true;
              aceite = _company.aceite_contrato ?? false;
              _isLoading = false;
            });
          }
        } else {
          debugPrint('Documento não existe no Firestore'); // Debug
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Erro ao carregar dados da empresa: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar dados: $e')),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Se a empresa já foi passada, usa os dados dela
      enabled = _company.active ?? false;
      cut = _company.cut ?? false;
      ht = _company.ht ?? false;
      shop = _company.shop ?? false;
      vet = _company.vet ?? false;
      delivery = _company.delivery ?? true;
      aceite = _company.aceite_contrato ?? false;
      setState(() {
        _isLoading = false;
      });
    }

    // Carrega o contrato e verifica se precisa exibir o modal
    _loadAndCheckContract();
  }

  Future<void> _loadAndCheckContract() async {
    try {
      final currentContract = await _contractService.getContractFromStorage();
      setState(() {
        _latestContract = currentContract;
      });

      // Lógica para forçar reaceite:
      // 1. Se o contrato nunca foi aceito
      // 2. Ou se a versão aceita pela empresa é diferente da versão atual
      debugPrint('Status aceite_contrato: ${_company.aceite_contrato}'); // Debug
      final bool needsAcceptance = _company.aceite_contrato != true;
      debugPrint('Precisa aceitar contrato? $needsAcceptance'); // Debug

      if (mounted && needsAcceptance) {
        _openContractAndAcceptIfConfirmed();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao carregar o contrato: $e')),
        );
      }
    }
  }

  Future<void> _openContractAndAcceptIfConfirmed() async {
    if (_latestContract == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Contrato ainda não carregado. Tente novamente.')),
      );
      return;
    }
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final accepted = await showContractDialog(
      context,
      contractHtmlContent: _latestContract!.htmlContent,
      contractVersion: _latestContract!.version,
      title: 'Contrato de Adesão 4youpet',
      acceptLabel: 'Li e aceito os termos do contrato',
      confirmButtonText: 'Aceitar e continuar',
      cancelButtonText: 'Cancelar',
      barrierDismissible:
          true, // Permitir fechar para poder ler sem aceitar se quiser
    );

    if (accepted == true) {
      try {
        setState(() => _saving = true);
        final allInfo = deviceInfo.data;
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          final info = allInfo['utsname'] ?? 'Desconhecido';
          final rede = info['nodename'] ?? 'Desconhecido';
          final model = allInfo['model'] ?? 'Desconhecido';
          final vendor = allInfo['identifierForVendor'] ?? 'Desconhecido';
          final deviceDetails = '$vendor - $model - rede: $rede';
          device = deviceDetails;
        } else {
          final model = allInfo['model'] ?? 'Desconhecido';
          final vendor = allInfo['id'] ?? 'Desconhecido';
          final rede = allInfo['host'] ?? 'Desconhecido';
          final deviceDetails = '$vendor - $model - rede: $rede';
          device = deviceDetails;
        }

        // Atualiza o estado local da empresa com o aceite
        _company.aceite_contrato = true;
        _company.device = device;
        aceite = true;

        // 🔥 SALVA NO FIRESTORE
        await _company.save();

        setState(() {
          _saving = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Contrato aceito e salvo com sucesso!')),
          );
        }
      } catch (e) {
        setState(() => _saving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao registrar aceite: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserManager>();
    context.watch<CompanyManager>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ChangeNotifierProvider.value(
        value: _company,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 255, 111, 0),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(widget.editing ? 'Editar Empresa' : 'Cadastrar Empresa',
                style: const TextStyle(color: Colors.white)),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                onPressed: () {
                  context.read<PageManager>().setPage(0);
                  // Se necessário, feche telas abertas
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 111, 0),
                  Color.fromARGB(255, 255, 161, 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Carregando dados...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Form(
                    key: formKey,
                    child: ListView(
                      padding: EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      children: <Widget>[
                        // ✅ CARD DE STATUS DA ASSINATURA (ATUALIZADO)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _company.subscriptionStatusColor,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _company.subscriptionStatusIcon,
                                    color: _company.subscriptionStatusColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Status da Assinatura',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _company.subscriptionStatusColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _company.subscriptionStatusText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _company.subscriptionStatusColor,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ✅ BOTÕES DE ASSINATURA MOVIDOS PARA DENTRO DO CARD
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!_company.hasActiveSubscription &&
                                      _company.id != null) ...[
                                    ElevatedButton.icon(
                                      onPressed: _subscriptionLoading
                                          ? null
                                          : () => _handleActivateSubscription(),
                                      icon: const Icon(Icons.credit_card,
                                          size: 18),
                                      label: _subscriptionLoading
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.white),
                                              ),
                                            )
                                          : const Text('Ativar Assinatura',
                                              style: TextStyle(fontSize: 16)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                  if (_company.hasActiveSubscription) ...[
                                    ElevatedButton.icon(
                                      onPressed: _subscriptionLoading
                                          ? null
                                          : () => _handleCancelSubscription(),
                                      icon: const Icon(Icons.cancel, size: 18),
                                      label: _subscriptionLoading
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.white),
                                              ),
                                            )
                                          : const Text('Cancelar Assinatura',
                                              style: TextStyle(fontSize: 16)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ✅ FORMULÁRIO DA EMPRESA - CARD COM FUNDO BRANCO
                        Card(
                          margin: const EdgeInsets.all(16),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                const Text(
                                  'Razão Social',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: _company.name,
                                  decoration: InputDecoration(
                                    hintText: 'Nome da Empresa',
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2),
                                    ),
                                    isDense: true,
                                  ),
                                  validator: Validatorless.min(
                                      6, 'Nome muito curto - Min.(6 dígitos)'),
                                  onSaved: (name) => _company.name = name,
                                ),
                                const SizedBox(height: 2),
                                CnpjField(company: _company),
                                const SizedBox(height: 2),
                                const Text(
                                  'E-mail',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: _company.email,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'email@email.com.br',
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2),
                                    ),
                                  ),
                                  validator:
                                      Validatorless.email('E-mail inválido'),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                  onSaved: (email) => _company.email = email,
                                ),
                                const SizedBox(height: 2),
                                CelularField(company: _company),
                                const SizedBox(height: 2),
                                AddressCard(company: _company),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.orange[300]!),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Horário de funcionamento',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Horário de Abertura',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    HoraInputFormatter(),
                                  ],
                                  initialValue: _company.abertura ?? '',
                                  textAlign: TextAlign.start,
                                  decoration: InputDecoration(
                                    hintText: '00:00',
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2),
                                    ),
                                    isDense: true,
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator:
                                      Validatorless.min(4, 'formato 00:00'),
                                  onSaved: (abertura) {
                                    _company.abertura = abertura;
                                  },
                                ),
                                const Text(
                                  'Horário de Fechamento',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    HoraInputFormatter(),
                                  ],
                                  initialValue: _company.fechamento ?? '',
                                  textAlign: TextAlign.start,
                                  decoration: InputDecoration(
                                    hintText: '00:00',
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2),
                                    ),
                                    isDense: true,
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator:
                                      Validatorless.min(4, 'formato 00:00'),
                                  onSaved: (fechamento) {
                                    _company.fechamento = fechamento;
                                  },
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.blue[300]!),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Delivery',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Valor Base',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                    initialValue:
                                        _company.base?.toStringAsFixed(2),
                                    textAlign: TextAlign.start,
                                    decoration: const InputDecoration(
                                      labelText: 'R\$ 0,00',
                                      isDense: true,
                                      prefixText: 'R\$',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (base) {
                                      if (base != null && base.contains(','))
                                        base =
                                            base.replaceAll(RegExp(r','), '.');
                                      if (num.tryParse(base ?? '') == null) {
                                        return 'Inválido';
                                      }
                                      return null;
                                    },
                                    onSaved: (base) {
                                      if (base != null && base.contains(','))
                                        base =
                                            base.replaceAll(RegExp(r','), '.');
                                      _company.base = num.tryParse(base ?? '');
                                    }),
                                const Text(
                                  'Valor por KM',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                TextFormField(
                                    initialValue:
                                        _company.km?.toStringAsFixed(2),
                                    textAlign: TextAlign.start,
                                    decoration: const InputDecoration(
                                      labelText: 'R\$ 0,00',
                                      isDense: true,
                                      prefixText: 'R\$',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (km) {
                                      if (km != null && km.contains(','))
                                        km = km.replaceAll(RegExp(r','), '.');
                                      if (num.tryParse(km ?? '') == null) {
                                        return 'Inválido';
                                      }
                                      return null;
                                    },
                                    onSaved: (km) {
                                      if (km != null && km.contains(','))
                                        km = km.replaceAll(RegExp(r','), '.');
                                      _company.km = num.tryParse(km ?? '');
                                    }),
                                const Text(
                                  'Isento até',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                TextFormField(
                                    initialValue:
                                        _company.minkm?.toStringAsFixed(2),
                                    textAlign: TextAlign.end,
                                    decoration: const InputDecoration(
                                      labelText: '0 KM',
                                      isDense: true,
                                      suffixText: 'KM',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (minkm) {
                                      if (minkm != null && minkm.contains(','))
                                        minkm =
                                            minkm.replaceAll(RegExp(r','), '.');
                                      if (num.tryParse(minkm ?? '') == null) {
                                        return 'Inválido';
                                      }
                                      return null;
                                    },
                                    onSaved: (minkm) {
                                      if (minkm != null && minkm.contains(','))
                                        minkm =
                                            minkm.replaceAll(RegExp(r','), '.');
                                      _company.minkm =
                                          num.tryParse(minkm ?? '');
                                    }),
                                const SizedBox(height: 2),
                                const Text(
                                  'Área de Cobertura',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                TextFormField(
                                    initialValue:
                                        _company.maxkm?.toStringAsFixed(2),
                                    textAlign: TextAlign.end,
                                    decoration: const InputDecoration(
                                      labelText: '50 KM',
                                      isDense: true,
                                      suffixText: 'KM',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (maxkm) {
                                      if (maxkm != null && maxkm.contains(','))
                                        maxkm =
                                            maxkm.replaceAll(RegExp(r','), '.');
                                      if (num.tryParse(maxkm ?? '') == null) {
                                        return 'Inválido';
                                      }
                                      return null;
                                    },
                                    onSaved: (maxkm) {
                                      if (maxkm != null && maxkm.contains(','))
                                        maxkm =
                                            maxkm.replaceAll(RegExp(r','), '.');
                                      _company.maxkm =
                                          num.tryParse(maxkm ?? '');
                                    }),
                                const SizedBox(height: 2),

                                // ✅ SWITCHES DE SERVIÇOS
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.green[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Serviços Oferecidos',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Flexible(
                                                  child: Text('Pet Shop:',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                                Switch(
                                                  value: shop,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      shop = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Flexible(
                                                  child: Text('Delivery:',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                                Switch(
                                                  value: delivery,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      delivery = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Flexible(
                                                  child: Text('Veterinário:',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                                Switch(
                                                  value: vet,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      vet = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Flexible(
                                                  child: Text('Cuidados:',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                                Switch(
                                                  value: cut,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      cut = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Flexible(
                                                  child: Text('Hotelzinho:',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                                Switch(
                                                  value: ht,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      ht = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Expanded(child: SizedBox()),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Text(
                                  'Prazo médio para entrega',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: _company.prazoentrega,
                                  decoration: InputDecoration(
                                    hintText: '(10 à 30 minutos)',
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2),
                                    ),
                                  ),
                                  onSaved: (prazoentrega) =>
                                      _company.prazoentrega = prazoentrega,
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.purple[300]!),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Dias de Folga',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple[800],
                                      ),
                                    ),
                                  ),
                                ),
                                DaysOffForm(company: _company),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.teal[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.teal[300]!),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Logo da Empresa',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.teal[800],
                                      ),
                                    ),
                                  ),
                                ),
                                ImagesForm(_company),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[300]!),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Contrato Social e Documentos dos Sócios',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.red[800],
                                      ),
                                    ),
                                  ),
                                ),
                                DocumentsForm(_company),
                                const SizedBox(height: 20),
                                Card(
                                  margin: EdgeInsets.zero,
                                  clipBehavior: Clip.antiAlias,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Contrato de Adesão',
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _company.aceite_contrato == true
                                                    ? 'Status: Aceito '
                                                    : 'Status: Pendente',
                                                style: TextStyle(
                                                  color: _company
                                                              .aceite_contrato ==
                                                          true
                                                      ? Colors.green
                                                      : Colors
                                                          .red, // Use a cor de erro para pendente
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (_company.aceite_contrato == true &&
                                            _latestContract != null)
                                          FilledButton.tonalIcon(
                                            onPressed: () =>
                                                _openContractAndAcceptIfConfirmed(), // Permite visualizar mesmo após aceito
                                            icon: const Icon(
                                                Icons.visibility_outlined),
                                            label: const Text('Ver contrato'),
                                          )
                                        else if (_latestContract !=
                                            null) // Só mostra o botão se o contrato já foi carregado
                                          FilledButton.icon(
                                            onPressed: () =>
                                                _openContractAndAcceptIfConfirmed(),
                                            icon: const Icon(
                                                Icons.description_outlined),
                                            label: const Text('Ler e aceitar'),
                                          )
                                        else // Exibe um indicador de carregamento enquanto o contrato é buscado
                                          const CircularProgressIndicator(),
                                      ],
                                    ),
                                  ),
                                ),

                                // ✅ BOTÃO DE SALVAR
                                SizedBox(
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: !_company.loading
                                        ? () async {
                                            setState(() {
                                              _company.loading = true;
                                            });
                                            try {
                                              _company.vet = vet;
                                              _company.delivery = delivery;
                                              _company.shop = shop;
                                              _company.ht = ht;
                                              _company.cut = cut;
                                              _company.active = enabled;
                                              _company.aceite_contrato = aceite;
                                              _company.device = device;

                                              formKey.currentState!.save();
                                              await _company.save();

                                              if (!widget.editing &&
                                                  (userManager.userapp
                                                              ?.companyID ==
                                                          null ||
                                                      userManager.userapp
                                                              ?.companyID ==
                                                          '')) {
                                                userManager.userapp?.companyID =
                                                    _company.id;
                                                await userManager.userapp
                                                    ?.saveData();
                                              }

                                              // Atualiza o estado global da empresa
                                              final companyManager = context
                                                  .read<CompanyManager>();
                                              await companyManager
                                                  .update(_company);
                                              await userManager.finduser();

                                              showTopSnackBar(
                                                Overlay.of(context),
                                                CustomSnackBar.success(
                                                    message:
                                                        "Salvo com sucesso"),
                                              );

                                              // Força atualização dos dados mais recentes
                                              await _fetchLatestCompanyData();
                                              Navigator.of(context).popUntil(
                                                  (route) => route.isFirst);
                                              // Navigator.pushAndRemoveUntil(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (BuildContext context) =>
                                              //             BaseScreen(
                                              //               forceRefresh: true,
                                              //             )),
                                              //     ModalRoute.withName('/'));
                                            } catch (e) {
                                              showTopSnackBar(
                                                Overlay.of(context),
                                                CustomSnackBar.error(
                                                    message:
                                                        "Erro ao salvar: $e"),
                                              );
                                            } finally {
                                              if (mounted) {
                                                setState(() {
                                                  _company.loading = false;
                                                });
                                              }
                                            }
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Theme.of(context)
                                          .primaryColor
                                          .withAlpha(100),
                                    ),
                                    child: _company.loading
                                        ? const CircularProgressIndicator
                                            .adaptive(
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                          )
                                        : const Text('Salvar',
                                            style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ✅ MÉTODO PARA ATIVAR ASSINATURA
  Future<void> _handleActivateSubscription() async {
    setState(() {
      _subscriptionLoading = true;
    });

    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SubscriptionFormScreen(),
        ),
      );

      await _fetchLatestCompanyData();
      if (_company.hasActiveSubscription) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.success(
            message: "Assinatura ativada com sucesso!",
          ),
        );

        // Só volta para a home se a assinatura foi ativada com sucesso
        if (mounted) {
          context.read<PageManager>().setPage(0);
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: 'Erro ao ativar assinatura: $e',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _subscriptionLoading = false;
        });
      }
    }
  }

  // ✅ MÉTODO PARA CANCELAR ASSINATURA
  Future<void> _handleCancelSubscription() async {
    // Confirmação antes de cancelar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Assinatura'),
          content: const Text(
            'Tem certeza que deseja cancelar sua assinatura? Esta ação não pode ser desfeita.',
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
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _subscriptionLoading = true;
    });

    try {
      final _pagBankService = PagBankService();
      await _pagBankService.cancelSubscription(
        subscriptionId: '${_company.subscriptionId}',
        companyID: '${_company.id}',
      );

      await _fetchLatestCompanyData();

      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: "Assinatura cancelada com sucesso!",
        ),
      );

      // Volta para a home após cancelar com sucesso
      if (mounted) {
        context.read<PageManager>().setPage(0);
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: 'Erro ao cancelar assinatura: $e',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _subscriptionLoading = false;
        });
      }
    }
  }

  // ✅ MÉTODO PARA ATUALIZAR DADOS DA EMPRESA
  Future<void> _fetchLatestCompanyData() async {
    if (_company.id != null) {
      try {
        final companyManager = context.read<CompanyManager>();
        final latestCompany =
            await companyManager.findCompanyByID(_company.id!);

        if (latestCompany != null && mounted) {
          setState(() {
            _company = latestCompany.clone();
            // Atualiza também as variáveis de estado dos switches
            enabled = _company.active ?? true;
            cut = _company.cut ?? false;
            ht = _company.ht ?? false;
            shop = _company.shop ?? false;
            vet = _company.vet ?? false;
            delivery = _company.delivery ?? true;
          });
        }
      } catch (e) {
        debugPrint('Erro ao atualizar dados da empresa: $e');
      }
    }
  }
}
