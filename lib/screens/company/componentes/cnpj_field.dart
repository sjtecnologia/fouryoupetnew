import 'package:flutter/material.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CnpjField extends StatelessWidget {
  final TextEditingController? controller;

  const CnpjField({Key? key, this.controller}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var maskFormatter = new MaskTextInputFormatter(
        mask: '##.###.###/####-##', filter: {"#": RegExp(r'[0-9]')});

    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        hintText: '00.000.000/0000-00',
        isDense: true,
        labelText: 'CNPJ',
        labelStyle: TextStyle(
          color: Colors.white,
        ),
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        //FilteringTextInputFormatter.digitsOnly,
        maskFormatter,
      ],
      validator: (cnpj) {
        if (cnpj!.isEmpty) return 'Campo Obrigatório';
        //} else if (!CNPJValidator.isValid(cnpj)) return 'CNPJ Inválido';
        return null;
      },
    );
  }
}
