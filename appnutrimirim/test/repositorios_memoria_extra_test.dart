import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/repositories/memoria/avaliacoes_memoria.dart';
import 'package:appnutrimirim/repositories/memoria/criancas_memoria.dart';
import 'package:appnutrimirim/repositories/repositorios.dart';
import 'package:flutter_test/flutter_test.dart';

// Lacunas de cobertura da camada em memória (janela de 15 min nos limites,
// motivo, ordenação, streams, busca e edição).

const _ana = UsuarioAtual(uid: 'ana', nome: 'Ana Souza');
const _master = UsuarioAtual(uid: 'm1', nome: 'Mestre', master: true);

Crianca _crianca(
  String id,
  String nome, {
  Responsavel? responsavel,
  String ubs = '',
}) => Crianca(
  id: id,
  nome: nome,
  sexo: Sexo.feminino,
  bairro: 'Centro',
  ubs: ubs,
  cadastradoEm: DateTime(2025, 1, 10),
  responsavel: responsavel,
);

Avaliacao _av(String criancaId, {DateTime? data, double peso = 12.5}) =>
    Avaliacao(
      criancaId: criancaId,
      data: data ?? DateTime(2026, 3, 1),
      pesoKg: peso,
      alturaCm: 85,
      situacao: Situacao.normal,
      indicadores: const {'pi': Indicador('P/I', -0.5, Situacao.normal)},
    );

Responsavel _resp(String cpf) =>
    Responsavel(nome: 'Mãe Teste', cpfMascarado: cpf, telefone: '', email: '');

