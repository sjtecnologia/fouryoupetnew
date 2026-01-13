// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart'; // Adicione a dependência uuid em pubspec.yaml

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  Future<String> uploadFile(File file, String path) async {
    try {
      final String fileName = '${_uuid.v4()}.${file.path.split('.').last}';
      final Reference ref = _storage.ref().child('$path/$fileName');
      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Erro ao fazer upload do arquivo: $e');
      rethrow;
    }
  }
}
