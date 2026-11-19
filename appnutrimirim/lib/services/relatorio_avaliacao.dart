import '../data/models.dart';
import '../utils/formatters.dart';
import 'antropometria_oms.dart';
import 'classificacao.dart';

String gerarRelatorioAvaliacao({
  required Crianca crianca,
  required DateTime nascimento,
  required DateTime dataAvaliacao,
  required ValidacaoAntropometrica validacao,
}) {
  final zScores = <IndicadorAntropometrico, double>{};
  for (final resultado in validacao.indicadores) {
    final zScore = resultado.zScore;
    if (zScore != null && zScore.isFinite) {
      zScores[_indicadorParaClassificacao(resultado.indicador)] = zScore;
    }
  }

  final classificacao = zScores.isEmpty ? null : classificarAvaliacao(zScores);
  final linhas = <String>[
    'Relatório resumido de avaliação — NutriMirim',
    '',
    'Criança: ${crianca.nome}',
    'Sexo: ${crianca.sexo == Sexo.feminino ? 'Feminino' : 'Masculino'}',
    'Data de nascimento: ${formatarData(nascimento)}',
    'Data da avaliação: ${formatarData(dataAvaliacao)}',
    '',
    classificacao == null
        ? 'Classificação geral: indisponível (nenhum z-score calculado).'
        : 'Classificação geral (indicadores disponíveis): '
              '${classificacao.pior.diagnostico}.',
    '',
    'Indicadores:',
  ];

  for (final indicador in IndicadorOms.values) {
    ResultadoIndicadorOms? resultado;
    for (final item in validacao.indicadores) {
      if (item.indicador == indicador) {
        resultado = item;
        break;
      }
    }

    final zScore = resultado?.zScore;
    if (zScore == null || !zScore.isFinite) {
      linhas.add('- ${indicador.rotulo}: z-score indisponível.');
      continue;
    }

    final faixa = classificarIndicador(
      _indicadorParaClassificacao(indicador),
      zScore,
    );
    linhas.add(
      '- ${indicador.rotulo}: z = ${formatarDecimal(zScore, casas: 2)}; '
      '${faixa.diagnostico}.',
    );
  }

  if (validacao.precisaConferencia) {
    linhas
      ..add('')
      ..add('Atenção: um ou mais indicadores exigem conferência das medidas.');
  }
  if (validacao.erros.isNotEmpty) {
    linhas
      ..add('')
      ..addAll(validacao.erros.map((erro) => 'Atenção: $erro'));
  }

  linhas
    ..add('')
    ..add('Confira os dados antes de compartilhar.')
    ..add('A interpretação deve ser feita por um profissional de saúde.');

  return linhas.join('\n');
}

IndicadorAntropometrico _indicadorParaClassificacao(IndicadorOms indicador) =>
    switch (indicador) {
      IndicadorOms.pesoIdade => IndicadorAntropometrico.pesoIdade,
      IndicadorOms.alturaIdade => IndicadorAntropometrico.estaturaIdade,
      IndicadorOms.pesoAltura => IndicadorAntropometrico.pesoEstatura,
      IndicadorOms.imcIdade => IndicadorAntropometrico.imcIdade,
    };
