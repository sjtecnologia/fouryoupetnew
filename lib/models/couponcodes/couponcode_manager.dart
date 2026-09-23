import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'couponcode.dart';

class CouponCodeManager extends ChangeNotifier {
  CouponCode? _appliedCoupon;
  String? _error;
  String? _errorMessage;
  bool _isLoading = false;
  String? cupomcode;

  // Getters
  CouponCode? get appliedCoupon => _appliedCoupon;
  String? get error => _error;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get hasCouponApplied => _appliedCoupon != null;

  // Método para aplicar cupom
  Future<bool> applyCoupon(
      String couponCode, double cartTotal, String userId) async {
    _isLoading = true;
    _error = null;
    _errorMessage = null;
    cupomcode = couponCode;
    notifyListeners();

    try {
      final coupon = await getCouponByCode(couponCode);

      if (coupon == null) {
        _setError('Cupom não encontrado');
        return false;
      }

      // Validar cupom
      final validation = await _validateCoupon(coupon, cartTotal, userId);
      if (!validation['isValid']) {
        _setError(validation['message']);
        return false;
      }

      _appliedCoupon = coupon;
      _error = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erro ao aplicar cupom: $e');
      return false;
    }
  }

  // Método para calcular desconto
  double getDiscountAmount(double cartTotal) {
    if (_appliedCoupon == null) return 0.0;

    double discount = 0.0;

    if (_appliedCoupon!.discountType == DiscountType.percentage) {
      discount = cartTotal * (_appliedCoupon!.discountValue / 100);
      // Aplicar desconto máximo se definido
      if (_appliedCoupon!.maxDiscount != null &&
          discount > _appliedCoupon!.maxDiscount!) {
        discount = _appliedCoupon!.maxDiscount!;
      }
    } else {
      discount = _appliedCoupon!.discountValue;
    }

    // Garantir que o desconto não seja maior que o total
    return discount > cartTotal ? cartTotal : discount;
  }

  // Método para remover cupom
  void removeCoupon() {
    _appliedCoupon = null;
    _error = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Método para limpar estado
  void clearState() {
    _appliedCoupon = null;
    _error = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // Método privado para definir erro
  void _setError(String message) {
    _error = message;
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  // Método para buscar cupom por código
  Future<CouponCode?> getCouponByCode(String code) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('couponcode')
          .where('code', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return CouponCode.fromDocument(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar cupom: $e');
    }
  }

  // Método para validar cupom
  Future<Map<String, dynamic>> _validateCoupon(
      CouponCode coupon, double cartTotal, String userId) async {
    // Verificar se está ativo
    if (!coupon.isActive) {
      return {'isValid': false, 'message': 'Cupom inativo'};
    }

    // Verificar data de expiração
    if (coupon.expirationDate.isBefore(DateTime.now())) {
      return {'isValid': false, 'message': 'Cupom expirado'};
    }

    // Verificar valor mínimo
    if (cartTotal < coupon.minimumValue) {
      return {
        'isValid': false,
        'message':
            'Valor mínimo: R\$ ${coupon.minimumValue.toStringAsFixed(2)}'
      };
    }

    // Verificar limite de uso
    // if (coupon.maxUses != null && coupon.usageCount >= coupon.usageLimit!) {
    //   return {'isValid': false, 'message': 'Cupom esgotado'};
    // }

    // Verificar se usuário já usou (se aplicável)
    //if (coupon.usageLimit != null) {
    final hasUsed = await _hasUserUsedCoupon(coupon.id, userId);
    if (hasUsed) {
      return {'isValid': false, 'message': 'Você já utilizou este cupom'};
    }
    //}

    return {'isValid': true, 'message': 'Cupom válido'};
  }

  // Verificar se usuário já usou o cupom
  Future<bool> _hasUserUsedCoupon(String couponId, String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('coupon_usage')
          .where('couponId', isEqualTo: couponId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Método para registrar uso do cupom
  Future<void> markCouponAsUsed(String userId, String orderId) async {
    if (_appliedCoupon == null) return;

    try {
      // Registrar uso
      await FirebaseFirestore.instance.collection('coupon_usage').add({
        'couponId': _appliedCoupon!.id,
        'userId': userId,
        'orderId': orderId,
        'usedAt': FieldValue.serverTimestamp(),
      });

      // Incrementar contador de uso
      await FirebaseFirestore.instance
          .collection('couponcode')
          .doc(_appliedCoupon!.id)
          .update({
        'usageCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Erro ao marcar cupom como usado: $e');
    }
  }

  // Métodos administrativos
  Future<void> createCoupon(CouponCode coupon) async {
    try {
      await FirebaseFirestore.instance
          .collection('couponcode')
          .add(coupon.toMap());
    } catch (e) {
      throw Exception('Erro ao criar cupom: $e');
    }
  }

  Future<void> updateCoupon(
      String couponId, Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance
          .collection('couponcode')
          .doc(couponId)
          .update(updates);
    } catch (e) {
      throw Exception('Erro ao atualizar cupom: $e');
    }
  }

  Future<void> deleteCoupon(String couponId) async {
    try {
      await FirebaseFirestore.instance
          .collection('couponcode')
          .doc(couponId)
          .delete();
    } catch (e) {
      throw Exception('Erro ao deletar cupom: $e');
    }
  }

  Stream<List<CouponCode>> getAllCoupons() {
    return FirebaseFirestore.instance
        .collection('couponcode')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CouponCode.fromDocument(doc)).toList());
  }

  Stream<List<CouponCode>> getActiveCoupons() {
    return FirebaseFirestore.instance
        .collection('couponcode')
        .where('isActive', isEqualTo: true)
        .where('expirationDate', isGreaterThan: Timestamp.now())
        .orderBy('expirationDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CouponCode.fromDocument(doc)).toList());
  }
}
