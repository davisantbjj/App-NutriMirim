import 'dart:async';

import 'package:appnutrimirim/app_state.dart';
import 'package:appnutrimirim/repositories/repositorios.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/auth/login_screen.dart';
import 'package:appnutrimirim/screens/perfil_screen.dart';
import 'package:appnutrimirim/screens/splash_screen.dart';
import 'package:appnutrimirim/services/auth_service.dart';
import 'package:appnutrimirim/services/auth_service_memoria.dart';
import 'package:appnutrimirim/services/sessao_service.dart';
import 'package:appnutrimirim/services/sessao_service_firestore.dart';
import 'package:appnutrimirim/services/sessao_service_memoria.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: subtype_of_sealed_class

// Login → perfil em `profissionais/{uid}` → repositórios, e o logout com o
// cache apagado. Sem Firebase: Firestore falso e serviços em memória.

const _email = 'ana@ubs.gov.br';
const _senha = 'senha123';
const _uid = 'uid-$_email'; // uid que o AuthServiceMemoria dá

Map<String, dynamic> _perfil({
  Object? papel = 'acs',
  Object? ativo = true,
  Object? ubsIds = const ['ubs-a', 'ubs-b'],
  Object? nome = 'Ana Souza',
  Object? microarea = '03',
}) => {
  'nome': nome,
  'email': _email,
  'papel': papel,
  'ubsIds': ubsIds,
  'microarea': microarea,
  'ativo': ativo,
};

// ---------------------------------------------------------------- Firestore

/// Firestore falso: documentos por caminho (`colecao/id`), erros por
/// caminho, e contadores de `terminate`/`clearPersistence`.
class _FirestoreFalso implements FirebaseFirestore {
  final docs = <String, Map<String, dynamic>>{};
  final erros = <String, Object>{};
  bool pendentes = false;
  int terminados = 0;
  int limpezas = 0;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _Colecao(this, path);

  @override
  Future<void> waitForPendingWrites() =>
      pendentes ? Completer<void>().future : Future.value();

  @override
  Future<void> terminate() async => terminados++;

