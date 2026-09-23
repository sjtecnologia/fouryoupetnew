import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Constantes da aplicação 4YouPet — carregadas do arquivo .env
String get CEPABERTO_TOKEN =>
    dotenv.env['CEPABERTO_TOKEN'] ?? '';

class EmailJSConfig {
  static String get serviceId =>
      dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
  static String get templateId =>
      dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
  static String get publicKey =>
      dotenv.env['EMAILJS_PUBLIC_KEY'] ?? '';
}
