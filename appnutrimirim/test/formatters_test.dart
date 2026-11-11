import 'package:flutter_test/flutter_test.dart';

import 'package:appnutrimirim/utils/formatters.dart';

void main() {
  group('formatarDecimal', () {
    test('usa vírgula e uma casa por padrão', () {
      expect(formatarDecimal(9.8), '9,8');
      expect(formatarDecimal(85), '85,0');
    });

    test('respeita casas = 0 e 2', () {
      expect(formatarDecimal(9.84, casas: 0), '10');
      expect(formatarDecimal(9.8, casas: 2), '9,80');
      expect(formatarDecimal(0, casas: 2), '0,00');
    });

    test('arredonda para cima a partir da metade', () {
      expect(formatarDecimal(0.05), '0,1');
      expect(formatarDecimal(9.86), '9,9');
      expect(formatarDecimal(9.84), '9,8');
      expect(formatarDecimal(0.5, casas: 0), '1');
    });

    test(
      '9.85 sai 9,8: toStringAsFixed arredonda o valor binário (9.8499...)',
      () {
        // Comportamento conhecido e aceito; o código antigo fazia o mesmo.
        expect(formatarDecimal(9.85), '9,8');
      },
    );

    test('números negativos mantêm o sinal', () {
      expect(formatarDecimal(-1.5), '-1,5');
    });

    test('nunca contém ponto decimal', () {
      expect(formatarDecimal(1234.5678, casas: 3).contains('.'), isFalse);
    });
  });

  group('formatarNumero', () {
    test('inteiro sai sem casas', () {
      expect(formatarNumero(85.0), '85');
      expect(formatarNumero(0), '0');
      expect(formatarNumero(-3), '-3');
    });

    test('fracionário usa vírgula', () {
      expect(formatarNumero(12.5), '12,5');
      expect(formatarNumero(12.25, casas: 2), '12,25');
    });

    test('valor que arredonda para inteiro sai sem casas', () {
      expect(formatarNumero(85.04), '85');
      expect(formatarNumero(85.96), '86');
      expect(formatarNumero(12.04, casas: 2), '12,04');
      expect(formatarNumero(12.50, casas: 2), '12,5');
    });
  });

  group('formatarPeso / formatarAltura', () {
    test('peso sempre com uma casa e kg', () {
      expect(formatarPeso(9.8), '9,8 kg');
      expect(formatarPeso(12), '12,0 kg');
    });

    test('altura inteira sem casas, fracionada com vírgula', () {
      expect(formatarAltura(85), '85 cm');
      expect(formatarAltura(85.5), '85,5 cm');
    });
  });

  group('formatarData / formatarDataHora', () {
    test('dia e mês com zero à esquerda', () {
      expect(formatarData(DateTime(2026, 11, 5)), '05/11/2026');
      expect(formatarData(DateTime(2026, 1, 9)), '09/01/2026');
      expect(formatarData(DateTime(2026, 12, 31)), '31/12/2026');
    });

    test('hora e minuto com zero à esquerda', () {
      expect(
        formatarDataHora(DateTime(2026, 9, 28, 8, 42)),
        '28/09/2026 às 08:42',
      );
      expect(
        formatarDataHora(DateTime(2026, 1, 2, 0, 5)),
        '02/01/2026 às 00:05',
      );
      expect(
        formatarDataHora(DateTime(2026, 1, 2, 23, 59)),
        '02/01/2026 às 23:59',
      );
    });
  });

  group('idadeEmMeses', () {
    final hoje = DateTime(2026, 11, 15);

    test('mesmo dia de nascimento: 0 meses', () {
      expect(idadeEmMeses(hoje, hoje: hoje), 0);
    });

    test('antes do dia do aniversário mensal ainda não completou', () {
      expect(idadeEmMeses(DateTime(2026, 10, 16), hoje: hoje), 0);
      expect(idadeEmMeses(DateTime(2026, 9, 16), hoje: hoje), 1);
    });

    test('no dia e depois do dia do aniversário mensal completou', () {
      expect(idadeEmMeses(DateTime(2026, 10, 15), hoje: hoje), 1);
      expect(idadeEmMeses(DateTime(2026, 10, 14), hoje: hoje), 1);
    });

    test('virada de ano', () {
      expect(idadeEmMeses(DateTime(2025, 12, 20), hoje: hoje), 10);
      expect(idadeEmMeses(DateTime(2025, 12, 10), hoje: hoje), 11);
      expect(idadeEmMeses(DateTime(2025, 11, 15), hoje: hoje), 12);
    });

    test('nascimento no futuro retorna 0', () {
      expect(idadeEmMeses(DateTime(2027, 1, 1), hoje: hoje), 0);
    });

    test('sem hoje usa a data atual', () {
      expect(idadeEmMeses(DateTime.now()), 0);
    });
  });

  group('formatarIdade', () {
    final hoje = DateTime(2026, 11, 15);

    test('0 meses e singular/plural de meses', () {
      expect(formatarIdade(hoje, hoje: hoje), '0 meses');
      expect(formatarIdade(DateTime(2026, 10, 15), hoje: hoje), '1 mês');
      expect(formatarIdade(DateTime(2026, 3, 15), hoje: hoje), '8 meses');
    });

    test('abaixo de 24 meses a idade fica em meses (caderneta/OMS)', () {
      expect(formatarIdade(DateTime(2025, 11, 15), hoje: hoje), '12 meses');
      expect(formatarIdade(DateTime(2024, 12, 15), hoje: hoje), '23 meses');
    });

    test('anos completos e anos com meses', () {
      expect(formatarIdade(DateTime(2024, 11, 15), hoje: hoje), '2 anos');
      expect(
        formatarIdade(DateTime(2024, 8, 15), hoje: hoje),
        '2 anos e 3 meses',
      );
      expect(
        formatarIdade(DateTime(2024, 10, 15), hoje: hoje),
        '2 anos e 1 mês',
      );
    });

    test('antes do aniversário de 2 anos ainda mostra meses', () {
      expect(formatarIdade(DateTime(2024, 11, 16), hoje: hoje), '23 meses');
    });
  });
}
