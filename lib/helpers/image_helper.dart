// helpers/image_helper.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    try {
      // Verificar permissões primeiro
      bool hasPermission = await _checkPermissions();
      if (!hasPermission) {
        _showPermissionDialog(context);
        return null;
      }

      // Selecionar imagem com configurações otimizadas
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      _showErrorDialog(context, e.toString());
      return null;
    }
  }

  static Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        // Android 12 ou inferior
        final status = await Permission.storage.request();
        return status == PermissionStatus.granted;
      } else {
        // Android 13+
        final status = await Permission.photos.request();
        return status == PermissionStatus.granted;
      }
    }
    return true; // iOS gerencia permissões automaticamente
  }

  static void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permissão Necessária'),
        content: Text(
            'Por favor, permita o acesso às fotos nas configurações do app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }

  static void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text('Erro ao selecionar imagem: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
