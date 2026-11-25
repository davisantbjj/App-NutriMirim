/// Z-score e percentil de uma avaliação já registrada, para a Curva (RF06).
library;

import 'dart:math' as math;

import '../data/models.dart';
import '../utils/formatters.dart';
import 'antropometria_oms.dart';
import 'classificacao.dart';
import 'resultado_nutricional.dart';

/// Posição da medida: a registrada (`deitado`/`em_pe`) ou, sem registro, a
/// esperada pela OMS para a idade (deitado antes dos 2 anos).
PosicaoMedicao posicaoDaAvaliacao(Avaliacao a, {int? idadeDias}) =>
    switch (a.tipoMedida) {
      'deitado' => PosicaoMedicao.deitado,
      'em_pe' => PosicaoMedicao.emPe,
      _ =>
        idadeDias != null && idadeDias >= 731
            ? PosicaoMedicao.emPe
            : PosicaoMedicao.deitado,
    };

/// Z-score do [indicador] na avaliação [a] da criança [c].
///
/// Usa o valor gravado em [Avaliacao.indicadores] quando existe (o z-score
/// calculado no registro, com o edema observado). Senão, calcula pelas
/// [tabelas] sem edema, porque a avaliação não guarda essa informação.
/// Nulo sem nascimento, fora da tabela ou com valor a conferir.
double? zScoreDaAvaliacao(
  TabelasOms tabelas,
  Crianca c,
  Avaliacao a,
  IndicadorOms indicador,
) {
  final gravado = a.indicadores[indicadorAntropometrico(indicador).chave];
  if (gravado != null) return gravado.zScore;

  final nascimento = c.nascimento;
  if (nascimento == null) return null;
  final validacao = tabelas.validar(
    sexo: c.sexo == Sexo.feminino ? SexoOms.feminino : SexoOms.masculino,
    nascimento: nascimento,
    medicao: a.data,
    hoje: a.data,
    pesoKg: a.pesoKg,
    alturaCm: a.alturaCm,
    posicao: posicaoDaAvaliacao(a, idadeDias: idadeEmDias(nascimento, a.data)),
    edema: false,
  );
  final r = validacao.indicadores.firstWhere((i) => i.indicador == indicador);
  return r.estado == EstadoPlausibilidade.semAlerta ? r.zScore : null;
}

/// Situação do z-score de um indicador da Curva (cores do app).
Situacao situacaoDoZScore(IndicadorOms indicador, double z) {
  final c = classificarIndicador(indicadorAntropometrico(indicador), z);
  return situacaoDe(c.gravidade, c.desvio);
}

/// Percentil (0 a 100) equivalente ao z-score na distribuição normal.
double percentilDeZ(double z) => 50 * (1 + _erf(z / math.sqrt2));

/// Texto do percentil: "P15,9", ou "< P0,1" e "> P99,9" nos extremos.
String formatarPercentil(double z) {
  final p = percentilDeZ(z);
  if (p < 0.1) return '< P0,1';
  if (p > 99.9) return '> P99,9';
  return 'P${formatarDecimal(p)}';
}

/// Função erro (Abramowitz e Stegun 7.1.26; erro < 1,5e-7).
double _erf(double x) {
  final sinal = x < 0 ? -1 : 1;
  final a = x.abs();
  final t = 1 / (1 + 0.3275911 * a);
  final y =
      1 -
      (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t -
                      0.284496736) *
                  t +
              0.254829592) *
          t *
          math.exp(-a * a);
  return sinal * y;
}
