bool emailValid(String email) {
  final RegExp regex = RegExp(
      r"^(([^<>()[\]\\.,;:\s@\']+(\.[^<>()[\]\\.,;:\s@\']+)*)|(\'.+\'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$");
  return regex.hasMatch(email);
}

bool isValidCPF(String cpf) {
  // Remove caracteres não numéricos
  cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');

  // Verifica se tem 11 dígitos
  if (cpf.length != 11) return false;

  // Verifica se todos os dígitos são iguais
  if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;

  // Calcula o primeiro dígito verificador
  int sum = 0;
  for (int i = 0; i < 9; i++) {
    sum += int.parse(cpf[i]) * (10 - i);
  }
  int firstDigit = (sum * 10) % 11;
  if (firstDigit == 10) firstDigit = 0;

  // Verifica o primeiro dígito
  if (firstDigit != int.parse(cpf[9])) return false;

  // Calcula o segundo dígito verificador
  sum = 0;
  for (int i = 0; i < 10; i++) {
    sum += int.parse(cpf[i]) * (11 - i);
  }
  int secondDigit = (sum * 10) % 11;
  if (secondDigit == 10) secondDigit = 0;

  // Verifica o segundo dígito
  return secondDigit == int.parse(cpf[10]);
}
