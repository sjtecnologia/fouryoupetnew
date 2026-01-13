import 'package:flutter/material.dart';
import 'package:fouryoupet/models/pet/pesos/pesos.dart';

import 'package:intl/intl.dart';

class PesoListTile extends StatelessWidget {
  const PesoListTile(this.peso);

  final Pesos peso;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Container(
        height: MediaQuery.of(context).size.height * .2,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Peso: ' + peso.peso!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
            Text(
              'Data da Pesagem: ' +
                  DateFormat('dd/MM/yyyy').format(peso.datapeso!),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
