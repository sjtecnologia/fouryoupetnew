import 'package:flutter/material.dart';

import '../../../models/pet/pet.dart';

class MyCheckboxPedigree extends StatefulWidget {
  MyCheckboxPedigree(this.pet);

  final Pet? pet;

  @override
  _MyCheckboxPedigreeState createState() => _MyCheckboxPedigreeState(pet!);
}

class _MyCheckboxPedigreeState extends State<MyCheckboxPedigree> {
  _MyCheckboxPedigreeState(this.pet);
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
            value: pet.pedigree ?? false,
            title: Text(
              'Possui Pedigree',
              style: TextStyle(fontSize: 20),
            ),
            onChanged: (value) {
              setState(() {
                pet.pedigree = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
