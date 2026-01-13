import 'package:cloud_firestore/cloud_firestore.dart';

/// Função para excluir a subcoleção 'pesos' de todos os documentos da coleção 'pet'.
Future<void> excluirPesosDeTodosOsPets() async {
  // Obtém uma instância do Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    print('Iniciando a exclusão da subcoleção "pesos" de todos os pets...');

    // 1. Acessa a coleção principal 'pet'
    QuerySnapshot petSnapshot = await _firestore.collection('pet').get();

    // Verifica se existem documentos na coleção 'pet'
    if (petSnapshot.docs.isEmpty) {
      print(
          'Nenhum registro encontrado na coleção "pet". Nenhuma exclusão necessária.');
      return;
    }

    // Inicializa um contador para os documentos de peso excluídos
    int totalPesosExcluidos = 0;

    // Itera sobre cada documento na coleção 'pet'
    for (var petDoc in petSnapshot.docs) {
      // 2. Referência à subcoleção 'pesos' dentro do documento 'pet' atual
      CollectionReference pesosCollection =
          petDoc.reference.collection('pesos');

      // 3. Obtém todos os documentos da subcoleção 'pesos' para o pet atual
      QuerySnapshot pesosSnapshot = await pesosCollection.get();

      // Verifica se existem documentos na subcoleção 'pesos' para este pet
      if (pesosSnapshot.docs.isEmpty) {
        print(
            '  > Pet ID: ${petDoc.id} - Não há documentos na subcoleção "pesos".');
        continue; // Pula para o próximo pet
      }

      // Prepara um WriteBatch para as exclusões deste pet
      WriteBatch batch = _firestore.batch();
      int pesosExcluidosPorPet = 0;

      // 4. Itera sobre cada documento na subcoleção 'pesos'
      for (var pesoDoc in pesosSnapshot.docs) {
        // 5. Adiciona a operação de exclusão ao batch
        batch.delete(pesoDoc.reference);
        pesosExcluidosPorPet++;
      }

      // 6. Confirma as exclusões para este pet
      await batch.commit();
      totalPesosExcluidos += pesosExcluidosPorPet;
      print(
          '  > Pet ID: ${petDoc.id} - Excluídos $pesosExcluidosPorPet documentos da subcoleção "pesos".');
    }

    print('Exclusão concluída com sucesso!');
    print(
        'Total de documentos de peso excluídos em todos os pets: $totalPesosExcluidos.');
  } catch (e) {
    print('Ocorreu um erro ao excluir pesos dos pets: $e');
  }
}

// Exemplo de como você pode chamar esta função no seu aplicativo Flutter:
/*
import 'package:flutter/material.dart';

class MinhaTelaDeGerenciamento extends StatelessWidget {
  const MinhaTelaDeGerenciamento({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Pets'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Botão de exclusão geralmente em vermelho
          onPressed: () async {
            // **IMPORTANTE**: Considere adicionar uma caixa de diálogo de confirmação aqui!
            bool? confirmarExclusao = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Confirmar Exclusão'),
                  content: const Text('Tem certeza de que deseja excluir TODAS as entradas de peso de TODOS os pets? Esta ação é irreversível.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false); // Retorna false
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Excluir Tudo'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true); // Retorna true
                      },
                    ),
                  ],
                );
              },
            );

            if (confirmarExclusao == true) {
              await excluirPesosDeTodosOsPets();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tentando excluir pesos dos pets... Verifique o console.'),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exclusão cancelada.'),
                ),
              );
            }
          },
          child: const Text('Excluir Todos os Pesos de Todos os Pets'),
        ),
      ),
    );
  }
}
*/
