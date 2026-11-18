import 'package:appnutrimirim/theme/app_palette.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'package:appnutrimirim/widgets/bottom_nav.dart';
import 'package:appnutrimirim/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contraste(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final claro = la > lb ? la : lb, escuro = la > lb ? lb : la;
  return (claro + 0.05) / (escuro + 0.05);
}

Future<void> _abrir(WidgetTester t, Widget filho, {bool hc = false}) {
  return t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(highContrast: hc),
      home: Scaffold(body: filho, bottomNavigationBar: const AppBottomNav()),
    ),
  );
}

void main() {
  final paletas = [
    ('normal', AppPalette.normal),
    ('alto contraste', AppPalette.altoContraste),
  ];

  for (final (nome, p) in paletas) {
    test('borda dos campos tem contraste >= 3:1 ($nome)', () {
      expect(_contraste(p.borda, p.superficie), greaterThanOrEqualTo(3));
      expect(_contraste(p.borda, p.fundo), greaterThanOrEqualTo(3));
    });

    test('textos da paleta têm contraste >= 4,5:1 ($nome)', () {
      for (final cor in [p.texto, p.textoSecundario]) {
        expect(_contraste(cor, p.superficie), greaterThanOrEqualTo(4.5));
        expect(_contraste(cor, p.fundo), greaterThanOrEqualTo(4.5));
      }
    });
  }

  test('o tema entrega a paleta certa', () {
    expect(AppTheme.light().extension<AppPalette>(), AppPalette.normal);
    expect(
      AppTheme.light(highContrast: true).extension<AppPalette>(),
      AppPalette.altoContraste,
    );
  });

  test('a borda dos campos vem da paleta', () {
    for (final hc in [false, true]) {
      final tema = AppTheme.light(highContrast: hc);
      final borda = tema.inputDecorationTheme.enabledBorder!.borderSide.color;
      expect(borda, tema.extension<AppPalette>()!.borda);
    }
  });

  testWidgets('alto contraste muda as cores dos widgets compartilhados', (
    t,
  ) async {
    Color corDoRotulo() => t
        .widget<RichText>(
          find.descendant(
            of: find.byType(FieldLabel),
            matching: find.byType(RichText),
          ),
        )
        .text
        .style!
        .color!;

    await _abrir(t, const FieldLabel('Peso'));
    expect(corDoRotulo(), AppPalette.normal.texto);

    await _abrir(t, const FieldLabel('Peso'), hc: true);
    await t.pumpAndSettle(); // espera a transição do tema
    expect(corDoRotulo(), AppPalette.altoContraste.texto);
  });

  testWidgets('textos dos widgets compartilhados têm no mínimo 12 px', (
    t,
  ) async {
    await _abrir(
      t,
      const SingleChildScrollView(
        child: Column(
          children: [
            FieldLabel('Peso', required: true),
            InfoRow('Responsável', 'Maria'),
            TextBackButton(),
          ],
        ),
      ),
    );
    final textos = t.widgetList<RichText>(find.byType(RichText));
    expect(textos, isNotEmpty);
    for (final rt in textos) {
      final tamanho = rt.text.style?.fontSize;
      if (tamanho == null) continue;
      expect(
        tamanho,
        greaterThanOrEqualTo(12),
        reason: '"${rt.text.toPlainText()}" com $tamanho px',
      );
    }
  });
}
