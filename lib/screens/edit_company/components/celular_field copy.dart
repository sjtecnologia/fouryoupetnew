import 'package:flutter/material.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '../../../models/company/company_manager.dart';

class CelularField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final companyManager = context.watch<CompanyManager>();
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
          initialValue: companyManager.company!.phone,
          decoration:
              const InputDecoration(hintText: '(00)00000-0000', isDense: true),
          keyboardType: TextInputType.number,
          inputFormatters: [
            maskFormatter,
          ],
          validator: (phone) {
            if (phone!.isEmpty) {
              return 'Campo Obrigatório';
            } else
              return null;
          },
          onChanged: companyManager.company!.setPhone,
        )
      ],
    );
  }
}
