import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Color(0xFFF7931E)), // Cor laranja
        SizedBox(height: 16),
        Text("Carregando informações...", style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
