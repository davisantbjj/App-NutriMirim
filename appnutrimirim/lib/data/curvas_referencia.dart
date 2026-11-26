import 'dart:math' as math;

import '../services/antropometria_oms.dart';
import 'models.dart';

/// Indicadores mostrados na tela 08 (Curva de Crescimento).
enum IndicadorCurva {
  pesoIdade(IndicadorOms.pesoIdade),
  alturaIdade(IndicadorOms.alturaIdade),
  pesoAltura(IndicadorOms.pesoAltura);

  const IndicadorCurva(this.oms);
  final IndicadorOms oms;
}

/// Linhas de z-score desenhadas no gráfico.
const zScoresDaCurva = [3, 2, 0, -2, -3];

/// Dias por mês usados pela OMS (365,25 / 12).
const diasPorMes = 30.4375;

/// Curvas de referência de um indicador: valores de cada linha de Z-score
/// (-3, -2, 0, +2, +3) nos pontos de [xs].
///
/// [CurvaReferencia.oms] calcula as linhas pelas tabelas LMS da OMS 2006
/// (as mesmas do z-score). [CurvaReferencia.eixos] traz só os eixos, sem
/// linhas, enquanto as tabelas carregam ou se o carregamento falhar.
class CurvaReferencia {
  const CurvaReferencia({
    required this.xs,
    required this.linhas,
    required this.yMin,
    required this.yMax,
    required this.yStep,
    required this.xTicks,
  });

  final List<double> xs;
  final Map<int, List<double>> linhas; // z-score -> valores
  final double yMin, yMax, yStep;
  final List<double> xTicks;

  double get xMin => xs.first;
  double get xMax => xs.last;

  /// Se o ponto cabe na área do gráfico.
  bool contem(double x, double y) =>
      x >= xMin && x <= xMax && y >= yMin && y <= yMax;

  /// Eixos do gráfico, sem as linhas de referência.
  ///
  /// [comprimento] vale para P/E: tabela por comprimento (45 a 110 cm,
  /// menores de 2 anos) ou por altura (65 a 120 cm).
  factory CurvaReferencia.eixos(
    IndicadorCurva indicador, {
    bool comprimento = true,
  }) {
    final (xs, ticks) = _eixoX(indicador, comprimento);
    final (yMin, yMax, yStep) = switch (indicador) {
      IndicadorCurva.alturaIdade => (40.0, 125.0, 10.0),
      IndicadorCurva.pesoIdade || IndicadorCurva.pesoAltura => (0.0, 30.0, 5.0),
    };
    return CurvaReferencia(
      xs: xs,
      linhas: const {},
      yMin: yMin,
      yMax: yMax,
      yStep: yStep,
      xTicks: ticks,
    );
  }

  /// Curvas da OMS 2006 para o [sexo], calculadas das [tabelas].
  factory CurvaReferencia.oms(
    TabelasOms tabelas,
    IndicadorCurva indicador,
    Sexo sexo, {
    bool comprimento = true,
  }) {
    final base = CurvaReferencia.eixos(indicador, comprimento: comprimento);
    final porIdade = indicador != IndicadorCurva.pesoAltura;
    final sexoOms = sexo == Sexo.feminino
        ? SexoOms.feminino
        : SexoOms.masculino;
    final xs = <double>[];
    final linhas = {for (final z in zScoresDaCurva) z: <double>[]};
    for (final x in base.xs) {
      // Por idade, o eixo é em meses e a tabela em dias (até 1826 = 60 m).
      final eixo = porIdade
          ? math.min((x * diasPorMes).roundToDouble(), 1826.0)
          : x;
      final valores = [
        for (final z in zScoresDaCurva)
          tabelas.valorReferencia(
            indicador: indicador.oms,
            sexo: sexoOms,
            eixo: eixo,
            z: z.toDouble(),
            comprimento: comprimento,
          ),
      ];
      if (valores.any((v) => v == null)) continue;
      xs.add(x);
      for (var i = 0; i < zScoresDaCurva.length; i++) {
        linhas[zScoresDaCurva[i]]!.add(valores[i]!);
      }
    }
    return CurvaReferencia(
      xs: xs,
      linhas: linhas,
      yMin: base.yMin,
      yMax: base.yMax,
      yStep: base.yStep,
      xTicks: base.xTicks,
    );
  }
}

(List<double>, List<double>) _eixoX(IndicadorCurva ind, bool comprimento) {
  if (ind != IndicadorCurva.pesoAltura) {
    return (
      [for (var m = 0; m <= 60; m++) m.toDouble()],
      [for (var m = 0; m <= 60; m += 6) m.toDouble()],
    );
  }
  final (inicio, fim) = comprimento ? (45, 110) : (65, 120);
  return (
    [for (var cm = inicio; cm <= fim; cm++) cm.toDouble()],
    [for (var cm = inicio; cm <= fim; cm += 10) cm.toDouble()],
  );
}
