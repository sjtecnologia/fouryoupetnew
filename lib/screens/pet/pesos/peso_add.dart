import 'package:flutter/material.dart';
import 'package:fouryoupet/models/pet/pesos/pesos.dart';
import 'package:provider/provider.dart';

import '../../../models/page_manager.dart';
import '../../../models/pet/pet.dart';
import 'peso_card.dart';

class PesoAdd extends StatelessWidget {
  const PesoAdd({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pet = Pet();
    var pesos = Pesos();
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments! as Map<String, dynamic>;
      pet = arguments['pet'] as Pet;
      pesos = arguments['pesos'] as Pesos;
    }
    bool editing = false;
    if (pesos.peso != null) editing = true;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: pesos.peso != null
            ? const Text('Editar Peso', style: TextStyle(color: Colors.white))
            : const Text('Cadastrar Peso',
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
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * .5,
          child: ListView(children: <Widget>[
            PesoCard(
              adding: !editing,
              pet: pet,
              pesos: pesos,
            ),
          ]),
        ),
      ),
    );
  }
}
