import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:appnutrimirim/services/antropometria_oms.dart';
import 'package:appnutrimirim/services/validadores.dart';

TabelasOms lerTabelas() {
  String ler(String nome) => File('assets/oms/$nome.txt').readAsStringSync();
  return TabelasOms(
    pesoIdade: ler('weianthro'),
    alturaIdade: ler('lenanthro'),
    pesoComprimento: ler('wflanthro'),
    pesoAltura: ler('wfhanthro'),
    imcIdade: ler('bmianthro'),
  );
}

void main() {
  late TabelasOms tabelas;
  setUpAll(() => tabelas = lerTabelas());
  ValidacaoAntropometrica avaliar({
    int idade = 500,
    SexoOms sexo = SexoOms.masculino,
    double peso = 10,
    double altura = 75,
    PosicaoMedicao posicao = PosicaoMedicao.deitado,
    bool edema = false,
  }) => tabelas.validar(
    sexo: sexo,
    nascimento: DateTime(2020, 1, 1),
    medicao: DateTime(2020, 1, 1).add(Duration(days: idade)),
    hoje: DateTime(2030),
    pesoKg: peso,
    alturaCm: altura,
    posicao: posicao,
    edema: edema,
  );
  ResultadoIndicadorOms indicador(ValidacaoAntropometrica r, IndicadorOms i) =>
      r.indicadores.singleWhere((v) => v.indicador == i);

  // Valores esperados publicados nos testes do pacote WHO anthro (links no documento).
  test('OMS: menina, 1522 dias, 17 kg -> WAZ 0,24', () {
    final r = avaliar(idade: 1522, sexo: SexoOms.feminino, peso: 17);
    expect(indicador(r, IndicadorOms.pesoIdade).zScore, 0.24);
  });
  test('OMS: menino, 987 dias, 72,86 cm deitado -> HAZ -6,09', () {
    final r = avaliar(idade: 987, altura: 72.86);
    expect(r.medidaAjustadaCm, closeTo(72.16, 1e-10));
    expect(indicador(r, IndicadorOms.alturaIdade).zScore, -6.09);
    expect(
      indicador(r, IndicadorOms.alturaIdade).estado,
      EstadoPlausibilidade.conferir,
    );
  });
  test('OMS: menina, 731 dias, 77,5 cm em pé -> HAZ -2,55', () {
    final r = avaliar(
      idade: 731,
      sexo: SexoOms.feminino,
      altura: 77.5,
      posicao: PosicaoMedicao.emPe,
    );
    expect(indicador(r, IndicadorOms.alturaIdade).zScore, -2.55);
    expect(
      indicador(r, IndicadorOms.alturaIdade).estado,
      EstadoPlausibilidade.semAlerta,
    );
  });
  test('medianas oficiais de peso, altura, IMC e peso/comprimento', () {
    final r = avaliar(idade: 0, peso: 3.3464, altura: 49.8842);
    expect(indicador(r, IndicadorOms.pesoIdade).zScore, 0);
    expect(indicador(r, IndicadorOms.alturaIdade).zScore, 0);
    final bmi = avaliar(
      idade: 0,
      peso: 13.4069 * 0.498842 * 0.498842,
      altura: 49.8842,
    );
    expect(indicador(bmi, IndicadorOms.imcIdade).zScore, 0);
    final pe = avaliar(idade: 0, peso: 2.441, altura: 45);
    expect(indicador(pe, IndicadorOms.pesoAltura).zScore, 0);
    final interpolado = avaliar(idade: 0, peso: 2.44935, altura: 45.05);
    expect(indicador(interpolado, IndicadorOms.pesoAltura).zScore, 0);
  });
  for (final i in IndicadorOms.values) {
    test('${i.name}: limites estritos e ausências', () {
      for (final z in [i.minimo, i.maximo, 0.0, -4.0]) {
        expect(avaliarZScore(i, z), EstadoPlausibilidade.semAlerta);
      }
      for (final z in [i.minimo - 0.01, i.maximo + 0.01]) {
        expect(avaliarZScore(i, z), EstadoPlausibilidade.conferir);
      }
      for (final z in [
        null,
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(avaliarZScore(i, z), EstadoPlausibilidade.indisponivel);
      }
    });
  }
  test('mesmas medidas em idades/sexos diferentes não têm resultado fixo', () {
    final a = indicador(avaliar(idade: 10), IndicadorOms.pesoIdade);
    final b = indicador(avaliar(idade: 1000), IndicadorOms.pesoIdade);
    final c = indicador(
      avaliar(idade: 1000, sexo: SexoOms.feminino),
      IndicadorOms.pesoIdade,
    );
    expect(a.zScore, isNot(b.zScore));
    expect(b.zScore, isNot(c.zScore));
    expect(a.estado, EstadoPlausibilidade.conferir);
  });
  test('ajuste único da posição na fronteira 730/731 dias', () {
    expect(
      avaliar(
        idade: 730,
        altura: 80,
        posicao: PosicaoMedicao.emPe,
      ).medidaAjustadaCm,
      80.7,
    );
    expect(avaliar(idade: 730, altura: 80).medidaAjustadaCm, 80);
    expect(avaliar(idade: 731, altura: 80).medidaAjustadaCm, 79.3);
    expect(
      avaliar(
        idade: 731,
        altura: 80,
        posicao: PosicaoMedicao.emPe,
      ).medidaAjustadaCm,
      80,
    );
  });
  test(
    'posição em pé antes de 9 meses pede nova medição sem invalidar P/I',
    () {
      final r = avaliar(idade: 100, posicao: PosicaoMedicao.emPe);
      expect(indicador(r, IndicadorOms.pesoIdade).zScore, isNotNull);
      expect(indicador(r, IndicadorOms.alturaIdade).zScore, isNull);
      expect(
        indicador(r, IndicadorOms.alturaIdade).motivo,
        contains('9 meses'),
      );
    },
  );
  test('edema torna apenas os indicadores de peso indisponíveis', () {
    final r = avaliar(edema: true);
    expect(indicador(r, IndicadorOms.alturaIdade).zScore, isNotNull);
    for (final i in [
      IndicadorOms.pesoIdade,
      IndicadorOms.pesoAltura,
      IndicadorOms.imcIdade,
    ]) {
      expect(indicador(r, i).zScore, isNull);
      expect(indicador(r, i).motivo, contains('Edema'));
    }
  });
  test('domínio P/E não bloqueia E/I; extremos são incluídos', () {
    for (final altura in [45.0, 110.0]) {
      expect(
        indicador(avaliar(altura: altura), IndicadorOms.pesoAltura).zScore,
        isNotNull,
      );
    }
    for (final altura in [44.99, 110.01]) {
      final r = avaliar(altura: altura);
      expect(indicador(r, IndicadorOms.pesoAltura).zScore, isNull);
      expect(indicador(r, IndicadorOms.alturaIdade).zScore, isNotNull);
    }
    for (final altura in [65.0, 120.0, 64.99, 120.01]) {
      final r = avaliar(
        idade: 1000,
        altura: altura,
        posicao: PosicaoMedicao.emPe,
      );
      expect(
        indicador(r, IndicadorOms.pesoAltura).zScore,
        altura >= 65 && altura <= 120 ? isNotNull : isNull,
      );
    }
  });
  test('cobertura <60 meses usa dias/30,4375: último dia 1826', () {
    expect(
      avaliar(idade: 1826).indicadores.every((i) => i.zScore != null),
      isTrue,
    );
    expect(
      avaliar(idade: 1827).indicadores.every((i) => i.zScore == null),
      isTrue,
    );
  });
  test('datas civis, ano bissexto e formatos impossíveis', () {
    expect(idadeEmDias(DateTime(2024, 2, 28, 23), DateTime(2024, 3, 1)), 2);
    expect(interpretarDataBrasileira('29/02/2024'), DateTime(2024, 2, 29));
    expect(interpretarDataBrasileira('29/02/2023'), isNull);
    expect(interpretarDataBrasileira('31/04/2024'), isNull);
    expect(interpretarDataBrasileira(''), isNull);
    expect(
      avaliar(idade: -1).erros,
      contains('A medição não pode ser anterior ao nascimento.'),
    );
  });
  test('dados ausentes, futuros e números inválidos nunca passam', () {
    final r = tabelas.validar(
      sexo: null,
      nascimento: DateTime(2040),
      medicao: DateTime(2041),
      hoje: DateTime(2030),
      pesoKg: double.nan,
      alturaCm: double.infinity,
      posicao: null,
      edema: null,
    );
    expect(r.erros.length, 7);
    expect(
      r.indicadores.every((i) => i.estado == EstadoPlausibilidade.indisponivel),
      isTrue,
    );
    for (final peso in [0.0, -1.0, double.nan, double.infinity]) {
      expect(avaliar(peso: peso).erros, isNotEmpty);
    }
    expect(avaliar(altura: 1e308).temIndisponiveis, isTrue);
    expect(avaliar(peso: 1e308).precisaConferencia, isTrue);
  });
  test('entradas aceitam decimal local sem expoentes nem unidades', () {
    expect(interpretarMedida(' 12,5 '), 12.5);
    expect(interpretarMedida('12.5'), 12.5);
    for (final texto in [
      '',
      'NaN',
      'Infinity',
      '0',
      '-1',
      '1e2',
      '12 kg',
      '1,2.3',
    ]) {
      expect(validarMedida(texto), isNotNull);
    }
  });
  test('asset parcial falha explicitamente', () {
    expect(
      () => TabelasOms(
        pesoIdade: 'sex age l m s\n1 0 1 1 1',
        alturaIdade: '',
        pesoComprimento: '',
        pesoAltura: '',
        imcIdade: '',
      ),
      throwsFormatException,
    );
  });
}
