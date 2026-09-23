import 'package:cloud_functions/cloud_functions.dart';

class PaymentResult {
  const PaymentResult({
    required this.success,
    this.paymentId,
    this.status,
    this.qrcode,
    this.copyPaste,
    this.error,
  });

  final bool success;
  final String? paymentId;
  final String? status;
  final String? qrcode;
  final String? copyPaste;
  final String? error;

  factory PaymentResult.fromMap(Map<dynamic, dynamic> data) {
    return PaymentResult(
      success: data['success'] == true,
      paymentId: data['paymentId'] as String?,
      status: data['status'] as String?,
      qrcode: data['qrcode'] as String?,
      copyPaste: data['copyPaste'] as String?,
      error: data['error'] as String?,
    );
  }
}

class PagBankPaymentService {
  PagBankPaymentService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<PaymentResult> chargeCard({
    required int amount,
    required Map<String, dynamic> customer,
    required String encryptedCard,
    required String securityCode,
    required String orderId,
  }) async {
    return _createPayment({
      'amount': amount,
      'customer': customer,
      'card': {'encrypted': encryptedCard},
      'securityCode': securityCode,
      'orderId': orderId,
      'paymentMethod': 'CREDIT_CARD',
    });
  }

  Future<PaymentResult> createPix({
    required int amount,
    required Map<String, dynamic> customer,
    required String orderId,
  }) async {
    return _createPayment({
      'amount': amount,
      'customer': customer,
      'orderId': orderId,
      'paymentMethod': 'PIX',
    });
  }

  Future<PaymentResult> _createPayment(Map<String, dynamic> data) async {
    try {
      final result =
          await _functions.httpsCallable('createPaymentOrder').call(data);
      return PaymentResult.fromMap(result.data as Map<dynamic, dynamic>);
    } catch (e) {
      return PaymentResult(success: false, error: e.toString());
    }
  }
}
