import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/data/oms_assets.dart';
import 'package:appnutrimirim/screens/avaliacao/registro_medidas_screen.dart';
import 'package:appnutrimirim/screens/crianca/dados_crianca_screen.dart';
import 'package:appnutrimirim/services/antropometria_oms.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'package:appnutrimirim/widgets/common.dart';
import 'antropometria_oms_test.dart' show lerTabelas;

Finder campo(String label) => find.descendant(
  of: find.byWidgetPredicate((w) => w is LabeledField && w.label == label),
  matching: find.byType(TextFormField),
);

Crianca criancaTeste() {
  final n = DateTime.now().subtract(const Duration(days: 500));
  return Crianca(
    id: 'crianca-teste',
    nome: 'Criança teste',
    sexo: Sexo.masculino,
    bairro: 'Teste',
    cadastradoEm: DateTime.now(),
    nascimento: DateUtils.dateOnly(n),
  );
}

Future<void> selecionar(WidgetTester t, Finder f, String opcao) async {
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pumpAndSettle();
  await t.tap(find.text(opcao).last);
  await t.pumpAndSettle();
}

Future<void> preencher(
  WidgetTester t, {
  String peso = '10',
  String altura = '75',
  String edema = 'Ausente',
}) async {
  await t.ensureVisible(campo('Peso (kg)'));
  await t.enterText(campo('Peso (kg)'), peso);
  await t.ensureVisible(campo('Altura/Comprimento (cm)'));
  await t.enterText(campo('Altura/Comprimento (cm)'), altura);
  await selecionar(
    t,
    find.byType(DropdownButtonFormField<PosicaoMedicao>),
    'Deitado (comprimento)',
  );
  await selecionar(t, find.byType(DropdownButtonFormField<bool>), edema);
  await t.ensureVisible(campo('Data da medição'));
  await t.tap(campo('Data da medição'));
  await t.pumpAndSettle();
  final ctx = t.element(find.byType(DatePickerDialog));
  await t.tap(find.text(MaterialLocalizations.of(ctx).okButtonLabel));
  await t.pumpAndSettle();
}

Future<void> validar(WidgetTester t) async {
  await t.ensureVisible(find.text('Validar medidas'));
  await t.tap(find.text('Validar medidas'));
  await t.pumpAndSettle();
}

