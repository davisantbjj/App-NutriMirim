import 'package:flutter/services.dart';

abstract class _MascaraNumericaFormatter extends TextInputFormatter {
  const _MascaraNumericaFormatter(this.limite);

  final int limite;

  String formatar(String digitos);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitados = digitos.length > limite
        ? digitos.substring(0, limite)
        : digitos;
    final texto = formatar(limitados);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

class CpfInputFormatter extends _MascaraNumericaFormatter {
  const CpfInputFormatter() : super(11);

  @override
  String formatar(String digitos) {
    final buffer = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digitos[i]);
    }
    return buffer.toString();
  }
}

class TelefoneInputFormatter extends _MascaraNumericaFormatter {
  const TelefoneInputFormatter() : super(11);

  @override
  String formatar(String digitos) {
    if (digitos.isEmpty) return '';

    final buffer = StringBuffer('(');
    final dddLength = digitos.length < 2 ? digitos.length : 2;
    buffer.write(digitos.substring(0, dddLength));
    if (digitos.length <= 2) return buffer.toString();

    buffer.write(') ');
    final numero = digitos.substring(2);
    final inicioHifen = digitos.length == 11 ? 5 : 4;
    if (numero.length <= inicioHifen) {
      buffer.write(numero);
      return buffer.toString();
    }

    buffer
      ..write(numero.substring(0, inicioHifen))
      ..write('-')
      ..write(numero.substring(inicioHifen));
    return buffer.toString();
  }
}
