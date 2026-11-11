import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appnutrimirim/screens/avaliacao/cadastro_crianca_screen.dart';
import 'package:appnutrimirim/services/validadores.dart';
import 'package:appnutrimirim/theme/app_theme.dart';

Future<void> _abrirCadastro(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const CadastroCriancaScreen(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('validação de CPF', () {
    test('aceita CPF com dígitos verificadores válidos', () {
      expect(cpfValido('529.982.247-25'), isTrue);
    });

    test('rejeita dígito verificador incorreto e números repetidos', () {
      expect(cpfValido('529.982.247-24'), isFalse);
      expect(cpfValido('111.111.111-11'), isFalse);
    });
  });

  testWidgets('sexo inicia sem seleção e informa semântica ao selecionar', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await _abrirCadastro(tester);

    expect(
      tester.getSemantics(find.bySemanticsLabel('Masculino')),
      matchesSemantics(
        label: 'Masculino',
        isButton: true,
        hasSelectedState: true,
        isSelected: false,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Feminino')),
      matchesSemantics(
        label: 'Feminino',
        isButton: true,
        hasSelectedState: true,
        isSelected: false,
        hasTapAction: true,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Feminino'));
    await tester.pump();

    expect(
      tester.getSemantics(find.bySemanticsLabel('Feminino')),
      matchesSemantics(
        label: 'Feminino',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('nascimento abre DatePicker e preenche a data escolhida', (
    tester,
  ) async {
    await _abrirCadastro(tester);

    final nascimento = find.widgetWithText(TextFormField, 'DD/MM/AAAA');
    await tester.tap(nascimento);
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
    final dialogContext = tester.element(find.byType(DatePickerDialog));
    final localizacoes = MaterialLocalizations.of(dialogContext);
    expect(Localizations.localeOf(dialogContext), const Locale('pt', 'BR'));
    expect(find.text(localizacoes.cancelButtonLabel), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final hoje = DateTime.now();
    final dataEsperada =
        '${hoje.day.toString().padLeft(2, '0')}/'
        '${hoje.month.toString().padLeft(2, '0')}/'
        '${hoje.year}';
    expect(find.widgetWithText(TextFormField, dataEsperada), findsOneWidget);
  });

  testWidgets('aplica máscaras e limita CPF e telefone', (tester) async {
    await _abrirCadastro(tester);

    final cpfs = find.widgetWithText(TextFormField, '000.000.000-00');
    final telefone = find.widgetWithText(TextFormField, '(00) 00000-0000');

    await tester.enterText(cpfs.first, '5299822472599');
    await tester.enterText(cpfs.last, '5299822472599');
    await tester.enterText(telefone, '7991234567899');

    String textoDoCampo(Finder campo) => tester
        .widget<EditableText>(
          find.descendant(of: campo, matching: find.byType(EditableText)),
        )
        .controller
        .text;

    expect(textoDoCampo(cpfs.first), '529.982.247-25');
    expect(textoDoCampo(cpfs.last), '529.982.247-25');
    expect(textoDoCampo(telefone), '(79) 91234-5678');
  });

  testWidgets('formulário mostra erro para CPF inválido', (tester) async {
    await _abrirCadastro(tester);

    final cpfs = find.widgetWithText(TextFormField, '000.000.000-00');
    await tester.enterText(cpfs.last, '52998224724');
    await tester.ensureVisible(find.text('Salvar e Continuar'));
    await tester.tap(find.text('Salvar e Continuar'));
    await tester.pump();

    expect(find.text('CPF inválido'), findsOneWidget);
  });
}
