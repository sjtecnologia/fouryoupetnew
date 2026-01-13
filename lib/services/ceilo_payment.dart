import 'dart:collection';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

import 'package:fouryoupet/models/user/userapp.dart';

class CieloPayment {
  final functions = FirebaseFunctions.instance;

  Future<String?> authorize({required num price, String? orderId, required Userapp user}) async {
    try {
      final Map<String, dynamic> dataSale = {
        'merchantOrderId': orderId,
        'amount': (price * 100).toInt(),
        'softDescriptor': '4You Pet',
        'installments': 1,
        'cpf': user.cpf,
        'paymentType': 'CreditCard',
      };

      final HttpsCallable callable =
          functions.httpsCallable('authorizeCreditCard');
      //callable.timeout = const Duration(seconds: 60);
      final response = await callable.call(dataSale);
      final data = Map<String, dynamic>.from(response.data as LinkedHashMap);
      if (data['success'] as bool) {
        return data['paymentId'] as String?;
      } else {
        debugPrint('${data['error']['message']}');
        return Future.error(data['error']['message']);
      }
    } catch (e) {
      debugPrint('$e');
      return Future.error('Falha ao processar transação, Tente mais tarde!');
    }
  }

  Future<void> capture(String payId) async {
    final Map<String, dynamic> captureData = {'payId': payId};
    final HttpsCallable callable = functions.httpsCallable('captureCreditCard');
    //callable.timeout = const Duration(seconds: 60);
    final response = await callable.call(captureData);
    final data = Map<String, dynamic>.from(response.data as LinkedHashMap);
    if (data['success'] as bool) {
      debugPrint('Captitura realizada com sucesso');
    } else {
      debugPrint('${data['error']['message']}');
      return Future.error(data['error']['message']);
    }
  }

  Future<void> cancel(String? payId) async {
    final Map<String, dynamic> cancelData = {'payId': payId};
    final HttpsCallable callable = functions.httpsCallable('cancelCreditCard');
    //callable.timeout = const Duration(seconds: 60);
    final response = await callable.call(cancelData);
    final data = Map<String, dynamic>.from(response.data as LinkedHashMap);
    if (data['success'] as bool) {
      debugPrint('Cencelamento realizado com sucesso');
    } else {
      debugPrint('${data['error']['message']}');
      return Future.error(data['error']['message']);
    }
  }
}
