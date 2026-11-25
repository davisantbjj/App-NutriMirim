import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'antropometria_oms_test.dart' show lerTabelas;
import 'fontes.dart';
import 'package:appnutrimirim/data/curvas_referencia.dart';
import 'package:appnutrimirim/data/mock_data.dart';
import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/screens/crianca/curva_crescimento_screen.dart';
import 'package:appnutrimirim/services/antropometria_oms.dart';
import 'package:appnutrimirim/services/zscore_avaliacao.dart';
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
  });

  group('Curva com as tabelas da OMS', () {
    late TabelasOms tabelas;
    setUpAll(() => tabelas = lerTabelas());

    test('linha 0 é a mediana da OMS e separa menina e menino', () {
      final f = CurvaReferencia.oms(
        tabelas,
        IndicadorCurva.pesoIdade,
        Sexo.feminino,
      );
      final m = CurvaReferencia.oms(
        tabelas,
        IndicadorCurva.pesoIdade,
        Sexo.masculino,
      );
      // Medianas ao nascer da tabela weianthro (OMS 2006).
      expect(f.linhas[0]!.first, closeTo(3.2322, 1e-4));
      expect(m.linhas[0]!.first, closeTo(3.3464, 1e-4));
      for (final ind in IndicadorCurva.values) {
        for (final s in Sexo.values) {
          for (final comprimento in [true, false]) {
            final r = CurvaReferencia.oms(
              tabelas,
              ind,
              s,
              comprimento: comprimento,
            );
            expect(r.xs, isNotEmpty);
            for (final z in zScoresDaCurva) {
              expect(r.linhas[z]!.length, r.xs.length);
            }
            // As linhas ficam em ordem: -3 < -2 < 0 < +2 < +3.
            for (var i = 0; i < r.xs.length; i++) {
              expect(r.linhas[-3]![i], lessThan(r.linhas[-2]![i]));
              expect(r.linhas[2]![i], lessThan(r.linhas[3]![i]));
            }
          }
        }
      }
    });

    test('P/E por comprimento vai de 45 a 110 cm e por altura de 65 a 120', () {
      final c = CurvaReferencia.oms(
        tabelas,
        IndicadorCurva.pesoAltura,
        Sexo.feminino,
      );
      final a = CurvaReferencia.oms(
        tabelas,
        IndicadorCurva.pesoAltura,
        Sexo.feminino,
        comprimento: false,
      );
      expect((c.xMin, c.xMax), (45, 110));
      expect((a.xMin, a.xMax), (65, 120));
    });

    test('percentil do z-score', () {
      expect(percentilDeZ(0), closeTo(50, 1e-6));
      expect(percentilDeZ(-2), closeTo(2.275, 1e-3));
      expect(formatarPercentil(1), 'P84,1');
      expect(formatarPercentil(-4), '< P0,1');
      expect(formatarPercentil(4), '> P99,9');
    });

    test('z-score gravado na avaliação tem prioridade sobre o cálculo', () {
      final c = MockData.criancaDestaque;
      final a = MockData.ultimaAvaliacaoDe(c.id)!;
      final gravada = a.copyWith(
        indicadores: {'pi': const Indicador('P/I', -1.23, Situacao.normal)},
      );
      expect(
        zScoreDaAvaliacao(tabelas, c, gravada, IndicadorOms.pesoIdade),
        -1.23,
      );
      expect(
        zScoreDaAvaliacao(tabelas, c, a, IndicadorOms.pesoIdade),
        isNotNull,
      );
      expect(
        zScoreDaAvaliacao(
          tabelas,
          c.copyWith(limparNascimento: true),
          a,
          IndicadorOms.pesoIdade,
        ),
        isNull,
      );
    });

    testWidgets('mostra o z-score e o percentil da aba na última avaliação', (
      t,
    ) async {
      await _ir(
        t,
        CurvaCrescimentoScreen(carregarTabelas: () async => tabelas),
        args: 'c0',
      );
      final c = MockData.criancaDestaque;
      final a = MockData.ultimaAvaliacaoDe(c.id)!;
      for (final (aba, ind) in [
        ('Peso/Idade', IndicadorOms.pesoIdade),
        ('Altura/Idade', IndicadorOms.alturaIdade),
        ('Peso/Altura', IndicadorOms.pesoAltura),
      ]) {
        await t.tap(find.text(aba));
        await t.pumpAndSettle();
        final z = zScoreDaAvaliacao(tabelas, c, a, ind)!;
        expect(
          find.text(
            z.toStringAsFixed(2).replaceAll('.', ','),
            skipOffstage: false,
          ),
          findsOneWidget,
          reason: aba,
        );
        expect(
          find.text(formatarPercentil(z), skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text(
            'Z-score e percentil de $aba (OMS 2006).',
            skipOffstage: false,
          ),
          findsOneWidget,
        );
      }
      expect(find.textContaining('Não foi possível carregar'), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('falha ao carregar as tabelas avisa sem quebrar a tela', (
      t,
    ) async {
      await _ir(
        t,
        CurvaCrescimentoScreen(carregarTabelas: () async => throw Exception()),
        args: 'c0',
      );
      expect(
        find.text('Não foi possível carregar as curvas da OMS.'),
        findsOneWidget,
      );
      expect(find.text('—', skipOffstage: false), findsWidgets);
    });
  });
}
