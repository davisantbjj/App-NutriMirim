import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/auth/recuperar_email_screen.dart';
import 'package:appnutrimirim/screens/auth/recuperar_nova_senha_screen.dart';
import 'package:appnutrimirim/theme/app_theme.dart';

Future<void> _abrir(WidgetTester t, Widget tela) async {
  t.view.physicalSize = const Size(1170, 2532);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: tela,
      routes: {
        Routes.recuperarEnviado: (_) => const Scaffold(body: Text('ENVIADO')),
        Routes.login: (_) => const Scaffold(body: Text('LOGIN')),
      },
    ),
  );
  await t.pumpAndSettle();
}

Future<void> _continuar(WidgetTester t) async {
  await t.ensureVisible(find.text('Continuar'));
  await t.tap(find.text('Continuar'));
  await t.pumpAndSettle();
}

void main() {
  group('02A - e-mail ou telefone', () {
    for (final v in ['', '   ']) {
      testWidgets('campo vazio ("$v") bloqueia e mostra mensagem', (t) async {
        await _abrir(t, const RecuperarEmailScreen());
        await t.enterText(find.byType(TextFormField), v);
        await _continuar(t);
        expect(find.text('Campo obrigatório'), findsOneWidget);
        expect(find.text('ENVIADO'), findsNothing);
      });
    }

    testWidgets('e-mail preenchido segue para "enviado"', (t) async {
      await _abrir(t, const RecuperarEmailScreen());
      await t.enterText(find.byType(TextFormField), 'ana@ubs.gov.br');
      await _continuar(t);
      expect(find.text('ENVIADO'), findsOneWidget);
      expect(find.text('Campo obrigatório'), findsNothing);
    });
  });

  group('02C - nova senha', () {
    Future<void> preencher(
      WidgetTester t,
      String senha,
      String confirma,
    ) async {
      final f = find.byType(TextFormField);
      await t.enterText(f.at(0), senha);
      await t.enterText(f.at(1), confirma);
    }

    testWidgets('senhas que não conferem bloqueiam', (t) async {
      await _abrir(t, const RecuperarNovaSenhaScreen());
      await preencher(t, 'abc12345', 'abc12346');
      await _continuar(t);
      expect(find.text('As senhas não conferem'), findsOneWidget);
      expect(find.text('LOGIN'), findsNothing);
    });

    testWidgets('senha com menos de 6 caracteres bloqueia', (t) async {
      await _abrir(t, const RecuperarNovaSenhaScreen());
      await preencher(t, '12345', '12345');
      await _continuar(t);
      expect(
        find.text('A senha deve ter ao menos 6 caracteres'),
        findsOneWidget,
      );
      expect(find.text('LOGIN'), findsNothing);
    });

    testWidgets('senhas iguais voltam ao Login', (t) async {
      await _abrir(t, const RecuperarNovaSenhaScreen());
      await preencher(t, 'abc12345', 'abc12345');
      await _continuar(t);
      expect(find.text('LOGIN'), findsOneWidget);
    });
  });
}
