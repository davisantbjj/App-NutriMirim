/// Classificação nutricional a partir do z-score (RF04), micro-condutas por
/// faixa (RF13), sugestão de retorno (RF17) e alerta de encaminhamento (RF12).
///
/// Funções puras, sem Flutter nem Firebase. O z-score vem de fora (cálculo da
/// OMS em RF03).
///
/// Fontes:
/// - Pontos de corte: Ministério da Saúde, "Orientações para a coleta e
///   análise de dados antropométricos em serviços de saúde" (SISVAN, 2011),
///   crianças de 0 a 5 anos, padrão OMS 2006.
/// - Retorno e encaminhamento: AIDPI Criança (MS/OPAS, 2017) e OMS,
///   "Updates on the management of severe acute malnutrition" (2013).
/// - Retorno da criança sem alteração: calendário mínimo de consultas da
///   Caderneta da Criança e do Caderno de Atenção Básica nº 33 (MS, 2012).
///
/// A cor do semáforo não é definida pelo SISVAN: é a convenção do app
/// (RF04): verde para a faixa adequada, amarelo para excesso de peso que
/// ainda não é obesidade e vermelho para déficit (z < -2) e obesidade.
library;

/// Indicadores antropométricos. A [chave] é a mesma usada no Firestore
/// (`avaliacoes.indicadores`).
enum IndicadorAntropometrico {
  pesoIdade('pi', 'Peso para idade (P/I)'),
  estaturaIdade('ei', 'Estatura para idade (E/I)'),
  pesoEstatura('pe', 'Peso para estatura (P/E)'),
  imcIdade('imci', 'IMC para idade (IMC/I)');

  const IndicadorAntropometrico(this.chave, this.nome);
  final String chave;
  final String nome;
}

/// Cor do semáforo (RF04).
enum Semaforo { verde, amarelo, vermelho }

/// Gravidade, da menor para a maior. A ordem do enum é usada para comparar.
enum Gravidade {
  /// Faixa adequada do SISVAN.
  adequado(Semaforo.verde),

  /// Risco de sobrepeso, sobrepeso ou peso elevado para a idade.
  atencao(Semaforo.amarelo),

  /// -3 ≤ z < -2 (baixo peso, baixa estatura, magreza) ou obesidade.
  risco(Semaforo.vermelho),

  /// "Vermelho severo": z < -3 em qualquer indicador.
  grave(Semaforo.vermelho);

  const Gravidade(this.semaforo);
  final Semaforo semaforo;

  bool operator >(Gravidade outra) => index > outra.index;
}

/// Lado do desvio: falta (desnutrição/baixa estatura) ou excesso de peso.
enum Desvio { nenhum, deficit, excesso }

/// Resultado da classificação de um indicador.
class ClassificacaoIndicador {
  const ClassificacaoIndicador({
    required this.indicador,
    required this.zScore,
    required this.diagnostico,
    required this.gravidade,
    required this.desvio,
  });

  final IndicadorAntropometrico indicador;
  final double zScore;

  /// Nome da faixa no SISVAN (ex.: "Baixo peso para a idade"). Serve de
  /// legenda junto da cor (RF04).
  final String diagnostico;
  final Gravidade gravidade;
  final Desvio desvio;

  Semaforo get semaforo => gravidade.semaforo;

  /// Magreza acentuada (P/E ou IMC/I < -3): desnutrição aguda grave pela OMS,
  /// que pede encaminhamento urgente.
  bool get desnutricaoAgudaGrave =>
      gravidade == Gravidade.grave &&
      (indicador == IndicadorAntropometrico.pesoEstatura ||
          indicador == IndicadorAntropometrico.imcIdade);
}

