/// Liga os z-scores da OMS (`antropometria_oms.dart`, RF03) à classificação,
/// às condutas, ao retorno e ao alerta (`classificacao.dart`, RF04, RF13,
/// RF17 e RF12). É o argumento da tela 07 (Resultado).
library;

import '../data/models.dart';
import 'antropometria_oms.dart';
import 'classificacao.dart';

/// Indicador que não entrou na classificação, com o motivo (edema, posição
/// inadequada, fora da tabela).
class IndicadorIndisponivel {
  const IndicadorIndisponivel(this.indicador, this.motivo);
  final IndicadorAntropometrico indicador;
  final String motivo;
}

/// Resultado nutricional de uma avaliação, pronto para a tela 07.
class ResultadoNutricional {
  const ResultadoNutricional({
    required this.criancaId,
    required this.dataAvaliacao,
    required this.classificacao,
    required this.indisponiveis,
    required this.condutas,
    required this.retorno,
    required this.alerta,
    this.idadeMeses,
    this.medidaUsadaCm,
  });

  /// [Crianca.id], para abrir a Curva da mesma criança.
  final String criancaId;
  final DateTime dataAvaliacao;
  final int? idadeMeses;

  /// Medida usada no cálculo, após o ajuste de 0,7 cm pela posição.
  final double? medidaUsadaCm;
  final ClassificacaoAvaliacao classificacao;
  final List<IndicadorIndisponivel> indisponiveis;
  final List<String> condutas;

  /// Nulo quando o profissional deve definir a data (sem nascimento).
  final DateTime? retorno;
  final AlertaEncaminhamento? alerta;
}

/// Mesma ordem e mesmo significado dos dois enums.
IndicadorAntropometrico indicadorAntropometrico(IndicadorOms i) => switch (i) {
  IndicadorOms.pesoIdade => IndicadorAntropometrico.pesoIdade,
  IndicadorOms.alturaIdade => IndicadorAntropometrico.estaturaIdade,
  IndicadorOms.pesoAltura => IndicadorAntropometrico.pesoEstatura,
  IndicadorOms.imcIdade => IndicadorAntropometrico.imcIdade,
};

/// Monta o resultado a partir da validação da tela 06.
///
/// Devolve `null` quando não há o que classificar: erros de entrada, algum
/// z-score fora dos limites de plausibilidade (a medida precisa ser
/// conferida antes, para não classificar um erro de digitação) ou nenhum
/// indicador calculado sem edema.
ResultadoNutricional? montarResultadoNutricional({
  required String criancaId,
  required ValidacaoAntropometrica validacao,
  required DateTime dataAvaliacao,
  required DateTime? nascimento,
  required bool edema,
}) {
  if (validacao.erros.isNotEmpty || validacao.precisaConferencia) return null;

  final zScores = <IndicadorAntropometrico, double>{};
  final indisponiveis = <IndicadorIndisponivel>[];
  for (final r in validacao.indicadores) {
    final indicador = indicadorAntropometrico(r.indicador);
    final z = r.zScore;
    if (z != null && r.estado == EstadoPlausibilidade.semAlerta) {
      zScores[indicador] = z;
    } else {
      indisponiveis.add(
        IndicadorIndisponivel(indicador, r.motivo ?? 'Indisponível.'),
      );
    }
  }
  if (zScores.isEmpty && !edema) return null;

  final classificacao = classificarAvaliacao(zScores, edema: edema);
  final dias = validacao.idadeDias;
  final idadeMeses = dias == null ? null : (dias / 30.4375).floor();
  return ResultadoNutricional(
    criancaId: criancaId,
    dataAvaliacao: dataAvaliacao,
    idadeMeses: idadeMeses,
    medidaUsadaCm: validacao.medidaAjustadaCm,
    classificacao: classificacao,
    indisponiveis: indisponiveis,
    condutas: microCondutas(classificacao, idadeMeses: idadeMeses),
    retorno: sugerirRetorno(
      dataAvaliacao,
      classificacao.gravidade,
      nascimento: nascimento,
    ),
    alerta: alertaEncaminhamento(classificacao),
  );
}

/// Situação (cores e selo do app) de um indicador classificado: verde é
/// [Situacao.normal], amarelo é [Situacao.atencao], déficit no vermelho é
/// [Situacao.abaixo] e obesidade é [Situacao.risco].
Situacao situacaoDe(Gravidade gravidade, Desvio desvio) => switch (gravidade) {
  Gravidade.adequado => Situacao.normal,
  Gravidade.atencao => Situacao.atencao,
  Gravidade.risco || Gravidade.grave =>
    desvio == Desvio.excesso ? Situacao.risco : Situacao.abaixo,
};
