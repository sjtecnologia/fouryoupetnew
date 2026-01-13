import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../common/custom_drawer/custom_drawer.dart';
import '../../models/page_manager.dart';
import '../../models/address/address.dart';
import '../../models/user/user_manager.dart';

import 'componentes/celular_field.dart';
import 'componentes/cnpj_field.dart';

class NewCompanyScreen extends StatefulWidget {
  @override
  _NewCompanyScreenState createState() => _NewCompanyScreenState();
}

class _NewCompanyScreenState extends State<NewCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Controladores para os campos do formulário
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _phoneController = TextEditingController();

  // Controladores de endereço completo
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  // Controladores operacionais
  final _baseController = TextEditingController();
  final _kmController = TextEditingController();
  final _maxkmController = TextEditingController();
  final _minkmController = TextEditingController();
  final _prazoentregaController = TextEditingController();
  final _aberturaController = TextEditingController();
  final _fechamentoController = TextEditingController();

  // Variáveis para os valores dos campos booleanos
  bool _vet = false;
  bool _cut = false;
  bool _ht = false;
  bool _shop = false;
  bool _delivery = true; // Padrão true conforme modelo
  bool _active = false;
  bool _aceiteContrato = false;

  // Dias de folga
  List<String> _daysoff = [];

  // Arquivos para upload
  List<File> _images = [];
  File? _logoFile;
  File? _contratoSocialFile;
  List<File> _documentosSociosFiles = [];

  String? _companyId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para garantir que o context está pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyData();
    });
  }

  Future<void> _loadCompanyData() async {
    final userManager = context.read<UserManager>();
    final companyId = userManager.userapp?.companyID;

    print('CompanyID do usuário: $companyId'); // Debug

    if (companyId != null && companyId.isNotEmpty) {
      try {
        print('Buscando empresa com ID: $companyId'); // Debug
        final companyDoc = await FirebaseFirestore.instance
            .collection('companys')
            .doc(companyId)
            .get();

        print('Documento encontrado: ${companyDoc.exists}'); // Debug
        if (companyDoc.exists) {
          final data = companyDoc.data() as Map<String, dynamic>;
          print('Dados da empresa: ${data['name']}'); // Debug
          _companyId = companyId;

          setState(() {
            // Dados básicos
            _nameController.text = data['name'] ?? '';
            _emailController.text = data['email'] ?? '';
            _cnpjController.text = data['cnpj'] ?? '';
            _phoneController.text = data['phone'] ?? '';

            // Endereço
            if (data['address'] != null) {
              final address = data['address'] as Map<String, dynamic>;
              _streetController.text = address['street'] ?? '';
              _numberController.text = address['number'] ?? '';
              _complementController.text = address['complement'] ?? '';
              _districtController.text = address['district'] ?? '';
              _cityController.text = address['city'] ?? '';
              _stateController.text = address['state'] ?? '';
              _zipCodeController.text = address['zipCode'] ?? '';
            }

            // Operacionais
            _baseController.text = data['base']?.toString() ?? '';
            _kmController.text = data['km']?.toString() ?? '';
            _maxkmController.text = data['maxkm']?.toString() ?? '';
            _minkmController.text = data['minkm']?.toString() ?? '';
            _prazoentregaController.text = data['prazoentrega'] ?? '';
            _aberturaController.text = data['abertura'] ?? '';
            _fechamentoController.text = data['fechamento'] ?? '';

            // Booleanos
            _vet = data['vet'] ?? false;
            _cut = data['cut'] ?? false;
            _ht = data['ht'] ?? false;
            _shop = data['shop'] ?? false;
            _delivery = data['delivery'] ?? true;
            _active = data['active'] ?? false;
            _aceiteContrato = data['aceite_contrato'] ?? false;

            // Dias de folga
            _daysoff = List<String>.from(data['daysoff'] ?? []);

            _isLoading = false;
          });
        } else {
          print('Documento não existe no Firestore'); // Debug
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Erro ao carregar dados da empresa: $e');
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
      print('Usuário sem companyID cadastrado'); // Debug
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para selecionar imagens da galeria
  Future<void> _selectImages() async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((xFile) => File(xFile.path)).toList();
      });
    }
  }

  // Método para selecionar logo
  Future<void> _selectLogo() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  // Método para selecionar contrato social
  Future<void> _selectContratoSocial() async {
    // Implementar seleção de arquivo PDF/imagem
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _contratoSocialFile = File(pickedFile.path);
      });
    }
  }

  // Método para selecionar documentos dos sócios
  Future<void> _selectDocumentosSocios() async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _documentosSociosFiles =
            pickedFiles.map((xFile) => File(xFile.path)).toList();
      });
    }
  }

  Future<void> _saveCompany() async {
    if (_formKey.currentState!.validate()) {
      if (!_aceiteContrato) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('É necessário aceitar os termos e condições')));
        return;
      }
      try {
        // Referência para a coleção "company" no Firestore
        final companyRef = FirebaseFirestore.instance.collection('companys');

        // Criar objeto Address
        final address = Address(
          street: _streetController.text,
          number: _numberController.text,
          complement: _complementController.text,
          district: _districtController.text,
          city: _cityController.text,
          state: _stateController.text,
          zipCode: _zipCodeController.text,
        );

        // Upload de documentos
        List<String> documentUrls = [];
        if (_contratoSocialFile != null) {
          final contratoUrl =
              await _uploadSingleFile(_contratoSocialFile!, 'contratos');
          if (contratoUrl != null) documentUrls.add(contratoUrl);
        }
        documentUrls.addAll(await _uploadDocumentosSocios());

        // Dados da company conforme modelo
        final companyData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'cnpj': _cnpjController.text,
          'phone': _phoneController.text,
          'address': address.toMap(),
          'vet': _vet,
          'cut': _cut,
          'ht': _ht,
          'shop': _shop,
          'delivery': _delivery,
          'active': _active,
          'aceite_contrato': _aceiteContrato,
          'base': _baseController.text.isNotEmpty
              ? double.tryParse(_baseController.text)
              : null,
          'km': _kmController.text.isNotEmpty
              ? double.tryParse(_kmController.text)
              : null,
          'maxkm': _maxkmController.text.isNotEmpty
              ? double.tryParse(_maxkmController.text)
              : null,
          'minkm': _minkmController.text.isNotEmpty
              ? double.tryParse(_minkmController.text)
              : null,
          'prazoentrega': _prazoentregaController.text.isNotEmpty
              ? _prazoentregaController.text
              : null,
          'abertura': _aberturaController.text.isNotEmpty
              ? _aberturaController.text
              : null,
          'fechamento': _fechamentoController.text.isNotEmpty
              ? _fechamentoController.text
              : null,
          'daysoff': _daysoff,
          'images': await _uploadImages(),
          'documents': documentUrls,
        };

        // Salva ou atualiza os dados no Firestore
        if (_companyId != null && _companyId!.isNotEmpty) {
          // Atualiza empresa existente
          await companyRef.doc(_companyId).update(companyData);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Negócio Pet atualizado com sucesso!')));
        } else {
          // Cria nova empresa
          final docRef = await companyRef.add(companyData);
          _companyId = docRef.id;

          // Atualiza o companyID no usuário
          final userManager = context.read<UserManager>();
          if (userManager.userapp != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userManager.userapp!.id)
                .update({'companyID': _companyId});
          }

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Negócio Pet cadastrado com sucesso!')));
        }

        // Limpa o formulário (opcional)
        _formKey.currentState?.reset();
        setState(() {
          _images = [];
          _logoFile = null;
          _contratoSocialFile = null;
          _documentosSociosFiles = [];
          _vet = false;
          _cut = false;
          _ht = false;
          _shop = false;
          _delivery = true;
          _active = false;
          _aceiteContrato = false;
          _daysoff = [];
        });

        // Navega de volta para a tela inicial
        context.read<PageManager>().setPage(0);
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar company: $e')));
      }
    }
  }

  // Método para fazer upload das imagens para o Firebase Storage
  Future<List<String>> _uploadImages() async {
    final List<String> imageUrls = [];

    for (final file in _images) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('company_images/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = await storageRef.putFile(file);
        final downloadURL = await uploadTask.ref.getDownloadURL();
        imageUrls.add(downloadURL);
      } catch (e) {
        // Trate erros de upload aqui
        print('Erro ao fazer upload da imagem: $e');
      }
    }

    return imageUrls;
  }

  // Método para fazer upload de um único arquivo
  Future<String?> _uploadSingleFile(File file, String folder) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('company_$folder/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = await storageRef.putFile(file);
      final downloadURL = await uploadTask.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Erro ao fazer upload do arquivo: $e');
      return null;
    }
  }

  // Método para fazer upload dos documentos dos sócios
  Future<List<String>> _uploadDocumentosSocios() async {
    final List<String> documentUrls = [];

    for (final file in _documentosSociosFiles) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
            'company_documentos_socios/${DateTime.now().millisecondsSinceEpoch}');
        final uploadTask = await storageRef.putFile(file);
        final downloadURL = await uploadTask.ref.getDownloadURL();
        documentUrls.add(downloadURL);
      } catch (e) {
        print('Erro ao fazer upload do documento: $e');
      }
    }

    return documentUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      key: _scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 255, 111, 0),
      body: Column(
        children: [
          // AppBar customizada com fundo 100% opaco
          Material(
            elevation: 4,
            shadowColor: Colors.black26,
            child: Container(
              color: const Color.fromARGB(255, 255, 111, 0),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _companyId != null
                              ? 'Editar Negócio Pet'
                              : 'Cadastro de Negócio Pet',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.home, color: Colors.white),
                        onPressed: () {
                          context.read<PageManager>().setPage(0);
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Conteúdo scrollável
          Expanded(
            child: _isLoading
                ? Container(
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
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(
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
                    child: SingleChildScrollView(
                      // Permite rolagem se o conteúdo for longo
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        margin: const EdgeInsets.all(0),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Nome Fantasia',
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
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Campo obrigatório';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
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
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Campo obrigatório';
                                    }
                                    // Adicione validação de email se necessário
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                CelularField(
                                  controller: _phoneController,
                                ),
                                const SizedBox(height: 16),
                                CnpjField(controller: _cnpjController),
                                const SizedBox(height: 16),

                                // Campos de Endereço (seguindo modelo Address)
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        controller: _streetController,
                                        decoration: InputDecoration(
                                          labelText: 'Rua/Logradouro',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2),
                                          ),
                                        ),
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Campo obrigatório';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 1,
                                      child: TextFormField(
                                        controller: _numberController,
                                        decoration: InputDecoration(
                                          labelText: 'Número',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2),
                                          ),
                                        ),
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Campo obrigatório';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Campo Complemento
                                TextFormField(
                                  controller: _complementController,
                                  decoration: InputDecoration(
                                    labelText: 'Complemento (opcional)',
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
                                ),
                                const SizedBox(height: 16),

                                // Campo Bairro
                                TextFormField(
                                  controller: _districtController,
                                  decoration: InputDecoration(
                                    labelText: 'Bairro',
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
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Campo obrigatório';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                    height:
                                        16), // Campos Cidade e Estado na mesma linha
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller: _cityController,
                                        decoration: InputDecoration(
                                          labelText: 'Cidade',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2),
                                          ),
                                        ),
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Campo obrigatório';
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
                                        decoration: InputDecoration(
                                          labelText: 'Estado',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2),
                                          ),
                                        ),
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return 'Campo obrigatório';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Campo CEP
                                TextFormField(
                                  controller: _zipCodeController,
                                  decoration: InputDecoration(
                                    labelText: 'CEP',
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
                                  keyboardType: TextInputType.number,
                                  validator: (text) {
                                    if (text == null || text.isEmpty) {
                                      return 'Campo obrigatório';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Seção Configurações Operacionais
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.cyan[300]!),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Configurações Operacionais',
                                      style: TextStyle(
                                        color: Colors.cyan[800],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Horários de funcionamento
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _aberturaController,
                                        decoration: InputDecoration(
                                          labelText: 'Horário de Abertura',
                                          hintText: '08:00',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _fechamentoController,
                                        decoration: InputDecoration(
                                          labelText: 'Horário de Fechamento',
                                          hintText: '18:00',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Configurações de preço e entrega
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _baseController,
                                        decoration: InputDecoration(
                                          labelText: 'Taxa Base (R\$)',
                                          hintText: '15.00',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2),
                                          ),
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _kmController,
                                        decoration: InputDecoration(
                                          labelText: 'Valor por KM (R\$)',
                                          hintText: '2.50',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2),
                                          ),
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Limites de quilometragem
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _minkmController,
                                        decoration: InputDecoration(
                                          labelText: 'KM Mínimo',
                                          hintText: '1',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _maxkmController,
                                        decoration: InputDecoration(
                                          labelText: 'KM Máximo',
                                          hintText: '50',
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 2),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Prazo de entrega
                                TextFormField(
                                  controller: _prazoentregaController,
                                  decoration: InputDecoration(
                                    labelText: 'Prazo de Entrega',
                                    hintText: 'Ex: 30-45 minutos',
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
                                ),
                                const SizedBox(height: 16),

                                // Checkbox para ativar empresa
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: CheckboxListTile(
                                    title: const Text(
                                      'Empresa Ativa',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Marque para ativar a empresa após cadastro',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    value: _active,
                                    activeColor: Colors.green,
                                    onChanged: (value) =>
                                        setState(() => _active = value!),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Checkbox para aceite contratual
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: CheckboxListTile(
                                    title: const Text(
                                      'Aceito os Termos e Condições',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Obrigatório para finalizar o cadastro',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    value: _aceiteContrato,
                                    activeColor: Colors.red,
                                    onChanged: (value) => setState(
                                        () => _aceiteContrato = value!),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Seção Dias de Folga
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.indigo[300]!),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Dias de Funcionamento',
                                      style: TextStyle(
                                        color: Colors.indigo[800],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selecione os dias em que a empresa NÃO funciona:',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          'Domingo',
                                          'Segunda',
                                          'Terça',
                                          'Quarta',
                                          'Quinta',
                                          'Sexta',
                                          'Sábado'
                                        ].map((day) {
                                          final isSelected =
                                              _daysoff.contains(day);
                                          return FilterChip(
                                            label: Text(day),
                                            selected: isSelected,
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected) {
                                                  _daysoff.add(day);
                                                } else {
                                                  _daysoff.remove(day);
                                                }
                                              });
                                            },
                                            selectedColor: Colors.red[100],
                                            checkmarkColor: Colors.red[700],
                                            backgroundColor: Colors.grey[100],
                                            labelStyle: TextStyle(
                                              color: isSelected
                                                  ? Colors.red[700]
                                                  : Colors.grey[700],
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.green[300]!),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Tipos de Negócios',
                                      style: TextStyle(
                                        color: Colors.green[800],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: CheckboxListTile(
                                    title: const Text(
                                      'Veterinário',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    value: _vet,
                                    activeColor: Colors.white,
                                    checkColor: Theme.of(context).primaryColor,
                                    onChanged: (value) =>
                                        setState(() => _vet = value!),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: CheckboxListTile(
                                    title: const Text(
                                      'Banho e Tosa',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    value: _cut,
                                    activeColor: Colors.white,
                                    checkColor: Theme.of(context).primaryColor,
                                    onChanged: (value) =>
                                        setState(() => _cut = value!),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: CheckboxListTile(
                                    title: const Text(
                                      'Hotel',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    value: _ht,
                                    activeColor: Colors.white,
                                    checkColor: Theme.of(context).primaryColor,
                                    onChanged: (value) =>
                                        setState(() => _ht = value!),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: CheckboxListTile(
                                    title: const Text(
                                      'Shop',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    value: _shop,
                                    activeColor: Colors.white,
                                    checkColor: Theme.of(context).primaryColor,
                                    onChanged: (value) =>
                                        setState(() => _shop = value!),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: CheckboxListTile(
                                    title: const Text(
                                      'Delivery',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    value: _delivery,
                                    activeColor: Colors.white,
                                    checkColor: Theme.of(context).primaryColor,
                                    onChanged: (value) =>
                                        setState(() => _delivery = value!),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Seção Logo
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
                                      'Logo da Empresa',
                                      style: TextStyle(
                                        color: Colors.blue[800],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Upload Logo
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _selectLogo,
                                        icon: Icon(Icons.image,
                                            color:
                                                Theme.of(context).primaryColor),
                                        label: Text(
                                          'Selecionar Logo',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[100],
                                          elevation: 0,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _logoFile != null
                                          ? Container(
                                              margin: const EdgeInsets.all(8),
                                              child: Image.file(
                                                _logoFile!,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                'Nenhum logo selecionado',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Seção para upload de imagens do estabelecimento
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
                                      'Fotos do Estabelecimento',
                                      style: TextStyle(
                                        color: Colors.purple[800],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: _selectImages,
                                        icon: Icon(Icons.photo_library,
                                            color:
                                                Theme.of(context).primaryColor),
                                        label: Text(
                                          'Selecionar Fotos do Estabelecimento',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[100],
                                          elevation: 0,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _images.isNotEmpty
                                          ? Container(
                                              padding: const EdgeInsets.all(8),
                                              child: Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: _images.map((image) {
                                                  return ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.file(
                                                      image,
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                'Nenhuma foto selecionada',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Seção Documentos
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
                                      'Documentos Necessários',
                                      style: TextStyle(
                                        color: Colors.orange[800],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Upload Contrato Social
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Contrato Social',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: _selectContratoSocial,
                                        icon: Icon(Icons.description,
                                            color:
                                                Theme.of(context).primaryColor),
                                        label: Text(
                                          'Selecionar Contrato Social',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[100],
                                          elevation: 0,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _contratoSocialFile != null
                                          ? Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.green[300]!),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.check_circle,
                                                      color: Colors.green[600]),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Contrato Social Selecionado',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.green[800]),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                'Nenhum contrato social selecionado',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),

                                // Upload Documentos dos Sócios
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Documentos dos Sócios',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: _selectDocumentosSocios,
                                        icon: Icon(Icons.folder_shared,
                                            color:
                                                Theme.of(context).primaryColor),
                                        label: Text(
                                          'Selecionar Documentos dos Sócios',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[100],
                                          elevation: 0,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _documentosSociosFiles.isNotEmpty
                                          ? Container(
                                              margin: const EdgeInsets.all(8),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.green[300]!),
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.check_circle,
                                                          color: Colors
                                                              .green[600]),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '${_documentosSociosFiles.length} documento(s) selecionado(s)',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .green[800]),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                'Nenhum documento dos sócios selecionado',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await _saveCompany();
                                    },
                                    icon: Icon(Icons.save, color: Colors.white),
                                    label: Text(
                                      'Cadastrar Negócio Pet',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
