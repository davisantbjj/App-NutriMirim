import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fontes.dart';
import 'package:appnutrimirim/data/curvas_referencia.dart';
import 'package:appnutrimirim/data/mock_data.dart';
import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/screens/avaliacao/resultado_screen.dart';
import 'package:appnutrimirim/screens/crianca/curva_crescimento_screen.dart';
import 'package:appnutrimirim/theme/app_theme.dart';

/// Abre [w] em 360 dp de largura, com [args] na rota e a fonte em [escala].
Future<void> _ir(
  WidgetTester t,
  Widget w, {
  Object? args,
  double escala = 1,
}) async {
  t.view.physicalSize = const Size(1080, 2400);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(const SizedBox());
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(escala)),
        child: child!,
      ),
      initialRoute: '/x',
      onGenerateRoute: (_) => MaterialPageRoute(
        settings: RouteSettings(name: '/x', arguments: args),
        builder: (_) => w,
      ),
    ),
  );
  await t.pumpAndSettle();
}

Finder _grafico(Pattern texto) => find.bySemanticsLabel(
  texto is RegExp ? texto : RegExp(RegExp.escape(texto as String)),
);

void main() {
  setUpAll(carregarFontes);

  group('Curva de crescimento', () {
    testWidgets('usa a criança passada pelo id', (t) async {
      final h = t.ensureSemantics();
      await _ir(t, const CurvaCrescimentoScreen(), args: 'c0');
      expect(find.text(MockData.criancaDestaque.nome), findsOneWidget);
      expect(find.text('Menina • 0 a 5 anos'), findsOneWidget);
      expect(
        _grafico('Medida atual: 24 meses, 10,2 kg, 15/08/2026'),
        findsOneWidget,
      );

      await t.tap(find.text('Altura/Idade'));
      await t.pumpAndSettle();
      // A curva mostra a mesma altura do mock (85 cm), não mais 82.
      expect(
        _grafico('Medida atual: 24 meses, 85 cm, 15/08/2026'),
        findsOneWidget,
      );

      await t.tap(find.text('Peso/Altura'));
      await t.pumpAndSettle();
      expect(_grafico('Medida atual: 85 cm, 10,2 kg'), findsOneWidget);
      h.dispose();
    });

    testWidgets('aceita o objeto Crianca e mostra o sexo certo', (t) async {
      final h = t.ensureSemantics();
      final victor = MockData.criancaPorId('c2')!;
      await _ir(t, const CurvaCrescimentoScreen(), args: victor);
      expect(find.text('Victor Santos'), findsOneWidget);
      expect(find.text('Menino • 0 a 5 anos'), findsOneWidget);
      // Sem avaliações: não há ponto, e a tela explica.
      expect(
        find.text('Sem avaliações registradas para marcar na curva.'),
        findsOneWidget,
      );
      h.dispose();
    });

    testWidgets('sem nascimento, avisa nos gráficos por idade', (t) async {
      // Luana (c9) tem avaliação, mas não tem data de nascimento.
      final h = t.ensureSemantics();
      await _ir(t, const CurvaCrescimentoScreen(), args: 'c9');
      expect(
        find.textContaining('Data de nascimento não informada'),
        findsOneWidget,
      );

      // Peso/Altura não depende da idade: o ponto aparece.
      await t.tap(find.text('Peso/Altura'));
      await t.pumpAndSettle();
      expect(find.textContaining('Data de nascimento'), findsNothing);
      expect(
        _grafico('Medida atual: 78 cm, 9,8 kg, 05/11/2024'),
        findsOneWidget,
      );
      h.dispose();
    });

    // Em 2x quem estoura é a barra inferior (bottom_nav.dart), fora desta task.
    for (final escala in [1.0, 1.3, 1.5]) {
      testWidgets('sem overflow em 360 dp com fonte x$escala', (t) async {
        await _ir(t, const CurvaCrescimentoScreen(), escala: escala);
        for (final aba in ['Altura/Idade', 'Peso/Altura']) {
          await t.tap(find.text(aba));
          await t.pumpAndSettle();
        }
        expect(t.takeException(), isNull);
      });
    }
  });

  group('Mock coerente com a regra provisória (peso < 10 → desnutrição)', () {
    test('nenhuma avaliação abaixo de 10 kg aparece como Normal', () {
      final todas = [
        for (final c in MockData.todasCriancas) ...MockData.avaliacoesDe(c.id),
      ];
      for (final a in todas.where((a) => a.pesoKg < 10)) {
        expect(a.situacao, isNot(Situacao.normal), reason: a.criancaId);
      }
    });

    test('curva de referência separa menina e menino', () {
      final f = CurvaReferencia.de(IndicadorCurva.pesoIdade, Sexo.feminino);
      final m = CurvaReferencia.de(IndicadorCurva.pesoIdade, Sexo.masculino);
      expect(f.linhas[0], isNot(equals(m.linhas[0])));
      for (final ind in IndicadorCurva.values) {
        for (final s in Sexo.values) {
          final r = CurvaReferencia.de(ind, s);
          for (final l in r.linhas.values) {
            expect(l.length, r.xs.length);
          }
        }
      }
    });
  });

  group('Resultado — variação Desnutrição', () {
    testWidgets('mostra título, z-scores e orientação de desnutrição', (
      t,
    ) async {
      await _ir(
        t,
        const ResultadoScreen(),
        args: MockData.resultadoDesnutricao,
      );
      expect(find.text('Desnutrição'), findsOneWidget);
      expect(find.text('!'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
      expect(
        find.textContaining('abaixo da faixa esperada para a idade'),
        findsOneWidget,
      );
      expect(find.text('-2,5'), findsOneWidget);
      expect(find.text('Abaixo da faixa'), findsOneWidget);
      expect(
        find.textContaining('sinais de desnutrição', skipOffstage: false),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('a variação Normal não mostra o alerta', (t) async {
      await _ir(t, const ResultadoScreen(), args: MockData.resultadoNormal);
      expect(find.text('Normal'), findsWidgets);
      expect(find.text('Desnutrição'), findsNothing);
      expect(find.text('!'), findsNothing);
    });
  });
}
