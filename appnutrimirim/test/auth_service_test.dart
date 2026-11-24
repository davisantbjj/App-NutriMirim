import 'package:appnutrimirim/app_state.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/auth/login_screen.dart';
import 'package:appnutrimirim/screens/auth/recuperar_email_screen.dart';
import 'package:appnutrimirim/screens/splash_screen.dart';
import 'package:appnutrimirim/services/auth_service.dart';
import 'package:appnutrimirim/services/auth_service_memoria.dart';
import 'package:appnutrimirim/services/firebase_auth_service.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _email = 'ana@ubs.gov.br';
const _senha = 'senha123';

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
        Routes.recuperarEnviado: (_) => const Scaffold(body: Text('ENVIADO')),
      },
    ),
  );
  await t.pumpAndSettle();
}

Future<void> _entrar(WidgetTester t, String email, String senha) async {
  final campos = find.byType(TextFormField);
  await t.enterText(campos.at(0), email);
  await t.enterText(campos.at(1), senha);
  await t.ensureVisible(find.text('Entrar'));
  await t.tap(find.text('Entrar'));
  await t.pumpAndSettle();
}

void main() {
  setUp(() {
    _auth = AuthServiceMemoria(contas: {_email: _senha});
    authService = _auth;
  });
  tearDown(() => authService = AuthServiceMemoria());

  group('AuthServiceMemoria', () {
    test('entra com a senha certa e sai', () async {
      final u = await _auth.entrar(email: ' $_email ', senha: _senha);
      expect(u.email, _email);
      expect(_auth.atual?.email, _email);
      await _auth.sair();
      expect(_auth.atual, isNull);
    });

    test('senha errada lança AuthException', () {
      expect(
        () => _auth.entrar(email: _email, senha: 'errada'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('mensagens de erro do Firebase', () {
    test('usuário inexistente e senha errada têm a mesma mensagem', () {
      final m = FirebaseAuthService.mensagemDoErro;
      expect(m('user-not-found'), m('wrong-password'));
      expect(m('invalid-credential'), 'E-mail ou senha incorretos.');
    });

    test('sem rede e código desconhecido têm mensagem em português', () {
      final m = FirebaseAuthService.mensagemDoErro;
      expect(m('network-request-failed'), contains('internet'));
      expect(m('qualquer-coisa'), 'Não foi possível concluir. Tente de novo.');
    });
  });

  test('emailValido', () {
    expect(emailValido('ana@ubs.gov.br'), isTrue);
    expect(emailValido(' ana@ubs.gov.br '), isTrue);
    for (final v in [null, '', 'ana', 'ana@', 'ana@ubs', '79 99999-0000']) {
      expect(emailValido(v), isFalse, reason: '"$v"');
    }
  });

  group('02 Login', () {
    testWidgets('senha certa vai para o Início', (t) async {
      await _abrir(t, const LoginScreen());
      await _entrar(t, _email, _senha);
      expect(find.text('INICIO'), findsOneWidget);
      expect(_auth.atual?.email, _email);
    });

    testWidgets('senha errada fica no Login e mostra o erro', (t) async {
      await _abrir(t, const LoginScreen());
      await _entrar(t, _email, 'errada');
      expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
      expect(find.text('INICIO'), findsNothing);
      expect(_auth.atual, isNull);
    });

    testWidgets('e-mail inválido nem chama o serviço', (t) async {
      await _abrir(t, const LoginScreen());
      await _entrar(t, 'ana@', _senha);
      expect(find.text('Informe um e-mail válido'), findsOneWidget);
      expect(_auth.atual, isNull);
    });
  });

  group('01 Abertura e sessão', () {
    testWidgets('sem sessão vai para o Login', (t) async {
      await _abrir(t, const SplashScreen());
      await t.pump(const Duration(seconds: 3));
      await t.pumpAndSettle();
      expect(find.text('LOGIN'), findsOneWidget);
    });

    testWidgets('com sessão salva vai direto para o Início', (t) async {
      authService = AuthServiceMemoria(
        logado: const UsuarioLogado(uid: 'u1', email: _email),
      );
      await _abrir(t, const SplashScreen());
      await t.pump(const Duration(seconds: 3));
      await t.pumpAndSettle();
      expect(find.text('INICIO'), findsOneWidget);
    });
  });

  group('02A Recuperação de senha', () {
    testWidgets('e-mail válido envia o link e segue para "enviado"', (t) async {
      await _abrir(t, const RecuperarEmailScreen());
      await t.enterText(find.byType(TextFormField), _email);
      await t.tap(find.text('Continuar'));
      await t.pumpAndSettle();
      expect(find.text('ENVIADO'), findsOneWidget);
      expect(_auth.recuperacoesEnviadas, [_email]);
    });

    testWidgets('telefone ou e-mail incompleto bloqueia', (t) async {
      await _abrir(t, const RecuperarEmailScreen());
      await t.enterText(find.byType(TextFormField), '79999990000');
      await t.tap(find.text('Continuar'));
      await t.pumpAndSettle();
      expect(find.text('Informe o e-mail cadastrado'), findsOneWidget);
      expect(find.text('ENVIADO'), findsNothing);
      expect(_auth.recuperacoesEnviadas, isEmpty);
    });
  });
}
