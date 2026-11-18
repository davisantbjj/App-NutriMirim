import 'package:flutter/services.dart';

/// Aplica a máscara progressiva sem mover o cursor sempre para o final.
class CpfInputFormatter extends TextInputFormatter {
  const CpfInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;
    final digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length > 11) return oldValue;

    final buffer = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digitos[i]);
    }
    final texto = buffer.toString();

    int mapearCursor(int offset) {
      if (offset < 0) return texto.length;
      final quantidade = newValue.text
          .substring(0, offset.clamp(0, newValue.text.length))
          .replaceAll(RegExp(r'[^0-9]'), '')
          .length;
      if (quantidade == 0) return 0;
      var encontrados = 0;
      for (var i = 0; i < texto.length; i++) {
        if (RegExp(r'[0-9]').hasMatch(texto[i])) encontrados++;
        if (encontrados == quantidade) return i + 1;
      }
      return texto.length;
    }

    return TextEditingValue(
      text: texto,
      selection: TextSelection(
        baseOffset: mapearCursor(newValue.selection.baseOffset),
        extentOffset: mapearCursor(newValue.selection.extentOffset),
      ),
    );
  }
}
