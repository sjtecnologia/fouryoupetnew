import 'dart:convert';
import 'package:fouryoupet/config/api_constants.dart';
import 'package:http/http.dart' as http;

Future sendEmail({
  required String name,
  required String email,
  required String subject,
  required String message,
}) async {
  final serviceId = EmailJSConfig.serviceId;
  final templateId = EmailJSConfig.templateId;
  final userId = EmailJSConfig.publicKey;

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final response = await http.post(
    url,
    headers: {
      'origin': 'http://localhost',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'template_params': {
        'user_email': email,
        'user_subject': subject,
        'message': message,
      },
    }),
  );
  debugPrint(response.body);
}
