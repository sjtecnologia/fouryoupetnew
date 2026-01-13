// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diacritic/diacritic.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:fouryoupet/models/address/address.dart';

class Company extends ChangeNotifier {
  Company({
    this.name,
    this.id,
    this.email,
    this.images,
    this.documents,
    this.cnpj,
    this.phone,
    this.address,
    this.vet,
    this.cut,
    this.ht,
    this.shop,
    this.daysoff,
    this.base,
    this.km,
    this.maxkm,
    this.minkm,
    this.delivery,
    this.active,
    this.aceite_contrato,
    this.device,
    this.prazoentrega,
    this.abertura,
    this.fechamento,
    // ✅ CAMPOS DE ASSINATURA
    this.subscriptionId,
    this.subscriptionStatus,
    this.subscription,
    this.customer_id,
  }) {
    daysoff = daysoff ?? [];
    images = images ?? [];
    documents = documents ?? [];
  }

  // ✅ ADICIONAR ESTES CAMPOS DE VOLTA (TEMPORÁRIO)
  Company? _selectedCompany;
  Company? get selectedCompany => _selectedCompany;

  set selectedCompany(Company? value) {
    _selectedCompany = value;
    notifyListeners();
  }

  void setSelected(Company company) {
    _selectedCompany = company;
    notifyListeners();
  }

  // ✅ CONSTRUTOR fromDocument COMPLETAMENTE ATUALIZADO
  Company.fromDocument(DocumentSnapshot document) {
    try {
      id = document.id;

      // ✅ ACESSO SEGURO AOS DADOS
      final data = document.data() as Map<String, dynamic>?;

      if (data == null) {
        // Documento vazio - inicializar com valores padrão
        _initializeDefaults();
        return;
      }

      // ✅ CAMPOS BÁSICOS DA EMPRESA
      name = data['name'] as String?;
      email = data['email'] as String?;
      cnpj = data['cnpj'] as String?;
      phone = data['phone'] as String?;

      // ✅ CAMPOS BOOLEANOS COM VALORES PADRÃO
      vet = data['vet'] as bool? ?? false;
      cut = data['cut'] as bool? ?? false;
      ht = data['ht'] as bool? ?? false;
      shop = data['shop'] as bool? ?? false;
      active = data['active'] as bool? ?? false;
      delivery = data['delivery'] as bool? ?? true;
      aceite_contrato = data['aceite_contrato'] as bool? ?? false;
      device = data['device'] as String?;

      // ✅ CAMPOS NUMÉRICOS
      base = data['base'] as num?;
      km = data['km'] as num?;
      maxkm = data['maxkm'] as num?;
      minkm = data['minkm'] as num?;

      // ✅ CAMPOS DE TEXTO
      prazoentrega = data['prazoentrega'] as String?;
      abertura = data['abertura'] as String?;
      fechamento = data['fechamento'] as String?;

      // ✅ LISTAS COM VALORES PADRÃO
      images = List<String>.from(data['images'] as List<dynamic>? ?? []);
      daysoff = List<String>.from(data['daysoff'] as List<dynamic>? ?? []);
      documents = List<String>.from(data['documents'] as List<dynamic>? ?? []);

      // ✅ ENDEREÇO
      if (data.containsKey('address') && data['address'] != null) {
        address = Address.fromMap(data['address'] as Map<String, dynamic>);
      }

      // ✅ CAMPOS DE ASSINATURA COM ACESSO SEGURO
      subscriptionId = data['subscriptionId'] as String?;
      subscriptionStatus = data['subscriptionStatus'] as String?;
      subscription = data['subscription'] as Map<String, dynamic>?;
      customer_id = data['customer_id'] as String?;
    } on Exception catch (e, s) {
      debugPrint('Erro ao carregar empresa do Firestore: $e\n$s');
      _initializeDefaults();
    }
  }