/// Classifica um z-score segundo os pontos de corte do SISVAN (0 a 5 anos).
///
/// Os limites seguem a tabela oficial: "< -3", "≥ -3 e < -2", "≥ -2 e ≤ +1",
/// "> +1 e ≤ +2", "> +2 e ≤ +3" e "> +3".
///
/// Lança [ArgumentError] se [zScore] não for um número finito.
ClassificacaoIndicador classificarIndicador(
  IndicadorAntropometrico indicador,
  double zScore,
) {
  if (!zScore.isFinite) {
    throw ArgumentError.value(zScore, 'zScore', 'precisa ser um número finito');
  }

  ClassificacaoIndicador c(
    String diagnostico,
    Gravidade gravidade,
    Desvio desvio,
  ) => ClassificacaoIndicador(
    indicador: indicador,
    zScore: zScore,
    diagnostico: diagnostico,
    gravidade: gravidade,
    desvio: desvio,
  );

  switch (indicador) {
    case IndicadorAntropometrico.pesoIdade:
      if (zScore < -3) {
        return c(
          'Muito baixo peso para a idade',
          Gravidade.grave,
          Desvio.deficit,
        );
      }
      if (zScore < -2) {
        return c('Baixo peso para a idade', Gravidade.risco, Desvio.deficit);
      }
      if (zScore <= 2) {
        return c(
          'Peso adequado para a idade',
          Gravidade.adequado,
          Desvio.nenhum,
        );
      }
      // O SISVAN não usa P/I para diagnosticar excesso: conferir P/E ou IMC/I.
      return c('Peso elevado para a idade', Gravidade.atencao, Desvio.excesso);

    case IndicadorAntropometrico.estaturaIdade:
      if (zScore < -3) {
        return c(
          'Muito baixa estatura para a idade',
          Gravidade.grave,
          Desvio.deficit,
        );
      }
      if (zScore < -2) {
        return c(
          'Baixa estatura para a idade',
          Gravidade.risco,
          Desvio.deficit,
        );
      }
      return c(
        'Estatura adequada para a idade',
        Gravidade.adequado,
        Desvio.nenhum,
      );

    case IndicadorAntropometrico.pesoEstatura:
    case IndicadorAntropometrico.imcIdade:
      if (zScore < -3) {
        return c('Magreza acentuada', Gravidade.grave, Desvio.deficit);
      }
      if (zScore < -2) {
        return c('Magreza', Gravidade.risco, Desvio.deficit);
      }
      if (zScore <= 1) {
        return c('Eutrofia', Gravidade.adequado, Desvio.nenhum);
      }
      if (zScore <= 2) {
        return c('Risco de sobrepeso', Gravidade.atencao, Desvio.excesso);
      }
      if (zScore <= 3) {
        return c('Sobrepeso', Gravidade.atencao, Desvio.excesso);
      }
      return c('Obesidade', Gravidade.risco, Desvio.excesso);
  }
}

/// Classificação geral de uma avaliação: a do pior indicador.
///
/// [edema] é o edema bilateral nos pés observado pelo profissional. Pela OMS
/// e pelo AIDPI, ele é desnutrição aguda grave em qualquer z-score; como o
/// edema invalida os indicadores de peso, a lista pode vir vazia nesse caso.
class ClassificacaoAvaliacao {
  ClassificacaoAvaliacao(
    List<ClassificacaoIndicador> indicadores, {
    this.edema = false,
  }) : indicadores = List.unmodifiable(indicadores) {
    if (indicadores.isEmpty && !edema) {
      throw ArgumentError.value(
        indicadores,
        'indicadores',
        'informe pelo menos um indicador',
      );
    }
  }

  final List<ClassificacaoIndicador> indicadores;
  final bool edema;

  /// Indicador de pior gravidade. No empate, o déficit vem antes do excesso,
  /// porque a desnutrição é o foco do app. Lança [StateError] se não houver
  /// indicadores (só acontece com [edema]).
  ClassificacaoIndicador get pior => indicadores.reduce((a, b) {
    if (b.gravidade > a.gravidade) return b;
    if (a.gravidade > b.gravidade) return a;
    return b.desvio == Desvio.deficit && a.desvio != Desvio.deficit ? b : a;
  });

  Gravidade get gravidade => edema ? Gravidade.grave : pior.gravidade;
  Semaforo get semaforo => gravidade.semaforo;

  /// Edema ou algum indicador abaixo de -2 (déficit de peso, de estatura ou
  /// magreza).
  bool get desnutricao =>
      edema || indicadores.any((i) => i.desvio == Desvio.deficit);

  /// Edema ou algum indicador com magreza acentuada (P/E ou IMC/I < -3).
  bool get desnutricaoAgudaGrave =>
      edema || indicadores.any((i) => i.desnutricaoAgudaGrave);
}

/// Classifica todos os z-scores informados. Lança [ArgumentError] se o mapa
/// estiver vazio (sem [edema]) ou tiver um z-score não finito.
ClassificacaoAvaliacao classificarAvaliacao(
  Map<IndicadorAntropometrico, double> zScores, {
  bool edema = false,
}) => ClassificacaoAvaliacao([
  for (final e in zScores.entries) classificarIndicador(e.key, e.value),
], edema: edema);

// ---------------------------------------------------------------------------
// RF13 — micro-condutas
// ---------------------------------------------------------------------------

