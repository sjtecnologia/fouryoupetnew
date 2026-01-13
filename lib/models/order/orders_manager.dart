import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/user/userapp.dart';
import 'order.dart' as od;

class OrdersManager extends ChangeNotifier {
  OrdersManager() {
    qtdMessage();
  }
  Userapp? user;

  String? orderId;
  int? qtdmsg = 0;

  List<od.Order> orders = [];
  od.Order order = new od.Order();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference get firestoreRef =>
      firestore.collection('orders').doc(orderId);
  CollectionReference get groupReference => firestoreRef.collection('messeges');

  StreamSubscription? _subscription;

  void updateUser(Userapp? user) {
    this.user = user;
    orders.clear();

    _subscription?.cancel();
    if (user != null) {
      _listenToOrders();
    }
  }

  Future<void> updateStatusMessage(String orderId, String userName) async {
    final ordersCollection = FirebaseFirestore.instance.collection('orders');

    final querySnapshot = await ordersCollection.get();

    for (final orderDoc in querySnapshot.docs.where((e) => e.id == orderId)) {
      final messagesCollection = orderDoc.reference
          .collection('messeges')
          .where('lido', isEqualTo: false)
          .where('sender', isNotEqualTo: userName);
      final messagesQuerySnapshot = await messagesCollection.get();

      for (final messageDoc in messagesQuerySnapshot.docs) {
        final data = messageDoc.data();
        if (data.containsKey('lido')) {
          // Adicione o campo "lido" com o valor inicial "false"

          await messageDoc.reference.set({
            'lido': true,
          }, SetOptions(merge: true));
        }
      }
    }
  }

  Future<void> adicionarCampoLido() async {
    final ordersCollection = FirebaseFirestore.instance.collection('orders');

    final querySnapshot = await ordersCollection.get();

    for (final orderDoc in querySnapshot.docs) {
      final messagesCollection = orderDoc.reference.collection('messeges');
      final messagesQuerySnapshot = await messagesCollection.get();

      for (final messageDoc in messagesQuerySnapshot.docs) {
        final data = messageDoc.data();
        if (!data.containsKey('lido')) {
          // Adicione o campo "lido" com o valor inicial "false"
          await messageDoc.reference.set({
            'lido': false,
          }, SetOptions(merge: true));
        }
      }
    }

    print('Campos "lido" adicionados aos documentos existentes.');
  }

  // getting the chats
  getChats(String groupId) async {
    orderId = groupId;
    return groupReference.orderBy("time").snapshots();
  }

  Future<int> getqtChats(String groupId) async {
    orderId = groupId;
    var teste = await groupReference
        .where('lido', isEqualTo: false)
        .where('sender', isNotEqualTo: user?.name)
        .get();
    return teste.size;
  }

  void _listenToOrders() {
    _subscription = firestore
        .collection('orders')
        .where('user', isEqualTo: user!.id)
        .orderBy('date', descending: false)
        .snapshots()
        .listen((event) {
      orders.clear();
      for (final doc in event.docs) {
        orders.add(od.Order.fromDocument(doc));
      }

      notifyListeners();
    });
  }

  void listenToOrderID(String id) {
    _subscription = firestore
        .collection('orders')
        .where('ID', isEqualTo: id)
        .snapshots()
        .listen((event) {
      orders.clear();
      for (final doc in event.docs) {
        orders.add(od.Order.fromDocument(doc));
      }
      notifyListeners();
    });
  }

  Future<int?>? qtdMessage() async {
    if (user != null) await _contarMensagensNaoLidas();

    return qtdmsg;
  }

  Future<void> _contarMensagensNaoLidas() async {
    qtdmsg = 0;
    final ordersCollection = FirebaseFirestore.instance.collection('orders');

    final querySnapshot =
        await ordersCollection.where('user', isEqualTo: user!.id).get();

    for (final orderDoc in querySnapshot.docs) {
      final messagesCollection = orderDoc.reference
          .collection('messeges')
          .where('lido', isEqualTo: false)
          .where('sender', isNotEqualTo: user?.name);
      final messagesQuerySnapshot = await messagesCollection.get();
      if (messagesQuerySnapshot.size > 0) {
        qtdmsg = qtdmsg! + messagesQuerySnapshot.size;
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}
