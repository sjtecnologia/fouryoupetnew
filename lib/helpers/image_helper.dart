// helpers/image_helper.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({
    required BuildContext context,
    required ImageSource source,
  }) async {
    try {
      // image_picker 1.x usa o seletor do sistema (Photo Picker no Android 13+
      // e ACTION_GET_CONTENT em versões anteriores) — não requer permissões de
      // leitura de mídia para acesso à galeria.
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
      debugPrint('Erro ao selecionar imagem: $e');
      _showErrorDialog(context, e.toString());
      return null;
    }
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
