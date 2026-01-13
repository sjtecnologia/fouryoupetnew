import 'package:flutter/material.dart';
import 'package:fouryoupet/models/pet/pet_manager.dart';
import 'package:fouryoupet/screens/pet/vacinas/components/vacina_input_field.dart';

import 'package:provider/provider.dart';

import '../../../models/pet/pet.dart';
import '../../../models/pet/vacinas/vacinas.dart';

class VacinaCard extends StatelessWidget {
  final bool adding;
  final Pet pet;
  final Vacinas? vacina;

  const VacinaCard(
      {Key? key, required this.adding, required this.pet, this.vacina})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .3,
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
                      'Vacinas do Pet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: const Color.fromARGB(255, 255, 111, 0),
                      ),
                    ),
                  ),
                  if (adding) VacinaInputField(pet, null, false),
                  if (!adding) VacinaInputField(pet, vacina, true),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
