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
}

class Avaliacao {
  Avaliacao({
    required this.criancaId,
    required this.data,
    required this.pesoKg,
    required this.alturaCm,
    required this.situacao,
  });

  /// [Crianca.id] da criança avaliada.
  final String criancaId;
  final DateTime data;
  final double pesoKg;
  final double alturaCm;
  final Situacao situacao;
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
