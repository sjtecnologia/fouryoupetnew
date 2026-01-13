// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';

class Userapp {
  Userapp({
    this.name,
    this.email,
    this.password,
    this.confirmPassword,
    this.cpf,
    this.id,
    this.companyID,
    this.celular,
    this.checked = false,
  });

  Userapp.findUserByID(String? id);
  Userapp.findUserByCompanyID(String? cpid);

  Userapp.fromDocument(DocumentSnapshot document) {
    if (document.data() != null) {
      Map<String, dynamic> dataMap = document.data() as Map<String, dynamic>;

      id = document.id;

      // Tentar diferentes formas de ler o nome
      if (dataMap.containsKey('name')) {
        name = dataMap['name'] as String?;
      } else if (dataMap.containsKey('nome')) {
        name = dataMap['nome'] as String?;
      }

      if (dataMap.containsKey('email')) {
        email = dataMap['email'] as String?;
      }

      if (dataMap.containsKey('address')) {
        try {
          address = (dataMap['address'] as List)
              .map((add) => Address.fromMap(add))
              .toList();
        } catch (e) {
          // Erro ao carregar endereços
        }
      }

      if (dataMap.containsKey('cpf')) {
        cpf = dataMap['cpf'] as String?;
      }

      if (dataMap.containsKey('celular')) {
        celular = dataMap['celular'] as String?;
      }

      if (dataMap.containsKey('companyID')) {
        companyID = dataMap['companyID'] as String?;
      }

      if (dataMap.containsKey('checked')) {
        checked = dataMap['checked'] as bool?;
      }

      if (dataMap.containsKey('referralCode')) {
        referralCode = dataMap['referralCode'] as String?;
      }

      if (dataMap.containsKey('referredBy')) {
        referredBy = dataMap['referredBy'] as String?;
      }

      if (dataMap.containsKey('hasCompletedFirstPurchase')) {
        hasCompletedFirstPurchase =
            dataMap['hasCompletedFirstPurchase'] as bool?;
      }
    }
  }
  String? id;
  String? name;
  String? email;
  String? cpf;
  String? celular;
  String? password;
  String? companyID;

  String? confirmPassword;

  bool admin = false;
  bool? checked = false;

  // Sistema de indicação de amigos
  String? referralCode; // Código único do usuário para indicar
  String? referredBy; // ID do usuário que indicou este
  bool? hasCompletedFirstPurchase = false; // Controla bônus de indicação

  List<Address>? address;

  CartManager? cartManager;

  Userapp clone() {
    return Userapp(
      id: id,
      name: name,
      companyID: companyID,
      email: email,
      password: password,
      celular: celular,
      checked: checked = false,
    );
  }

  Userapp.fromMap(Map<String, dynamic> map) {
    name = map['name'] as String?;
    email = map['type'] as String?;
    celular = map['celular'] as String?;
    checked = map['checked'] as bool;
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  DocumentReference get firestoreRef => firestore.doc('users/$id');
  DocumentReference get firestoreAdmin => firestore.doc('admins/$id');

  CollectionReference get cartReference => firestoreRef.collection('cart');

  CollectionReference get tokenReference => firestoreRef.collection('tokens');

  Stream<String>? _tokenRefreshSub;

  // Limpa todos os docs da subcoleção tokens
  Future<void> _clearAllTokens() async {
    final snap = await tokenReference.get();
    if (snap.docs.isEmpty) return;

    // Lida com lotes (batch) para evitar limites, mesmo que improvável ter muitos
    WriteBatch batch = firestore.batch();
    int count = 0;
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
      count++;
      if (count == 450) {
        await batch.commit();
        batch = firestore.batch();
        count = 0;
      }
    }
    if (count > 0) {
      await batch.commit();
    }
  }

  // Controle de debounce para evitar múltiplas chamadas
  static DateTime? _lastTokenRefresh;
  static const _tokenRefreshCooldown = Duration(seconds: 10);

  // Solicita permissão quando aplicável
  Future<void> _ensureNotificationPermission() async {
    // iOS precisa pedir, Android 13+ pode precisar (via Manifest/perm handler).
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (kDebugMode) {
      print('Notification permission status: ${settings.authorizationStatus}');
    }
  }

