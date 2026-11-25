import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/avaliacao/registro_medidas_screen.dart';
import 'package:appnutrimirim/screens/avaliacao/resultado_screen.dart';
import 'package:appnutrimirim/services/antropometria_oms.dart';
import 'package:appnutrimirim/services/classificacao.dart';
import 'package:appnutrimirim/services/resultado_nutricional.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'antropometria_oms_test.dart' show lerTabelas;
import 'fontes.dart';
import 'registro_medidas_test.dart' show criancaTeste, preencher, validar;

final _nascimento = DateTime(2025, 1, 1);
final _medicao = DateTime(2026, 5, 16); // 500 dias

void main() {
  late TabelasOms tabelas;
  setUpAll(() {
    tabelas = lerTabelas();
    return carregarFontes();
  });

  ValidacaoAntropometrica validar_({
    double peso = 10.2,
    double altura = 78,
    bool edema = false,
    PosicaoMedicao posicao = PosicaoMedicao.deitado,
  }) => tabelas.validar(
    sexo: SexoOms.masculino,
    nascimento: _nascimento,
    medicao: _medicao,
    hoje: _medicao,
    pesoKg: peso,
    alturaCm: altura,
    posicao: posicao,
    edema: edema,
  );

  ResultadoNutricional? montar(
    ValidacaoAntropometrica v, {
    bool edema = false,
  }) => montarResultadoNutricional(
    criancaId: 'c1',
    validacao: v,
    dataAvaliacao: _medicao,
    nascimento: _nascimento,
    edema: edema,
  );

  group('montarResultadoNutricional', () {
    test('medidas adequadas: verde, sem alerta, retorno pelo calendário', () {
      final r = montar(validar_())!;
      expect(r.criancaId, 'c1');
      expect(r.classificacao.indicadores, hasLength(4));
      expect(r.indisponiveis, isEmpty);
      expect(r.classificacao.semaforo, Semaforo.verde);
      expect(r.alerta, isNull);
      expect(r.idadeMeses, 16);
      // 16 meses conta como a consulta dos 18; o retorno é aos 24 meses.
      expect(r.retorno, DateTime(2027, 1, 1));
      expect(r.condutas, isNotEmpty);
    });

    test('usa os z-scores calculados pela OMS, sem alterá-los', () {
      final v = validar_(peso: 7.5);
      final r = montar(v)!;
      for (final ind in v.indicadores) {
        final c = r.classificacao.indicadores.singleWhere(
          (c) => c.indicador == indicadorAntropometrico(ind.indicador),
        );
        expect(c.zScore, ind.zScore);
      }
      expect(r.classificacao.desnutricao, isTrue);
      expect(r.alerta, isNotNull);
    });

    test('edema é desnutrição aguda grave mesmo sem z-score de peso', () {
      final r = montar(validar_(edema: true), edema: true)!;
      expect(r.classificacao.edema, isTrue);
      expect(r.classificacao.gravidade, Gravidade.grave);
      expect(r.indisponiveis.map((i) => i.indicador), [
        IndicadorAntropometrico.pesoIdade,
        IndicadorAntropometrico.pesoEstatura,
        IndicadorAntropometrico.imcIdade,
      ]);
      expect(r.alerta!.urgente, isTrue);
      expect(r.alerta!.mensagem, contains('edema bilateral'));
      expect(r.retorno, DateTime(2026, 5, 21));
      expect(r.condutas.first, contains('urgência'));
    });

    test('valor implausível não é classificado: pede conferência', () {
      final v = validar_(peso: 100);
      expect(v.precisaConferencia, isTrue);
      expect(montar(v), isNull);
    });

    test('erro de entrada não gera resultado', () {
      final v = tabelas.validar(
        sexo: SexoOms.masculino,
        nascimento: null,
        medicao: _medicao,
        hoje: _medicao,
        pesoKg: 10,
        alturaCm: 78,
        posicao: PosicaoMedicao.deitado,
        edema: false,
      );
      expect(montar(v), isNull);
    });

    test('situacaoDe separa déficit de obesidade no vermelho', () {
      expect(situacaoDe(Gravidade.adequado, Desvio.nenhum), Situacao.normal);
      expect(situacaoDe(Gravidade.atencao, Desvio.excesso), Situacao.atencao);
      expect(situacaoDe(Gravidade.risco, Desvio.deficit), Situacao.abaixo);
      expect(situacaoDe(Gravidade.grave, Desvio.deficit), Situacao.abaixo);
      expect(situacaoDe(Gravidade.risco, Desvio.excesso), Situacao.risco);
    });
  });

  group('Tela 07 — Resultado', () {
    Future<List<Object?>> abrir(WidgetTester t, Object? args) async {
      final curva = <Object?>[];
      t.view.physicalSize = const Size(1080, 2400);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          onGenerateRoute: (s) => MaterialPageRoute(
            settings: s,
            builder: (_) {
              if (s.name == Routes.curvaCrescimento) {
                curva.add(s.arguments);
                return const Scaffold(body: Text('CURVA'));
              }
              return const ResultadoScreen();
            },
          ),
          initialRoute: '/',
          onGenerateInitialRoutes: (_) => [
            MaterialPageRoute(
              settings: RouteSettings(arguments: args),
              builder: (_) => const ResultadoScreen(),
            ),
          ],
        ),
      );
      await t.pumpAndSettle();
      return curva;
    }

    testWidgets('sem resultado não mostra dados fictícios', (t) async {
      await abrir(t, null);
      expect(find.textContaining('Nenhuma avaliação para mostrar'), findsOne);
      expect(find.text('Indicadores (Z-score)'), findsNothing);
    });

    testWidgets('adequado: verde, z-scores reais e sem alerta', (t) async {
      final r = montar(validar_())!;
      await abrir(t, r);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Adequado'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      final pi = r.classificacao.indicadores.first;
      expect(
        find.text(pi.zScore.toStringAsFixed(2).replaceAll('.', ',')),
        findsWidgets,
      );
      expect(find.text('Retorno sugerido'), findsOneWidget);
      expect(find.text('01/01/2027', skipOffstage: false), findsOneWidget);
      expect(find.textContaining('ilustrativ'), findsNothing);
    });

    testWidgets('déficit abre o alerta em modal (RF12)', (t) async {
      final r = montar(validar_(peso: 7.5))!;
      await abrir(t, r);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text(r.alerta!.titulo), findsNWidgets(2));
      await t.tap(find.text('Entendi'));
      await t.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text(r.classificacao.pior.diagnostico), findsWidgets);
      expect(find.text('!'), findsOneWidget);
    });

    testWidgets('edema mostra desnutrição aguda grave e indisponíveis', (
      t,
    ) async {
      await abrir(t, montar(validar_(edema: true), edema: true));
      await t.tap(find.text('Entendi'));
      await t.pumpAndSettle();
      expect(find.text('Desnutrição aguda grave'), findsOneWidget);
      expect(find.text('—'), findsNWidgets(3));
    });

    testWidgets('a Curva abre com a mesma criança', (t) async {
      final curva = await abrir(t, montar(validar_()));
      await t.scrollUntilVisible(find.text('Ver detalhes do cálculo'), 200);
      await t.tap(find.text('Ver detalhes do cálculo'));
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.text('Ver curva de crescimento ›'), 200);
      await t.drag(find.byType(ListView), const Offset(0, -300));
      await t.pumpAndSettle();
      await t.tap(find.text('Ver curva de crescimento ›'));
      await t.pumpAndSettle();
      expect(find.text('CURVA'), findsOneWidget);
      expect(curva, ['c1']);
    });

    testWidgets('cabe em 360 dp com fonte ampliada', (t) async {
      t.view.physicalSize = const Size(360, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          onGenerateRoute: (_) => MaterialPageRoute(
            settings: RouteSettings(
              arguments: montar(validar_(edema: true), edema: true),
            ),
            builder: (_) => const ResultadoScreen(),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  });

  testWidgets('tela 06 abre a 07 com o resultado calculado', (t) async {
    Object? recebido;
    t.view.physicalSize = const Size(800, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: RegistroMedidasScreen(
          crianca: criancaTeste(),
          carregarTabelas: () async => tabelas,
        ),
        routes: {
          Routes.resultado: (ctx) {
            recebido = ModalRoute.of(ctx)!.settings.arguments;
            return const Scaffold(body: Text('RESULTADO'));
          },
        },
      ),
    );
    await preencher(t, peso: '10,2');
    await validar(t);
    await t.ensureVisible(find.text('Ver resultado'));
    await t.tap(find.text('Ver resultado'));
    await t.pumpAndSettle();
    expect(find.text('RESULTADO'), findsOneWidget);
    expect(recebido, isA<ResultadoNutricional>());
    expect((recebido! as ResultadoNutricional).criancaId, 'crianca-teste');
  });

  testWidgets('tela 06 não oferece resultado com medida a conferir', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: RegistroMedidasScreen(
          crianca: criancaTeste(),
          carregarTabelas: () async => tabelas,
        ),
      ),
    );
    await preencher(t, peso: '100');
    await validar(t);
    expect(find.text('Validação OMS'), findsOneWidget);
    expect(find.text('Ver resultado'), findsNothing);
  });
}
