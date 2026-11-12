import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fontes.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/historico_screen.dart';
import 'package:appnutrimirim/theme/app_theme.dart';

Future<void> _abrir(WidgetTester t) async {
  t.view.physicalSize = const Size(1170, 4000);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      routes: {...Routes.table, '/': (_) => const HistoricoScreen()},
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('Histórico abre a criança do item tocado', (t) async {
    await _abrir(t);
    await t.tap(find.text('Luana Silva'));
    await t.pumpAndSettle();
    expect(find.text('Dados da criança'), findsOneWidget);
    expect(find.text('Luana Silva'), findsOneWidget);
    expect(find.text('Maria Joaquina de Lima Santos'), findsNothing);
  });

  testWidgets('Histórico ordena da avaliação mais recente para a mais antiga', (
    t,
  ) async {
    await _abrir(t);
    double y(String n) => t.getTopLeft(find.text(n)).dy;
    expect(y('Talita Feitosa'), lessThan(y('Luana Silva')));
    expect(y('Luana Silva'), lessThan(y('Vinicius Feitosa')));
  });

  testWidgets('Histórico não tem filtro "Todas"', (t) async {
    await _abrir(t);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Todas'), findsNothing);
  });
}
