import 'dart:math' as math;

/// Parâmetros e convenções: docs/validacao-antropometrica-oms.md.
/// Funções puras; sem persistência, classificação clínica ou Flutter.
enum SexoOms { masculino, feminino }

enum PosicaoMedicao { deitado, emPe }

enum EstadoPlausibilidade { semAlerta, conferir, indisponivel }

enum IndicadorOms {
  pesoIdade('Peso para idade', -6, 5),
  alturaIdade('Comprimento/altura para idade', -6, 6),
  pesoAltura('Peso para comprimento/altura', -5, 5),
  imcIdade('IMC para idade', -5, 5);

  const IndicadorOms(this.rotulo, this.minimo, this.maximo);
  final String rotulo;
  final double minimo;
  final double maximo;
}

EstadoPlausibilidade avaliarZScore(IndicadorOms indicador, double? z) {
  if (z == null || !z.isFinite) return EstadoPlausibilidade.indisponivel;
  return z < indicador.minimo || z > indicador.maximo
      ? EstadoPlausibilidade.conferir
      : EstadoPlausibilidade.semAlerta;
}

class ResultadoIndicadorOms {
  const ResultadoIndicadorOms(this.indicador, this.zScore, [this.motivo]);
  final IndicadorOms indicador;
  final double? zScore;
  final String? motivo;
  EstadoPlausibilidade get estado => avaliarZScore(indicador, zScore);
}

class ValidacaoAntropometrica {
  ValidacaoAntropometrica({
    required List<ResultadoIndicadorOms> indicadores,
    required List<String> erros,
    this.idadeDias,
    this.medidaAjustadaCm,
  }) : indicadores = List.unmodifiable(indicadores),
       erros = List.unmodifiable(erros);

  final List<ResultadoIndicadorOms> indicadores;
  final List<String> erros;
  final int? idadeDias;
  final double? medidaAjustadaCm;
  bool get precisaConferencia =>
      indicadores.any((i) => i.estado == EstadoPlausibilidade.conferir);
  bool get temIndisponiveis =>
      indicadores.any((i) => i.estado == EstadoPlausibilidade.indisponivel);
}

DateTime _dia(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// Datas civis, sem efeito de hora do dia ou mudança de horário de verão.
int idadeEmDias(DateTime nascimento, DateTime medicao) =>
    _dia(medicao).difference(_dia(nascimento)).inDays;

DateTime? interpretarDataBrasileira(String texto) {
  final match = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto.trim());
  if (match == null) return null;
  final dia = int.parse(match[1]!);
  final mes = int.parse(match[2]!);
  final ano = int.parse(match[3]!);
  final data = DateTime(ano, mes, dia);
  return data.year == ano && data.month == mes && data.day == dia ? data : null;
}

class _Lms {
  const _Lms(this.l, this.m, this.s);
  final double l, m, s;
  _Lms interpolar(_Lms outra, double fracao) => _Lms(
    l + (outra.l - l) * fracao,
    m + (outra.m - m) * fracao,
    s + (outra.s - s) * fracao,
  );

  double zScore(double medida, {required bool ajustarExtremos}) {
    var z = l == 0
        ? math.log(medida / m) / s
        : (math.pow(medida / m, l) - 1) / (l * s);
    double valor(double desvio) => l == 0
        ? m * math.exp(s * desvio)
        : m * math.pow(1 + l * s * desvio, 1 / l);
    if (ajustarExtremos && z > 3) {
      z = 3 + (medida - valor(3)) / (valor(3) - valor(2));
    }
    if (ajustarExtremos && z < -3) {
      z = -3 + (medida - valor(-3)) / (valor(-2) - valor(-3));
    }
    // A referência arredonda a duas casas antes de aplicar os flags.
    if (!z.isFinite) return z;
    final escalado = z.abs() * 100;
    if (!escalado.isFinite || escalado > 9e15) return z;
    final inteiro = escalado.floor();
    final fracao = escalado - inteiro;
    final arredondado = fracao > 0.5 || (fracao == 0.5 && inteiro.isOdd)
        ? inteiro + 1
        : inteiro;
    return z.sign * arredondado / 100;
  }
}

