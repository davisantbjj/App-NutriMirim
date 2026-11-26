import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/screens/avaliacao/cadastro_crianca_screen.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'package:appnutrimirim/widgets/common.dart';
import 'package:appnutrimirim/repositories/repositorios.dart';

Finder _campo(String label) => find.descendant(
  of: find.byWidgetPredicate((w) => w is LabeledField && w.label == label),
  matching: find.byType(TextFormField),
);

Future<void> _abrir(WidgetTester t) async {
  t.view.physicalSize = const Size(800, 1400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: const CadastroCriancaScreen(),
      routes: {
        Routes.registroMedidas: (_) =>
            const Scaffold(body: Text('MEDIDAS_STUB')),
      },
    ),
  );
}

Future<void> _salvar(WidgetTester t) async {
  await t.ensureVisible(find.text('Salvar e Continuar'));
  await t.tap(find.text('Salvar e Continuar'));
  await t.pumpAndSettle();
}

Future<void> _data(WidgetTester t) async {
  await t.tap(_campo('Nascimento'));
  await t.pumpAndSettle();
  final dialog = t.element(find.byType(DatePickerDialog));
  await t.tap(find.text(MaterialLocalizations.of(dialog).okButtonLabel));
  await t.pumpAndSettle();
}

Future<void> _dadosObrigatorios(WidgetTester t) async {
  for (final entrada in {
    'Nome completo': 'Criança de teste',
    'Bairro': 'Bairro de teste',
    'Responsável legal': 'Responsável de teste',
    'CPF Responsável': '52998224725',
    'Contato': '11999999999',
  }.entries) {
    await t.enterText(_campo(entrada.key), entrada.value);
  }
}

void main() {
  setUp(
    () => Repositorios.usarMemoria(
      sessao: const SessaoProfissional(
        uid: 'teste',
        nome: 'Teste',
        papel: PapelProfissional.acs,
        ubsIds: ['ubs-teste'],
        ubsAtualId: 'ubs-teste',
        nomesUbs: {'ubs-teste': 'UBS Teste'},
      ),
    ),
  );
  tearDown(Repositorios.reiniciar);
  testWidgets('sexo começa vazio e anuncia botão e seleção exclusiva', (
    t,
  ) async {
    await _abrir(t);
    for (final label in ['Masculino', 'Feminino']) {
      expect(
        t.getSemantics(find.bySemanticsLabel(label)),
        containsSemantics(
          isButton: true,
          hasSelectedState: true,
          isSelected: false,
        ),
      );
    }
    await t.tap(find.text('Feminino'));
    await t.pump();
    expect(
      t.getSemantics(find.bySemanticsLabel('Feminino')),
      containsSemantics(hasSelectedState: true, isSelected: true),
    );
    await t.tap(find.text('Masculino'));
    await t.pump();
    expect(
      t.getSemantics(find.bySemanticsLabel('Feminino')),
      containsSemantics(hasSelectedState: true, isSelected: false),
    );
    expect(
      t.getSemantics(find.bySemanticsLabel('Masculino')),
      containsSemantics(hasSelectedState: true, isSelected: true),
    );
  });

  testWidgets('sexo e nascimento ausentes impedem continuar', (t) async {
    await _abrir(t);
    await _dadosObrigatorios(t);
    await _salvar(t);
    expect(find.text('Selecione o sexo'), findsOneWidget);
    expect(find.text('Escolha a data de nascimento'), findsOneWidget);
    expect(find.text('MEDIDAS_STUB'), findsNothing);
    await t.tap(find.text('Feminino'));
    await _data(t);
    expect(find.text('Selecione o sexo'), findsNothing);
    expect(find.text('Escolha a data de nascimento'), findsNothing);
    await _salvar(t);
    expect(find.text('MEDIDAS_STUB'), findsOneWidget);
    final id =
        ModalRoute.of(t.element(find.text('MEDIDAS_STUB')))!.settings.arguments
            as String;
    final crianca = (await Repositorios.criancas.porId(id))!;
    expect(crianca.nome, 'Criança de teste');
    expect(crianca.sexo, Sexo.feminino);
    expect(crianca.nascimento, DateUtils.dateOnly(DateTime.now()));
  });

  testWidgets('calendário limita nascimento a hoje e cancelar mantém vazio', (
    t,
  ) async {
    await _abrir(t);
    final field = t.widget<TextFormField>(_campo('Nascimento'));
    final input = t.widget<TextField>(
      find.descendant(
        of: _campo('Nascimento'),
        matching: find.byType(TextField),
      ),
    );
    expect(input.readOnly, isTrue);
    await t.tap(_campo('Nascimento'));
    await t.pumpAndSettle();
    final picker = t.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(picker.lastDate, DateUtils.dateOnly(DateTime.now()));
    final ctx = t.element(find.byType(DatePickerDialog));
    await t.tap(find.text(MaterialLocalizations.of(ctx).cancelButtonLabel));
    await t.pumpAndSettle();
    expect(field.controller!.text, isEmpty);
    await _data(t);
    final hoje = DateTime.now();
    expect(
      field.controller!.text,
      '${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}/${hoje.year}',
    );
    await t.tap(_campo('Nascimento'));
    await t.pumpAndSettle();
    expect(
      t.widget<DatePickerDialog>(find.byType(DatePickerDialog)).initialDate,
      DateUtils.dateOnly(hoje),
    );
    final ctx2 = t.element(find.byType(DatePickerDialog));
    await t.tap(find.text(MaterialLocalizations.of(ctx2).cancelButtonLabel));
    await t.pumpAndSettle();
    expect(field.controller!.text, isNotEmpty);
  });

  for (final label in ['CPF Responsável', 'CPF da criança']) {
    testWidgets('$label recebe máscara e bloqueia dígitos inválidos', (
      t,
    ) async {
      await _abrir(t);
      await _dadosObrigatorios(t);
      await t.tap(find.text('Masculino'));
      await _data(t);
      await t.enterText(_campo(label), '52998224724');
      expect(
        t.widget<TextFormField>(_campo(label)).controller!.text,
        '529.982.247-24',
      );
      await _salvar(t);
      expect(find.text('CPF inválido'), findsOneWidget);
      expect(find.text('MEDIDAS_STUB'), findsNothing);
      await t.enterText(_campo(label), '52998224725');
      await _salvar(t);
      expect(find.text('MEDIDAS_STUB'), findsOneWidget);
    });
  }
}
