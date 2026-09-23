// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Tipos de arquivo permitidos para imagens
  static const _allowedImageExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  // Tamanho máximo: 10 MB para imagens
  static const int _maxImageSizeBytes = 10 * 1024 * 1024;

  Future<String> uploadFile(File file, String path) async {
    // Validar extensão
    final ext = file.path.split('.').last.toLowerCase();
    if (!_allowedImageExtensions.contains(ext)) {
      throw StorageException(
          'Tipo de arquivo não permitido. Use: ${_allowedImageExtensions.join(', ')}');
    }

    // Validar tamanho
    final fileSize = await file.length();
    if (fileSize > _maxImageSizeBytes) {
      final sizeMb = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      throw StorageException(
          'Arquivo muito grande (${sizeMb}MB). Máximo: 10MB');
    }

    try {
      // Nome aleatório para evitar path traversal
      final String fileName = '${_uuid.v4()}.$ext';
      final Reference ref = _storage.ref().child('$path/$fileName');
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Erro ao fazer upload do arquivo: $e');
      rethrow;
    }
  }
}

class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => message;
}
