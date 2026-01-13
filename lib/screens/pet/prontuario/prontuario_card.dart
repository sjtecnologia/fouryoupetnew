import 'package:flutter/material.dart';
import 'package:fouryoupet/models/pet/pet_manager.dart';
import 'package:fouryoupet/models/pet/prontuario/prontuarios.dart';

import 'package:provider/provider.dart';

import '../../../models/pet/pet.dart';

import 'components/prontuario_input_field.dart';

class ProntuarioCard extends StatelessWidget {
  final bool adding;
  final Pet pet;
  final Prontuarios? prontuario;

  const ProntuarioCard(
      {Key? key, required this.adding, required this.pet, this.prontuario})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .65,
      child: Consumer<PetManager>(builder: (_, petManager, __) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: const Text(
                      'Prontuários do Pet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color.fromARGB(255, 255, 111, 0),
                      ),
                    ),
                  ),
                  if (adding) ProntuarioInputField(pet, null),
                  if (!adding) ProntuarioInputField(pet, prontuario)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
