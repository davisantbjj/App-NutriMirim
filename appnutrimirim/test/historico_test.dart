import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fontes.dart';
import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/repositories/repositorios.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/historico_screen.dart';
import 'package:appnutrimirim/theme/app_theme.dart';

/// Abre o Histórico com [args] na rota (`null` = histórico geral).
Future<void> _abrir(WidgetTester t, {Object? args}) async {
  t.view.physicalSize = const Size(1170, 4000);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      routes: Routes.table,
      initialRoute: '/x',
      onGenerateRoute: (s) => s.name == '/x'
          ? MaterialPageRoute(
              settings: RouteSettings(name: '/x', arguments: args),
              builder: (_) => const HistoricoScreen(),
            )
          : null,
    ),
  );
  await t.pumpAndSettle();
}

Crianca _crianca(String id, String nome) => Crianca(
  id: id,
  nome: nome,
  sexo: Sexo.feminino,
  bairro: 'Centro',
  cadastradoEm: DateTime(2026, 1, 10),
);

Avaliacao _avaliacao(
  String criancaId,
  DateTime data, {
  double peso = 12.5,
  double altura = 85,
  Situacao situacao = Situacao.normal,
}) => Avaliacao(
  criancaId: criancaId,
  data: data,
  pesoKg: peso,
  alturaCm: altura,
  situacao: situacao,
  indicadores: {'pi': Indicador('P/I', -0.5, situacao)},
);

/// Banco vazio com duas crianças: Ana (2 avaliações) e Bia (1 avaliação).
Future<void> _duasCriancas() async {
  Repositorios.usarMemoria(comMock: false);
  await Repositorios.criancas.cadastrar(_crianca('a1', 'Ana Teste'));
  await Repositorios.criancas.cadastrar(_crianca('b1', 'Bia Teste'));
  await Repositorios.avaliacoes.registrar(
    _avaliacao('a1', DateTime(2026, 3, 10), peso: 9.4, altura: 74.5),
  );
  await Repositorios.avaliacoes.registrar(
    _avaliacao(
      'a1',
      DateTime(2026, 6, 20),
      peso: 8.9,
      altura: 76,
      situacao: Situacao.abaixo,
    ),
  );
  await Repositorios.avaliacoes.registrar(
    _avaliacao('b1', DateTime(2026, 5, 2), peso: 14, altura: 92),
  );
}

void main() {
  setUpAll(carregarFontes);
  setUp(Repositorios.reiniciar);
  tearDown(Repositorios.reiniciar);

  group('Histórico geral (dados do mock)', () {
    testWidgets('abre a criança do item tocado', (t) async {
      await _abrir(t);
      await t.tap(find.text('Luana Silva'));
      await t.pumpAndSettle();
      expect(find.text('Dados da criança'), findsOneWidget);
      expect(find.text('Luana Silva'), findsOneWidget);
      expect(find.text('Maria Joaquina de Lima Santos'), findsNothing);
    });

    testWidgets('ordena da avaliação mais recente para a mais antiga', (
      t,
    ) async {
      await _abrir(t);
      double y(String n) => t.getTopLeft(find.text(n)).dy;
      expect(y('Talita Feitosa'), lessThan(y('Luana Silva')));
      expect(y('Luana Silva'), lessThan(y('Vinicius Feitosa')));
    });

    testWidgets('não tem filtro "Todas"', (t) async {
      await _abrir(t);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.text('Todas'), findsNothing);
    });
  });

  group('Histórico de uma criança', () {
    testWidgets('pelo id, mostra só as avaliações dela', (t) async {
      await _duasCriancas();
      await _abrir(t, args: 'a1');
      expect(find.text('Ana Teste'), findsNWidgets(2));
      expect(find.text('Bia Teste'), findsNothing);
      expect(find.text('20/06/2026'), findsOneWidget);
      expect(find.text('10/03/2026'), findsOneWidget);
      expect(find.text('02/05/2026'), findsNothing);
    });

    testWidgets('pelo objeto Crianca, mostra só as avaliações dela', (t) async {
      await _duasCriancas();
      await _abrir(t, args: (await Repositorios.criancas.porId('b1'))!);
      expect(find.text('Bia Teste'), findsOneWidget);
      expect(find.text('Ana Teste'), findsNothing);
      expect(find.text('02/05/2026'), findsOneWidget);
    });

    testWidgets('mantém a ordem da mais recente para a mais antiga', (t) async {
      await _duasCriancas();
      await _abrir(t, args: 'a1');
      expect(
        t.getTopLeft(find.text('20/06/2026')).dy,
        lessThan(t.getTopLeft(find.text('10/03/2026')).dy),
      );
    });

    testWidgets('sem avaliações mostra a mensagem de vazio', (t) async {
      await _duasCriancas();
      await Repositorios.criancas.cadastrar(_crianca('c1', 'Cris Teste'));
      await _abrir(t, args: 'c1');
      expect(find.text('Nenhuma avaliação registrada.'), findsOneWidget);
      expect(find.text('Ana Teste'), findsNothing);
    });

    testWidgets('mostra avaliação nova registrada com a tela aberta', (
      t,
    ) async {
      await _duasCriancas();
      await _abrir(t, args: 'b1');
      expect(find.text('Bia Teste'), findsOneWidget);
      await t.runAsync(
        () => Repositorios.avaliacoes.registrar(
          _avaliacao('b1', DateTime(2026, 7, 1)),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Bia Teste'), findsNWidgets(2));
      expect(
        t.getTopLeft(find.text('01/07/2026')).dy,
        lessThan(t.getTopLeft(find.text('02/05/2026')).dy),
      );
    });
  });

  group('Conteúdo do item', () {
    testWidgets('mostra data, peso, altura e situação', (t) async {
      await _duasCriancas();
      await _abrir(t, args: 'a1');
      expect(find.text('Peso: 8,9 kg  |  Altura: 76 cm'), findsOneWidget);
      expect(find.text('Peso: 9,4 kg  |  Altura: 74,5 cm'), findsOneWidget);
      expect(find.text(Situacao.abaixo.label), findsOneWidget);
      expect(find.text(Situacao.normal.label), findsOneWidget);
    });

    testWidgets('tocar no item abre os dados da criança certa', (t) async {
      await _duasCriancas();
      await _abrir(t);
      await t.tap(find.text('Bia Teste'));
      await t.pumpAndSettle();
      expect(find.text('Dados da criança'), findsOneWidget);
      expect(find.text('Bia Teste'), findsOneWidget);
      expect(find.text('Ana Teste'), findsNothing);
    });

    testWidgets('criança inexistente não quebra a lista', (t) async {
      // Avaliação órfã (criança apagada do banco local, por exemplo).
      final banco = Repositorios.usarMemoria(comMock: false);
      await Repositorios.criancas.cadastrar(_crianca('a1', 'Ana Teste'));
      await Repositorios.avaliacoes.registrar(
        _avaliacao('a1', DateTime(2026, 3, 10)),
      );
      banco.criancas.remove('a1');
      await _abrir(t);
      expect(find.text('10/03/2026'), findsOneWidget);
      expect(find.text('Ana Teste'), findsNothing);
      expect(t.takeException(), isNull);
    });
  });
}