class _Tabela {
  _Tabela(String texto, {required bool porIdade}) : porIdade = porIdade {
    final linhas = texto.trim().split(RegExp(r'\r?\n'));
    final cabecalho = linhas.first.trim().split(RegExp(r'\s+'));
    if (cabecalho.length < 5 ||
        cabecalho[0] != 'sex' ||
        cabecalho[1] != (porIdade ? 'age' : 'length') &&
            cabecalho[1] != (porIdade ? 'age' : 'height') ||
        cabecalho.sublist(2, 5).join(',') != 'l,m,s') {
      throw const FormatException('Cabeçalho OMS inválido');
    }
    for (final linha in linhas.skip(1)) {
      final campos = linha.trim().split(RegExp(r'\s+'));
      if (campos.length < 5) {
        throw const FormatException('Linha OMS incompleta');
      }
      final sexo = int.parse(campos[0]);
      final eixo = double.parse(campos[1]);
      final lms = _Lms(
        double.parse(campos[2]),
        double.parse(campos[3]),
        double.parse(campos[4]),
      );
      if ((sexo != 1 && sexo != 2) ||
          !eixo.isFinite ||
          eixo < 0 ||
          !lms.l.isFinite ||
          !lms.m.isFinite ||
          !lms.s.isFinite ||
          lms.m <= 0 ||
          lms.s <= 0) {
        throw const FormatException('Parâmetros OMS inválidos');
      }
      final chave = (eixo * (porIdade ? 1 : 10)).round();
      if ((_linhas[sexo] ??= {}).containsKey(chave)) {
        throw const FormatException('Linha OMS duplicada');
      }
      _linhas[sexo]![chave] = lms;
    }
    // Falha explícita em assets truncados; nunca valida com tabela parcial.
    final inicio = porIdade
        ? 0
        : cabecalho[1] == 'length'
        ? 450
        : 650;
    final fim = porIdade
        ? 1826
        : cabecalho[1] == 'length'
        ? 1100
        : 1200;
    for (final sexo in [1, 2]) {
      if (_linhas[sexo]?.length != fim - inicio + 1) {
        throw const FormatException('Tabela OMS incompleta');
      }
      for (var chave = inicio; chave <= fim; chave++) {
        if (!_linhas[sexo]!.containsKey(chave)) {
          throw const FormatException('Intervalo OMS incompleto');
        }
      }
    }
  }
  final bool porIdade;
  final _linhas = <int, Map<int, _Lms>>{};

  _Lms? obter(SexoOms sexo, double eixo) {
    final linhas = _linhas[sexo.index + 1]!;
    final posicao = eixo * (porIdade ? 1 : 10);
    if (!posicao.isFinite || posicao < 0 || posicao > 2000) return null;
    // Evita que erros binários em valores como 65,1 exijam a linha anterior.
    final arredondado = posicao.round();
    if ((posicao - arredondado).abs() < 1e-9) return linhas[arredondado];
    final baixo = posicao.floor();
    final a = linhas[baixo], b = linhas[baixo + 1];
    return a == null || b == null ? null : a.interpolar(b, posicao - baixo);
  }
}

class TabelasOms {
  TabelasOms({
    required String pesoIdade,
    required String alturaIdade,
    required String pesoComprimento,
    required String pesoAltura,
    required String imcIdade,
  }) : _pesoIdade = _Tabela(pesoIdade, porIdade: true),
       _alturaIdade = _Tabela(alturaIdade, porIdade: true),
       _pesoComprimento = _Tabela(pesoComprimento, porIdade: false),
       _pesoAltura = _Tabela(pesoAltura, porIdade: false),
       _imcIdade = _Tabela(imcIdade, porIdade: true);

  final _Tabela _pesoIdade,
      _alturaIdade,
      _pesoComprimento,
      _pesoAltura,
      _imcIdade;

  /// Medida da curva de referência no z-score [z] (para desenhar as linhas
  /// -3, -2, 0, +2 e +3 da Curva). [eixo] é a idade em dias (P/I, E/I e
  /// IMC/I) ou o comprimento/altura em cm (P/E); [comprimento] escolhe a
  /// tabela de P/E: por comprimento (45 a 110 cm, menores de 2 anos) ou por
  /// altura (65 a 120 cm). Nulo fora do domínio da tabela.
  double? valorReferencia({
    required IndicadorOms indicador,
    required SexoOms sexo,
    required double eixo,
    required double z,
    bool comprimento = true,
  }) {
    final tabela = switch (indicador) {
      IndicadorOms.pesoIdade => _pesoIdade,
      IndicadorOms.alturaIdade => _alturaIdade,
      IndicadorOms.pesoAltura => comprimento ? _pesoComprimento : _pesoAltura,
      IndicadorOms.imcIdade => _imcIdade,
    };
    final lms = tabela.obter(sexo, eixo);
    if (lms == null) return null;
    return lms.l == 0
        ? lms.m * math.exp(lms.s * z)
        : lms.m * math.pow(1 + lms.l * lms.s * z, 1 / lms.l);
  }

