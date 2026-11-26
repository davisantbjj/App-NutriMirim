import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appnutrimirim/data/mock_data.dart';
import 'package:appnutrimirim/repositories/repositorios.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/avaliacao/cadastro_crianca_screen.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'package:appnutrimirim/utils/formatters.dart';
import 'package:appnutrimirim/widgets/common.dart';

Finder campo(String label) => find.descendant(
  of: find.byWidgetPredicate((w) => w is LabeledField && w.label == label),
  matching: find.byType(TextFormField),
);

void main() {
  setUp(Repositorios.reiniciar);
  tearDown(Repositorios.reiniciar);
  for (final porId in [true, false]) {
    testWidgets(
      'cadastro por ${porId ? 'id' : 'objeto'} preserva criança na OMS',
      (t) async {
        final original = MockData.criancaDestaque;
        t.view.physicalSize = const Size(800, 1600);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        await t.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            initialRoute: Routes.cadastroCrianca,
            onGenerateInitialRoutes: (_) => [
              MaterialPageRoute<void>(
                settings: RouteSettings(
                  name: Routes.cadastroCrianca,
                  arguments: porId ? original.id : original,
                ),
                builder: (_) => const CadastroCriancaScreen(),
              ),
            ],
            routes: Routes.table,
          ),
        );
        await t.pumpAndSettle();
        expect(
          t.widget<TextFormField>(campo('Nascimento')).controller!.text,
          formatarData(original.nascimento!),
        );
        await t.enterText(campo('Nome completo'), 'Nome editado para teste');
        await t.enterText(campo('CPF Responsável'), '52998224725');
        await t.ensureVisible(campo('Motivo da alteração'));
        await t.enterText(campo('Motivo da alteração'), 'Atualização do nome');
        await t.ensureVisible(find.text('Salvar alterações'));
        await t.tap(find.text('Salvar alterações'));
        await t.pumpAndSettle();
        expect(find.text('Dados da criança'), findsOneWidget);
        await t.ensureVisible(find.text('Registrar Avaliação'));
        await t.tap(find.text('Registrar Avaliação'));
        await t.pumpAndSettle();
        expect(find.text('Registro de Medidas'), findsOneWidget);
        final nome = find.text('Nome editado para teste');
        expect(nome, findsOneWidget);
        final id = ModalRoute.of(t.element(nome))!.settings.arguments as String;
        final recebida = (await Repositorios.criancas.porId(id))!;
        expect(recebida.id, original.id);
        expect(recebida.nascimento, original.nascimento);
        expect(recebida.cadastradoEm, original.cadastradoEm);
        expect(recebida.endereco, original.endereco);
        expect(recebida.responsavel!.email, original.responsavel!.email);
        expect(
          t.widget<TextFormField>(campo('Nascimento')).controller!.text,
          formatarData(original.nascimento!),
        );
        expect(original.nome, isNot('Nome editado para teste'));
        expect(t.takeException(), isNull);
      },
    );
  }
}
