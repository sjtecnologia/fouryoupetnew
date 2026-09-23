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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );

  final String text;
  final bool isFavorite;
  final VoidCallback onPressed;
}
