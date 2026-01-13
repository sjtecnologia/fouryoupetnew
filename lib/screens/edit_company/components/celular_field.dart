// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:validatorless/validatorless.dart';

import '../../../models/company/company.dart';

class CelularField extends StatelessWidget {
  final Company company;
  const CelularField({
    Key? key,
    required this.company,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var maskFormatter = new MaskTextInputFormatter(
        mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Celular',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        TextFormField(
            initialValue: company.phone,
            decoration: const InputDecoration(
                hintText: '(00)00000-0000', isDense: true),
            keyboardType: TextInputType.number,
            inputFormatters: [
              maskFormatter,
            ],
            validator: Validatorless.required('Campo obrigatório'),
            onChanged: (celular) => company.phone = celular)
      ],
    );
  }
}
