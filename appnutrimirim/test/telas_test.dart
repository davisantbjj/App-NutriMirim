import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fontes.dart';
import 'package:appnutrimirim/data/mock_data.dart';
import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/avaliacao/resultado_screen.dart';
import 'package:appnutrimirim/screens/crianca/dados_crianca_screen.dart';
import 'package:appnutrimirim/screens/crianca/lista_criancas_screen.dart';
import 'package:appnutrimirim/screens/perfil_screen.dart';
import 'package:appnutrimirim/theme/app_theme.dart';

double _contraste(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

Future<void> _ir(WidgetTester t, Widget w, {Object? args}) async {
  t.view.physicalSize = const Size(1170, 4000);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(const SizedBox());
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      initialRoute: '/x',
      onGenerateRoute: (_) => MaterialPageRoute(
        settings: RouteSettings(name: '/x', arguments: args),
        builder: (_) => w,
      ),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontes);

  testWidgets('Resultado exibe aviso ilustrativo (normal e desnutricao)', (
    t,
  ) async {
    for (final r in [MockData.resultadoNormal, MockData.resultadoDesnutricao]) {
      await _ir(t, const ResultadoScreen(), args: r);
      expect(
        find.textContaining('Resultado ilustrativo', skipOffstage: false),
        findsOneWidget,
      );
    }
  });

  testWidgets('Dados da criança sem responsável mostra "Não informado"', (
    t,
  ) async {
    await _ir(t, const DadosCriancaScreen(), args: MockData.criancas.first);
    expect(find.text('Não informado', skipOffstage: false), findsWidgets);
    expect(
      find.text(
        MockData.criancaDestaque.responsavel!.nome,
        skipOffstage: false,
      ),
      findsNothing,
    );
  });

  testWidgets('Dados da criança com responsável mostra o nome', (t) async {
    await _ir(t, const DadosCriancaScreen(), args: MockData.criancaDestaque);
    expect(
      find.text('Joana de Lima Santos', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Não informado', skipOffstage: false), findsNothing);
  });

  testWidgets('Busca na lista encontra nomes ignorando acentos e caixa', (
    t,
  ) async {
    await _ir(t, const ListaCriancasScreen());

    await t.enterText(find.byType(TextField), 'joao');
    await t.pumpAndSettle();
    expect(find.text('João Rocha'), findsOneWidget);

    await t.enterText(find.byType(TextField), 'JOÃO');
    await t.pumpAndSettle();
    expect(find.text('João Rocha'), findsOneWidget);
  });

  testWidgets('Editar dados no Perfil fica indisponível e sinalizado', (
    t,
  ) async {
    await _ir(t, const PerfilScreen());

    expect(find.text('Editar dados (em breve)'), findsOneWidget);
    final botao = t.widget<TextButton>(
      find.ancestor(
        of: find.text('Editar dados (em breve)'),
        matching: find.byType(TextButton),
      ),
    );
    expect(botao.onPressed, isNull);
  });

  group('contraste de Situacao.textColor >= 4.5', () {
    for (final s in Situacao.values) {
      test(s.name, () {
        expect(
          _contraste(s.textColor, s.background),
          greaterThanOrEqualTo(4.5),
        );
      });
    }
  });

  for (final cfg in [(360.0, 1.0), (360.0, 1.3)]) {
    testWidgets('sem overflow em ${cfg.$1}dp textScale ${cfg.$2}', (t) async {
      t.view.physicalSize = Size(cfg.$1 * 3, 800 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      for (final e in Routes.table.entries) {
        if (e.key == Routes.splash) continue;
        await t.pumpWidget(
          MaterialApp(
            key: ValueKey(e.key),
            theme: AppTheme.light(),
            routes: Routes.table,
            initialRoute: e.key,
            builder: (c, w) => MediaQuery(
              data: MediaQuery.of(
                c,
              ).copyWith(textScaler: TextScaler.linear(cfg.$2)),
              child: w ?? const SizedBox(),
            ),
            onGenerateInitialRoutes: (n) => [
              MaterialPageRoute(
                settings: RouteSettings(name: e.key),
                builder: e.value,
              ),
            ],
          ),
        );
        await t.pumpAndSettle();
        final ex = t.takeException();
        expect(ex, isNull, reason: '${e.key} ${cfg.$2}');
        final nome = ModalRoute.of(
          t.element(find.byType(Scaffold).first),
        )?.settings.name;
        expect(nome, e.key, reason: 'rota montada');
        final login = find
            .text('Bem-vindo ao NutriMirim')
            .evaluate()
            .isNotEmpty;
        expect(login, e.key == Routes.login, reason: 'tela ${e.key}');
      }
    });
  }
}
