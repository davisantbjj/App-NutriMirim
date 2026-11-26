import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fontes.dart';
import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/repositories/repositorios.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/avaliacao/cadastro_crianca_screen.dart';
import 'package:appnutrimirim/screens/avaliacao/registro_medidas_screen.dart';
import 'package:appnutrimirim/screens/crianca/dados_crianca_screen.dart';
import 'package:appnutrimirim/screens/crianca/lista_criancas_screen.dart';
import 'package:appnutrimirim/screens/historico_screen.dart';
import 'package:appnutrimirim/theme/app_theme.dart';

Future<void> _ir(WidgetTester t, Widget w, {Object? args}) async {
  t.view.physicalSize = const Size(1080, 4000);
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
              builder: (_) => w,
            )
          : null,
    ),
  );
  await t.pumpAndSettle();
}

Crianca _nova(String id, String nome) => Crianca(
  id: id,
  nome: nome,
  sexo: Sexo.feminino,
  bairro: 'Centro',
  cadastradoEm: DateTime(2026, 1, 10),
);

Avaliacao _avaliacao(String criancaId, DateTime data) => Avaliacao(
  criancaId: criancaId,
  data: data,
  pesoKg: 12.5,
  alturaCm: 85,
  situacao: Situacao.normal,
  indicadores: const {'pi': Indicador('P/I', -0.5, Situacao.normal)},
);

