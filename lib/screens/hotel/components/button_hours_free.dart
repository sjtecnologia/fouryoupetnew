import 'package:flutter/material.dart';

class ButtonHoursFree extends StatelessWidget {
  const ButtonHoursFree({
    Key? key,
    required this.text,
    required this.isFavorite,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: isFavorite ? Colors.orange[900] : Colors.orange[400],
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: Colors.black),
        ),
      );

  final String text;
  final bool isFavorite;
  final VoidCallback onPressed;
}
