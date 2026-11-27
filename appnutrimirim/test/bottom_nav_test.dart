import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fontes.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/home_screen.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'package:appnutrimirim/widgets/bottom_nav.dart';

/// Mantém a pilha de rotas atual (só nomes) para conferir se cresce.
class _Pilha extends NavigatorObserver {
  final rotas = <Route<dynamic>>[];

  List<String?> get nomes => rotas.map((r) => r.settings.name).toList();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      rotas.add(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      rotas.remove(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      rotas.remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final i = rotas.indexOf(oldRoute!);
    if (i >= 0) {
      rotas[i] = newRoute!;
    }
  }
}

/// Abre o app com a pilha [rotas] (por padrão, só a Home).
Future<_Pilha> _abrirHome(
  WidgetTester t, {
  List<String> rotas = const [Routes.home],
}) async {
  t.view.physicalSize = const Size(1080, 2400); // 360 x 800 dp
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  final pilha = _Pilha();
  await t.pumpWidget(const SizedBox());
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      routes: Routes.table,
      initialRoute: Routes.home,
      navigatorObservers: [pilha],
      // Pilha exata (sem a Splash que o initialRoute '/inicio' geraria).
      onGenerateInitialRoutes: (_) => [
        for (final nome in rotas)
          MaterialPageRoute(
            settings: RouteSettings(name: nome),
            builder: Routes.table[nome]!,
          ),
      ],
    ),
  );
  await t.pumpAndSettle();
  return pilha;
}

Future<void> _tocar(WidgetTester t, String rotulo) async {
  await t.tap(
    find.descendant(of: find.byType(AppBottomNav), matching: find.text(rotulo)),
  );
  await t.pumpAndSettle();
}

void _soHome(WidgetTester t, _Pilha pilha) {
  expect(pilha.nomes, [Routes.home]);
  expect(find.byType(HomeScreen, skipOffstage: false), findsOneWidget);
  final nav = Navigator.of(t.element(find.byType(HomeScreen)));
  expect(nav.canPop(), isFalse);
}

void main() {
  setUpAll(carregarFontes);

  for (final escala in [1.0, 1.3, 1.5, 2.0, 3.0]) {
    testWidgets('barra inferior cabe em 360 dp com fonte ${escala}x', (
      t,
    ) async {
      t.view.physicalSize = const Size(1080, 2340);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(360, 780),
            ).copyWith(textScaler: TextScaler.linear(escala)),
            child: const Scaffold(
              bottomNavigationBar: AppBottomNav(current: NavTab.avaliacao),
            ),
          ),
        ),
      );
      expect(t.takeException(), isNull);
      for (final rotulo in ['Início', 'Histórico', 'Avaliação', 'Perfil']) {
        final texto = find.text(rotulo);
        expect(texto, findsOneWidget);
        // Uma linha só: a palavra não pode ser quebrada no meio.
        final linha = t.renderObject<RenderParagraph>(texto);
        expect(
          linha
              .getBoxesForSelection(
                TextSelection(baseOffset: 0, extentOffset: rotulo.length),
              )
              .map((b) => b.top)
              .toSet()
              .length,
          1,
          reason: '"$rotulo" quebrou em mais de uma linha com fonte ${escala}x',
        );
      }
    });
  }

  testWidgets('Início após ir ao Histórico deixa apenas uma Home na pilha', (
    t,
  ) async {
    final pilha = await _abrirHome(t);
    await _tocar(t, 'Histórico');
    expect(pilha.nomes.last, Routes.historico);

    await _tocar(t, 'Início');
    _soHome(t, pilha);
  });

  testWidgets('Início após ir ao Perfil deixa apenas uma Home na pilha', (
    t,
  ) async {
    final pilha = await _abrirHome(t);
    await _tocar(t, 'Perfil');
    expect(pilha.nomes.last, Routes.perfil);

    await _tocar(t, 'Início');
    _soHome(t, pilha);
  });

  testWidgets('Navegar entre abas várias vezes não faz a pilha crescer', (
    t,
  ) async {
    final pilha = await _abrirHome(t);
    for (final aba in ['Histórico', 'Perfil', 'Avaliação']) {
      await _tocar(t, aba);
      // Home + aba atual, no máximo.
      expect(pilha.rotas.length, lessThanOrEqualTo(2), reason: aba);
    }
    await _tocar(t, 'Início');
    _soHome(t, pilha);

    // Segunda volta completa.
    for (final aba in ['Perfil', 'Histórico', 'Início']) {
      await _tocar(t, aba);
    }
    _soHome(t, pilha);
  });

  testWidgets('Na Home, Início está selecionado e tocar nele não empilha', (
    t,
  ) async {
    final pilha = await _abrirHome(t);
    expect(_barra(t).current, NavTab.inicio);
    expect(find.byIcon(Icons.home), findsOneWidget);

    await _tocar(t, 'Início');
    await _tocar(t, 'Início');
    _soHome(t, pilha);
  });

  testWidgets('Início a partir de uma tela sem aba volta à mesma Home', (
    t,
  ) async {
    final pilha = await _abrirHome(
      t,
      rotas: [Routes.home, Routes.dadosCrianca, Routes.curvaCrescimento],
    );
    await _tocar(t, 'Início');
    _soHome(t, pilha);
  });

  testWidgets('Sem Home na pilha, Início recria a Home sozinha', (t) async {
    final pilha = await _abrirHome(t, rotas: [Routes.splash, Routes.historico]);
    await _tocar(t, 'Início');
    _soHome(t, pilha);
  });
}

AppBottomNav _barra(WidgetTester t) =>
    t.widget<AppBottomNav>(find.byType(AppBottomNav));