void main() {
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

  group('janela de 15 minutos (RF14) nos limites exatos', () {
    final t0 = DateTime(2026, 5, 10, 9);

    Future<Avaliacao> registrada() => repo.registrar(_av('c1'));

    test('14:59 ainda corrige e exclui', () async {
      final a = await registrada();
      agora = t0.add(const Duration(minutes: 14, seconds: 59));
      await repo.corrigir(a.copyWith(pesoKg: 13), motivo: 'Peso errado');
      await repo.excluir(a.id, motivo: 'Lançada errada');
      expect(await repo.ultimaDe('c1'), isNull);
    });

    test('15:00 exato já expirou (limite exclusivo)', () async {
      final a = await registrada();
      agora = t0.add(const Duration(minutes: 15));
      await expectLater(
        repo.corrigir(a.copyWith(pesoKg: 13), motivo: 'Peso errado'),
        throwsA(isA<PrazoCorrecaoExpirado>()),
      );
      await expectLater(
        repo.excluir(a.id, motivo: 'Lançada errada'),
        throwsA(isA<PrazoCorrecaoExpirado>()),
      );
    });

    test('15:01 expirou', () async {
      final a = await registrada();
      agora = t0.add(const Duration(minutes: 15, seconds: 1));
      await expectLater(
        repo.excluir(a.id, motivo: 'Lançada errada'),
        throwsA(isA<PrazoCorrecaoExpirado>()),
      );
    });

    test('prazo expirado não altera a avaliação nem gera log', () async {
      final a = await registrada();
      agora = t0.add(const Duration(minutes: 20));
      await expectLater(
        repo.corrigir(a.copyWith(pesoKg: 20), motivo: 'Peso errado'),
        throwsA(isA<PrazoCorrecaoExpirado>()),
      );
      expect(banco.avaliacoes[a.id]!.pesoKg, 12.5);
      expect(banco.alteracoes, isEmpty);
    });

    test('master corrige horas depois, mas não uma já excluída', () async {
      final a = await registrada();
      banco.usuario = _master;
      agora = t0.add(const Duration(hours: 5));
      await repo.corrigir(a.copyWith(pesoKg: 14), motivo: 'Revisão');
      await repo.excluir(a.id, motivo: 'Duplicada');
      await expectLater(
        repo.corrigir(a.copyWith(pesoKg: 15), motivo: 'Revisão'),
        throwsA(isA<EstadoInvalido>()),
      );
    });
  });

  group('avaliação excluída, criança inativa ou inexistente', () {
    test('corrigir/excluir avaliação já excluída: EstadoInvalido', () async {
      final a = await repo.registrar(_av('c1'));
      await repo.excluir(a.id, motivo: 'Lançada errada');
      await expectLater(
        repo.corrigir(a, motivo: 'Tentando de novo'),
        throwsA(isA<EstadoInvalido>()),
      );
      await expectLater(
        repo.excluir(a.id, motivo: 'Tentando de novo'),
        throwsA(isA<EstadoInvalido>()),
      );
      expect(banco.alteracoes.length, 1, reason: 'só o log da exclusão');
    });

    test('registrar para criança inexistente: NaoEncontrado', () async {
      await expectLater(
        repo.registrar(_av('nao-existe')),
        throwsA(isA<NaoEncontrado>()),
      );
    });

    test('registrar para criança desativada: EstadoInvalido', () async {
      await criancas.desativar('c1', motivo: 'Mudou de cidade');
      await expectLater(
        repo.registrar(_av('c1')),
        throwsA(isA<EstadoInvalido>()),
      );
      expect(banco.avaliacoes, isEmpty);
    });

    test('registrar sem criancaId: DadosInvalidos', () async {
      await expectLater(
        repo.registrar(_av('')),
        throwsA(isA<DadosInvalidos>()),
      );
    });

    test('id já usado (inclusive de excluída) é recusado', () async {
      final a = await repo.registrar(_av('c1'));
      await repo.excluir(a.id, motivo: 'Lançada errada');
      await expectLater(
        repo.registrar(_av('c1').copyWith(id: a.id)),
        throwsA(isA<EstadoInvalido>()),
      );
    });

    test('corrigir não troca a criança da avaliação', () async {
      await criancas.cadastrar(_crianca('c2', 'Outra Criança'));
      final a = await repo.registrar(_av('c1'));
      await repo.corrigir(
        a.copyWith(criancaId: 'c2', pesoKg: 13),
        motivo: 'Peso errado',
      );
      expect(banco.avaliacoes[a.id]!.criancaId, 'c1');
      expect(banco.avaliacoes[a.id]!.pesoKg, 13);
    });
  });

  group('motivo: 2/3/200/201 caracteres e só espaços', () {
    Future<void> editarCom(String motivo) =>
        criancas.editar(_crianca('c1', 'Maria Souza Editada'), motivo: motivo);

    test('2 caracteres e só espaços falham', () async {
      for (final m in ['ab', '  ab  ', '   ', '', '\t\n ']) {
        await expectLater(
          editarCom(m),
          throwsA(isA<MotivoObrigatorio>()),
          reason: 'motivo "$m"',
        );
      }
      expect(banco.alteracoes, isEmpty);
    });

    test('3 e 200 caracteres passam; 201 falha', () async {
      await editarCom('abc');
      await editarCom('x' * 200);
      await expectLater(
        editarCom('x' * 201),
        throwsA(isA<MotivoObrigatorio>()),
      );
      expect(banco.alteracoes.length, 2);
    });

    test(
      'espaços nas pontas não contam; o log guarda o motivo aparado',
      () async {
        await editarCom('   abc   ');
        expect(banco.alteracoes.single.motivo, 'abc');
        await editarCom('  ${'y' * 200}  ');
        expect(banco.alteracoes.last.motivo.length, 200);
      },
    );

    test('mesma regra em excluir e desativar', () async {
      final a = await repo.registrar(_av('c1'));
      await expectLater(
        repo.excluir(a.id, motivo: 'ab'),
        throwsA(isA<MotivoObrigatorio>()),
      );
      await expectLater(
        criancas.desativar('c1', motivo: 'x' * 201),
        throwsA(isA<MotivoObrigatorio>()),
      );
      expect(banco.criancas['c1']!.ativa, isTrue);
      expect(banco.avaliacoes[a.id]!.excluida, isFalse);
    });

    test('versão sobe de 1 em 1 a cada edição bem-sucedida', () async {
      await editarCom('primeira');
      await editarCom('segunda');
      await expectLater(editarCom('x'), throwsA(isA<MotivoObrigatorio>()));
      expect(banco.alteracoes.map((e) => e.versao), [1, 2]);
      expect(banco.versoes['c1'], 2);
    });
  });

  group('registrar ignora o que vem do objeto', () {
    test('profissionalId, profissionalNome, criadoEm e excluida', () async {
      final salva = await repo.registrar(
        _av('c1').copyWith(
          profissionalId: 'invasor',
          profissionalNome: 'Invasor',
          criadoEm: DateTime(2000),
          excluida: true,
        ),
      );
      expect(salva.profissionalId, 'ana');
      expect(salva.profissionalNome, 'Ana Souza');
      expect(salva.criadoEm, agora);
      expect(salva.excluida, isFalse);
      expect(banco.avaliacoes[salva.id]!.criadoEm, agora);
      expect((await repo.ultimaDe('c1'))!.id, salva.id);
    });

    test('outro usuário logado vira o autor', () async {
      banco.usuario = const UsuarioAtual(uid: 'beto', nome: 'Beto');
      final salva = await repo.registrar(_av('c1'));
      expect(salva.profissionalId, 'beto');
    });

    test('o papel vem do usuário logado, não do objeto', () async {
      banco.usuario = const UsuarioAtual(
        uid: 'beto',
        nome: 'Beto',
        papel: PapelProfissional.nutricionista,
      );
      final salva = await repo.registrar(
        _av('c1').copyWith(profissionalPapel: PapelProfissional.master),
      );
      expect(salva.profissionalPapel, PapelProfissional.nutricionista);
      expect(
        banco.avaliacoes[salva.id]!.profissionalPapel,
        PapelProfissional.nutricionista,
      );
    });

    test('usuário sem papel não herda o papel do objeto', () async {
      banco.usuario = const UsuarioAtual(uid: 'beto', nome: 'Beto');
      final salva = await repo.registrar(
        _av('c1').copyWith(profissionalPapel: PapelProfissional.master),
      );
      expect(salva.profissionalPapel, isNull);
    });
  });

  group('ultimaDe e ordenação', () {
    test(
      'após excluir a mais recente volta a anterior; sem nenhuma, null',
      () async {
        final velha = await repo.registrar(
          _av('c1', data: DateTime(2026, 3, 1)),
        );
        final nova = await repo.registrar(
          _av('c1', data: DateTime(2026, 4, 1)),
        );
        expect((await repo.ultimaDe('c1'))!.id, nova.id);
        await repo.excluir(nova.id, motivo: 'Lançada errada');
        expect((await repo.ultimaDe('c1'))!.id, velha.id);
        await repo.excluir(velha.id, motivo: 'Lançada errada');
        expect(await repo.ultimaDe('c1'), isNull);
      },
    );

    test('ultimaDe de criança sem avaliações ou inexistente é null', () async {
      expect(await repo.ultimaDe('c1'), isNull);
      expect(await repo.ultimaDe('nao-existe'), isNull);
    });

    test('ordena pela data da medição, não pela ordem de registro', () async {
      final b = await repo.registrar(_av('c1', data: DateTime(2026, 4, 1)));
      final a = await repo.registrar(_av('c1', data: DateTime(2026, 2, 1)));
      final c = await repo.registrar(_av('c1', data: DateTime(2026, 5, 1)));
      final lista = await repo.observarDe('c1').first;
      expect(lista.map((e) => e.id), [c.id, b.id, a.id]);
    });

    test(
      'mesma data: a registrada por último (criadoEm maior) vem primeiro',
      () async {
        final mesma = DateTime(2026, 4, 1);
        final a = await repo.registrar(_av('c1', data: mesma));
        agora = agora.add(const Duration(minutes: 1));
        final b = await repo.registrar(_av('c1', data: mesma));
        agora = agora.add(const Duration(minutes: 1));
        final c = await repo.registrar(_av('c1', data: mesma));
        final ids = (await repo.observarDe('c1').first).map((e) => e.id);
        expect(ids, [c.id, b.id, a.id]);
        expect((await repo.ultimaDe('c1'))!.id, c.id);
      },
    );

    test('mesma data e mesmo criadoEm: ordem igual entre leituras', () async {
      final mesma = DateTime(2026, 4, 1);
      for (var i = 0; i < 12; i++) {
        await repo.registrar(_av('c1', data: mesma));
      }
      final l1 = (await repo.observarDe('c1').first).map((e) => e.id).toList();
      final l2 = (await repo.observarDe('c1').first).map((e) => e.id).toList();
      expect(l1, l2);
      expect(l1.toSet().length, 12);
    });

    test(
      'mesma data e mesmo criadoEm: a registrada por último deveria vir primeiro',
      () async {
        final mesma = DateTime(2026, 4, 1);
        await repo.registrar(_av('c1', data: mesma));
        final ultima = await repo.registrar(_av('c1', data: mesma));
        expect((await repo.ultimaDe('c1'))!.id, ultima.id);
      },
    );

    test('observarTodas mistura crianças e respeita a data', () async {
      await criancas.cadastrar(_crianca('c2', 'Outra Criança'));
      final x = await repo.registrar(_av('c1', data: DateTime(2026, 3, 1)));
      final y = await repo.registrar(_av('c2', data: DateTime(2026, 4, 1)));
      final lista = await repo.observarTodas().first;
      expect(lista.map((e) => e.id), [y.id, x.id]);
    });

    test('a lista emitida não pode ser alterada pelo chamador', () async {
      await repo.registrar(_av('c1'));
      final lista = await repo.observarTodas().first;
      expect(() => lista.clear(), throwsUnsupportedError);
    });
  });

  group('streams', () {
    test('cada mudança emite uma única vez; falha não emite', () async {
      final emitidos = <int>[];
      final sub = repo.observarDe('c1').listen((l) => emitidos.add(l.length));
      await Future<void>.delayed(Duration.zero);
      expect(emitidos, [0]);

      final a = await repo.registrar(_av('c1'));
      expect(emitidos, [0, 1]);

      await expectLater(
        repo.corrigir(a.copyWith(pesoKg: 999), motivo: 'Peso errado'),
        throwsA(isA<DadosInvalidos>()),
      );
      await expectLater(
        repo.excluir(a.id, motivo: 'x'),
        throwsA(isA<MotivoObrigatorio>()),
      );
      expect(emitidos, [0, 1], reason: 'operações recusadas não notificam');

      await repo.corrigir(a.copyWith(pesoKg: 13), motivo: 'Peso errado');
      expect(emitidos, [0, 1, 1]);
      await repo.excluir(a.id, motivo: 'Lançada errada');
      expect(emitidos, [0, 1, 1, 0]);
      await sub.cancel();
    });

    test('depois de cancelar, a assinatura não recebe mais nada', () async {
      var chamadas = 0;
      final sub = repo.observarTodas().listen((_) => chamadas++);
      await Future<void>.delayed(Duration.zero);
      expect(chamadas, 1);
      await sub.cancel();
      await repo.registrar(_av('c1'));
      await criancas.cadastrar(_crianca('c9', 'Zeca'));
      expect(chamadas, 1);
    });

    test('cancelar uma assinatura não afeta as outras', () async {
      final a = <int>[], b = <int>[];
      final s1 = repo.observarTodas().listen((l) => a.add(l.length));
      final s2 = repo.observarTodas().listen((l) => b.add(l.length));
      await Future<void>.delayed(Duration.zero);
      await s1.cancel();
      await repo.registrar(_av('c1'));
      await Future<void>.delayed(Duration.zero);
      expect(a, [0]);
      expect(b, [0, 1]);
      await s2.cancel();
    });

    test('reassinar o mesmo stream traz de novo o estado atual', () async {
      await repo.registrar(_av('c1'));
      final stream = repo.observarTodas();
      expect((await stream.first).length, 1);
      expect((await stream.first).length, 1);
    });

    test('stream de crianças emite ao editar e desativar', () async {
      final nomes = <List<String>>[];
      final sub = criancas.observarTodas().listen(
        (l) => nomes.add(l.map((c) => c.nome).toList()),
      );
      await Future<void>.delayed(Duration.zero);
      await criancas.editar(
        _crianca('c1', 'Ana Maria'),
        motivo: 'Nome corrigido',
      );
      await Future<void>.delayed(Duration.zero);
      await criancas.desativar('c1', motivo: 'Mudou de cidade');
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(nomes, [
        ['Maria Souza'],
        ['Ana Maria'],
        <String>[],
      ]);
    });
  });

  group('buscar', () {
    setUp(() async {
      await criancas.cadastrar(
        _crianca('c2', 'João Pedro', responsavel: _resp('857.123.456-54')),
      );
      await criancas.cadastrar(
        _crianca('c3', 'Joana Silva', responsavel: _resp('***.123.456-**')),
      );
    });

    test('CPF formatado e só dígitos acham o mesmo resultado', () async {
      expect((await criancas.buscar('857.123.456-54')).map((c) => c.id), [
        'c2',
      ]);
      expect((await criancas.buscar('85712345654')).map((c) => c.id), ['c2']);
    });

    test('CPF com espaços acha; com 10 dígitos vira busca por nome', () async {
      expect((await criancas.buscar('  85712345654 ')).map((c) => c.id), [
        'c2',
      ]);
      expect(await criancas.buscar('8571234565'), isEmpty);
    });

    test('CPF de ninguém não devolve nada', () async {
      expect(await criancas.buscar('000.000.000-00'), isEmpty);
    });

    test(
      'CPF mascarado de outro responsável não casa por dígitos parciais',
      () async {
        expect(await criancas.buscar('123456'), isEmpty);
      },
    );

    test('termo vazio ou só espaços devolve todas, em ordem de nome', () async {
      for (final t in ['', '   ']) {
        final r = await criancas.buscar(t);
        expect(r.map((c) => c.nome), [
          'Joana Silva',
          'João Pedro',
          'Maria Souza',
        ]);
      }
    });

    test('nome parcial sem acento/caixa; não devolve desativadas', () async {
      expect((await criancas.buscar('JOAO')).map((c) => c.id), ['c2']);
      expect((await criancas.buscar('jo')).length, 2);
      await criancas.desativar('c2', motivo: 'Mudou de cidade');
      expect(await criancas.buscar('joao'), isEmpty);
      expect(await criancas.buscar('85712345654'), isEmpty);
    });

    test('termo com caracteres de regex não quebra', () async {
      expect(await criancas.buscar('.*'), isEmpty);
      expect(await criancas.buscar('(['), isEmpty);
    });
  });

  group('editar preserva ativa, cadastradoEm e ubs', () {
    test('valores vindos no objeto são ignorados', () async {
      await criancas.cadastrar(
        _crianca('c5', 'Beatriz Lima', ubs: 'UBS Jardim das Flores'),
      );
      final antes = banco.criancas['c5']!;
      final tentativa = antes.copyWith(
        nome: '  Beatriz Lima Souza  ',
        ubs: 'Outra UBS',
        ativa: false,
        cadastradoEm: DateTime(2025, 6, 1),
        bairro: 'Bairro Novo',
      );
      await criancas.editar(tentativa, motivo: 'Dados atualizados');
      final depois = banco.criancas['c5']!;
      expect(depois.ubs, 'UBS Jardim das Flores');
      expect(depois.ativa, isTrue);
      expect(depois.cadastradoEm, DateTime(2025, 1, 10));
      expect(depois.nome, 'Beatriz Lima Souza');
      expect(depois.bairro, 'Bairro Novo');
    });

    test(
      'limpar responsável e nascimento 29/02; editar inexistente falha',
      () async {
        await criancas.cadastrar(
          _crianca('c6', 'Carla Dias', responsavel: _resp('111.222.333-44')),
        );
        await criancas.editar(
          banco.criancas['c6']!.copyWith(
            limparResponsavel: true,
            nascimento: DateTime(2024, 2, 29),
          ),
          motivo: 'Responsável removido',
        );
        expect(banco.criancas['c6']!.responsavel, isNull);
        expect(banco.criancas['c6']!.nascimento, DateTime(2024, 2, 29));
        await expectLater(
          criancas.editar(_crianca('x', 'Fulano'), motivo: 'Motivo ok'),
          throwsA(isA<NaoEncontrado>()),
        );
      },
    );

    test('dados inválidos na edição não alteram nada nem geram log', () async {
      await expectLater(
        criancas.editar(_crianca('c1', 'A'), motivo: 'Motivo ok'),
        throwsA(isA<DadosInvalidos>()),
      );
      expect(banco.criancas['c1']!.nome, 'Maria Souza');
      expect(banco.alteracoes, isEmpty);
    });

    test('desativar duas vezes falha; porId ainda acha a desativada', () async {
      await criancas.desativar('c1', motivo: 'Mudou de cidade');
      await expectLater(
        criancas.desativar('c1', motivo: 'Mudou de cidade'),
        throwsA(isA<EstadoInvalido>()),
      );
      expect((await criancas.porId('c1'))!.ativa, isFalse);
      expect(await criancas.observarTodas().first, isEmpty);
    });
  });
}
