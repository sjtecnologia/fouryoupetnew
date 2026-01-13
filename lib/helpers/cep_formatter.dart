/// Formata o valor do campo com a mascara de CEP `XX.XXX-XXX`
class CepFormatter {
  /// Define o tamanho máximo do campo.
  final maxLength = 8;

  /// [ponto] indica se o formato do CEP deve utilizar `.` ou não.
  final bool ponto;

  CepFormatter({this.ponto = true});

  String formatEditUpdate(String oldValue, String newValue) {
    final newValueLength = newValue.length;

    if (newValueLength > maxLength) {
      return oldValue;
    }
    var substrInicio = 2;
    if (!ponto) {
      substrInicio = 0;
    }

    var substrIndex = 0;
    final newText = StringBuffer();

    if (newValueLength >= 3 && ponto) {
      newText.write(newValue.substring(0, substrIndex = 2) + '.');
    }
    if (newValueLength >= 6) {
      newText.write(newValue.substring(substrInicio, substrIndex = 5) + '-');
    }

    if (newValueLength >= substrIndex) {
      newText.write(newValue.substring(substrIndex));
    }

    return newText.toString();
  }
}
