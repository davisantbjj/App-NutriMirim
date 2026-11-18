/// Valida somente o formato e os dígitos verificadores, sem consultar a Receita.
/// Aceita 11 dígitos ou a máscara completa; não descarta caracteres inválidos.
bool cpfValido(String cpf) {
  final texto = cpf.trim();
  if (!RegExp(
    r'^(?:[0-9]{11}|[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2})$',
  ).hasMatch(texto)) {
    return false;
  }
  final digitos = texto.replaceAll(RegExp(r'[.-]'), '');
  if (digitos.split('').every((d) => d == digitos[0])) return false;

  final numeros = digitos.split('').map(int.parse).toList();
  for (final tamanho in [9, 10]) {
    var soma = 0;
    for (var i = 0; i < tamanho; i++) {
      soma += numeros[i] * (tamanho + 1 - i);
    }
    final resto = soma % 11;
    final verificador = resto < 2 ? 0 : 11 - resto;
    if (numeros[tamanho] != verificador) return false;
  }
  return true;
}

/// Retorna uma mensagem para formulários ou null quando o CPF é aceito.
String? validarCpf(String? valor, {bool obrigatorio = true}) {
  if (valor == null || valor.trim().isEmpty) {
    return obrigatorio ? 'Informe o CPF' : null;
  }
  return cpfValido(valor) ? null : 'CPF inválido';
}

/// Aceita vírgula ou ponto decimal; não aceita notação exponencial/unidades.
double? interpretarMedida(String? texto) {
  final valor = (texto ?? '').trim();
  if (!RegExp(r'^[0-9]+(?:[.,][0-9]+)?$').hasMatch(valor)) return null;
  final numero = double.tryParse(valor.replaceAll(',', '.'));
  return numero != null && numero.isFinite && numero > 0 ? numero : null;
}

String? validarMedida(String? texto) => interpretarMedida(texto) == null
    ? 'Informe um número maior que zero'
    : null;