  @override
  Future<void> clearPersistence() async => limpezas++;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Colecao implements CollectionReference<Map<String, dynamic>> {
  _Colecao(this.db, this.path);
  final _FirestoreFalso db;
  @override
  final String path;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? id]) =>
      _Doc(db, '$path/$id');

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    final erro = db.erros[path];
    if (erro != null) throw erro;
    return _Consulta([
      for (final e in db.docs.entries)
        if (e.key.startsWith('$path/')) _Snap(e.key, e.value),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Doc implements DocumentReference<Map<String, dynamic>> {
  _Doc(this.db, this.path);
  final _FirestoreFalso db;
  @override
  final String path;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    final erro = db.erros[path];
    if (erro != null) throw erro;
    final d = db.docs[path];
    return d == null ? _SnapAusente() : _Snap(path, d);
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Snap implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _Snap(this.path, this._data);
  final String path;
  final Map<String, dynamic> _data;

  @override
  String get id => path.split('/').last;

  @override
  bool get exists => true;

  @override
  Map<String, dynamic> data() => _data;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// `DocumentSnapshot.data()` de documento inexistente devolve `null`.
class _SnapAusente implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  Map<String, dynamic>? data() => null;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Consulta implements QuerySnapshot<Map<String, dynamic>> {
  _Consulta(this.docs);
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

FirebaseException _erro(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

// -------------------------------------------------------------------- telas

late AuthServiceMemoria _auth;

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1170, 2532);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: tela,
      routes: {
        Routes.home: (_) => const Scaffold(body: Text('INICIO')),
        Routes.login: (_) => const Scaffold(body: Text('LOGIN')),
      },
    ),
  );
  await t.pumpAndSettle();
}

Future<void> _entrar(WidgetTester t) async {
  final campos = find.byType(TextFormField);
  await t.enterText(campos.at(0), _email);
  await t.enterText(campos.at(1), _senha);
  await t.ensureVisible(find.text('Entrar'));
  await t.tap(find.text('Entrar'));
  await t.pumpAndSettle();
}

Future<void> _tocarSair(WidgetTester t) async {
  await t.scrollUntilVisible(
    find.text('Sair da conta'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await t.tap(find.text('Sair da conta'));
  await t.pumpAndSettle();
}

void main() {
  setUp(() {
    Repositorios.reiniciar();
    _auth = AuthServiceMemoria(contas: {_email: _senha});
    authService = _auth;
  });
  tearDown(() {
    authService = AuthServiceMemoria();
    sessaoService = SessaoServiceMemoria();
    Repositorios.reiniciar();
  });

  group('sessaoDePerfil', () {
    test('monta a sessão do ACS com a primeira UBS como atual', () {
      final s = sessaoDePerfil('u1', _perfil(), nomesUbs: {'ubs-a': 'UBS A'});
      expect(s.uid, 'u1');
      expect(s.nome, 'Ana Souza');
      expect(s.papel, PapelProfissional.acs);
      expect(s.ubsIds, ['ubs-a', 'ubs-b']);
      expect(s.ubsAtualId, 'ubs-a');
      expect(s.microarea, '03');
      expect(s.nomesUbs, {'ubs-a': 'UBS A'});
    });

    test('master pode não ter UBS (UBS atual vazia)', () {
      final s = sessaoDePerfil('m1', _perfil(papel: 'master', ubsIds: []));
      expect(s.master, isTrue);
      expect(s.ubsAtualId, '');
    });

    test('microárea vazia ou ausente fica nula', () {
      expect(sessaoDePerfil('u1', _perfil(microarea: '')).microarea, isNull);
      expect(sessaoDePerfil('u1', _perfil(microarea: null)).microarea, isNull);
    });

    final negados = <String, Map<String, dynamic>?>{
      'sem perfil': null,
      'inativo': _perfil(ativo: false),
      'sem o campo ativo': _perfil(ativo: null),
      'papel desconhecido': _perfil(papel: 'admin'),
      'sem nome': _perfil(nome: ' '),
      'ubsIds não é lista': _perfil(ubsIds: 'ubs-a'),
      'ubsIds com id vazio': _perfil(ubsIds: ['ubs-a', '']),
      'não master sem UBS': _perfil(ubsIds: []),
    };
    for (final caso in negados.entries) {
      test('${caso.key}: acesso não liberado', () {
        expect(
          () => sessaoDePerfil('u1', caso.value),
          throwsA(isA<AcessoNaoLiberadoException>()),
        );
      });
    }
  });

  group('SessaoServiceFirestore', () {
    late _FirestoreFalso db;
    late SessaoServiceFirestore servico;
    const usuario = UsuarioLogado(uid: 'u1', email: _email);

    setUp(() {
      db = _FirestoreFalso();
      servico = SessaoServiceFirestore(
        firestore: db,
        limitePendentes: const Duration(milliseconds: 50),
      );
    });

    test('lê o perfil e os nomes das UBS da lista', () async {
      db.docs['profissionais/u1'] = _perfil();
      db.docs['ubs/ubs-a'] = {'nome': 'UBS A'};
      db.docs['ubs/ubs-b'] = {'nome': 'UBS B'};
      db.docs['ubs/ubs-c'] = {'nome': 'UBS C'}; // fora da lista
      final s = await servico.carregar(usuario);
      expect(s.papel, PapelProfissional.acs);
      expect(s.nomesUbs, {'ubs-a': 'UBS A', 'ubs-b': 'UBS B'});
    });

    test('master lê os nomes de todas as UBS', () async {
      db.docs['profissionais/u1'] = _perfil(papel: 'master', ubsIds: []);
      db.docs['ubs/ubs-a'] = {'nome': 'UBS A'};
      db.docs['ubs/ubs-c'] = {'nome': 'UBS C'};
      final s = await servico.carregar(usuario);
      expect(s.nomesUbs, {'ubs-a': 'UBS A', 'ubs-c': 'UBS C'});
    });

    test('perfil inexistente: acesso não liberado', () {
      expect(
        () => servico.carregar(usuario),
        throwsA(isA<AcessoNaoLiberadoException>()),
      );
    });

    test('permission-denied no perfil: acesso não liberado', () {
      db.erros['profissionais/u1'] = _erro('permission-denied');
      expect(
        () => servico.carregar(usuario),
        throwsA(isA<AcessoNaoLiberadoException>()),
      );
    });

    test('sem rede: mensagem de perfil indisponível', () {
      db.erros['profissionais/u1'] = _erro('unavailable');
      expect(
        () => servico.carregar(usuario),
        throwsA(
          isA<AuthException>()
              .having((e) => e.mensagem, 'mensagem', mensagemPerfilIndisponivel)
              .having(
                (e) => e,
                'tipo',
                isNot(isA<AcessoNaoLiberadoException>()),
              ),
        ),
      );
    });

    test('falha ao ler as UBS não impede o login', () async {
      db.docs['profissionais/u1'] = _perfil();
      db.erros['ubs/ubs-a'] = _erro('permission-denied');
      final s = await servico.carregar(usuario);
      expect(s.nomesUbs, isEmpty);
    });

    test('ligar troca os repositórios e guarda a sessão', () async {
      db.docs['profissionais/u1'] = _perfil();
      final s = await servico.carregar(usuario);
      await servico.ligar(s);
      expect(Repositorios.sessao, same(s));
      expect(
        Repositorios.criancas.runtimeType.toString(),
        'CriancaRepositoryFirestore',
      );
    });

    test('desligar volta à memória e apaga o cache', () async {
      db.docs['profissionais/u1'] = _perfil();
      await servico.ligar(await servico.carregar(usuario));
      await servico.desligar();
      expect(Repositorios.sessao, isNull);
      expect(
        Repositorios.criancas.runtimeType.toString(),
        'CriancaRepositoryMemoria',
      );
      expect(db.terminados, 1);
      expect(db.limpezas, 1);
    });

    test('registros pendentes: detecta pelo tempo limite', () async {
      expect(await servico.semRegistrosPendentes(), isTrue);
      db.pendentes = true;
      expect(await servico.semRegistrosPendentes(), isFalse);
    });
  });

  group('iniciarSessao e sairDaConta', () {
    test('sem perfil: sai da conta do Firebase e relança', () async {
      sessaoService = SessaoServiceMemoria(perfis: {});
      final u = await _auth.entrar(email: _email, senha: _senha);
      await expectLater(
        iniciarSessao(u),
        throwsA(isA<AcessoNaoLiberadoException>()),
      );
      expect(authService.atual, isNull);
    });

    test('com perfil: liga a sessão', () async {
      final sessao = SessaoServiceMemoria(perfis: {_uid: _perfil()});
      sessaoService = sessao;
      final u = await _auth.entrar(email: _email, senha: _senha);
      final s = await iniciarSessao(u);
      expect(sessao.ligada, same(s));
      expect(authService.atual, isNotNull);
    });

    test('com registros pendentes não sai', () async {
      sessaoService = SessaoServiceMemoria(registrosPendentes: true);
      await _auth.entrar(email: _email, senha: _senha);
      await expectLater(
        sairDaConta(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.mensagem,
            'mensagem',
            mensagemRegistrosPendentes,
          ),
        ),
      );
      expect(authService.atual, isNotNull);
    });
  });

  group('telas', () {
    testWidgets('Login com perfil ativo liga a sessão e abre o Início', (
      t,
    ) async {
      final sessao = SessaoServiceMemoria(perfis: {_uid: _perfil()});
      sessaoService = sessao;
      await _abrir(t, const LoginScreen());
      await _entrar(t);
      expect(find.text('INICIO'), findsOneWidget);
      expect(sessao.ligada?.nome, 'Ana Souza');
    });

    testWidgets('Login com perfil inativo fica no Login com a mensagem', (
      t,
    ) async {
      sessaoService = SessaoServiceMemoria(
        perfis: {_uid: _perfil(ativo: false)},
      );
      await _abrir(t, const LoginScreen());
      await _entrar(t);
      expect(find.text('INICIO'), findsNothing);
      expect(find.text(mensagemAcessoNaoLiberado), findsOneWidget);
      expect(authService.atual, isNull);
    });

    testWidgets('Login sem conexão para o perfil mostra o erro', (t) async {
      sessaoService = SessaoServiceMemoria(
        erroAoCarregar: const AuthException(mensagemPerfilIndisponivel),
      );
      await _abrir(t, const LoginScreen());
      await _entrar(t);
      expect(find.text(mensagemPerfilIndisponivel), findsOneWidget);
      expect(authService.atual, isNull);
    });

    testWidgets('Abertura com sessão salva e perfil ativo vai ao Início', (
      t,
    ) async {
      final sessao = SessaoServiceMemoria(perfis: {'u1': _perfil()});
      sessaoService = sessao;
      authService = AuthServiceMemoria(
        logado: const UsuarioLogado(uid: 'u1', email: _email),
      );
      await _abrir(t, const SplashScreen());
      await t.pump(const Duration(seconds: 3));
      await t.pumpAndSettle();
      expect(find.text('INICIO'), findsOneWidget);
      expect(sessao.ligada, isNotNull);
    });

    testWidgets('Abertura com sessão salva sem perfil vai ao Login', (t) async {
      sessaoService = SessaoServiceMemoria(perfis: {});
      authService = AuthServiceMemoria(
        logado: const UsuarioLogado(uid: 'u1', email: _email),
      );
      await _abrir(t, const SplashScreen());
      await t.pump(const Duration(seconds: 3));
      await t.pumpAndSettle();
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text(mensagemAcessoNaoLiberado), findsOneWidget);
      expect(authService.atual, isNull);
    });

    testWidgets('Sair abre o Login e depois apaga o cache', (t) async {
      final sessao = SessaoServiceMemoria();
      sessaoService = sessao;
      authService = AuthServiceMemoria(
        logado: const UsuarioLogado(uid: 'u1', email: _email),
      );
      await _abrir(t, const PerfilScreen());
      await _tocarSair(t);
      expect(find.text('LOGIN'), findsOneWidget);
      expect(authService.atual, isNull);
      expect(sessao.desligamentos, 1);
    });

    testWidgets('Sair com registros pendentes fica no Perfil', (t) async {
      final sessao = SessaoServiceMemoria(registrosPendentes: true);
      sessaoService = sessao;
      authService = AuthServiceMemoria(
        logado: const UsuarioLogado(uid: 'u1', email: _email),
      );
      await _abrir(t, const PerfilScreen());
      await _tocarSair(t);
      expect(find.text(mensagemRegistrosPendentes), findsOneWidget);
      expect(find.text('LOGIN'), findsNothing);
      expect(authService.atual, isNotNull);
      expect(sessao.desligamentos, 0);
    });
  });
}
