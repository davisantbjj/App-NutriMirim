import 'models.dart';

/// Dados de exemplo usados nas telas enquanto não há backend/armazenamento.
class MockData {
  MockData._();

  static final criancaDestaque = Crianca(
    id: 'c0',
    nome: 'Maria Joaquina de Lima Santos',
    sexo: Sexo.feminino,
    bairro: 'Centro',
    cadastradoEm: DateTime(2024, 8, 15),
    endereco: 'Rua Lais Grangeiro, 254',
    ubs: 'UBS Jardim das Flores',
    nascimento: DateTime(2024, 8, 15),
    responsavel: Responsavel(
      nome: 'Joana de Lima Santos',
      cpfMascarado: '857.***.***-54',
      telefone: '(79) 12345-678',
      email: 'maria@email.com',
    ),
  );

  static final List<Crianca> criancas = List.unmodifiable(<Crianca>[
    Crianca(
      id: 'c1',
      nome: 'Talita Feitosa',
      sexo: Sexo.feminino,
      bairro: 'Ponto Novo',
      cadastradoEm: DateTime(2025, 1, 10),
    ),
    Crianca(
      id: 'c2',
      nome: 'Victor Santos',
      sexo: Sexo.masculino,
      bairro: 'Rosa Elze',
      cadastradoEm: DateTime(2025, 1, 10),
    ),
    Crianca(
      id: 'c3',
      nome: 'Rafael Almeida',
      sexo: Sexo.masculino,
      bairro: 'Rosa Elze',
      cadastradoEm: DateTime(2025, 1, 10),
    ),
    Crianca(
      id: 'c4',
      nome: 'Lorena Frota',
      sexo: Sexo.feminino,
      bairro: 'Grageru',
      cadastradoEm: DateTime(2025, 1, 10),
    ),
    Crianca(
      id: 'c5',
      nome: 'Davi Medeiros',
      sexo: Sexo.masculino,
      bairro: 'Orlando Dantas',
      cadastradoEm: DateTime(2025, 1, 10),
    ),
    Crianca(
      id: 'c6',
      nome: 'Larissa Mendonça',
      sexo: Sexo.feminino,
      bairro: 'Rosa Maria',
      cadastradoEm: DateTime(2025, 1, 10),
    ),
    Crianca(
      id: 'c7',
      nome: 'João Rocha',
      sexo: Sexo.masculino,
      bairro: 'Rosa Elze',
      cadastradoEm: DateTime(2025, 1, 10),
    ),
  ]);

  /// Crianças que só aparecem no Histórico do protótipo (fora da lista).
  static final _soNoHistorico = <Crianca>[
    Crianca(
      id: 'c8',
      nome: 'Pedro Menezes',
      sexo: Sexo.masculino,
      bairro: 'Centro',
      cadastradoEm: DateTime(2025, 1, 10),
    ),
    Crianca(
      id: 'c9',
      nome: 'Luana Silva',
      sexo: Sexo.feminino,
      bairro: 'Centro',
      cadastradoEm: DateTime(2024, 11, 5),
    ),
    Crianca(
      id: 'c10',
      nome: 'Vinicius Feitosa',
      sexo: Sexo.masculino,
      bairro: 'Centro',
      cadastradoEm: DateTime(2024, 9, 12),
    ),
  ];

  /// Avaliação da criança em destaque (não aparece no Histórico do protótipo).
  static final _avaliacaoDestaque = Avaliacao(
    criancaId: 'c0',
    data: DateTime(2026, 8, 15),
    pesoKg: 9.8,
    alturaCm: 85,
    situacao: Situacao.normal,
  );

  /// Avaliações exibidas no Histórico.
  static final List<Avaliacao> avaliacoes = List.unmodifiable(<Avaliacao>[
    Avaliacao(
      criancaId: 'c1',
      data: DateTime(2025, 1, 10),
      pesoKg: 12.5,
      alturaCm: 85,
      situacao: Situacao.normal,
    ),
    Avaliacao(
      criancaId: 'c8',
      data: DateTime(2025, 1, 10),
      pesoKg: 12.1,
      alturaCm: 82,
      situacao: Situacao.normal,
    ),
    Avaliacao(
      criancaId: 'c9',
      data: DateTime(2024, 11, 5),
      pesoKg: 9.8,
      alturaCm: 78,
      situacao: Situacao.risco,
    ),
    Avaliacao(
      criancaId: 'c10',
      data: DateTime(2024, 9, 12),
      pesoKg: 11.2,
      alturaCm: 78,
      situacao: Situacao.normal,
    ),
  ]);

  /// Todas as crianças conhecidas pelo mock.
  static List<Crianca> get todasCriancas => [
    criancaDestaque,
    ...criancas,
    ..._soNoHistorico,
  ];

  /// Criança pelo [id], ou null se não existir.
  static Crianca? criancaPorId(String id) {
    for (final c in todasCriancas) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Avaliações da criança, da mais recente para a mais antiga.
  static List<Avaliacao> avaliacoesDe(String criancaId) =>
      [
          ...avaliacoes,
          _avaliacaoDestaque,
        ].where((a) => a.criancaId == criancaId).toList()
        ..sort((a, b) => b.data.compareTo(a.data));

  /// Avaliação mais recente da criança, ou null se não houver.
  static Avaliacao? ultimaAvaliacaoDe(String criancaId) {
    final lista = avaliacoesDe(criancaId);
    return lista.isEmpty ? null : lista.first;
  }

  static const resultadoNormal = ResultadoAvaliacao(
    desnutricao: false,
    indicadores: [
      Indicador('Peso para idade (P/I)', -0.5, Situacao.normal),
      Indicador('Estatura para idade (E/I)', -0.3, Situacao.normal),
      Indicador('Peso para estatura (P/E)', 0.1, Situacao.normal),
    ],
  );

  static const resultadoDesnutricao = ResultadoAvaliacao(
    desnutricao: true,
    indicadores: [
      Indicador('Peso para idade (P/I)', -2.5, Situacao.abaixo),
      Indicador('Estatura para idade (E/I)', -1.8, Situacao.atencao),
      Indicador('Peso para estatura (P/E)', 0.1, Situacao.normal),
    ],
  );
}
