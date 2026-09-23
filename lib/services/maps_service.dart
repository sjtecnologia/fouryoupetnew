// lib/services/maps_service.dart
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapsService {
  static const MethodChannel _channel = MethodChannel('fouryoupet/maps');

  static Future<void> initializeGoogleMaps() async {
    var idapi;
    try {
      if (Platform.isIOS) {
        idapi = "AIzaSyCsXI6iK1Dbf7ZtJI6NHNv74Hv_CXP-428";
      } else {
        idapi = "AIzaSyAQd6I7u0hruSW2VCFLpJ_2En00Uq8J-c8";
      }
      final apiKey = idapi; //dotenv.env['IOS_MAPS_APIKEY'] ?? '';

      // if (apiKey.isEmpty) {
      //   print('WARN: IOS_MAPS_APIKEY não encontrada no .env');
      //   return;
      // }

      await _channel.invokeMethod('setGoogleMapsApiKey', {
        'apiKey': apiKey,
      });

      debugPrint('Google Maps configurado com sucesso!');
    } catch (e) {
      debugPrint('Erro ao configurar Google Maps: $e');
    }
  }
}
