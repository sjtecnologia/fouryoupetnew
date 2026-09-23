import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
// Para debugPrint ou print

// Importe sua classe Pesos e Pet
import 'package:fouryoupet/models/pet/pesos/pesos.dart';
// Certifique-se de que o caminho para a sua classe Pet está correto
// import 'package:fouryoupet/models/pet/pet.dart'; // Não precisaremos da classe Pet inteira aqui, apenas a estrutura de Pesos.

/// Função para atualizar todos os registros de pets existentes
/// adicionando um peso padrão se a lista de pesos estiver vazia.
Future<void> adicionarPesoPadraoAosPetsExistentes() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    debugPrint(
        'Iniciando a verificação e atualização de pesos para pets existentes...');

    // 1. Obtém todos os documentos da coleção 'pet'
    QuerySnapshot petSnapshot = await _firestore.collection('pet').get();

    if (petSnapshot.docs.isEmpty) {
      debugPrint(
          'Nenhum registro encontrado na coleção "pet". Nenhuma atualização necessária.');
      return;
    }

    WriteBatch batch = _firestore.batch();
    int petsAtualizados = 0;

    // Itera sobre cada documento de pet
    for (var doc in petSnapshot.docs) {
      // Obtém o ID do documento
      final petId = doc.id;
      // Obtém a lista de pesos existente (se houver)
      List<dynamic>? existingPesosData =
          doc.data() is Map && (doc.data() as Map).containsKey('pesos')
              ? (doc.get('pesos') as List<dynamic>?)
              : null;

      // Se a lista de pesos não existe ou está vazia
      if (existingPesosData == null || existingPesosData.isEmpty) {
        // 2. Cria um novo objeto Pesos com o peso padrão e data atual
        final Pesos defaultPeso = Pesos(
          peso: "2.0", // Peso padrão de 2 kg como String
          datapeso: DateTime.now(), // Data e hora atual
        );

        // 3. Converte o objeto Pesos para um mapa, conforme o método toMap() da classe Pesos
        final Map<String, dynamic> defaultPesoMap = defaultPeso.toMap();

        // 4. Cria a nova lista de pesos com o item padrão
        final List<Map<String, dynamic>> newPesosList = [defaultPesoMap];

        // 5. Adiciona a operação de atualização ao batch
        // Atualiza apenas o campo 'pesos' no documento do pet
        batch.update(doc.reference, {'pesos': newPesosList});
        petsAtualizados++;
        debugPrint(
            '  > Pet ID: $petId - Adicionando peso padrão: ${defaultPeso.peso} kg em ${defaultPeso.datapeso}.');
      } else {
        debugPrint(
            '  > Pet ID: $petId - Já possui ${existingPesosData.length} registros de peso. Nenhuma alteração.');
      }
    }

    // 6. Executa todas as operações do batch
    if (petsAtualizados > 0) {
      await batch.commit();
      debugPrint('Atualização concluída com sucesso!');
      debugPrint(
          '$petsAtualizados registros de pets foram atualizados com um peso padrão.');
    } else {
      debugPrint('Nenhum pet precisou de atualização de peso padrão.');
    }
  } catch (e) {
    debugPrint('Ocorreu um erro ao adicionar pesos aos pets existentes: $e');
  }
}

// Exemplo de como você pode chamar esta função no seu aplicativo Flutter:
/*
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração de Pets'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Chamada da função de atualização
            await adicionarPesoPadraoAosPetsExistentes();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verificando e atualizando pesos... Verifique o console.'),
              ),
            );
          },
          child: const Text('Adicionar Peso Padrão a Pets Existentes'),
        ),
      ),
    );
  }
}
*/
