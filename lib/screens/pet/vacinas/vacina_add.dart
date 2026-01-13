import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/page_manager.dart';
import '../../../models/pet/pet.dart';
import '../../../models/pet/vacinas/vacinas.dart';
import 'vacina_card.dart';

class VacinaAdd extends StatelessWidget {
  const VacinaAdd({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pet1 = Pet();
    var vacina1 = Vacinas();
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments! as Map<String, dynamic>;
      pet1 = arguments['pet'] as Pet;
      vacina1 = arguments['vacina'] as Vacinas;
    }
    bool editing = false;
    if (vacina1.name != null) editing = true;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: vacina1.name != null
            ? const Text('Editar Vacina', style: TextStyle(color: Colors.white))
            : const Text('Cadastrar Vacina',
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
            VacinaCard(
              adding: !editing,
              pet: pet1,
              vacina: vacina1,
            ),
          ]),
        ),
      ),
    );
  }
}
