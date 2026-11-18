import 'models.dart';

/// Indicadores mostrados na tela 08 (Curva de Crescimento).
enum IndicadorCurva { pesoIdade, alturaIdade, pesoAltura }

/// Curvas de referência de um indicador: valores de cada linha de Z-score
/// (-3, -2, 0, +2, +3) nos pontos de [xs].
///
/// Valores APROXIMADOS das curvas da OMS (0 a 5 anos), só para desenhar o
/// gráfico. O cálculo real do Z-score (tabelas LMS) é a task de back-end
/// "z-score OMS" e vai substituir estes dados.
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

  static CurvaReferencia de(IndicadorCurva indicador, Sexo sexo) {
    final menina = sexo == Sexo.feminino;
    return switch (indicador) {
      IndicadorCurva.pesoIdade => menina ? _pesoIdadeF : _pesoIdadeM,
      IndicadorCurva.alturaIdade => menina ? _alturaIdadeF : _alturaIdadeM,
      IndicadorCurva.pesoAltura => menina ? _pesoAlturaF : _pesoAlturaM,
    };
  }
}

const _meses = <double>[0, 6, 12, 24, 36, 48, 60];
const _tickMeses = <double>[0, 6, 12, 18, 24, 30, 36, 42, 48, 54, 60];
const _alturas = <double>[45, 60, 75, 90, 105, 120];

const _pesoIdadeF = CurvaReferencia(
  xs: _meses,
  linhas: {
    3: [4.8, 10.6, 13.1, 17.0, 20.9, 25.2, 29.5],
    2: [4.2, 9.3, 11.5, 14.8, 18.1, 21.5, 24.9],
    0: [3.2, 7.3, 8.9, 11.5, 13.9, 16.1, 18.2],
    -2: [2.4, 5.7, 7.0, 9.0, 10.8, 12.3, 13.7],
    -3: [2.0, 5.1, 6.3, 8.1, 9.6, 10.9, 12.1],
  },
  yMin: 0,
  yMax: 30,
  yStep: 5,
  xTicks: _tickMeses,
);

const _pesoIdadeM = CurvaReferencia(
  xs: _meses,
  linhas: {
    3: [5.0, 10.9, 13.3, 17.1, 20.7, 24.2, 27.9],
    2: [4.4, 9.8, 12.0, 15.3, 18.3, 21.2, 24.2],
    0: [3.3, 7.9, 9.6, 12.2, 14.3, 16.3, 18.3],
    -2: [2.5, 6.4, 7.7, 9.7, 11.3, 12.7, 14.1],
    -3: [2.1, 5.7, 6.9, 8.6, 10.0, 11.2, 12.4],
  },
  yMin: 0,
  yMax: 30,
  yStep: 5,
  xTicks: _tickMeses,
);

const _alturaIdadeF = CurvaReferencia(
  xs: _meses,
  linhas: {
    3: [54.7, 71.6, 81.7, 95.2, 105.0, 113.0, 120.0],
    2: [52.9, 69.6, 79.2, 92.0, 101.4, 109.0, 115.7],
    0: [49.1, 65.7, 74.0, 85.7, 95.1, 102.7, 109.4],
    -2: [45.4, 61.8, 68.9, 79.3, 88.0, 95.0, 101.0],
    -3: [43.6, 59.9, 66.3, 76.0, 84.0, 91.0, 97.0],
  },
  yMin: 40,
  yMax: 125,
  yStep: 10,
  xTicks: _tickMeses,
);

const _alturaIdadeM = CurvaReferencia(
  xs: _meses,
  linhas: {
    3: [55.6, 74.0, 82.9, 96.3, 107.2, 115.9, 123.9],
    2: [53.7, 71.9, 80.5, 93.2, 103.5, 111.7, 119.2],
    0: [49.9, 67.6, 75.7, 87.1, 96.1, 103.3, 110.0],
    -2: [46.1, 63.3, 71.0, 81.0, 88.7, 94.9, 100.7],
    -3: [44.2, 61.2, 68.6, 78.0, 85.0, 90.7, 96.1],
  },
  yMin: 40,
  yMax: 125,
  yStep: 10,
  xTicks: _tickMeses,
);

const _pesoAlturaF = CurvaReferencia(
  xs: _alturas,
  linhas: {
    3: [3.0, 7.1, 11.0, 15.3, 20.2, 27.0],
    2: [2.7, 6.4, 10.0, 13.9, 18.4, 24.5],
    0: [2.5, 5.5, 8.9, 12.1, 16.0, 21.2],
    -2: [2.0, 4.8, 7.7, 10.6, 14.0, 18.5],
    -3: [1.9, 4.5, 7.2, 10.0, 13.1, 17.3],
  },
  yMin: 0,
  yMax: 30,
  yStep: 5,
  xTicks: _alturas,
);

const _pesoAlturaM = CurvaReferencia(
  xs: _alturas,
  linhas: {
    3: [3.3, 7.6, 12.2, 15.8, 21.2, 28.7],
    2: [3.0, 7.0, 11.2, 14.6, 19.4, 26.0],
    0: [2.4, 5.9, 9.5, 12.9, 16.8, 22.4],
    -2: [2.0, 5.1, 8.3, 11.3, 14.8, 19.6],
    -3: [1.9, 4.7, 7.7, 10.5, 13.8, 18.2],
  },
  yMin: 0,
  yMax: 30,
  yStep: 5,
  xTicks: _alturas,
);