  // Atualiza o token atual: limpa a coleção e grava o novo token como doc.id
  Future<void> refreshDeviceToken() async {
    if (id == null) return; // precisa do uid

    // Verifica se já foi chamado recentemente
    final now = DateTime.now();
    if (_lastTokenRefresh != null &&
        now.difference(_lastTokenRefresh!) < _tokenRefreshCooldown) {
      if (kDebugMode) {
        print(
            '⏭️ Token refresh ignorado - cooldown ativo (${now.difference(_lastTokenRefresh!).inSeconds}s desde última chamada)');
      }
      return;
    }

    _lastTokenRefresh = now;
    if (kDebugMode) print('🔄 Iniciando refresh do token FCM...');

    await _ensureNotificationPermission();

    String? fcmToken;

    if (Platform.isIOS) {
      String? apnsToken;
      for (int i = 0; i < 5; i++) {
        // Tenta até 5 vezes
        try {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) {
            if (kDebugMode)
              print('APNs token obtido após ${i + 1} tentativas.');
            break; // APNs token obtido, sai do loop
          }
        } catch (e) {
          if (kDebugMode)
            print('Erro ao tentar obter APNs token na tentativa ${i + 1}: $e');
        }
        await Future.delayed(
            const Duration(seconds: 2)); // Espera 2 segundos antes de re-tentar
      }
      if (apnsToken == null) {
        if (kDebugMode)
          print(
              'Falha em obter o APNs token após múltiplas tentativas. O token FCM pode falhar.');
      }
    }

    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      if (kDebugMode) print('Erro ao obter token FCM: $e');
      // Captura o erro 'apns-token-not-set' se a tentativa de obter o APNs token falhou
    }

    if (fcmToken == null) {
      if (kDebugMode) print('Token FCM é nulo, não pode ser salvo.');
      return; // Token não obtido, encerra o método
    }

    if (kDebugMode) print('Current FCM token: $fcmToken');

    // final token = await FirebaseMessaging.instance.getToken();
    // if (kDebugMode) print('Current FCM token: $token');

    // Zera a coleção antes de inserir o novo token
    await _clearAllTokens();

    if (fcmToken != null) {
      await tokenReference.doc(fcmToken).set({
        'token': fcmToken,
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      });
      if (kDebugMode) print('✅ Token FCM salvo com sucesso no Firestore');
    }
  }

  // Inicia listener para atualização de token (rotação do FCM)
  void startTokenRefreshListener() {
    // Evita múltiplas inscrições
    _tokenRefreshSub ??= FirebaseMessaging.instance.onTokenRefresh
        .asBroadcastStream()
        .map((t) => t);

    _tokenRefreshSub!.listen((newToken) async {
      if (kDebugMode) print('FCM onTokenRefresh: $newToken');
      if (id == null) return;

      // Zera a coleção e salva somente o novo token
      await _clearAllTokens();
      await tokenReference.doc(newToken).set({
        'token': newToken,
        'updatedAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      });
    });
  }

  Future<void> saveToken() => refreshDeviceToken();

  Future<void> saveData() async {
    await firestoreRef.set(toMap());
    if (companyID != null) await firestoreAdmin.set(toMapadm());
  }

  List<Map<String, dynamic>> exportAddressList() {
    return address!.map((address) => address.toMap()).toList();
  }

  CollectionReference get groupReference => firestoreRef.collection('messeges');

  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    id = groupId;
    groupReference.add(chatMessageData);
  }

  Map<String, dynamic> toMapadm() {
    final retorno = {
      'user': id,
      'companyID': companyID,
    };
    return retorno;
  }

  Map<String, dynamic> toMap() {
    final retorno = {
      'name': name,
      'email': email,
      'companyID': companyID,
      if (address != null) 'address': exportAddressList(),
      if (cpf != null) 'cpf': cpf,
      if (celular != null) 'celular': celular,
      'checked': checked,
      if (referralCode != null) 'referralCode': referralCode,
      if (referredBy != null) 'referredBy': referredBy,
      'hasCompletedFirstPurchase': hasCompletedFirstPurchase ?? false,
    };
    return retorno;
  }

  void setAddress(Address address) {
    saveData();
  }

  void setCheckedAddress(bool check, int index) {
    if (index >= 0) {
      address![index].checked = check;
    } else {
      for (var i = 0; i < address!.length; i++) {
        address![i].checked = false;
      }
      address!.last.checked = check;
    }

    saveData();
  }

  void setCpf(String? cpf) {
    this.cpf = cpf;
    saveData();
  }

  void setCelular(String? celular) {
    this.celular = celular;
    saveData();
  }

  void setChequed(bool cheched) {
    this.checked = checked;
    saveData();
  }

  // Future<void> saveToken() async {
  //   final token = await FirebaseMessaging.instance.getToken();
  //   if (kDebugMode) print(token);

  //   tokenReference.doc(token).set({
  //     'token': token,
  //     'updatedAt': FieldValue.serverTimestamp(),
  //     'platform': Platform.operatingSystem,
  //   });
  // }
}
