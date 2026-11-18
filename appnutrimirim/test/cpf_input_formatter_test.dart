import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appnutrimirim/utils/cpf_input_formatter.dart';

TextEditingValue _valor(String texto, {int? cursor}) => TextEditingValue(
  text: texto,
  selection: TextSelection.collapsed(offset: cursor ?? texto.length),
);

void main() {
  final formatter = CpfInputFormatter();

  test('digitação progressiva aplica a máscara e mantém o cursor', () {
    var atual = TextEditingValue.empty;
    for (final digito in '52998224725'.split('')) {
      atual = formatter.formatEditUpdate(atual, _valor('${atual.text}$digito'));
      expect(atual.selection.baseOffset, atual.text.length);
    }
    expect(atual.text, '529.982.247-25');
  });

  test('cola CPF com máscara, apaga tudo e limita a onze dígitos', () {
    final completo = formatter.formatEditUpdate(
      TextEditingValue.empty,
      _valor('529.982.247-25'),
    );
    expect(completo.text, '529.982.247-25');
    expect(
      formatter.formatEditUpdate(completo, _valor('529982247255')),
      completo,
    );
    expect(formatter.formatEditUpdate(completo, _valor('')).text, isEmpty);
  });

  test('edição no meio preserva a posição em vez de saltar ao final', () {
    final editado = formatter.formatEditUpdate(
      _valor('529.982.247-25', cursor: 5),
      _valor('529.82.247-25', cursor: 4),
    );
    expect(editado.text, '529.822.472-5');
    expect(editado.selection.baseOffset, 3);
  });

  test('retrocesso na pontuação permite continuar apagando os dígitos', () {
    final semPonto = formatter.formatEditUpdate(
      _valor('529.982', cursor: 4),
      _valor('529982', cursor: 3),
    );
    expect(semPonto.selection.baseOffset, 3);
    final semDigito = formatter.formatEditUpdate(
      semPonto,
      _valor('52.982', cursor: 2),
    );
    expect(semDigito.text, '529.82');
    expect(semDigito.selection.baseOffset, 2);
  });
}
