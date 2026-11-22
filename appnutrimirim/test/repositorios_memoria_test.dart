import 'package:appnutrimirim/data/mock_data.dart';
import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/repositories/memoria/avaliacoes_memoria.dart';
import 'package:appnutrimirim/repositories/memoria/criancas_memoria.dart';
import 'package:appnutrimirim/repositories/repositorios.dart';
import 'package:appnutrimirim/utils/texto.dart';
import 'package:flutter_test/flutter_test.dart';

const _ana = UsuarioAtual(uid: 'ana', nome: 'Ana Souza');
const _beto = UsuarioAtual(uid: 'beto', nome: 'Beto Lima');
const _master = UsuarioAtual(uid: 'm1', nome: 'Mestre', master: true);

const _ind = {'pi': Indicador('P/I', -0.5, Situacao.normal)};

Crianca _crianca(String id, String nome, {Responsavel? responsavel}) => Crianca(
  id: id,
  nome: nome,
  sexo: Sexo.feminino,
  bairro: 'Centro',
  cadastradoEm: DateTime(2025, 1, 10),
  responsavel: responsavel,
);

Avaliacao _avaliacao(String criancaId, {DateTime? data, double peso = 12.5}) =>
    Avaliacao(
      criancaId: criancaId,
      data: data ?? DateTime(2026, 3, 1),
      pesoKg: peso,
      alturaCm: 85,
      situacao: Situacao.normal,
      indicadores: const {'pi': Indicador('P/I', -0.5, Situacao.normal)},
    );

