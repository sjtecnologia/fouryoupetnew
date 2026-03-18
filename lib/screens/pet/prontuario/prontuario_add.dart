import 'package:flutter/material.dart';
import 'package:fouryoupet/models/pet/prontuario/prontuarios.dart';
import 'package:provider/provider.dart';

import '../../../models/page_manager.dart';
import '../../../models/pet/pet.dart';
import 'prontuario_card.dart';

class ProntuarioAdd extends StatelessWidget {
  const ProntuarioAdd({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pet = Pet();
    var prontuario = Prontuarios();
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments! as Map<String, dynamic>;
      pet = arguments['pet'] as Pet;
      prontuario = arguments['prontuario'] as Prontuarios;
    }
    bool editing = false;
    if (prontuario.descricao != null) editing = true;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
        title: prontuario.descricao != null
            ? const Text('Editar Prontuário',
                style: TextStyle(color: Colors.white))
            : const Text('Cadastrar Prontuário',
                style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<PageManager>().setPage(0);
              // Se necessário, feche telas abertas
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 111, 0),
              Color.fromARGB(255, 255, 161, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          children: <Widget>[
            ProntuarioCard(
              adding: !editing,
              pet: pet,
              prontuario: prontuario,
            ),
          ],
        ),
      ),
    );
  }
}
