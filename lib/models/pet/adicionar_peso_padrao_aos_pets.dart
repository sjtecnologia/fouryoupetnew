import 'package:cloud_firestore/cloud_firestore.dart';

/// Função para atualizar todos os documentos da coleção 'pet'
/// adicionando uma nova entrada na subcoleção 'pesos'.
Future<void> adicionarPesoPadraoAosPets() async {
  // Obtém uma instância do Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    print('Iniciando a atualização de pesos para os pets...');

    // 1. Acessa a coleção principal 'pet'
    QuerySnapshot petSnapshot = await _firestore.collection('pet').get();

    // Verifica se existem documentos na coleção 'pet'
    if (petSnapshot.docs.isEmpty) {
      print(
          'Nenhum registro encontrado na coleção "pet". Nenhuma atualização necessária.');
      return;
    }

    // Usa um 'WriteBatch' para realizar múltiplas operações de escrita
    // de forma atômica e eficiente. Isso é ideal para atualizar muitos documentos.
    WriteBatch batch = _firestore.batch();
    int petsAtualizados = 0;

    // Itera sobre cada documento na coleção 'pet'
    for (var petDoc in petSnapshot.docs) {
      // 2. Referência à subcoleção 'pesos' dentro do documento 'pet' atual
      CollectionReference pesosCollection =
          petDoc.reference.collection('pesos');

      // 3. Define os dados para a nova entrada de peso
      Map<String, dynamic> novaEntradaPeso = {
        'peso': 2.0, // Peso padrão em kg (usando double para flexibilidade)
        'datapeso': Timestamp.now(), // Data e hora atual do servidor
      };

      // 4. Adiciona um novo documento à subcoleção 'pesos' com um ID automático.
      // Usa .set() com um .doc() vazio para criar um novo documento.
      batch.set(pesosCollection.doc(), novaEntradaPeso);
      petsAtualizados++;
    }

    // 5. Confirma todas as operações do batch
    await batch.commit();

    print('Atualização concluída com sucesso!');
    print(
        '$petsAtualizados registros de pets receberam uma nova entrada de peso padrão.');
  } catch (e) {
    print('Ocorreu um erro ao adicionar pesos aos pets: $e');
  }
}

// Exemplo de como você pode chamar esta função no seu aplicativo Flutter:
// Geralmente, você chamaria isso em um botão, na inicialização de uma tela,
// ou em um evento específico.

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
          onPressed: () async {
            // Chama a função para adicionar o peso padrão
            await adicionarPesoPadraoAosPets();
            // Você pode adicionar um SnackBar ou outra indicação de sucesso/erro aqui
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tentando atualizar pesos dos pets... Verifique o console.'),
              ),
            );
          },
          child: const Text('Adicionar Peso Padrão a Todos os Pets'),
        ),
      ),
    );
  }
}
*/