  // ✅ CONSTRUTOR fromMap COMPLETAMENTE ATUALIZADO
  Company.fromMap(Map<String, dynamic> map) {
    id = map['id'] as String?;
    name = map['name'] as String?;
    email = map['email'] as String?;
    cnpj = map['cnpj'] as String?;
    phone = map['phone'] as String?;

    // ✅ CAMPOS BOOLEANOS COM VALORES PADRÃO
    vet = map['vet'] as bool? ?? false;
    cut = map['cut'] as bool? ?? false;
    ht = map['ht'] as bool? ?? false;
    shop = map['shop'] as bool? ?? false;
    active = map['active'] as bool? ?? false;
    delivery = map['delivery'] as bool? ?? true;
    aceite_contrato = map['aceite_contrato'] as bool? ?? false;
    device = map['device'] as String?;

    // ✅ CAMPOS NUMÉRICOS
    base = map['base'] as num?;
    km = map['km'] as num?;
    maxkm = map['maxkm'] as num?;
    minkm = map['minkm'] as num?;

    // ✅ CAMPOS DE TEXTO
    prazoentrega = map['prazoentrega'] as String?;
    abertura = map['abertura'] as String?;
    fechamento = map['fechamento'] as String?;

    // ✅ LISTAS COM VALORES PADRÃO
    images = List<String>.from(map['images'] as List<dynamic>? ?? []);
    daysoff = List<String>.from(map['daysoff'] as List<dynamic>? ?? []);
    documents = List<String>.from(map['documents'] as List<dynamic>? ?? []);

    // ✅ ENDEREÇO
    if (map.containsKey('address') && map['address'] != null) {
      address = Address.fromMap(map['address'] as Map<String, dynamic>);
    }

    // ✅ CAMPOS DE ASSINATURA
    subscriptionId = map['subscriptionId'] as String?;
    subscriptionStatus = map['subscriptionStatus'] as String?;
    subscription = map['subscription'] as Map<String, dynamic>?;
    customer_id = map['customer_id'] as String?;
  }

  // ✅ MÉTODO PARA INICIALIZAR VALORES PADRÃO
  void _initializeDefaults() {
    name = '';
    email = '';
    cnpj = '';
    phone = '';
    vet = false;
    cut = false;
    ht = false;
    shop = false;
    active = false;
    delivery = true;
    aceite_contrato = false;
    device = '';

    images = [];
    daysoff = [];
    documents = [];
  }

  // ✅ PROPRIEDADES DA EMPRESA
  String? id;
  String? name;
  String? email;
  String? cnpj;
  String? phone;
  bool? vet;
  bool? cut;
  bool? ht;
  bool? shop;
  num? base;
  num? km;
  num? maxkm;
  num? minkm;
  num? distancia; // Campo temporário para cálculos
  bool? active;
  bool? delivery;
  String? prazoentrega;
  String? abertura;
  String? fechamento;
  List<String>? daysoff;
  bool? aceite_contrato;
  String? device;

  // ✅ PROPRIEDADES DE MÍDIA
  List<String>? images;
  List<dynamic>? newImages; // Para upload de novas imagens
  List<String>? documents; // URLs dos documentos legais
  List<dynamic>? newDocuments; // Para upload de novos documentos

  // ✅ PROPRIEDADES DE ASSINATURA
  String? subscriptionId;
  String? subscriptionStatus;
  Map<String, dynamic>? subscription; // Dados completos da assinatura
  String? customer_id;

  // ✅ PROPRIEDADES DE CONTROLE
  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool admin = false; // Para controle de interface
  Address? address;

  // ✅ REFERÊNCIAS DO FIREBASE
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  DocumentReference get firestoreRef => firestore.doc('companys/$id');
  Reference get storageRef => storage.ref().child('companys').child(id!);
  CollectionReference get tokenReference => firestoreRef.collection('tokens');

  // Helpers para status
  bool get hasActiveSubscription =>
      subscriptionStatus == 'ACTIVE' || subscriptionStatus == 'TRIAL';
  bool get needsPaymentUpdate =>
      subscriptionStatus == 'SUSPENDED' ||
      subscriptionStatus == 'PAYMENT_METHOD_CHANGE';
  bool get isInactive =>
      subscriptionStatus == 'CANCELED' ||
      subscriptionStatus == 'EXPIRED' ||
      subscriptionStatus == 'INACTIVE';

