import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appnutrimirim/data/mock_data.dart';
import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/avaliacao/registro_medidas_screen.dart';

Object? _args;

Future<void> _abrir(WidgetTester t) async {
  _args = null;
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const RegistroMedidasScreen(),
      routes: {
        Routes.resultado: (ctx) {
          _args = ModalRoute.of(ctx)!.settings.arguments;
          return const Scaffold(body: Text('RESULTADO_STUB'));
        },
      },
    ),
  );
}

Future<void> _preencher(WidgetTester t, {String? peso, String? altura}) async {
  final f = find.byType(TextFormField);
  if (peso != null) await t.enterText(f.at(0), peso);
  if (altura != null) await t.enterText(f.at(1), altura);
}

Future<void> _escolherData(WidgetTester t) async {
  await t.tap(find.byType(TextFormField).at(2));
  await t.pumpAndSettle();
  await t.tap(find.text('OK'));
  await t.pumpAndSettle();
}

Future<void> _calcular(WidgetTester t) async {
  await t.ensureVisible(find.text('Calcular'));
  await t.tap(find.text('Calcular'));
  await t.pumpAndSettle();
}

void main() {
  group('validação de peso', () {
    for (final v in ['0,4', '60,1', '', 'abc', '0', 'NaN', 'Infinity']) {
      testWidgets('rejeita "$v"', (t) async {
        await _abrir(t);
        await _preencher(t, peso: v, altura: '85');
        await _escolherData(t);
        await _calcular(t);
        expect(find.text('RESULTADO_STUB'), findsNothing);
        expect(find.textContaining('Informe '), findsOneWidget);
      });
    }
    for (final v in ['0,5', '60', '12,5', '12.5']) {
      testWidgets('aceita "$v"', (t) async {
        await _abrir(t);
        await _preencher(t, peso: v, altura: '85');
        await _escolherData(t);
        await _calcular(t);
        expect(find.text('RESULTADO_STUB'), findsOneWidget);
      });
    }
  });

  group('validação de altura', () {
    for (final v in ['39,9', '130,1', '', 'x', 'NaN', 'Infinity']) {
      testWidgets('rejeita "$v"', (t) async {
        await _abrir(t);
        await _preencher(t, peso: '12', altura: v);
        await _escolherData(t);
        await _calcular(t);
        expect(find.text('RESULTADO_STUB'), findsNothing);
      });
    }
    for (final v in ['40', '130', '85,0']) {
      testWidgets('aceita "$v"', (t) async {
        await _abrir(t);
        await _preencher(t, peso: '12', altura: v);
        await _escolherData(t);
        await _calcular(t);
        expect(find.text('RESULTADO_STUB'), findsOneWidget);
      });
    }
  });

  testWidgets('data ausente bloqueia e mostra mensagem', (t) async {
    await _abrir(t);
    await _preencher(t, peso: '12', altura: '85');
    await _calcular(t);
    expect(find.text('Escolha a data da medição'), findsOneWidget);
    expect(find.text('RESULTADO_STUB'), findsNothing);
  });

  group('regra provisória de resultado', () {
    final casos = {
      '9,99': MockData.resultadoDesnutricao,
      '10': MockData.resultadoNormal,
      '10,01': MockData.resultadoNormal,
      '5': MockData.resultadoDesnutricao,
    };
    casos.forEach((peso, esperado) {
      testWidgets('peso $peso -> desnutricao=${esperado.desnutricao}', (
        t,
      ) async {
        await _abrir(t);
        await _preencher(t, peso: peso, altura: '85');
        await _escolherData(t);
        await _calcular(t);
        expect(_args, same(esperado));
      });
    });
  });

  test('tipos de argumento', () {
    expect(MockData.resultadoDesnutricao, isA<ResultadoAvaliacao>());
  });
}
