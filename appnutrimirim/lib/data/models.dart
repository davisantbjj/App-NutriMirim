import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum Sexo { masculino, feminino }

/// Situação nutricional exibida em selos e indicadores.
enum Situacao {
  normal(
    'Normal',
    AppColors.statusNormal,
    AppColors.statusNormalText,
    AppColors.lightGreen,
  ),
  atencao(
    'Atenção',
    AppColors.statusAttention,
    AppColors.statusAttentionText,
    AppColors.lightYellow,
  ),
  risco(
    'Risco',
    AppColors.statusRisk,
    AppColors.statusRiskText,
    AppColors.statusRiskBg,
  ),
  abaixo(
    'Abaixo da faixa',
    AppColors.statusBad,
    AppColors.statusBadText,
    AppColors.lightRed,
  );

  const Situacao(this.label, this.color, this.textColor, this.background);
  final String label;

  /// Cor pura: usar só em pontos, ícones e fundos.
  final Color color;

  /// Tom escuro para texto (contraste AA sobre [background]).
  final Color textColor;
  final Color background;
}

class Responsavel {
  const Responsavel({
    required this.nome,
    required this.cpfMascarado,
    required this.telefone,
    required this.email,
  });

  final String nome;
  final String cpfMascarado;
  final String telefone;
  final String email;
}

class Crianca {
  Crianca({
    required this.id,
    required this.nome,
    required this.sexo,
    required this.bairro,
    required this.cadastradoEm,
    this.endereco = '',
    this.ubs = 'UBS Jardim das Flores',
    this.nascimento,
    this.responsavel,
    this.ativa = true,
  });

  /// Identificador estável (no back-end será o id do registro).
  final String id;
  final String nome;
  final Sexo sexo;
  final String bairro;
  final DateTime cadastradoEm;
  final String endereco;
  final String ubs;

  /// Nulo quando a data de nascimento não foi informada.
  final DateTime? nascimento;
  final Responsavel? responsavel;

  /// `false` = cadastro desativado (exclusão lógica; nada é apagado).
  final bool ativa;

  /// Cópia com campos trocados. Para zerar [nascimento] ou [responsavel],
  /// use [limparNascimento] / [limparResponsavel] (null sozinho = manter).
  Crianca copyWith({
    String? nome,
    Sexo? sexo,
    String? bairro,
    DateTime? cadastradoEm,
    String? endereco,
    String? ubs,
    DateTime? nascimento,
    bool limparNascimento = false,
    Responsavel? responsavel,
    bool limparResponsavel = false,
    bool? ativa,
  }) => Crianca(
    id: id,
    nome: nome ?? this.nome,
    sexo: sexo ?? this.sexo,
    bairro: bairro ?? this.bairro,
    cadastradoEm: cadastradoEm ?? this.cadastradoEm,
    endereco: endereco ?? this.endereco,
    ubs: ubs ?? this.ubs,
    nascimento: limparNascimento ? null : (nascimento ?? this.nascimento),
    responsavel: limparResponsavel ? null : (responsavel ?? this.responsavel),
    ativa: ativa ?? this.ativa,
  );
}

class Avaliacao {
  Avaliacao({
    required this.criancaId,
    required this.data,
    required this.pesoKg,
    required this.alturaCm,
    required this.situacao,
    this.id = '',
    this.criadoEm,
    this.profissionalId,
    this.profissionalNome,
    this.tipoMedida,
    this.indicadores = const {},
    this.desnutricao = false,
    this.versaoTabelaOms = 'oms-2006',
    this.retornoSugerido,
    this.excluida = false,
  });

  /// Id da avaliação (vazio até ser registrada; use `novoId()` do repositório).
  final String id;

  /// [Crianca.id] da criança avaliada.
  final String criancaId;
  final DateTime data;
  final double pesoKg;
  final double alturaCm;
  final Situacao situacao;

  /// Quando foi registrada (definido pelo repositório; base dos 15 min do RF14).
  final DateTime? criadoEm;
  final String? profissionalId;
  final String? profissionalNome;

  /// `deitado` ou `em_pe`.
  final String? tipoMedida;

  /// Chaves fixas do Firestore: `pi`, `ei`, `pe` e `imci`.
  final Map<String, Indicador> indicadores;
  final bool desnutricao;
  final String versaoTabelaOms;
  final DateTime? retornoSugerido;
  final bool excluida;

  Avaliacao copyWith({
    String? id,
    String? criancaId,
    DateTime? data,
    double? pesoKg,
    double? alturaCm,
    Situacao? situacao,
    DateTime? criadoEm,
    String? profissionalId,
    String? profissionalNome,
    String? tipoMedida,
    bool limparTipoMedida = false,
    Map<String, Indicador>? indicadores,
    bool? desnutricao,
    String? versaoTabelaOms,
    DateTime? retornoSugerido,
    bool limparRetornoSugerido = false,
    bool? excluida,
  }) => Avaliacao(
    id: id ?? this.id,
    criancaId: criancaId ?? this.criancaId,
    data: data ?? this.data,
    pesoKg: pesoKg ?? this.pesoKg,
    alturaCm: alturaCm ?? this.alturaCm,
    situacao: situacao ?? this.situacao,
    criadoEm: criadoEm ?? this.criadoEm,
    profissionalId: profissionalId ?? this.profissionalId,
    profissionalNome: profissionalNome ?? this.profissionalNome,
    tipoMedida: limparTipoMedida ? null : (tipoMedida ?? this.tipoMedida),
    indicadores: indicadores ?? this.indicadores,
    desnutricao: desnutricao ?? this.desnutricao,
    versaoTabelaOms: versaoTabelaOms ?? this.versaoTabelaOms,
    retornoSugerido: limparRetornoSugerido
        ? null
        : (retornoSugerido ?? this.retornoSugerido),
    excluida: excluida ?? this.excluida,
  );
}

/// Indicador antropométrico (Z-score) mostrado na tela de Resultado.
class Indicador {
  const Indicador(this.nome, this.zScore, this.situacao);
  final String nome;
  final double zScore;
  final Situacao situacao;
}

class ResultadoAvaliacao {
  const ResultadoAvaliacao({
    required this.desnutricao,
    required this.indicadores,
  });

  final bool desnutricao;
  final List<Indicador> indicadores;
}
