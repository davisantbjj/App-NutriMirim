import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/repositories/excecoes.dart';
import 'package:appnutrimirim/repositories/firestore/conversoes.dart';
import 'package:appnutrimirim/repositories/firestore/erros_firestore.dart';
import 'package:appnutrimirim/repositories/memoria/banco_memoria.dart';
import 'package:appnutrimirim/repositories/memoria/criancas_memoria.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:flutter_test/flutter_test.dart';

Crianca _c({String cpf = '', String tel = ''}) => Crianca(
  id: 'k1',
  nome: 'Maria Souza',
  sexo: Sexo.feminino,
  bairro: 'Centro',
  cadastradoEm: DateTime(2025, 1, 10),
  responsavel: Responsavel(
    nome: 'Joana Souza',
    cpfMascarado: cpf,
    telefone: tel,
    email: '',
  ),
);

FirebaseException _fb(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

void main() {
  group('CPF e telefone com tamanho errado', () {
    late CriancaRepositoryMemoria repo;
    setUp(() => repo = CriancaRepositoryMemoria(BancoMemoria()));

    test('cadastrar recusa CPF e telefone incompletos', () async {
      for (final c in [
        _c(cpf: '123.456'),
        _c(cpf: '123456789012'),
        _c(tel: '(79) 1234'),
        _c(tel: '119876543210'),
      ]) {
        await expectLater(repo.cadastrar(c), throwsA(isA<DadosInvalidos>()));
      }
    });

    test('vazio é aceito; valores completos também', () async {
      await repo.cadastrar(_c());
      await repo.editar(
        _c(cpf: '529.982.247-25', tel: '(79) 91234-5678'),
        motivo: 'Dados completos',
      );
      final r = (await repo.porId('k1'))!.responsavel!;
      expect(r.cpfMascarado, '529.982.247-25');
    });

    test('editar recusa tamanho errado e campo vazio apaga', () async {
      await repo.cadastrar(_c(cpf: '529.982.247-25'));
      await expectLater(
        repo.editar(_c(cpf: '529'), motivo: 'Correção'),
        throwsA(isA<DadosInvalidos>()),
      );
      await repo.editar(_c(), motivo: 'Apagar CPF');
      expect((await repo.porId('k1'))!.responsavel!.cpfMascarado, '');
    });

    test('CPF mascarado com * mantém o antigo completo', () async {
      await repo.cadastrar(_c(cpf: '529.982.247-25'));
      await repo.editar(_c(cpf: '529.***.***-25'), motivo: 'Outra edição');
      expect(
        (await repo.porId('k1'))!.responsavel!.cpfMascarado,
        '529.982.247-25',
      );
    });
  });

  group('observarPorId (memória)', () {
    test('emite a criança, as edições e null se não existe', () async {
      final banco = BancoMemoria();
      final repo = CriancaRepositoryMemoria(banco);
      expect(await repo.observarPorId('k1').first, isNull);

      await repo.cadastrar(_c());
      final nomes = <String?>[];
      final sub = repo.observarPorId('k1').listen((c) => nomes.add(c?.nome));
      await Future<void>.delayed(Duration.zero);
      await repo.editar(
        _c().copyWith(nome: 'Maria S. Lima'),
        motivo: 'Erro de digitação',
      );
      await repo.desativar('k1', motivo: 'Mudou de cidade');
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(nomes, ['Maria Souza', 'Maria S. Lima', 'Maria S. Lima']);
      // Desativada continua emitida (com ativa == false).
      expect((await repo.observarPorId('k1').first)!.ativa, isFalse);
    });
  });

  group('traduzirErro', () {
    test('permission-denied: texto neutro', () {
      final e = erroTraduzido(_fb('permission-denied'));
      expect(e, isA<PermissaoNegada>());
      expect(
        (e as PermissaoNegada).mensagem,
        'O servidor recusou a operação. Recarregue os dados e tente de novo.',
      );
    });
    test('unavailable, not-found e código desconhecido', () {
      expect(
        (erroTraduzido(_fb('unavailable')) as RepositorioException).mensagem,
        contains('Sem conexão'),
      );
      expect(erroTraduzido(_fb('not-found')), isA<NaoEncontrado>());
      final d = erroTraduzido(_fb('aborted')) as RepositorioException;
      expect(d.mensagem, contains('aborted'));
      expect(d, isNot(isA<PermissaoNegada>()));
    });
    test('traduzirErro lança; outros erros passam como estão', () {
      expect(
        () => traduzirErro(_fb('permission-denied'), StackTrace.current),
        throwsA(isA<PermissaoNegada>()),
      );
      expect(
        () => traduzirErro(const PrazoCorrecaoExpirado(), StackTrace.current),
        throwsA(isA<PrazoCorrecaoExpirado>()),
      );
      expect(
        () => traduzirErro(StateError('x'), StackTrace.current),
        throwsStateError,
      );
    });
    test('traduzir converte erro assíncrono', () async {
      await expectLater(
        traduzir<void>(() async => throw _fb('unavailable')),
        throwsA(isA<RepositorioException>()),
      );
    });
  });

  group('leitura tolerante', () {
    test('tipos errados viram padrão, sem TypeError', () {
      final c = criancaDeMap('k', {
        'nome': 5,
        'bairro': true,
        'endereco': 1.5,
        'ubsId': 3,
        'ativa': 'sim',
        'sexo': 9,
      });
      expect(c.nome, '');
      expect(c.bairro, '');
      expect(c.ativa, isTrue);
      final r = responsavelDeMap({'nome': 7, 'email': 8})!;
      expect(r.nome, '');
      expect(r.email, '');
      final a = avaliacaoDeMap('a', {
        'criancaId': 1,
        'pesoKg': 'x',
        'alturaCm': [],
        'profissionalId': 2,
        'profissionalNome': 3,
        'tipoMedida': 4,
        'desnutricao': 'nao',
        'versaoTabelaOms': 5,
        'excluida': 'nao',
      });
      expect(a.criancaId, '');
      expect(a.pesoKg, 0);
      expect(a.profissionalId, isNull);
      expect(a.tipoMedida, isNull);
      expect(a.desnutricao, isFalse);
      expect(a.versaoTabelaOms, 'oms-2006');
      expect(a.excluida, isFalse);
    });
  });
}
