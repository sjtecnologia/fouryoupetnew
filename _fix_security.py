#!/usr/bin/env python3
"""Script de correções de segurança - 4YouPet Flutter App"""
import os, re

BASE = '/Users/renato/Documents/Developement/fouryoupetnew'

# ─────────────────────────────────────────────────────────────────────────────
# FIX 2a: push_notification_service.dart  → rewrite completo
# ─────────────────────────────────────────────────────────────────────────────
NEW_PUSH_SERVICE = """\
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
      debugPrint('Erro ao enviar notificação push: $e');
    }
  }
}
"""

path = os.path.join(BASE, 'lib/helpers/push_notification_service.dart')
with open(path, 'w', encoding='utf-8') as f:
    f.write(NEW_PUSH_SERVICE)
print(f'✅ push_notification_service.dart reescrito')

# ─────────────────────────────────────────────────────────────────────────────
# FIX 2b: chat_page.dart  → imports + sendNotificationToSelectedDriver
# ─────────────────────────────────────────────────────────────────────────────
path = os.path.join(BASE, 'lib/common/order/chat/chat_page.dart')
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove imports desnecessários
content = content.replace("import 'dart:convert';\n", "")
content = content.replace("\nimport 'package:googleapis_auth/auth_io.dart' as auth;\n", "")
content = content.replace("\nimport 'package:http/http.dart' as http;\n", "")

# Adiciona cloud_functions após cloud_firestore
content = content.replace(
    "import 'package:cloud_firestore/cloud_firestore.dart';",
    "import 'package:cloud_firestore/cloud_firestore.dart';\nimport 'package:cloud_functions/cloud_functions.dart';"
)

# Substitui constructFCMPayload + for loop + métodos estáticos
marker = "      String constructFCMPayload("
idx = content.find(marker)
if idx < 0:
    print('❌ chat_page.dart: marcador não encontrado')
else:
    new_ending = """\
      if (userToken != null && userToken.isNotEmpty) {
        final callable = FirebaseFunctions.instance
            .httpsCallable('sendChatNotification');
        for (final token in userToken) {
          callable.call(<String, dynamic>{
            'token': token,
            'title': 'Nova mensagem do pedido \${widget.groupId}',
            'body': chatMessageMap['message'].toString(),
            'data': {
              'name': chatMessageMap['sender'] ?? '',
              'click_action': chatMessageMap['click'] ?? '',
              'type': chatMessageMap['type'] ?? '',
            },
          }).catchError((dynamic e) {
            debugPrint('Erro ao enviar notificação de chat: $e');
          });
        }
      }
    }
  }
}
"""
    content = content[:idx] + new_ending
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'✅ chat_page.dart corrigido')

# ─────────────────────────────────────────────────────────────────────────────
# FIX 2c: chat_page_event.dart  → imports + sendNotificationToSelectedDriver
# ─────────────────────────────────────────────────────────────────────────────
path = os.path.join(BASE, 'lib/common/event/chat/chat_page_event.dart')
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove imports desnecessários
content = content.replace("import 'dart:convert';\n", "")
content = content.replace("\nimport 'package:googleapis_auth/auth_io.dart' as auth;\n", "")
content = content.replace("import 'package:googleapis_auth/auth_io.dart' as auth;\n", "")
content = content.replace("\nimport 'package:http/http.dart' as http;\n", "")
content = content.replace("import 'package:http/http.dart' as http;\n", "")

# Adiciona cloud_functions após cloud_firestore
content = content.replace(
    "import 'package:cloud_firestore/cloud_firestore.dart';",
    "import 'package:cloud_firestore/cloud_firestore.dart';\nimport 'package:cloud_functions/cloud_functions.dart';"
)

# Substitui constructFCMPayload + for loop + métodos estáticos
marker = "      String constructFCMPayload("
idx = content.find(marker)
if idx < 0:
    print('❌ chat_page_event.dart: marcador não encontrado')
else:
    new_ending = """\
      if (userToken != null && userToken.isNotEmpty) {
        final callable = FirebaseFunctions.instance
            .httpsCallable('sendChatNotification');
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
            debugPrint('Erro ao enviar notificação de chat: $e');
          });
        }
      }
    }
  }
}
"""
    content = content[:idx] + new_ending
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'✅ chat_page_event.dart corrigido')

print('\nFix 2 concluído.')
