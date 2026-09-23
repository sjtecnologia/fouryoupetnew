#!/usr/bin/env python3
"""Remove RSA private key from 3 chat files and replace with Cloud Function calls"""

import os
import re

BASE = os.getcwd()

# ═══════════════════════════════════════════════════════════════════════════
# FIX 2a: push_notification_service.dart
# ═══════════════════════════════════════════════════════════════════════════
path_a = os.path.join(BASE, 'lib/helpers/push_notification_service.dart')
content_a = '''import 'package:cloud_functions/cloud_functions.dart';
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
'''

with open(path_a, 'w') as f:
    f.write(content_a)
print(f'✅ push_notification_service.dart reescrito')

# ═══════════════════════════════════════════════════════════════════════════
# FIX 2b: chat_page.dart
# ═══════════════════════════════════════════════════════════════════════════
path_b = os.path.join(BASE, 'lib/common/order/chat/chat_page.dart')
with open(path_b, 'r') as f:
    content_b = f.read()

# Remove imports
content_b = content_b.replace("import 'dart:convert';\n", "")
content_b = content_b.replace("\nimport 'package:googleapis_auth/auth_io.dart' as auth;", "")
content_b = content_b.replace("\nimport 'package:http/http.dart' as http;", "")

# Add cloud_functions import after cloud_firestore
content_b = content_b.replace(
    "import 'package:cloud_firestore/cloud_firestore.dart';",
    "import 'package:cloud_firestore/cloud_firestore.dart';\nimport 'package:cloud_functions/cloud_functions.dart';"
)

# Find and replace sendMessage onwards
start_marker = "  sendMessage(List<String>? userToken) async {"
end_marker = "  static Future<String> getAccessToken()"
start_idx = content_b.find(start_marker)
end_idx = content_b.find(end_marker)

if start_idx > 0 and end_idx > 0:
    # Keep everything up to sendMessage start
    before = content_b[:start_idx]
    # Insert new sendMessage implementation
    new_send_message = '''sendMessage(List<String>? userToken) async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": 'order',
        "click": widget.groupId,
        "lido": false,
      };

      context
          .read<OrdersManager>()
          .order
          .sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
        Future.delayed(const Duration(milliseconds: 500));
        scrollDown();
      });

      if (userToken != null && userToken.isNotEmpty) {
        final callable =
            FirebaseFunctions.instance.httpsCallable('sendChatNotification');
        for (final token in userToken) {
          callable.call(<String, dynamic>{
            'token': token,
            'title': 'Nova mensagem do pedido ${widget.groupId}',
            'body': chatMessageMap['message'].toString(),
            'data': {
              'name': chatMessageMap['sender'] ?? '',
              'click_action': chatMessageMap['click'] ?? '',
              'type': chatMessageMap['type'] ?? '',
            },
          }).catchError((dynamic e) {
            debugPrint('Erro ao enviar notificação: $e');
          });
        }
      }
    }
  }
}
'''
    content_b = before + new_send_message
    with open(path_b, 'w') as f:
        f.write(content_b)
    print(f'✅ chat_page.dart corrigido')
else:
    print(f'❌ chat_page.dart: marcadores não encontrados')

# ═══════════════════════════════════════════════════════════════════════════
# FIX 2c: chat_page_event.dart
# ═══════════════════════════════════════════════════════════════════════════
path_c = os.path.join(BASE, 'lib/common/event/chat/chat_page_event.dart')
with open(path_c, 'r') as f:
    content_c = f.read()

# Remove imports
content_c = content_c.replace("import 'dart:convert';\n", "")
content_c = content_c.replace("\nimport 'package:googleapis_auth/auth_io.dart' as auth;", "")
content_c = content_c.replace("import 'package:googleapis_auth/auth_io.dart' as auth;", "")
content_c = content_c.replace("\nimport 'package:http/http.dart' as http;", "")

# Add cloud_functions import after cloud_firestore
content_c = content_c.replace(
    "import 'package:cloud_firestore/cloud_firestore.dart';",
    "import 'package:cloud_firestore/cloud_firestore.dart';\nimport 'package:cloud_functions/cloud_functions.dart';"
)

# Find and replace sendMessage onwards
start_marker = "  sendMessage(List<String>? userToken) async {"
end_marker = "  static sendNotificationToSelectedDriver("
start_idx = content_c.find(start_marker)
end_idx = content_c.find(end_marker)

if start_idx > 0 and end_idx > 0:
    # Keep everything up to sendMessage start
    before = content_c[:start_idx]
    # Insert new sendMessage implementation
    new_send_message = '''sendMessage(List<String>? userToken) async {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageController.text,
        "sender": widget.userName,
        "time": DateTime.now().millisecondsSinceEpoch,
        "type": 'event',
        "click": widget.groupId,
        "lido": false,
      };

      context
          .read<EventProvider>()
          .appEvent
          .sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
        Future.delayed(const Duration(milliseconds: 500));
        scrollDown();
      });

      if (userToken != null && userToken.isNotEmpty) {
        final callable =
            FirebaseFunctions.instance.httpsCallable('sendChatNotification');
        for (final token in userToken) {
          callable.call(<String, dynamic>{
            'token': token,
            'title': 'Mensagem de Agendamento',
            'body': chatMessageMap['message'].toString(),
            'data': {
              'name': chatMessageMap['sender'] ?? '',
              'click_action': chatMessageMap['click'] ?? '',
              'type': chatMessageMap['type'] ?? '',
            },
          }).catchError((dynamic e) {
            debugPrint('Erro ao enviar notificação: $e');
          });
        }
      }
    }
  }
}
'''
    content_c = before + new_send_message
    with open(path_c, 'w') as f:
        f.write(content_c)
    print(f'✅ chat_page_event.dart corrigido')
else:
    print(f'❌ chat_page_event.dart: marcadores não encontrados')

print("\n✅ Fix 2 concluído: Chave privada removida dos 3 arquivos")
