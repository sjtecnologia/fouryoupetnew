// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LinkedLabelRadio extends StatelessWidget {
  const LinkedLabelRadio({
    Key? key,
    required this.label,
    required this.padding,
    required this.groupValue,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool groupValue;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Radio<bool>(
              key: key,
              groupValue: groupValue,
              value: value,
              onChanged: (bool? newValue) {
                onChanged(newValue!);
              }),
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: Colors.blueAccent,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  debugPrint('Label has been tapped.');
                },
            ),
          ),
        ],
      ),
    );
  }
}
