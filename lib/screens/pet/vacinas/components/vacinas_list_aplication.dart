import 'package:flutter/material.dart';

import '../../../../models/pet/vacinas/vacinas.dart';

class VacinaListAplication extends StatelessWidget {
  const VacinaListAplication(this.vacina);

  final Vacinas vacina;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (_, index) {
                return Text(index.toString());
              })
        ],
      ),
    );
  }
}