  ValidacaoAntropometrica validar({
    required SexoOms? sexo,
    required DateTime? nascimento,
    required DateTime? medicao,
    required DateTime hoje,
    required double? pesoKg,
    required double? alturaCm,
    required PosicaoMedicao? posicao,
    required bool? edema,
  }) {
    final erros = <String>[];
    if (sexo == null) erros.add('Informe o sexo da criança.');
    if (nascimento == null) erros.add('Informe a data de nascimento.');
    if (medicao == null) erros.add('Informe a data da medição.');
    if (nascimento != null && _dia(nascimento).isAfter(_dia(hoje))) {
      erros.add('Nascimento não pode ser futuro.');
    }
    if (medicao != null && _dia(medicao).isAfter(_dia(hoje))) {
      erros.add('A medição não pode ser futura.');
    }
    final idade = nascimento != null && medicao != null
        ? idadeEmDias(nascimento, medicao)
        : null;
    if (idade != null && idade < 0) {
      erros.add('A medição não pode ser anterior ao nascimento.');
    }
    if (pesoKg == null || !pesoKg.isFinite || pesoKg <= 0) {
      erros.add('Informe um peso positivo e finito em kg.');
    }
    if (alturaCm == null || !alturaCm.isFinite || alturaCm <= 0) {
      erros.add('Informe uma medida positiva e finita em cm.');
    }
    if (posicao == null) erros.add('Informe a posição da medição.');
    if (edema == null) erros.add('Informe a presença ou ausência de edema.');
    if (erros.isNotEmpty) {
      return ValidacaoAntropometrica(
        erros: erros,
        idadeDias: idade,
        indicadores: [
          for (final i in IndicadorOms.values)
            ResultadoIndicadorOms(
              i,
              null,
              'Complete ou corrija os dados de entrada.',
            ),
        ],
      );
    }
    final dias = idade!;
    final meses = dias / 30.4375;
    if (meses >= 60) {
      return ValidacaoAntropometrica(
        erros: [],
        idadeDias: dias,
        indicadores: [
          for (final i in IndicadorOms.values)
            ResultadoIndicadorOms(
              i,
              null,
              'Referência disponível para idade inferior a 60 meses.',
            ),
        ],
      );
    }
    final posicaoInadequada = meses < 9 && posicao == PosicaoMedicao.emPe;
    final ajuste = dias < 731 && posicao == PosicaoMedicao.emPe
        ? 0.7
        : dias >= 731 && posicao == PosicaoMedicao.deitado
        ? -0.7
        : 0.0;
    final medida = alturaCm! + ajuste;
    ResultadoIndicadorOms calcular(
      IndicadorOms i,
      _Tabela tabela,
      double eixo,
      double valor, {
      String? motivo,
    }) {
      if (motivo != null) return ResultadoIndicadorOms(i, null, motivo);
      final lms = tabela.obter(sexo!, eixo);
      if (lms == null) {
        return ResultadoIndicadorOms(
          i,
          null,
          'Medida fora do domínio da tabela deste indicador.',
        );
      }
      final z = lms.zScore(
        valor,
        ajustarExtremos: i != IndicadorOms.alturaIdade,
      );
      return z.isFinite
          ? ResultadoIndicadorOms(i, z)
          : ResultadoIndicadorOms(
              i,
              null,
              'Não foi possível calcular com estas medidas.',
            );
    }

    final motivoPeso = edema!
        ? 'Edema presente: indicador relacionado ao peso indisponível.'
        : null;
    final motivoAltura = posicaoInadequada
        ? 'Menor de 9 meses: confira a medida e meça deitado.'
        : medida <= 0
        ? 'Medida ajustada deve ser positiva.'
        : null;
    return ValidacaoAntropometrica(
      erros: [],
      idadeDias: dias,
      medidaAjustadaCm: motivoAltura == null ? medida : null,
      indicadores: [
        calcular(
          IndicadorOms.pesoIdade,
          _pesoIdade,
          dias.toDouble(),
          pesoKg!,
          motivo: motivoPeso,
        ),
        calcular(
          IndicadorOms.alturaIdade,
          _alturaIdade,
          dias.toDouble(),
          medida,
          motivo: motivoAltura,
        ),
        calcular(
          IndicadorOms.pesoAltura,
          dias < 731 ? _pesoComprimento : _pesoAltura,
          medida,
          pesoKg,
          motivo: motivoPeso ?? motivoAltura,
        ),
        calcular(
          IndicadorOms.imcIdade,
          _imcIdade,
          dias.toDouble(),
          pesoKg / math.pow(medida / 100, 2),
          motivo: motivoPeso ?? motivoAltura,
        ),
      ],
    );
  }
}