void main() {
  setUpAll(carregarFontes);
  setUp(Repositorios.reiniciar);

  testWidgets('Lista reflete criança cadastrada pelo repositório', (t) async {
    await _ir(t, const ListaCriancasScreen());
    expect(find.text('Zuleica Nova'), findsNothing);

    await Repositorios.criancas.cadastrar(_nova('z1', 'Zuleica Nova'));
    await t.pumpAndSettle();
    expect(find.text('Zuleica Nova'), findsOneWidget);
  });

  testWidgets('Lista esconde criança desativada', (t) async {
    await _ir(t, const ListaCriancasScreen());
    expect(find.text('Talita Feitosa'), findsOneWidget);

    await Repositorios.criancas.desativar('c1', motivo: 'Mudou de cidade');
    await t.pumpAndSettle();
    expect(find.text('Talita Feitosa'), findsNothing);
  });

  testWidgets('Histórico mostra avaliação registrada e some ao excluir', (
    t,
  ) async {
    await Repositorios.criancas.cadastrar(_nova('z1', 'Zuleica Nova'));
    await _ir(t, const HistoricoScreen());
    expect(find.text('Zuleica Nova'), findsNothing);

    final salva = await Repositorios.avaliacoes.registrar(
      _avaliacao('z1', DateTime.now()),
    );
    await t.pumpAndSettle();
    expect(find.text('Zuleica Nova'), findsOneWidget);

    await Repositorios.avaliacoes.excluir(salva.id, motivo: 'Lançada errada');
    await t.pumpAndSettle();
    expect(find.text('Zuleica Nova'), findsNothing);
  });

  testWidgets('Histórico mantém o nome de criança desativada', (t) async {
    await _ir(t, const HistoricoScreen());
    expect(find.text('Talita Feitosa'), findsOneWidget);
    await Repositorios.criancas.desativar('c1', motivo: 'Mudou de cidade');
    await t.pumpAndSettle();
    expect(find.text('Talita Feitosa'), findsOneWidget);
  });

  testWidgets('Dados da criança mostram a última avaliação do repositório', (
    t,
  ) async {
    await Repositorios.criancas.cadastrar(_nova('z1', 'Zuleica Nova'));
    await _ir(t, const DadosCriancaScreen(), args: 'z1');
    expect(find.text('Zuleica Nova'), findsOneWidget);
    expect(find.text('Sem avaliações registradas'), findsWidgets);

    await Repositorios.avaliacoes.registrar(
      _avaliacao('z1', DateTime(2026, 5, 20)),
    );
    await t.pumpAndSettle();
    expect(find.text('20/05/2026'), findsWidgets);
    expect(find.text('Sem avaliações registradas'), findsNothing);
  });

  testWidgets('Dados da criança: id inexistente mostra mensagem', (t) async {
    await _ir(t, const DadosCriancaScreen(), args: 'nao-existe');
    expect(find.text('Criança não encontrada.'), findsOneWidget);
  });

  testWidgets('Dados da criança sem argumento mostra a criança destaque', (
    t,
  ) async {
    await _ir(t, const DadosCriancaScreen());
    expect(find.text('Maria Joaquina de Lima Santos'), findsOneWidget);
  });

  testWidgets('Ficha atualiza ao vivo depois de editar', (t) async {
    await _ir(t, const DadosCriancaScreen(), args: 'c1');
    expect(find.text('Talita Feitosa'), findsOneWidget);
    final c = (await Repositorios.criancas.porId('c1'))!;
    await Repositorios.criancas.editar(
      c.copyWith(nome: 'Talita Editada'),
      motivo: 'Correção de nome',
    );
    await t.pumpAndSettle();
    expect(find.text('Talita Editada'), findsOneWidget);
    expect(find.text('Talita Feitosa'), findsNothing);
  });

  testWidgets('Criança desativada mostra aviso e desabilita os botões', (
    t,
  ) async {
    await Repositorios.criancas.desativar('c1', motivo: 'Mudou de cidade');
    await _ir(t, const DadosCriancaScreen(), args: 'c1');
    expect(find.text('Cadastro desativado'), findsOneWidget);
    final editar = t.widget<TextButton>(
      find.widgetWithText(TextButton, 'Editar dados'),
    );
    expect(editar.onPressed, isNull);
    await t.ensureVisible(find.text('Registrar Avaliação'));
    final registrar = t.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Registrar Avaliação'),
    );
    expect(registrar.onPressed, isNull);
  });

  testWidgets('Registro de medidas de criança desativada mostra aviso', (
    t,
  ) async {
    await Repositorios.criancas.desativar('c1', motivo: 'Mudou de cidade');
    await _ir(t, const RegistroMedidasScreen(), args: 'c1');
    expect(find.text('Cadastro desativado'), findsOneWidget);
  });

  testWidgets('Histórico mantém nomes com avaliação nova no topo', (t) async {
    await _ir(t, const HistoricoScreen());
    await Repositorios.avaliacoes.registrar(_avaliacao('c5', DateTime.now()));
    await t.pumpAndSettle();
    expect(find.text('Davi Medeiros'), findsWidgets);
    expect(find.text('Talita Feitosa'), findsWidgets);
    double y(String n) => t.getTopLeft(find.text(n).first).dy;
    expect(y('Davi Medeiros'), lessThan(y('Talita Feitosa')));
  });

  testWidgets('Cadastro com id inexistente mostra mensagem, sem formulário', (
    t,
  ) async {
    await _ir(t, const CadastroCriancaScreen(), args: 'nao-existe');
    expect(find.text('Criança não encontrada.'), findsOneWidget);
    expect(find.text('Salvar e Continuar'), findsNothing);
  });

  testWidgets('Cadastro com id existente preenche o formulário', (t) async {
    await _ir(t, const CadastroCriancaScreen(), args: 'c1');
    expect(find.text('Talita Feitosa'), findsOneWidget);
    expect(find.text('Salvar alterações'), findsOneWidget);
  });

  testWidgets('Registro de medidas com id inexistente mostra mensagem', (
    t,
  ) async {
    await _ir(t, const RegistroMedidasScreen(), args: 'nao-existe');
    expect(find.text('Criança não encontrada.'), findsOneWidget);
  });

  testWidgets('Lista busca por CPF do responsável', (t) async {
    await Repositorios.criancas.cadastrar(
      _nova('z1', 'Zuleica Nova').copyWith(
        responsavel: const Responsavel(
          nome: 'Mae Nova',
          cpfMascarado: '52998224725',
          telefone: '',
          email: '',
        ),
      ),
    );
    await _ir(t, const ListaCriancasScreen());
    await t.enterText(find.byType(TextField), '529.982.247-25');
    await t.pumpAndSettle();
    expect(find.text('Zuleica Nova'), findsOneWidget);
    expect(find.text('Talita Feitosa'), findsNothing);
  });
}
