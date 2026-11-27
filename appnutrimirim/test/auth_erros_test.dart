import 'dart:async';

import 'package:appnutrimirim/app_state.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/perfil_screen.dart';
import 'package:appnutrimirim/screens/splash_screen.dart';
import 'package:appnutrimirim/services/auth_service.dart';
import 'package:appnutrimirim/services/auth_service_memoria.dart';
import 'package:appnutrimirim/services/firebase_auth_service.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Firebase Auth falso: cada método faz o que o teste mandar.
class _FirebaseAuthFalso implements FirebaseAuth {
  Stream<User?> Function() estado = () => Stream.value(null);
  Future<UserCredential> Function() login = () async => _CredencialFalsa(null);
  Future<void> Function() reset = () async {};
  Future<void> Function() logout = () async {};

  @override
  Stream<User?> authStateChanges() => estado();

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => login();

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) => reset();

  @override
  Future<void> signOut() => logout();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CredencialFalsa implements UserCredential {
  _CredencialFalsa(this.user);

  @override
  final User? user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UsuarioFalso implements User {
  @override
  String get uid => 'u1';

  @override
  String? get email => 'ana@ubs.gov.br';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FirebaseAuthException _erro(String code) => FirebaseAuthException(code: code);

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

void main() {
  late _FirebaseAuthFalso fb;
  late FirebaseAuthService servico;

  setUp(() {
    fb = _FirebaseAuthFalso();
    servico = FirebaseAuthService(fb, const Duration(milliseconds: 50));
  });
  tearDown(() => authService = AuthServiceMemoria());

  group('FirebaseAuthService: erros viram AuthException', () {
    test('entrar: erro que não é do Firebase', () {
      fb.login = () async => throw StateError('plugin quebrado');
      expect(
        () => servico.entrar(email: 'a@b.com', senha: '123456'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.mensagem,
            'mensagem',
            'Não foi possível concluir. Tente de novo.',
          ),
        ),
      );
    });

    test('entrar: Firebase sem usuário na resposta (antes era cred.user!)', () {
      fb.login = () async => _CredencialFalsa(null);
      expect(
        () => servico.entrar(email: 'a@b.com', senha: '123456'),
        throwsA(isA<AuthException>()),
      );
    });

    test('entrar: senha errada continua com a mensagem própria', () {
      fb.login = () async => throw _erro('invalid-credential');
      expect(
        () => servico.entrar(email: 'a@b.com', senha: 'x'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.mensagem,
            'mensagem',
            'E-mail ou senha incorretos.',
          ),
        ),
      );
    });

    test('entrar: sucesso devolve o usuário', () async {
      fb.login = () async => _CredencialFalsa(_UsuarioFalso());
      final u = await servico.entrar(email: 'ana@ubs.gov.br', senha: 'x');
      expect(u.uid, 'u1');
    });

    test('sair: erro vira AuthException', () {
      fb.logout = () async => throw StateError('falhou');
      expect(servico.sair, throwsA(isA<AuthException>()));
    });

    test('restaurarSessao: erro devolve null (segue para o Login)', () async {
      fb.estado = () => Stream.error(StateError('falhou'));
      expect(await servico.restaurarSessao(), isNull);
    });

    test('restaurarSessao: demora demais devolve null', () async {
      // Stream que nunca emite: simula o Firebase sem responder.
      fb.estado = () => StreamController<User?>().stream;
      expect(await servico.restaurarSessao(), isNull);
    });
  });

  group('recuperação sem revelar quais e-mails têm conta', () {
    test('e-mail sem conta (user-not-found) conta como enviado', () async {
      fb.reset = () async => throw _erro('user-not-found');
      await expectLater(
        servico.recuperarSenha('ninguem@ubs.gov.br'),
        completes,
      );
    });

    test('e-mail com conta também conta como enviado', () async {
      await expectLater(servico.recuperarSenha('ana@ubs.gov.br'), completes);
    });

    test('outros erros continuam aparecendo (ex.: sem internet)', () {
      fb.reset = () async => throw _erro('network-request-failed');
      expect(
        () => servico.recuperarSenha('ana@ubs.gov.br'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.mensagem,
            'mensagem',
            contains('internet'),
          ),
        ),
      );
    });
  });

  group('telas', () {
    testWidgets('Abertura cai no Login se a sessão não puder ser lida', (
      t,
    ) async {
      authService = AuthServiceMemoria(erroAoRestaurar: StateError('falhou'));
      await _abrir(t, const SplashScreen());
      await t.pump(const Duration(seconds: 3));
      await t.pumpAndSettle();
      expect(find.text('LOGIN'), findsOneWidget);
    });

    testWidgets('Sair com erro fica no Perfil e mostra a mensagem', (t) async {
      authService = AuthServiceMemoria(
        logado: const UsuarioLogado(uid: 'u1', email: 'ana@ubs.gov.br'),
        erroAoSair: const AuthException('Não foi possível sair da conta.'),
      );
      await _abrir(t, const PerfilScreen());
      await t.scrollUntilVisible(
        find.text('Sair da conta'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      // Garante o botão inteiro acima da barra inferior antes do toque.
      await t.ensureVisible(find.text('Sair da conta'));
      await t.pumpAndSettle();
      await t.tap(find.text('Sair da conta'));
      await t.pump();
      expect(find.text('Não foi possível sair da conta.'), findsOneWidget);
      expect(find.text('LOGIN'), findsNothing);
      expect(authService.atual, isNotNull);
    });
  });
}
