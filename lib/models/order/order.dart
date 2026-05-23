import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:fouryoupet/models/address/address.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';
import 'package:fouryoupet/models/cart/cart_product.dart';
import 'package:fouryoupet/models/company/company_manager.dart';
import 'package:fouryoupet/models/loyalty/loyalty_manager.dart';

import '../../helpers/send_email.dart';
import '../company/company.dart';
import '../product/product.dart';

enum Status { canceled, approval, preparing, transporting, delivered }

class Order {
  Order.fromCartManager(CartManager cartManager) {
    items = List.from(cartManager.items);
    price = cartManager.totalPrice;
    frete = cartManager.delivery == true ? cartManager.deliveryPrice : 0;
    userId = cartManager.user!.id;
    address = cartManager.userAddress;
    status = Status.approval;
    companyID = items!.first.companyID;
    payId = cartManager.payId;
    trocopara = cartManager.trocopara;
    discount = cartManager.discount?.toDouble();
    couponCode = cartManager.couponCode;
  }

  Order.fromDocument(DocumentSnapshot doc) {
    if (doc.data() != null) {
      orderId = doc.id;

      items = (doc.get('items') as List<dynamic>).map((e) {
        return CartProduct.fromMap(e as Map<String, dynamic>);
      }).toList();

      price = doc.get('price') as num?;
      frete = doc.get('frete') as num?;
      userId = doc.get('user') as String?;
      address = Address.fromMap(doc.get('address') as Map<String, dynamic>);
      date = doc.get('date') as Timestamp?;
      companyID = items!.first.companyID;
      status = Status.values[doc.get('status') as int];
      trocopara = doc.get('trocopara') as num?;
      payId = doc.get('payId') as String?;
      Map<String, dynamic> dataMap = doc.data() as Map<String, dynamic>;
      if (dataMap.containsKey('discount')) {
        discount = doc.get('discount') as double?;
      }
      if (dataMap.containsKey('couponCode')) {
        couponCode = doc.get('couponCode') as String?;
      }
    }
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  DocumentReference get firestoreRef =>
      firestore.collection('orders').doc(orderId);

  CollectionReference get groupReference => firestoreRef.collection('messeges');

  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    orderId = groupId;
    groupReference.add(chatMessageData);
  }

  void updateFromDocument(DocumentSnapshot doc) {
    status = Status.values[doc.get('status') as int];
  }

  Future<void> save() async {
    Company? company =
        await CompanyManager().findCompanyNameEndByID(companyID!);
    String? emailcompany = company!.email;
    String? namecompany = company.name;

    try {
      await firestore.collection('orders').doc(orderId).set({
        'items': items!.map((e) => e.toOrderItemMap()).toList(),
        'price': price,
        'frete': frete,
        'user': userId,
        'address': address!.toMap(),
        'status': status?.index ?? 1,
        'date': Timestamp.now(),
        'payId': payId,
        'companyID': companyID,
        'trocopara': trocopara,
        'discount': discount,
        'couponCode': couponCode,
      });
    } on Exception catch (e, s) {
      log('Erro ao gerar pedido', error: e, stackTrace: s);
      rethrow;
    }

    String? subject = 'Novo Pedido';
    String? message =
        'Novo Pedido de Número: ' + orderId! + ' recebido no App 4YouPet';
    try {
      if (namecompany != null && emailcompany != null) {
        sendEmail(
            name: namecompany.toUpperCase(),
            email: emailcompany,
            subject: subject,
            message: message);
      } else {
        sendEmail(
            name: 'Pedido $orderId' + 'fornecedor sem email',
            email: 'notificacoes@4youpet.app',
            subject: 'Erro ao enviar email',
            message: 'Erro ao enviar email de pedido');
      }
    } on Exception catch (e, s) {
      log('Erro ao enviar pedido', error: e, stackTrace: s);
    }
  }

  Function()? get back {
    return status!.index >= Status.transporting.index
        ? () {
            status = Status.values[status!.index - 1];
            firestoreRef.update({'status': status!.index});
          }
        : null;
  }

  Function()? get advance {
    return status!.index <= Status.transporting.index
        ? () {
            status = Status.values[status!.index + 1];
            firestoreRef.update({'status': status!.index});
          }
        : null;
  }

