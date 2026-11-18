import 'package:flutter_test/flutter_test.dart';
import 'package:appnutrimirim/services/validadores.dart';

void main() {
  group('CPF: formato e dois dígitos verificadores', () {
    for (final cpf in [
      '52998224725',
      '529.982.247-25',
      ' 529.982.247-25 ',
      '11144477735',
      '12345678909',
    ]) {
      test('aceita $cpf', () => expect(cpfValido(cpf), isTrue));
    }
    for (final cpf in [
      '',
      '123',
      '5299822472',
      '529982247255',
      '52998224735',
      '52998224724',
      '529.982.24725',
      '529-982-247.25',
      'abc52998224725',
      '529 982 247 25',
      for (var i = 0; i <= 9; i++) '$i' * 11,
    ]) {
      test('rejeita "$cpf"', () => expect(cpfValido(cpf), isFalse));
    }
  });

  test('CPF do responsável é obrigatório e o da criança é opcional', () {
    for (final vazio in [null, '', '   ']) {
      expect(validarCpf(vazio), 'Informe o CPF');
      expect(validarCpf(vazio, obrigatorio: false), isNull);
    }
    expect(validarCpf('123', obrigatorio: false), 'CPF inválido');
    expect(validarCpf('529.982.247-25'), isNull);
  });
}
