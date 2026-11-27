import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/auth/login_screen.dart';
import 'package:appnutrimirim/screens/home_screen.dart';
import 'package:appnutrimirim/screens/splash_screen.dart';
import 'package:appnutrimirim/theme/app_palette.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'package:appnutrimirim/widgets/bottom_nav.dart';
import 'package:appnutrimirim/widgets/common.dart';
import 'package:appnutrimirim/screens/avaliacao/nova_avaliacao_screen.dart';
import 'package:appnutrimirim/screens/avaliacao/cadastro_crianca_screen.dart';
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
  testWidgets(
    'telas de cadastro e nova avaliação acompanham o alto contraste',
    (t) async {
      for (final hc in [false, true]) {
        await t.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(highContrast: hc),
            home: const CadastroCriancaScreen(),
          ),
        );
        await t.pumpAndSettle();
        final label = t.widget<Text>(find.text('Feminino'));
        expect(
          label.style!.color,
          hc
              ? AppPalette.altoContraste.textoSecundario
              : AppPalette.normal.textoSecundario,
        );
        await t.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(highContrast: hc),
            home: const NovaAvaliacaoScreen(),
          ),
        );
        await t.pumpAndSettle();
        final introducao = t.widget<Text>(
          find.textContaining('Selecione uma das opções'),
        );
        expect(
          introducao.style!.color,
          hc
              ? AppPalette.altoContraste.textoSecundario
              : AppPalette.normal.textoSecundario,
        );
        if (hc) {
          for (final card in t.widgetList<AppCard>(find.byType(AppCard))) {
            expect(card.color, AppPalette.altoContraste.superficie);
          }
        }
        expect(t.takeException(), isNull);
      }
    },
  );

  testWidgets('Login e Abertura acompanham o alto contraste', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    for (final hc in [false, true]) {
      final esperado = hc
          ? AppPalette.altoContraste.textoSecundario
          : AppPalette.normal.textoSecundario;
      Widget app(Widget tela) => MaterialApp(
        theme: AppTheme.light(highContrast: hc),
        home: tela,
        routes: {Routes.login: (_) => const Scaffold(body: Text('LOGIN'))},
      );

      await t.pumpWidget(app(const LoginScreen()));
      await t.pumpAndSettle();
      for (final texto in [
        'Monitoramento Nutricional Infantil',
        'Acesse sua conta para acompanhar o crescimento e a saúde das crianças.',
        'Seus dados são tratados com segurança e privacidade.',
      ]) {
        expect(t.widget<Text>(find.text(texto)).style!.color, esperado);
      }
      expect(
        t.widget<Icon>(find.byIcon(Icons.verified_user_outlined)).color,
        esperado,
      );
      expect(
        t
            .widget<Text>(
              find.text('Seus dados são tratados com segurança e privacidade.'),
            )
            .style!
            .fontSize,
        greaterThanOrEqualTo(12),
      );

      await t.pumpWidget(app(const SplashScreen()));
      expect(
        t.widget<Text>(find.textContaining('A trena digital')).style!.color,
        esperado,
      );
      expect(
        t
            .widget<Text>(find.text('Monitoramento Nutricional Infantil'))
            .style!
            .color,
        esperado.withValues(alpha: .9),
      );
      // Deixa a Abertura seguir para o Login (sem sessão) antes do próximo tema.
      await t.pump(const Duration(seconds: 3));
      await t.pumpAndSettle();
      expect(find.text('LOGIN'), findsOneWidget);
      // Zera a árvore: senão o Navigator mantém a rota LOGIN por cima.
      await t.pumpWidget(const SizedBox());
    }
  });

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

  testWidgets('textos do Início têm no mínimo 12 px', (t) async {
    t.view.physicalSize = const Size(1170, 2532);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const HomeScreen()),
    );
    await t.pumpAndSettle();
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
