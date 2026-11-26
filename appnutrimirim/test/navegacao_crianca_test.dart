import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appnutrimirim/data/mock_data.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/crianca/dados_crianca_screen.dart';
import 'package:appnutrimirim/theme/app_theme.dart';

Future<void> _abrirDados(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 4000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      initialRoute: Routes.dadosCrianca,
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute(
          settings: const RouteSettings(
            name: Routes.dadosCrianca,
            arguments: 'c9',
          ),
          builder: (_) => const DadosCriancaScreen(),
        ),
      ],
      routes: Routes.table,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final luana = MockData.criancaPorId('c9')!;

  testWidgets('Dados passa o id para Registrar Avaliação', (tester) async {
    await _abrirDados(tester);

    await tester.ensureVisible(find.text('Registrar Avaliação'));
    await tester.tap(find.text('Registrar Avaliação'));
    await tester.pumpAndSettle();

    expect(find.text('Registro de Medidas'), findsOneWidget);
    expect(find.text(luana.nome), findsOneWidget);
  });

  testWidgets('Dados passa o id para Curva de Crescimento', (tester) async {
    await _abrirDados(tester);

    await tester.ensureVisible(find.text('Curva de Crescimento'));
    await tester.tap(find.text('Curva de Crescimento'));
    await tester.pumpAndSettle();

    expect(find.text('Curva de Crescimento'), findsOneWidget);
    expect(find.text(luana.nome), findsOneWidget);
  });

  testWidgets('Dados passa o id para o Histórico', (tester) async {
    await _abrirDados(tester);

    await tester.ensureVisible(find.text('Ver histórico'));
    await tester.tap(find.text('Ver histórico'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text(luana.nome), findsOneWidget);
  });

  testWidgets('Editar dados abre o cadastro preenchido da criança', (
    tester,
  ) async {
    await _abrirDados(tester);

    await tester.ensureVisible(find.text('Editar dados'));
    await tester.tap(find.text('Editar dados'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastro da Criança'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, luana.nome), findsOneWidget);
  });
}
