import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fouryoupet/models/cart/cart_manager.dart';
import 'package:fouryoupet/models/product/product.dart';
import 'package:fouryoupet/services/ceilo_payment.dart';
import 'package:fouryoupet/models/loyalty/loyalty_manager.dart';
import 'package:fouryoupet/models/loyalty/loyalty.dart';

import 'couponcodes/couponcode_manager.dart';
import 'order/order.dart' as od;

class CheckoutManager extends ChangeNotifier {
  late CartManager cartManager;

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CieloPayment cieloPayment = CieloPayment();

  // ignore: use_setters_to_change_properties
  void updateCart(CartManager cartManager) {
    this.cartManager = cartManager;
  }

  Future<void> checkout({
    Function? onStockFail,
    Function? onSuccess,
    Function? onPayFail,
    CouponCodeManager? couponManager,
    LoyaltyManager? loyaltyManager,
  }) async {
    loading = true;

    final orderId = await _getOrderId();

    try {
      await _decrementStock();
    } catch (e) {
      //cieloPayment.cancel(payId);
      onStockFail!(e);
      loading = false;
      return;
    }

    try {
      await cartManager.areacoberta();
    } catch (e) {
      onPayFail!(e);
      loading = false;
      return;
    }

    //try {
    //   await cieloPayment.capture(payId);
    // } catch (e){
    //   onPayFail(e);
    //   loading = false;
    //   return;
    // }

    // Register coupon usage if a coupon was applied
    if (couponManager != null && couponManager.hasCouponApplied) {
      await couponManager.markCouponAsUsed(
        cartManager.user!.id ?? '',
        orderId.toString(),
      );
    }

    final order = od.Order.fromCartManager(cartManager);
    order.orderId = orderId.toString();
    order.discount = couponManager?.getDiscountAmount(order.price!.toDouble() -
        order.frete!.toDouble()); //cartManager.discount?.toDouble();
    order.couponCode = couponManager?.cupomcode; //cartManager.couponCode;

    //order.payId = payId;

    await order.save();

    // Adicionar pontos de fidelidade após pedido ser salvo
    if (loyaltyManager != null && cartManager.user != null) {
      await _addLoyaltyPoints(
        loyaltyManager: loyaltyManager,
        orderValue: order.price?.toDouble() ?? 0.0,
        orderId: orderId.toString(),
        userId: cartManager.user!.id!,
      );

      // Processar indicação se for primeira compra
      await _processReferralIfFirstPurchase(
        loyaltyManager: loyaltyManager,
        userId: cartManager.user!.id!,
        orderId: orderId.toString(),
      );
    }

    cartManager.clear();

    onSuccess!(order);

    loading = false;
  }

  /// Adiciona pontos de fidelidade baseado no valor do pedido
  Future<void> _addLoyaltyPoints({
    required LoyaltyManager loyaltyManager,
    required double orderValue,
    required String orderId,
    required String userId,
  }) async {
    try {
      // Carregar programa de fidelidade se ainda não carregou
      if (loyaltyManager.loyaltyProgram == null) {
        await loyaltyManager.loadLoyaltyProgram();
      }

      final tier =
          loyaltyManager.loyaltyProgram?.currentTier ?? LoyaltyTier.bronze;

      final points = loyaltyManager.calculatePointsFromPurchase(
        orderValue,
        tier,
      );

      await loyaltyManager.addPoints(
        points: points,
        description: 'Compra aprovada - Pedido #$orderId',
        orderId: orderId,
        metadata: {
          'orderValue': orderValue,
          'tier': tier.name,
        },
      );

      debugPrint('✅ $points pontos adicionados ao programa de fidelidade');
    } catch (e) {
      debugPrint('⚠️ Erro ao adicionar pontos de fidelidade: $e');
      // Não interrompe o checkout se falhar ao adicionar pontos
    }
  }

  /// Processa indicação de amigo se for primeira compra
  Future<void> _processReferralIfFirstPurchase({
    required LoyaltyManager loyaltyManager,
    required String userId,
    required String orderId,
  }) async {
    try {
      // Buscar dados do usuário
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      final hasCompletedFirstPurchase =
          userData['hasCompletedFirstPurchase'] as bool? ?? false;
      final referredBy = userData['referredBy'] as String?;

      // Se não é primeira compra ou não foi indicado, não faz nada
      if (hasCompletedFirstPurchase || referredBy == null) {
        return;
      }

      // Processar indicação (dá pontos para ambos)
      await loyaltyManager.processReferral(
        referredUserId: userId,
        referrerUserId: referredBy,
        orderId: orderId,
      );

      debugPrint('✅ Indicação processada para primeira compra');
    } catch (e) {
      debugPrint('⚠️ Erro ao processar indicação: $e');
      // Não interrompe o checkout se falhar
    }
  }

  Future<int?> _getOrderId() async {
    final ref = firestore.doc('aux/ordercounter');

    try {
      final result = await firestore.runTransaction((tx) async {
        final doc = await tx.get(ref);
        final orderId = doc.get('current') as int;
        await tx.update(ref, {'current': orderId + 1});
        return {'orderId': orderId};
      });
      return result['orderId'];
    } catch (e) {
      return Future.error('Falha ao gerar número do pedido');
    }
  }

  Future<void> _decrementStock() {
    return firestore.runTransaction((tx) async {
      final List<Product> productsToUpdate = [];
      final List<Product> productsWithoutStock = [];

      for (final cartProduct in cartManager.items) {
        Product product;

        if (productsToUpdate.any((p) => p.id == cartProduct.productId)) {
          product =
              productsToUpdate.firstWhere((p) => p.id == cartProduct.productId);
        } else {
          final doc =
              await tx.get(firestore.doc('products/${cartProduct.productId}'));
          product = Product.fromDocument(doc);
        }

        cartProduct.product = product;

        final size = product.findSize(cartProduct.sizes)!;
        if (size.stock! - cartProduct.quantity! < 0) {
          productsWithoutStock.add(product);
        } else {
          size.stock = size.stock! - cartProduct.quantity!;
          productsToUpdate.add(product);
        }
      }

      if (productsWithoutStock.isNotEmpty) {
        return Future.error(
            '${productsWithoutStock.length} produtos sem estoque');
      }

      for (final product in productsToUpdate) {
        tx.update(firestore.doc('products/${product.id}'),
            {'sizes': product.exportSizeList()});
      }
    });
  }
}
