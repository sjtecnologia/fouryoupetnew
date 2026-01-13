import 'package:flutter/material.dart';
import 'package:fouryoupet/models/pet/prontuario/prontuarios.dart';
import 'package:intl/intl.dart';

class ProntuarioListTile extends StatelessWidget {
  const ProntuarioListTile(this.prontuario);

  final Prontuarios prontuario;

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
              'Descrição: ' + prontuario.descricao!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
            Text(
              'Observação: ' + prontuario.observacao!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
            Text(
              'Data do Procedimento: ' +
                  DateFormat('dd/MM/yyyy').format(prontuario.dataprocedimento!),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
            Text(
              'Data do Retorno: ' +
                  DateFormat('dd/MM/yyyy').format(prontuario.dataretorno!),
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