/// Orientações práticas para o profissional, de acordo com a faixa e a idade
/// (AIDPI 2017, Caderneta da Criança e Guia Alimentar para Crianças
/// Brasileiras Menores de 2 Anos, MS 2019).
///
/// [idadeMeses] nulo (nascimento não informado) omite a orientação que
/// depende da idade.
List<String> microCondutas(
  ClassificacaoAvaliacao classificacao, {
  int? idadeMeses,
}) {
  final condutas = <String>[];

  if (classificacao.desnutricaoAgudaGrave) {
    condutas.addAll(const [
      'Encaminhar com urgência, no mesmo dia, para avaliação médica.',
      'Verificar sinais de perigo: inchaço nos dois pés, sonolência, '
          'recusa alimentar, vômitos ou diarreia com desidratação.',
      'Registrar o encaminhamento e confirmar se a família foi atendida.',
    ]);
  } else if (classificacao.pior.desvio == Desvio.deficit) {
    condutas.addAll([
      if (classificacao.gravidade == Gravidade.grave)
        'Agendar consulta com médico ou nutricionista da UBS nos próximos '
            'dias.'
      else
        'Agendar consulta com médico ou nutricionista da UBS.',
      'Avaliar a alimentação da criança e orientar a família conforme o '
          'que ela come hoje.',
      'Verificar sinais de perigo: inchaço nos dois pés, sonolência, '
          'recusa alimentar, vômitos ou diarreia com desidratação.',
      'Investigar doenças recentes (diarreia, infecções) e a segurança '
          'alimentar da família.',
      'Conferir na caderneta as vacinas e a suplementação de ferro e de '
          'vitamina A.',
    ]);
  } else if (classificacao.pior.desvio == Desvio.excesso) {
    condutas.addAll([
      if (classificacao.gravidade == Gravidade.risco)
        'Agendar consulta com médico ou nutricionista da UBS.',
      'Avaliar a alimentação e orientar evitar bebidas açucaradas, '
          'biscoitos recheados e outros ultraprocessados.',
      'Estimular brincadeiras ativas e limitar o tempo de tela.',
    ]);
  } else {
    condutas.addAll(const [
      'Manter o acompanhamento no calendário de consultas e registrar na '
          'caderneta.',
      'Reforçar a alimentação saudável e elogiar os cuidados da família.',
    ]);
  }

  if (idadeMeses != null) {
    condutas.add(_condutaPorIdade(idadeMeses));
  }
  return condutas;
}

String _condutaPorIdade(int idadeMeses) {
  if (idadeMeses < 6) {
    return 'Reforçar o aleitamento materno exclusivo, sem água, chás ou '
        'outros alimentos até os 6 meses.';
  }
  if (idadeMeses < 24) {
    return 'Manter o aleitamento materno e oferecer a comida da família, '
        'sem açúcar nem ultraprocessados antes dos 2 anos.';
  }
  return 'Oferecer as refeições da família, com frutas e legumes todos os '
      'dias.';
}

// ---------------------------------------------------------------------------
// RF17 — sugestão de retorno
// ---------------------------------------------------------------------------

/// Idades (em meses) das consultas do calendário mínimo do MS: 1ª semana,
/// 1, 2, 4, 6, 9, 12, 18 e 24 meses; depois, uma por ano.
const marcosConsultasMeses = [0, 1, 2, 4, 6, 9, 12, 18, 24];

/// Data sugerida para a reavaliação (sem hora).
///
/// - Z-score abaixo de -3 (grave): 5 dias, como o retorno do "peso muito
///   baixo" no AIDPI. Na magreza acentuada, o encaminhamento é no mesmo dia
///   e o retorno serve para confirmar o atendimento.
/// - Déficit entre -3 e -2, obesidade, sobrepeso, risco de sobrepeso e peso
///   elevado: 30 dias (AIDPI: "peso baixo" e problemas de alimentação).
/// - Adequado: a próxima consulta do calendário mínimo do MS, contada pelo
///   [nascimento]. Sem o nascimento não dá para seguir o calendário, e a
///   função devolve `null` para o profissional definir a data.
DateTime? sugerirRetorno(
  DateTime dataAvaliacao,
  Gravidade gravidade, {
  DateTime? nascimento,
}) {
  final dia = DateTime(
    dataAvaliacao.year,
    dataAvaliacao.month,
    dataAvaliacao.day,
  );
  switch (gravidade) {
    case Gravidade.grave:
      return DateTime(dia.year, dia.month, dia.day + 5);
    case Gravidade.risco:
    case Gravidade.atencao:
      return DateTime(dia.year, dia.month, dia.day + 30);
    case Gravidade.adequado:
      if (nascimento == null) return null;
      return proximaConsultaDoCalendario(nascimento, dia);
  }
}

