import 'package:appnutrimirim/app_state.dart';
import 'package:appnutrimirim/main.dart';
import 'package:appnutrimirim/repositories/repositorios.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/auth/login_screen.dart';
import 'package:appnutrimirim/screens/historico_screen.dart';
import 'package:appnutrimirim/screens/home_screen.dart';
import 'package:appnutrimirim/screens/perfil_screen.dart';
import 'package:appnutrimirim/screens/splash_screen.dart';
import 'package:appnutrimirim/services/auth_service.dart';
import 'package:appnutrimirim/services/auth_service_memoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Abre o app como se o endereço [rota] tivesse sido digitado no navegador.
Future<void> _abrirEm(WidgetTester t, String rota) async {
  t.view.physicalSize = const Size(1170, 2532);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  t.binding.platformDispatcher.defaultRouteNameTestValue = rota;
  addTearDown(t.binding.platformDispatcher.clearDefaultRouteNameTestValue);
  await t.pumpWidget(const NutriMirimApp());
  await t.pump();
}

/// Deixa a Abertura restaurar a sessão e seguir.
Future<void> _passarDaAbertura(WidgetTester t) async {
  await t.pump(const Duration(seconds: 3));
  await t.pumpAndSettle();
}

NavigatorState _navegador(WidgetTester t) =>
    t.state<NavigatorState>(find.byType(Navigator));

void main() {
  setUp(Repositorios.reiniciar);
  tearDown(() => authService = AuthServiceMemoria());

  group('sem login', () {
    setUp(() => authService = AuthServiceMemoria());

    for (final rota in [
      Routes.home,
      Routes.historico,
      Routes.perfil,
      Routes.listaCriancas,
    ]) {
      testWidgets('abrir $rota direto passa pela Abertura e cai no Login', (
        t,
      ) async {
        await _abrirEm(t, rota);
        expect(find.byType(SplashScreen), findsOneWidget);
        expect(find.byType(HomeScreen), findsNothing);
        expect(find.byType(HistoricoScreen), findsNothing);
        expect(find.byType(PerfilScreen), findsNothing);
        await _passarDaAbertura(t);
        expect(find.byType(LoginScreen), findsOneWidget);
      });
    }

    testWidgets('Login e recuperação de senha abrem direto', (t) async {
      await _abrirEm(t, Routes.login);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('navegar para rota protegida abre o Login', (t) async {
      await _abrirEm(t, Routes.login);
      _navegador(t).pushNamed(Routes.perfil);
      await t.pumpAndSettle();
      expect(find.byType(PerfilScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    test('rota desconhecida continua sem rota', () {
      expect(Routes.gerar(const RouteSettings(name: '/nao-existe')), isNull);
    });
  });

  group('com login', () {
    setUp(
      () => authService = AuthServiceMemoria(
        logado: const UsuarioLogado(uid: 'u1', email: 'ana@ubs.gov.br'),
      ),
    );

    testWidgets('abrir /perfil direto restaura a sessão e vai ao Início', (
      t,
    ) async {
      await _abrirEm(t, Routes.perfil);
      expect(find.byType(SplashScreen), findsOneWidget);
      await _passarDaAbertura(t);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('navega normalmente pelas rotas protegidas', (t) async {
      await _abrirEm(t, Routes.splash);
      await _passarDaAbertura(t);
      _navegador(t).pushNamed(Routes.perfil);
      await t.pumpAndSettle();
      expect(find.byType(PerfilScreen), findsOneWidget);
    });
  });
}
