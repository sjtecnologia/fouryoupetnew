import 'package:flutter/material.dart';
import 'package:fouryoupet/models/company/company.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CnpjField extends StatelessWidget {
  final Company company;

  const CnpjField({Key? key, required this.company}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var maskFormatter = new MaskTextInputFormatter(
        mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9]')});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'CNPJ',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        TextFormField(
          initialValue: company.cnpj,
          decoration: const InputDecoration(
              hintText: '00.000.000/0000-00', isDense: true),
          keyboardType: TextInputType.number,
          inputFormatters: [
            //FilteringTextInputFormatter.digitsOnly,
            maskFormatter,
          ],
          onChanged: (cnpj) => company.cnpj = cnpj,
          validator: (cnpj) {
            if (cnpj!.isEmpty) return 'Campo Obrigatório';
            //} else if (!CNPJValidator.isValid(cnpj)) return 'CNPJ Inválido';
            return null;
          },
        )
      ],
    );
  }
}