void main() {
  late TabelasOms tabelas;
  setUpAll(() => tabelas = lerTabelas());
  testWidgets('tabelas oficiais são carregadas pelos assets do aplicativo', (
    t,
  ) async {
    final carregadas = await t.runAsync(carregarTabelasOms);
    expect(carregadas, isA<TabelasOms>());
  });
  Future<void> abrir(
    WidgetTester t, {
    Future<TabelasOms> Function()? carregar,
    Future<void> Function(String texto)? compartilhar,
  }) async {
    t.view.physicalSize = const Size(800, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: RegistroMedidasScreen(
          crianca: criancaTeste(),
          carregarTabelas: carregar ?? () async => tabelas,
          compartilharTexto: compartilhar,
        ),
      ),
    );
  }

  testWidgets('sem criança não inventa idade nem usa mock', (t) async {
    await t.pumpWidget(const MaterialApp(home: RegistroMedidasScreen()));
    expect(find.text('Selecionar criança'), findsOneWidget);
    expect(find.text('Validar medidas'), findsNothing);
  });
  testWidgets('campos obrigatórios impedem validação', (t) async {
    await abrir(t);
    await validar(t);
    expect(find.text('Informe um número maior que zero'), findsNWidgets(2));
    expect(find.text('Informe a posição'), findsOneWidget);
    expect(find.text('Informe se há edema'), findsOneWidget);
    expect(find.text('Escolha a data da medição'), findsOneWidget);
    expect(find.text('Validação OMS'), findsNothing);
  });
  testWidgets('medidas válidas exibem indicadores e editar limpa resultado', (
    t,
  ) async {
    await abrir(t);
    await preencher(t, peso: '10,2');
    await validar(t);
    expect(find.text('Validação OMS'), findsOneWidget);
    expect(
      find.textContaining('Sem alertas de plausibilidade'),
      findsOneWidget,
    );
    expect(find.textContaining('Peso para idade: z ='), findsOneWidget);
    await t.ensureVisible(campo('Peso (kg)'));
    await t.enterText(campo('Peso (kg)'), '20');
    await t.pump();
    expect(find.text('Validação OMS'), findsNothing);
  });
  testWidgets('compartilha relatório com dados, z-scores e classificação', (
    t,
  ) async {
    String? relatorio;
    await abrir(t, compartilhar: (texto) async => relatorio = texto);
    await preencher(t);
    await validar(t);

    await t.ensureVisible(find.text('Compartilhar relatório'));
    await t.tap(find.text('Compartilhar relatório'));
    await t.pumpAndSettle();

    expect(relatorio, contains('Criança: Criança teste'));
    expect(relatorio, contains('Data de nascimento:'));
    expect(relatorio, matches(RegExp(r'Data da avaliação: \d{2}/\d{2}/\d{4}')));
    expect(relatorio, contains('Classificação geral'));
    expect(relatorio, contains('Peso para idade: z ='));
    expect(relatorio, contains('Confira os dados antes de compartilhar.'));
  });
  testWidgets('peso extremo pede conferência e preserva a medida digitada', (
    t,
  ) async {
    await abrir(t);
    await preencher(t, peso: '100');
    await validar(t);
    expect(find.textContaining('Há valores fora'), findsOneWidget);
    await t.ensureVisible(campo('Peso (kg)'));
    expect(t.widget<TextFormField>(campo('Peso (kg)')).controller!.text, '100');
  });
  testWidgets('edema não exibe escores fictícios de peso', (t) async {
    await abrir(t);
    await preencher(t, edema: 'Presente');
    await validar(t);
    expect(find.textContaining('Edema presente'), findsNWidgets(3));
    expect(
      find.textContaining('Comprimento/altura para idade: z ='),
      findsOneWidget,
    );
  });
  testWidgets('erro ao carregar permite tentar novamente', (t) async {
    var chamadas = 0;
    await abrir(
      t,
      carregar: () async {
        if (chamadas++ == 0) throw const FormatException('asset inválido');
        return tabelas;
      },
    );
    await preencher(t);
    await validar(t);
    expect(find.textContaining('Não foi possível carregar'), findsOneWidget);
    await validar(t);
    expect(find.text('Validação OMS'), findsOneWidget);
    expect(chamadas, 2);
  });
  testWidgets('ficha encaminha exatamente a criança selecionada', (t) async {
    final crianca = criancaTeste();
    Object? recebida;
    await t.pumpWidget(
      MaterialApp(
        initialRoute: '/ficha',
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute<void>(
            settings: RouteSettings(arguments: crianca),
            builder: (_) => const DadosCriancaScreen(),
          ),
        ],
        routes: {
          Routes.registroMedidas: (ctx) {
            recebida = ModalRoute.of(ctx)!.settings.arguments;
            return const Scaffold(body: Text('MEDIDAS'));
          },
        },
      ),
    );
    await t.ensureVisible(find.text('Registrar Avaliação'));
    await t.pumpAndSettle();
    await t.tap(find.text('Registrar Avaliação'));
    await t.pumpAndSettle();
    expect(recebida, same(crianca));
  });
  testWidgets('formulário e resultado cabem em 360dp com fonte ampliada', (
    t,
  ) async {
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
        home: RegistroMedidasScreen(
          crianca: criancaTeste(),
          carregarTabelas: () async => tabelas,
        ),
      ),
    );
    await preencher(t, peso: '100');
    await validar(t);
    expect(find.text('Validação OMS'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
