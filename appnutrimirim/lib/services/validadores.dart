String somenteDigitos(String valor) => valor.replaceAll(RegExp(r'\D'), '');

bool cpfValido(String valor) {
  final cpf = somenteDigitos(valor);
  if (cpf.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
    return false;
  }

  int calcularDigito(String base, int pesoInicial) {
    var soma = 0;
    for (var i = 0; i < base.length; i++) {
      soma += int.parse(base[i]) * (pesoInicial - i);
    }
    final resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }

  final primeiro = calcularDigito(cpf.substring(0, 9), 10);
  final segundo = calcularDigito('${cpf.substring(0, 9)}$primeiro', 11);
  return cpf.endsWith('$primeiro$segundo');
}

String? validarCpf(String? valor, {bool obrigatorio = true}) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return obrigatorio ? 'Campo obrigatório' : null;
  return cpfValido(texto) ? null : 'CPF inválido';
}
