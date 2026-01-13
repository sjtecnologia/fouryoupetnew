// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:validatorless/validatorless.dart';

class CelularField extends StatelessWidget {
  final TextEditingController? controller;
  const CelularField({
    this.controller,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var maskFormatter = new MaskTextInputFormatter(
        mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Celular',
        labelStyle: TextStyle(
          color: Colors.white,
        ),
        hintText: '(00)00000-0000',
        isDense: true,
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        maskFormatter,
      ],
      validator: Validatorless.required('Campo obrigatório'),
    );
  }
}