void main() {
  group('normalizarBusca', () {
    test('minúsculas, sem acento, trim e espaços colapsados', () {
      expect(normalizarBusca('  João  MENDONÇA '), 'joao mendonca');
      expect(normalizarBusca('Ângela Çé'), 'angela ce');
      expect(normalizarBusca(''), '');
    });
    test('somenteDigitos', () {
      expect(somenteDigitos('857.123.456-54'), '85712345654');
    });
  });

  group('Modelos', () {
    test('construtores antigos continuam valendo, com defaults novos', () {
      final c = _crianca('x', 'Fulana');
      expect(c.ativa, isTrue);
      final a = Avaliacao(
        criancaId: 'x',
        data: DateTime(2026),
        pesoKg: 10,
        alturaCm: 80,
        situacao: Situacao.normal,
      );
      expect(a.id, '');
      expect(a.indicadores, isEmpty);
      expect(a.versaoTabelaOms, 'oms-2006');
      expect(a.desnutricao, isFalse);
      expect(a.excluida, isFalse);
    });
    test('copyWith mantém o resto e limpa campos nulos quando pedido', () {
      final c = _crianca('x', 'Fulana').copyWith(nome: 'Sicrana');
      expect(c.nome, 'Sicrana');
      expect(c.id, 'x');
      final com = c.copyWith(nascimento: DateTime(2024, 5, 6));
      expect(com.copyWith(limparNascimento: true).nascimento, isNull);
      expect(com.copyWith(bairro: 'Outro').nascimento, DateTime(2024, 5, 6));
    });
    test('mock tem ids estáveis nas avaliações', () {
      final ids = MockData.avaliacoesDe('c0').map((a) => a.id);
      expect(ids, ['a5']);
      expect(MockData.avaliacoes.map((a) => a.id), ['a1', 'a2', 'a3', 'a4']);
    });
  });

  group('CriancaRepositoryMemoria', () {
    late BancoMemoria banco;
    late CriancaRepositoryMemoria repo;
    setUp(() {
      banco = BancoMemoria(usuario: _ana);
      repo = CriancaRepositoryMemoria(banco);
    });

    test('vazio no início; novoId gera ids diferentes', () async {
      expect(await repo.buscar(''), isEmpty);
      expect(repo.novoId(), isNot(repo.novoId()));
    });

    test('comMock carrega todas as crianças do mock', () async {
      final r = CriancaRepositoryMemoria.comMock();
      expect((await r.buscar('')).length, MockData.todasCriancas.length);
      expect((await r.porId('c0'))?.nome, 'Maria Joaquina de Lima Santos');
    });

    test('cadastrar, porId e ordenação por nome sem acento', () async {
      await repo.cadastrar(_crianca('1', 'Zélia'));
      await repo.cadastrar(_crianca('2', 'álvaro'));
      await repo.cadastrar(_crianca('3', 'Bruno'));
      final nomes = (await repo.buscar('')).map((c) => c.nome);
      expect(nomes, ['álvaro', 'Bruno', 'Zélia']);
      expect((await repo.porId('2'))?.nome, 'álvaro');
      expect(await repo.porId('nao-existe'), isNull);
    });

    test('cadastrar valida nome e id repetido', () async {
      expect(
        () => repo.cadastrar(_crianca('1', 'A')),
        throwsA(isA<DadosInvalidos>()),
      );
      expect(
        () => repo.cadastrar(_crianca('', 'Ana Maria')),
        throwsA(isA<DadosInvalidos>()),
      );
      await repo.cadastrar(_crianca('1', 'Ana Maria'));
      expect(
        () => repo.cadastrar(_crianca('1', 'Outra Pessoa')),
        throwsA(isA<EstadoInvalido>()),
      );
    });

    test('stream emite o estado atual ao assinar e após cadastrar', () async {
      await repo.cadastrar(_crianca('1', 'Bruno'));
      final emissoes = <List<String>>[];
      final sub = repo.observarTodas().listen(
        (l) => emissoes.add(l.map((c) => c.nome).toList()),
      );
      await Future<void>.delayed(Duration.zero);
      await repo.cadastrar(_crianca('2', 'Ana'));
      await repo.desativar('1', motivo: 'Mudou de cidade');
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(emissoes, [
        ['Bruno'],
        ['Ana', 'Bruno'],
        ['Ana'],
      ]);
    });

    test('stream é broadcast (vários ouvintes)', () async {
      final s = repo.observarTodas();
      expect(s.isBroadcast, isTrue);
      final a = s.first;
      final b = s.first;
      expect(await a, isEmpty);
      expect(await b, isEmpty);
    });

    test('busca por nome parcial sem acento nem caixa', () async {
      await repo.cadastrar(_crianca('1', 'Larissa Mendonça'));
      await repo.cadastrar(_crianca('2', 'João Rocha'));
      expect((await repo.buscar('MENDONCA')).map((c) => c.id), ['1']);
      expect((await repo.buscar('joao')).map((c) => c.id), ['2']);
      expect((await repo.buscar('  roc ')).map((c) => c.id), ['2']);
      expect(await repo.buscar('zzz'), isEmpty);
    });

    test('busca por CPF do responsável (com ou sem máscara)', () async {
      await repo.cadastrar(
        _crianca(
          '1',
          'Maria Souza',
          responsavel: const Responsavel(
            nome: 'Joana Souza',
            cpfMascarado: '529.982.247-25',
            telefone: '',
            email: '',
          ),
        ),
      );
      await repo.cadastrar(_crianca('2', 'Pedro Lima'));
      expect((await repo.buscar('529.982.247-25')).map((c) => c.id), ['1']);
      expect((await repo.buscar('52998224725')).map((c) => c.id), ['1']);
      expect(await repo.buscar('11111111111'), isEmpty);
    });

    test('editar exige motivo de 3 a 200 caracteres', () async {
      await repo.cadastrar(_crianca('1', 'Maria Souza'));
      final nova = (await repo.porId('1'))!.copyWith(nome: 'Maria S. Lima');
      for (final ruim in ['', '  ', 'ab', 'x' * 201]) {
        expect(
          () => repo.editar(nova, motivo: ruim),
          throwsA(isA<MotivoObrigatorio>()),
        );
      }
      expect((await repo.porId('1'))!.nome, 'Maria Souza');
      await repo.editar(nova, motivo: 'Erro de digitação');
      expect((await repo.porId('1'))!.nome, 'Maria S. Lima');
      expect(banco.alteracoes.single.motivo, 'Erro de digitação');
      expect(banco.alteracoes.single.versao, 1);
    });

    test('editar não muda ativa nem cadastradoEm e acha o id', () async {
      await repo.cadastrar(_crianca('1', 'Maria Souza'));
      await repo.editar(
        _crianca(
          '1',
          'Maria Souza',
        ).copyWith(ativa: false, cadastradoEm: DateTime(2020), bairro: 'Novo'),
        motivo: 'Mudança de bairro',
      );
      final c = (await repo.porId('1'))!;
      expect(c.ativa, isTrue);
      expect(c.cadastradoEm, DateTime(2025, 1, 10));
      expect(c.bairro, 'Novo');
      expect(
        () => repo.editar(_crianca('x', 'Fulano'), motivo: 'teste ok'),
        throwsA(isA<NaoEncontrado>()),
      );
    });

    test(
      'desativar: exige motivo, some das listas e porId ainda acha',
      () async {
        await repo.cadastrar(_crianca('1', 'Maria Souza'));
        expect(
          () => repo.desativar('1', motivo: ''),
          throwsA(isA<MotivoObrigatorio>()),
        );
        await repo.desativar('1', motivo: 'Mudou de cidade');
        expect(await repo.buscar(''), isEmpty);
        expect(await repo.observarTodas().first, isEmpty);
        expect((await repo.porId('1'))!.ativa, isFalse);
        expect(
          () => repo.desativar('1', motivo: 'de novo'),
          throwsA(isA<EstadoInvalido>()),
        );
        expect(
          () => repo.desativar('nada', motivo: 'motivo'),
          throwsA(isA<NaoEncontrado>()),
        );
      },
    );
  });

  group('AvaliacaoRepositoryMemoria', () {
    late DateTime agora;
    late BancoMemoria banco;
    late CriancaRepositoryMemoria criancas;
    late AvaliacaoRepositoryMemoria repo;

    setUp(() async {
      agora = DateTime(2026, 5, 10, 9);
      banco = BancoMemoria(agora: () => agora, usuario: _ana);
      criancas = CriancaRepositoryMemoria(banco);
      repo = AvaliacaoRepositoryMemoria(banco);
      await criancas.cadastrar(_crianca('c1', 'Maria Souza'));
    });

    test(
      'registrar preenche id, autor e criadoEm; ignora o que veio',
      () async {
        final salva = await repo.registrar(
          _avaliacao('c1').copyWith(profissionalId: 'outro'),
        );
        expect(salva.id, isNotEmpty);
        expect(salva.profissionalId, 'ana');
        expect(salva.profissionalNome, 'Ana Souza');
        expect(salva.criadoEm, agora);
        expect((await repo.ultimaDe('c1'))!.id, salva.id);
      },
    );

    test('registrar valida criança, peso, altura e indicadores', () async {
      expect(
        () => repo.registrar(_avaliacao('nada')),
        throwsA(isA<NaoEncontrado>()),
      );
      expect(
        () => repo.registrar(_avaliacao('c1', peso: 0.1)),
        throwsA(isA<DadosInvalidos>()),
      );
      expect(
        () => repo.registrar(_avaliacao('c1').copyWith(indicadores: const {})),
        throwsA(isA<DadosInvalidos>()),
      );
      expect(
        () => repo.registrar(
          _avaliacao('c1').copyWith(
            indicadores: const {'xx': Indicador('x', 0, Situacao.normal)},
          ),
        ),
        throwsA(isA<DadosInvalidos>()),
      );
      expect(
        () => repo.registrar(
          _avaliacao('c1').copyWith(
            indicadores: const {'pi': Indicador('x', 11, Situacao.normal)},
          ),
        ),
        throwsA(isA<DadosInvalidos>()),
      );
    });

    test('criança desativada não recebe avaliação', () async {
      await criancas.desativar('c1', motivo: 'Mudou de cidade');
      expect(
        () => repo.registrar(_avaliacao('c1')),
        throwsA(isA<EstadoInvalido>()),
      );
    });

    test(
      'listas: mais recente primeiro, por criança e geral; stream',
      () async {
        await criancas.cadastrar(_crianca('c2', 'Pedro Lima'));
        final velha = await repo.registrar(
          _avaliacao('c1', data: DateTime(2026, 1, 1)),
        );
        final nova = await repo.registrar(
          _avaliacao('c1', data: DateTime(2026, 4, 1)),
        );
        final outra = await repo.registrar(
          _avaliacao('c2', data: DateTime(2026, 3, 1)),
        );
        expect((await repo.observarDe('c1').first).map((a) => a.id), [
          nova.id,
          velha.id,
        ]);
        expect((await repo.observarTodas().first).map((a) => a.id), [
          nova.id,
          outra.id,
          velha.id,
        ]);
        expect((await repo.ultimaDe('c2'))!.id, outra.id);
        expect(await repo.ultimaDe('c9'), isNull);

        final emissoes = <int>[];
        final sub = repo.observarDe('c2').listen((l) => emissoes.add(l.length));
        await Future<void>.delayed(Duration.zero);
        await repo.registrar(_avaliacao('c2', data: DateTime(2026, 5, 1)));
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        expect(emissoes, [1, 2]);
      },
    );

    test(
      'corrigir: autor dentro de 15 min, atualiza campos e guarda log',
      () async {
        final salva = await repo.registrar(_avaliacao('c1'));
        agora = agora.add(const Duration(minutes: 14, seconds: 59));
        await repo.corrigir(
          salva.copyWith(pesoKg: 13.1, tipoMedida: 'em_pe'),
          motivo: 'Peso digitado errado',
        );
        final r = (await repo.ultimaDe('c1'))!;
        expect(r.pesoKg, 13.1);
        expect(r.tipoMedida, 'em_pe');
        expect(r.profissionalId, 'ana');
        expect(banco.alteracoes.single.acao, 'correcao');
      },
    );

    test('corrigir: depois de 15 min o autor é barrado', () async {
      final salva = await repo.registrar(_avaliacao('c1'));
      agora = agora.add(const Duration(minutes: 15));
      expect(
        () => repo.corrigir(salva.copyWith(pesoKg: 13), motivo: 'Peso errado'),
        throwsA(isA<PrazoCorrecaoExpirado>()),
      );
      expect(
        () => repo.excluir(salva.id, motivo: 'Duplicada'),
        throwsA(isA<PrazoCorrecaoExpirado>()),
      );
    });

    test(
      'corrigir: outro profissional é barrado, mesmo dentro do prazo',
      () async {
        final salva = await repo.registrar(_avaliacao('c1'));
        banco.usuario = _beto;
        expect(
          () =>
              repo.corrigir(salva.copyWith(pesoKg: 13), motivo: 'Peso errado'),
          throwsA(isA<PermissaoNegada>()),
        );
      },
    );

    test('corrigir/excluir: master a qualquer momento', () async {
      final salva = await repo.registrar(_avaliacao('c1'));
      agora = agora.add(const Duration(days: 30));
      banco.usuario = _master;
      await repo.corrigir(salva.copyWith(pesoKg: 13), motivo: 'Peso errado');
      expect((await repo.ultimaDe('c1'))!.pesoKg, 13);
      await repo.excluir(salva.id, motivo: 'Lançada na criança errada');
      expect(await repo.ultimaDe('c1'), isNull);
    });

    test('dados do mock (sem autor) só o master corrige', () async {
      final mock = AvaliacaoRepositoryMemoria.comMock();
      final a1 = (await mock.observarTodas().first).firstWhere(
        (a) => a.id == 'a1',
      );
      expect(
        () => mock.corrigir(
          a1.copyWith(pesoKg: 12, indicadores: _ind),
          motivo: 'Peso errado',
        ),
        throwsA(isA<PermissaoNegada>()),
      );
      mock.banco.usuario = _master;
      await mock.corrigir(
        a1.copyWith(pesoKg: 12, indicadores: _ind),
        motivo: 'Peso errado',
      );
      expect((await mock.ultimaDe('c1'))!.pesoKg, 12);
    });

    test('corrigir/excluir exigem motivo e avaliação existente', () async {
      final salva = await repo.registrar(_avaliacao('c1'));
      expect(
        () => repo.corrigir(salva, motivo: 'a'),
        throwsA(isA<MotivoObrigatorio>()),
      );
      expect(
        () => repo.excluir(salva.id, motivo: ''),
        throwsA(isA<MotivoObrigatorio>()),
      );
      expect(
        () => repo.excluir('nada', motivo: 'motivo ok'),
        throwsA(isA<NaoEncontrado>()),
      );
      expect(
        () => repo.corrigir(salva.copyWith(pesoKg: 99), motivo: 'Peso errado'),
        throwsA(isA<DadosInvalidos>()),
      );
    });

    test('exclusão lógica: some das listas, não pode mais editar', () async {
      final salva = await repo.registrar(_avaliacao('c1'));
      final emissoes = <int>[];
      final sub = repo.observarTodas().listen((l) => emissoes.add(l.length));
      await Future<void>.delayed(Duration.zero);
      await repo.excluir(salva.id, motivo: 'Lançada por engano');
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(emissoes, [1, 0]);
      expect(await repo.observarDe('c1').first, isEmpty);
      expect(
        () => repo.corrigir(salva, motivo: 'Tentando de novo'),
        throwsA(isA<EstadoInvalido>()),
      );
      expect(
        () => repo.excluir(salva.id, motivo: 'Tentando de novo'),
        throwsA(isA<EstadoInvalido>()),
      );
      // O registro continua no banco (nada é apagado).
      expect(banco.avaliacoes[salva.id]!.excluida, isTrue);
    });
  });

  group('Repositorios (ponto de acesso)', () {
    setUp(Repositorios.reiniciar);
    tearDown(Repositorios.reiniciar);

    test('padrão: memória com mock, incluindo a criança em destaque', () async {
      final todas = await Repositorios.criancas.buscar('');
      expect(todas.length, MockData.todasCriancas.length);
      final ultima = await Repositorios.avaliacoes.ultimaDe('c0');
      expect(ultima?.id, 'a5');
      expect((await Repositorios.avaliacoes.observarTodas().first).length, 5);
    });

    test('os dois repositórios compartilham dados', () async {
      final id = Repositorios.criancas.novoId();
      await Repositorios.criancas.cadastrar(_crianca(id, 'Nova Criança'));
      final salva = await Repositorios.avaliacoes.registrar(_avaliacao(id));
      expect((await Repositorios.avaliacoes.ultimaDe(id))!.id, salva.id);
      await Repositorios.criancas.desativar(id, motivo: 'Mudou de cidade');
      expect(
        () => Repositorios.avaliacoes.registrar(_avaliacao(id)),
        throwsA(isA<EstadoInvalido>()),
      );
    });

    test(
      'usarMemoria(comMock: false) começa vazio e reiniciar volta ao mock',
      () async {
        Repositorios.usarMemoria(comMock: false);
        expect(await Repositorios.criancas.buscar(''), isEmpty);
        Repositorios.reiniciar();
        expect(await Repositorios.criancas.buscar(''), isNotEmpty);
      },
    );
  });
}
