import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  static Future<void> sendNotificationToSelectedDriver(
    String deviceToken,
    String title,
    String body, {
    Map<String, String> data = const {},
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('sendChatNotification');
      await callable.call(<String, dynamic>{
        'token': deviceToken,
        'title': title,
        'body': body,
        'data': data,
      });
    } catch (e) {
      debugPrint('Erro ao enviar notificação: $e');
    }
  }
}