  String get statusDisplay {
    switch (subscriptionStatus) {
      case 'ACTIVE':
        return 'Ativa';
      case 'SUSPENDED':
        return 'Suspensa';
      case 'CANCELED':
        return 'Cancelada';
      case 'TRIAL':
        return 'Período de Teste';
      case 'PAYMENT_METHOD_CHANGE':
        return 'Aguardando Atualização de Pagamento';
      case 'EXPIRED':
        return 'Expirada';
      default:
        return 'Inativa';
    }
  }

  Color get statusColor {
    switch (subscriptionStatus) {
      case 'ACTIVE':
        return Colors.green;
      case 'TRIAL':
        return Colors.blue;
      case 'SUSPENDED':
      case 'PAYMENT_METHOD_CHANGE':
        return Colors.orange;
      case 'CANCELED':
      case 'EXPIRED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ✅ FUNÇÃO PARA GERAR KEYWORDS DE BUSCA
  List<String> _generateKeywords(String text) {
    final words = removeDiacritics(text).toLowerCase().split(' ');
    final keywords = <String>[];
    for (var word in words) {
      for (var i = 0; i < word.length; i++) {
        for (var j = i + 1; j <= word.length; j++) {
          keywords.add(word.substring(i, j));
        }
      }
    }
    return keywords;
  }

  // ✅ MÉTODO SAVE COMPLETAMENTE ATUALIZADO
  Future<void> save() async {
    debugPrint('🔍 DEBUG: Salvando empresa...');
    debugPrint('🔍 DEBUG: ID antes de salvar: $id');
    debugPrint('🔍 DEBUG: Nome: $name');

    loading = true;

    try {
      // ✅ PREPARAR DADOS PRINCIPAIS
      final Map<String, dynamic> data = {
        'name': name,
        'phone': phone,
        'email': email,
        'vet': vet ?? false,
        'cut': cut ?? false,
        'ht': ht ?? false,
        'shop': shop ?? false,
        'base': base,
        'km': km,
        'maxkm': maxkm,
        'minkm': minkm,
        'delivery': delivery ?? true,
        'active': active ?? false,
        'aceite_contrato': aceite_contrato ?? false,
        'device': device, 
        'abertura': abertura,
        'fechamento': fechamento,
        'keywords': name != null ? _generateKeywords(name!) : [],
      };

      // ✅ ADICIONAR CAMPOS OPCIONAIS
      if (prazoentrega != null) data['prazoentrega'] = prazoentrega;
      if (address != null) data['address'] = address!.toMap();
      if (cnpj != null) data['cnpj'] = cnpj;
      if (subscriptionId != null) data['subscriptionId'] = subscriptionId;
      if (subscriptionStatus != null)
        data['subscriptionStatus'] = subscriptionStatus;
      if (customer_id != null) data['customer_id'] = customer_id;

      // ✅ SALVAR OU ATUALIZAR DOCUMENTO PRINCIPAL
      if (id == null) {
        final docRef = await firestore.collection('companys').add(data);
        id = docRef.id;
        debugPrint('✅ DEBUG: Nova empresa criada com ID: $id');
      } else {
        await firestoreRef.set(data, SetOptions(merge: true));
        debugPrint('✅ DEBUG: Empresa atualizada com ID: $id');
      }

      // ✅ PROCESSAR DAYSOFF
      final List<String> updateDaysOff = [];
      if (daysoff != null) {
        updateDaysOff.addAll(daysoff!);
      }
      await firestoreRef.update({'daysoff': updateDaysOff});
      daysoff = updateDaysOff;

      // ✅ PROCESSAR IMAGES
      await _processImages();

      // ✅ PROCESSAR DOCUMENTS
      await _processDocuments();

      loading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ DEBUG: Erro ao salvar empresa: $e');
      loading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ✅ MÉTODO PARA PROCESSAR IMAGENS
  Future<void> _processImages() async {
    final List<String> updateImages = [];
    final List<String> currentImagesInModel = List<String>.from(images ?? []);

    if (newImages != null) {
      for (final imgItem in newImages!) {
        if (imgItem is String) {
          // Já é uma URL
          updateImages.add(imgItem);
        } else if (imgItem is File) {
          // É um novo arquivo para upload
          try {
            final UploadTask task = storageRef
                .child('images/${const Uuid().v1()}')
                .putFile(imgItem);
            final TaskSnapshot snapshot = await task;
            final String url = await snapshot.ref.getDownloadURL();
            updateImages.add(url);
          } catch (e) {
            debugPrint('Falha ao fazer upload da imagem ${imgItem.path}: $e');
          }
        }
      }
    }

    // Deletar imagens removidas
    for (final oldImageUrl in currentImagesInModel) {
      if (!updateImages.contains(oldImageUrl) &&
          oldImageUrl.contains('firebase')) {
        try {
          final ref = storage.refFromURL(oldImageUrl);
          await ref.delete();
          debugPrint('Imagem deletada: $oldImageUrl');
        } catch (e) {
          debugPrint('Falha ao deletar imagem $oldImageUrl: $e');
        }
      }
    }

    await firestoreRef.update({'images': updateImages});
    images = updateImages;
  }

  // ✅ MÉTODO PARA PROCESSAR DOCUMENTOS
  Future<void> _processDocuments() async {
    final List<String> updateDocuments = [];
    final List<String> currentDocumentsInModel =
        List<String>.from(documents ?? []);

    if (newDocuments != null) {
      for (final docItem in newDocuments!) {
        if (docItem is String) {
          // Já é uma URL
          updateDocuments.add(docItem);
        } else if (docItem is File) {
          // É um novo arquivo para upload
          try {
            final UploadTask task = storageRef
                .child('documents/${const Uuid().v1()}')
                .putFile(docItem);
            final TaskSnapshot snapshot = await task;
            final String url = await snapshot.ref.getDownloadURL();
            updateDocuments.add(url);
          } catch (e) {
            debugPrint(
                'Falha ao fazer upload do documento ${docItem.path}: $e');
          }
        }
      }
    }

    // Deletar documentos removidos
    for (final oldDocumentUrl in currentDocumentsInModel) {
      if (!updateDocuments.contains(oldDocumentUrl) &&
          oldDocumentUrl.contains('firebase')) {
        try {
          final ref = storage.refFromURL(oldDocumentUrl);
          await ref.delete();
          debugPrint('Documento deletado: $oldDocumentUrl');
        } catch (e) {
          debugPrint('Falha ao deletar documento $oldDocumentUrl: $e');
        }
      }
    }

    await firestoreRef.update({'documents': updateDocuments});
    documents = updateDocuments;
  }
  // Adicione estes getters na classe Company:

  // Getter para cor do status da assinatura
  Color get subscriptionStatusColor {
    if (subscriptionStatus == null) return Colors.grey;

    switch (subscriptionStatus?.toLowerCase()) {
      case 'active':
      case 'authorized':
        return Colors.green;
      case 'pending':
      case 'pending_payment':
        return Colors.orange;
      case 'cancelled':
      case 'expired':
        return Colors.red;
      case 'paused':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Getter para ícone do status da assinatura
  IconData get subscriptionStatusIcon {
    if (subscriptionStatus == null) return Icons.info_outline;

    switch (subscriptionStatus?.toLowerCase()) {
      case 'active':
      case 'authorized':
        return Icons.check_circle;
      case 'pending':
      case 'pending_payment':
        return Icons.access_time;
      case 'cancelled':
      case 'expired':
        return Icons.cancel;
      case 'paused':
        return Icons.pause_circle;
      default:
        return Icons.info_outline;
    }
  }

  // Getter para texto do status da assinatura
  String get subscriptionStatusText {
    if (subscriptionStatus == null) return 'Sem assinatura';

    switch (subscriptionStatus?.toLowerCase()) {
      case 'active':
        return 'Assinatura Ativa';
      case 'authorized':
        return 'Assinatura Autorizada';
      case 'pending':
        return 'Assinatura Pendente';
      case 'pending_payment':
        return 'Aguardando Pagamento';
      case 'cancelled':
        return 'Assinatura Cancelada';
      case 'expired':
        return 'Assinatura Expirada';
      case 'paused':
        return 'Assinatura Pausada';
      default:
        return 'Status: $subscriptionStatus';
    }
  }

  // Getter para data de fim da assinatura
  DateTime? get subscriptionEndDate {
    // Se você tiver um campo de data de fim, use-o aqui
    // Por enquanto, vou retornar null
    // Exemplo: return subscriptionEnd;
    return null;
  }

  // Getter para data formatada
  String get formattedSubscriptionEndDate {
    if (subscriptionEndDate == null) return '';

    final day = subscriptionEndDate!.day.toString().padLeft(2, '0');
    final month = subscriptionEndDate!.month.toString().padLeft(2, '0');
    final year = subscriptionEndDate!.year;

    return '$day/$month/$year';
  }

  // ✅ MÉTODO toMap ATUALIZADO
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'vet': vet ?? false,
      'cut': cut ?? false,
      'ht': ht ?? false,
      'shop': shop ?? false,
      'base': base,
      'km': km,
      'maxkm': maxkm,
      'minkm': minkm,
      'delivery': delivery ?? true,
      'active': active ?? false,
      'aceite_contrato': aceite_contrato ?? false,
      'device': device, 
      'abertura': abertura,
      'fechamento': fechamento,
      'keywords': name != null ? _generateKeywords(name!) : [],
      'images': images ?? [],
      'documents': documents ?? [],
      'daysoff': daysoff ?? [],
      if (prazoentrega != null) 'prazoentrega': prazoentrega,
      if (address != null) 'address': address!.toMap(),
      if (cnpj != null) 'cnpj': cnpj,
      if (subscriptionId != null) 'subscriptionId': subscriptionId,
      if (subscriptionStatus != null) 'subscriptionStatus': subscriptionStatus,
      if (customer_id != null) 'customer_id': customer_id,
    };
  }

  // ✅ MÉTODOS AUXILIARES
  void setAddress(Address address) {
    this.address = address;
    notifyListeners();
  }

  void setCnpj(String? cnpj) {
    this.cnpj = cnpj;
    notifyListeners();
  }

  void setPhone(String? phone) {
    this.phone = phone;
    notifyListeners();
  }

  // ✅ MÉTODO PARA SALVAR TOKEN FCM
  Future<void> saveToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) debugPrint('FCM Token: $token');

    if (token == null || id == null) {
      debugPrint(
          'Não foi possível salvar o token: Token ou ID da empresa nulo.');
      return;
    }

    final docRef = tokenReference.doc(token);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      });
    } else {
      await docRef.set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      });
    }
  }

  // ✅ MÉTODO clone ATUALIZADO
  Company clone() {
    return Company(
      id: id,
      name: name,
      email: email,
      cnpj: cnpj,
      phone: phone,
      vet: vet,
      cut: cut,
      ht: ht,
      shop: shop,
      base: base,
      km: km,
      maxkm: maxkm,
      minkm: minkm,
      delivery: delivery,
      active: active,
      aceite_contrato: aceite_contrato,
      device: device,
      abertura: abertura,
      fechamento: fechamento,
      prazoentrega: prazoentrega,
      images: images != null ? List<String>.from(images!) : [],
      documents: documents != null ? List<String>.from(documents!) : [],
      daysoff: daysoff != null ? List<String>.from(daysoff!) : [],
      address: address, // Assumindo que Address tem método clone
      // ✅ CAMPOS DE ASSINATURA NO CLONE
      subscriptionId: subscriptionId,
      subscriptionStatus: subscriptionStatus,
      customer_id: customer_id,
    );
  }
}