/// Próxima consulta do calendário mínimo depois da [dataAvaliacao].
///
/// A avaliação conta como a consulta do marco mais próximo da idade (no
/// empate, o marco menor), e o retorno é o marco seguinte. Assim, uma
/// criança avaliada com 5 meses e 28 dias fez a consulta dos 6 meses e
/// volta aos 9, em vez de voltar no dia seguinte.
DateTime proximaConsultaDoCalendario(
  DateTime nascimento,
  DateTime dataAvaliacao,
) {
  final nasc = DateTime(nascimento.year, nascimento.month, nascimento.day);
  final dia = DateTime(
    dataAvaliacao.year,
    dataAvaliacao.month,
    dataAvaliacao.day,
  );

  DateTime marco(int i) => _somarMeses(
    nasc,
    i < marcosConsultasMeses.length
        ? marcosConsultasMeses[i]
        : 24 + 12 * (i - marcosConsultasMeses.length + 1),
  );

  // Avaliação antes do nascimento (data errada): a primeira consulta.
  if (dia.isBefore(nasc)) return marco(0);

  // Marco i tal que marco(i) <= dia < marco(i + 1).
  var i = 0;
  while (!marco(i + 1).isAfter(dia)) {
    i++;
  }
  final atual =
      dia.difference(marco(i)).inDays <= marco(i + 1).difference(dia).inDays
      ? i
      : i + 1;
  return marco(atual + 1);
}

/// Soma meses mantendo o dia; se o mês não tiver o dia, usa o último
/// (31/01 + 1 mês = 28 ou 29/02).
DateTime _somarMeses(DateTime data, int meses) {
  final ano = data.year + (data.month - 1 + meses) ~/ 12;
  final mes = (data.month - 1 + meses) % 12 + 1;
  final ultimoDia = DateTime(ano, mes + 1, 0).day;
  return DateTime(ano, mes, data.day > ultimoDia ? ultimoDia : data.day);
}

// ---------------------------------------------------------------------------
// RF12 — alerta de encaminhamento
// ---------------------------------------------------------------------------

class AlertaEncaminhamento {
  const AlertaEncaminhamento({
    required this.titulo,
    required this.mensagem,
    required this.urgente,
    required this.indicadores,
  });

  final String titulo;
  final String mensagem;

  /// `true` na desnutrição aguda grave (magreza acentuada): encaminhar no
  /// mesmo dia.
  final bool urgente;

  /// Indicadores que dispararam o alerta, do mais grave para o menos grave.
  final List<ClassificacaoIndicador> indicadores;
}

/// Alerta para mostrar em modal quando algum indicador está no vermelho
/// (déficit abaixo de -2 ou obesidade), ou `null` quando não está.
///
/// É urgente só na magreza acentuada (P/E ou IMC/I < -3), critério de
/// encaminhamento urgente da OMS e do AIDPI. Os outros casos pedem consulta
/// com médico ou nutricionista, sem ser no mesmo dia.
///
/// O z-score não detecta edema. Inchaço nos dois pés também é desnutrição
/// aguda grave: com [ClassificacaoAvaliacao.edema], o alerta é urgente mesmo
/// sem indicador no vermelho.
AlertaEncaminhamento? alertaEncaminhamento(
  ClassificacaoAvaliacao classificacao,
) {
  final criticos =
      classificacao.indicadores
          .where((i) => i.semaforo == Semaforo.vermelho)
          .toList()
        ..sort((a, b) => b.gravidade.index - a.gravidade.index);
  if (criticos.isEmpty && !classificacao.edema) return null;

  final nomes = [
    if (classificacao.edema) 'edema bilateral nos pés',
    for (final i in criticos) i.diagnostico.toLowerCase(),
  ].join(', ');

  if (classificacao.desnutricaoAgudaGrave) {
    return AlertaEncaminhamento(
      titulo: 'Encaminhamento urgente',
      mensagem:
          'Desnutrição aguda grave ($nomes). Encaminhe a criança hoje para '
          'avaliação médica.',
      urgente: true,
      indicadores: criticos,
    );
  }
  return AlertaEncaminhamento(
    titulo: 'Encaminhamento prioritário',
    mensagem:
        'Z-score fora da faixa adequada ($nomes). Agende consulta com médico '
        'ou nutricionista da UBS.',
    urgente: false,
    indicadores: criticos,
  );
}
