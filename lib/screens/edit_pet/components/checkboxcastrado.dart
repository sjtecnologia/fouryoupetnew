import 'package:flutter/material.dart';

import '../../../models/pet/pet.dart';

class MyCheckboxCastrado extends StatefulWidget {
  MyCheckboxCastrado(this.pet);

  final Pet? pet;

  @override
  _MyCheckboxCastradoState createState() => _MyCheckboxCastradoState(pet!);
}

class _MyCheckboxCastradoState extends State<MyCheckboxCastrado> {
  _MyCheckboxCastradoState(this.pet);
  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return criaMyCheckboxButton(pet);
  }

  criaMyCheckboxButton(Pet pet) {
    return Container(
      child: Column(
        children: <Widget>[
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Color.fromARGB(255, 255, 111, 0),
            value: pet.castrado ?? false,
            title: Text(
              'Castrado',
              style: TextStyle(fontSize: 20),
            ),
            onChanged: (value) {
              setState(() {
                pet.castrado = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