  Future<void> cancel() async {
    try {
      // await CieloPayment().cancel(payId);

      status = Status.canceled;
      await firestoreRef.update({'status': status!.index});
      await _incrementStock();

      // Remover pontos de fidelidade se foram adicionados
      await _removeLoyaltyPoints();
    } catch (e) {
      debugPrint('Erro ao cancelar: $e');
      return Future.error('Falha ao cancelar');
    }
  }

  Future<void> _removeLoyaltyPoints() async {
    try {
      debugPrint('🔍 Buscando pontos para remover do pedido: $orderId');

      // Buscar transação de pontos relacionada a este pedido
      final querySnapshot = await firestore
          .collection('points_transactions')
          .where('orderId', isEqualTo: orderId)
          .where('type', isEqualTo: 'earned')
          .get();

      debugPrint('📊 Transações encontradas: ${querySnapshot.docs.length}');

      if (querySnapshot.docs.isNotEmpty) {
        // Se encontrou pontos ganhos neste pedido, remover
        final transaction = querySnapshot.docs.first;
        final pointsEarned = transaction.get('points') as int;
        final userId = transaction.get('userId') as String;

        debugPrint('💰 Pontos a remover: $pointsEarned');
        debugPrint('👤 UserId: $userId');

        final success = await LoyaltyManager.removePointsStatic(
          userId: userId,
          points: pointsEarned,
          description: 'Estorno - Pedido $formattedId cancelado',
          orderId: orderId,
          metadata: {'reason': 'order_cancelled'},
        );

        if (success) {
          debugPrint(
              '✅ Pontos removidos com sucesso: $pointsEarned (Pedido $formattedId)');
        } else {
          debugPrint('❌ Falha ao remover pontos');
        }
      } else {
        debugPrint('ℹ️ Nenhum ponto encontrado para este pedido');
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao remover pontos de fidelidade: $e');
      // Não falhar o cancelamento se houver erro na remoção de pontos
    }
  }

  Future<void> _incrementStock() {
    return firestore.runTransaction((tx) async {
      final List<Product> productsToUpdate = [];
      //final List<Product> productsWithoutStock = [];

      for (final orderProduct in items!) {
        Product product;

        if (productsToUpdate.any((p) => p.id == orderProduct.productId)) {
          product = productsToUpdate
              .firstWhere((p) => p.id == orderProduct.productId);
        } else {
          final doc =
              await tx.get(firestore.doc('products/${orderProduct.productId}'));
          product = Product.fromDocument(doc);
        }

        orderProduct.product = product;

        final size = product.findSize(orderProduct.sizes)!;

        size.stock = size.stock! + orderProduct.quantity!;
        productsToUpdate.add(product);
      }

      for (final product in productsToUpdate) {
        tx.update(firestore.doc('products/${product.id}'),
            {'sizes': product.exportSizeList()});
      }
    });
  }

  String? orderId;

  String? get id => orderId;
  String? payId;
  String? username;

  List<CartProduct>? items;
  num? price;

  num? frete;

  String? userId;

  String? companyID;

  Address? address;

  Status? status;

  Timestamp? date;

  String get formattedId => '#${orderId!.padLeft(6, '0')}';

  String get statusText => getStatusText(status);
  num? trocopara;

  double? discount;
  String? couponCode;
  Order({
    this.orderId,
    this.payId,
    this.username,
    this.items,
    this.price,
    this.frete,
    this.userId,
    this.companyID,
    this.address,
    this.status,
    this.date,
    this.trocopara,
    this.discount,
    this.couponCode,
  });

  static String getStatusText(Status? status) {
    switch (status) {
      case Status.canceled:
        return 'Cancelado';
      case Status.approval:
        return 'Em aprovação';
      case Status.preparing:
        return 'Em preparação';
      case Status.transporting:
        return 'Em transporte';
      case Status.delivered:
        return 'Entregue';
      default:
        return '';
    }
  }

  @override
  String toString() {
    return 'Order{firestore: $firestore, orderId: $orderId, items: $items, price: $price, frete: $frete, userId: $userId, address: $address, date: $date, trocoparo $trocopara, discount $discount, couponCode $couponCode}';
  }
}
