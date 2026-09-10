import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';
import 'package:fouryoupet/models/couponcodes/couponcode_manager.dart';
import 'package:fouryoupet/models/order/order.dart' as od;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class CheckoutManager extends ChangeNotifier {
  late CartManager cartManager;

  bool _loading = false;
  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseFunctions functions =
      FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  // ignore: use_setters_to_change_properties
  void updateCart(CartManager cartManager) {
    this.cartManager = cartManager;
  }

  Future<void> checkout({
    Function? onStockFail,
    Function? onSuccess,
    Function? onPayFail,
    CouponCodeManager? couponManager,
  }) async {
    if (_loading) return;
    loading = true;

    try {
      if (cartManager.user?.id == null || cartManager.items.isEmpty) {
        throw StateError('Entre novamente e confira os itens do carrinho.');
      }

      final companyIds = cartManager.items
          .map((item) => item.companyID)
          .whereType<String>()
          .toSet();
      if (companyIds.length != 1) {
        throw StateError(
          'Finalize os produtos de um petshop por vez para pagar com segurança.',
        );
      }

      final callable = functions.httpsCallable('createMarketplaceCheckout');
      final result = await callable.call(<String, dynamic>{
        'companyId': companyIds.single,
        'clientRequestId': const Uuid().v4().replaceAll('-', ''),
        'items': cartManager.items
            .map((item) => <String, dynamic>{
                  'productId': item.productId,
                  'size': item.sizes,
                  'quantity': item.quantity,
                })
            .toList(),
        if (couponManager?.hasCouponApplied == true)
          'couponCode': couponManager?.cupomcode,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      final checkoutUrl = Uri.tryParse(data['checkoutUrl'] as String? ?? '');
      final orderId = data['orderId'] as String?;
      if (checkoutUrl == null || orderId == null) {
        throw StateError('O Mercado Pago não retornou um checkout válido.');
      }

      final opened = await launchUrl(
        checkoutUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        throw StateError('Não foi possível abrir o Mercado Pago.');
      }

      final orderDocument = await firestore.collection('orders').doc(orderId).get();
      if (!orderDocument.exists) {
        throw StateError('Pedido criado, mas não foi possível exibi-lo.');
      }
      final order = od.Order.fromDocument(orderDocument);
      cartManager.clear();
      onSuccess?.call(order);
    } on FirebaseFunctionsException catch (error) {
      final message = error.message ?? 'Falha ao iniciar o pagamento.';
      if (error.code == 'failed-precondition' &&
          message.toLowerCase().contains('estoque')) {
        onStockFail?.call(message);
      } else {
        onPayFail?.call(message);
      }
    } catch (error) {
      final message = error is StateError
          ? error.message.toString()
          : 'Não foi possível iniciar o pagamento. Tente novamente.';
      onPayFail?.call(message);
    } finally {
      loading = false;
    }
  }
}

