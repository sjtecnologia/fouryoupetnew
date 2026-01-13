import 'package:flutter/material.dart';

import 'package:fouryoupet/models/user/user_manager.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

class CelularField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserManager>();
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
          initialValue: userManager.userapp!.celular,
          decoration:
              const InputDecoration(hintText: '(00)00000-0000', isDense: true),
          keyboardType: TextInputType.number,
          inputFormatters: [
            maskFormatter,
          ],
          validator: (celular) {
            if (celular!.isEmpty) {
              return 'Campo Obrigatório';
            } else
              return null;
          },
          onSaved: (value) => userManager.userapp!.celular = value,
        )
      ],
    );
  }
}
