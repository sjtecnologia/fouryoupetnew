// lib/utils/formatters.dart
import 'package:flutter/services.dart';

/// Formata um número de cartão de crédito inserindo espaços a cada 4 dígitos.
class CreditCardNumberInputFormatter extends TextInputFormatter {
  // Define o número máximo de dígitos para a maioria dos cartões de crédito
  // (Visa, Mastercard, Discover, etc. geralmente 16, Amex 15, Diners 14, alguns até 19).
  // Usaremos 19 como um limite superior seguro para processamento.
  static const _maxRawDigits = 19;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // O valor atual no campo de texto
    TextEditingValue newValue, // O novo valor após a entrada do usuário
  ) {
    // Remove qualquer caractere não numérico do novo valor
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limita o comprimento do número de dígitos crus
    if (newText.length > _maxRawDigits) {
      newText = newText.substring(0, _maxRawDigits);
    }

    // Calcula quantos dígitos existem antes da posição atual do cursor
    int numDigitsBeforeCursor = 0;
    for (int i = 0; i < newValue.selection.end; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        numDigitsBeforeCursor++;
      }
    }

    // Constrói a string formatada e determina a nova posição do cursor
    String formattedText = '';
    int newCursorPosition = 0;
    int digitCount = 0;

    for (int i = 0; i < newText.length; i++) {
      // Adiciona o dígito atual à string formatada
      formattedText += newText[i];
      digitCount++; // Conta o dígito

      // Se este dígito é o dígito que estava sob/antes do cursor original,
      // define a nova posição do cursor após ele na string formatada.
      if (digitCount == numDigitsBeforeCursor) {
        newCursorPosition = formattedText.length;
      }

      // Adiciona um espaço a cada 4 dígitos, a menos que seja o último dígito
      if (digitCount % 4 == 0 && i < newText.length - 1) {
        formattedText += ' ';
      }
    }

    // Trata o caso especial em que o cursor estava no final do texto original.
    // A nova posição do cursor deve ser o final do texto formatado.
    if (newValue.selection.end == newValue.text.length) {
      newCursorPosition = formattedText.length;
    }

    // Retorna um novo TextEditingValue com o texto formatado e a posição do cursor ajustada
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
