import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fontes.dart';
import 'package:appnutrimirim/main.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/theme/app_theme.dart';

void main() {
  setUpAll(carregarFontes);

  testWidgets('Abertura leva ao Login', (tester) async {
    await tester.pumpWidget(const NutriMirimApp());
    expect(find.text('Monitoramento Nutricional Infantil'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Bem-vindo ao NutriMirim'), findsOneWidget);
  });

  testWidgets('Todas as telas renderizam sem erro', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    for (final entry in Routes.table.entries) {
      if (entry.key == Routes.splash) continue;
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(entry.key),
          theme: AppTheme.light(),
          routes: Routes.table,
          initialRoute: entry.key,
          onGenerateInitialRoutes: (name) => [
            MaterialPageRoute(
              settings: RouteSettings(name: name),
              builder: Routes.table[name]!,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: entry.key);
      expect(
        ModalRoute.of(
          tester.element(find.byType(Scaffold).first),
        )?.settings.name,
        entry.key,
      );
      expect(
        find.text('Bem-vindo ao NutriMirim').evaluate().isNotEmpty,
        entry.key == Routes.login,
        reason: entry.key,
      );
    }
  });
}
