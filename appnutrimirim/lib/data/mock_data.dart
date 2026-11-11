import 'models.dart';

/// Dados de exemplo usados nas telas enquanto não há backend/armazenamento.
class MockData {
  MockData._();

  static const criancaDestaque = Crianca(
    nome: 'Maria Joaquina de Lima Santos',
    sexo: Sexo.feminino,
    bairro: 'Centro',
    cadastradoEm: '15/08/2024',
    endereco: 'Rua Lais Grangeiro, 254',
    ubs: 'UBS Jardim das Flores',
    nascimento: '15/08/2024',
    responsavel: Responsavel(
      nome: 'Joana de Lima Santos',
      cpfMascarado: '857.***.***-54',
      telefone: '(79) 12345-678',
      email: 'maria@email.com',
    ),
  );

  static const criancas = <Crianca>[
    Crianca(
      nome: 'Talita Feitosa',
      sexo: Sexo.feminino,
      bairro: 'Ponto Novo',
      cadastradoEm: '10/01/2025',
    ),
    Crianca(
      nome: 'Victor Santos',
      sexo: Sexo.masculino,
      bairro: 'Rosa Elze',
      cadastradoEm: '10/01/2025',
    ),
    Crianca(
      nome: 'Rafael Almeida',
      sexo: Sexo.masculino,
      bairro: 'Rosa Elze',
      cadastradoEm: '10/01/2025',
    ),
    Crianca(
      nome: 'Lorena Frota',
      sexo: Sexo.feminino,
      bairro: 'Grageru',
      cadastradoEm: '10/01/2025',
    ),
    Crianca(
      nome: 'Davi Medeiros',
      sexo: Sexo.masculino,
      bairro: 'Orlando Dantas',
      cadastradoEm: '10/01/2025',
    ),
    Crianca(
      nome: 'Larissa Mendonça',
      sexo: Sexo.feminino,
      bairro: 'Rosa Maria',
      cadastradoEm: '10/01/2025',
    ),
    Crianca(
      nome: 'João Rocha',
      sexo: Sexo.masculino,
      bairro: 'Rosa Elze',
      cadastradoEm: '10/01/2025',
    ),
  ];

  /// Avaliação da criança em destaque (não aparece no Histórico do protótipo).
  static const _avaliacaoDestaque = Avaliacao(
    nomeCrianca: 'Maria Joaquina de Lima Santos',
    data: '15/08/2026',
    pesoKg: 9.8,
    alturaCm: 85,
    situacao: Situacao.normal,
  );

  static const avaliacoes = <Avaliacao>[
    Avaliacao(
      nomeCrianca: 'Talita Feitosa',
      data: '10/01/2025',
      pesoKg: 12.5,
      alturaCm: 85,
      situacao: Situacao.normal,
    ),
    Avaliacao(
      nomeCrianca: 'Pedro Menezes',
      data: '10/01/2025',
      pesoKg: 12.1,
      alturaCm: 82,
      situacao: Situacao.normal,
    ),
    Avaliacao(
      nomeCrianca: 'Luana Silva',
      data: '05/11/2024',
      pesoKg: 9.8,
      alturaCm: 78,
      situacao: Situacao.risco,
    ),
    Avaliacao(
      nomeCrianca: 'Vinicius Feitosa',
      data: '12/09/2024',
      pesoKg: 11.2,
      alturaCm: 78,
      situacao: Situacao.normal,
    ),
  ];

  /// Avaliação mais recente da criança (por nome), ou null se não houver.
  static Avaliacao? ultimaAvaliacaoDe(String nome) {
    DateTime d(String s) {
      final p = s.split('/');
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    }

    Avaliacao? r;
    for (final a in [...avaliacoes, _avaliacaoDestaque]) {
      if (a.nomeCrianca != nome) continue;
      if (r == null || d(a.data).isAfter(d(r.data))) r = a;
    }
    return r;
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
