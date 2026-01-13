import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

// Modelo para os dados do contrato
class ContractData {
  final String htmlContent; // Conteúdo HTML do contrato
  final String version;     // Versão do contrato

  ContractData({required this.htmlContent, required this.version});
}

class ContractService {
  final FirebaseStorage _storage;

  ContractService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// Busca o contrato HTML do Firebase Storage.
  /// O caminho padrão é 'contracts/contract_v1.html'.
  /// A versão está hardcoded para v1.0, mas idealmente viria de Remote Config ou Firestore.
  Future<ContractData> getContractFromStorage({
    String path = 'contracts/contract_v1.html',
    String version = 'v1.0', // Versão hardcoded para este exemplo
    int maxSizeBytes = 2 * 1024 * 1024, // Limite de 2MB para o arquivo
  }) async {
    try {
      final ref = _storage.ref(path);
      final bytes = await ref.getData(maxSizeBytes);

      if (bytes == null) {
        throw Exception('Não foi possível ler o arquivo do contrato no caminho: $path');
      }

      final htmlContent = utf8.decode(bytes);
      return ContractData(htmlContent: htmlContent, version: version);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        throw Exception('Arquivo do contrato não encontrado no Storage: $path');
      }
      rethrow; // Relançar outras exceções do Firebase
    } catch (e) {
      throw Exception('Erro ao carregar contrato do Storage: $e');
    }
  }
}