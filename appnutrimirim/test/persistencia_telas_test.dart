import 'dart:async';

import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/repositories/memoria/criancas_memoria.dart';
import 'package:appnutrimirim/repositories/repositorios.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/avaliacao/cadastro_crianca_screen.dart';
import 'package:appnutrimirim/screens/avaliacao/registro_medidas_screen.dart';
import 'package:appnutrimirim/services/antropometria_oms.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'antropometria_oms_test.dart' show lerTabelas;
import 'registro_medidas_test.dart'
    show campo, preencher, validar, criancaTeste;

const _autor = UsuarioAtual(uid: 'autor', nome: 'Profissional de teste');

SessaoProfissional _sessao(PapelProfissional papel) => SessaoProfissional(
  uid: _autor.uid,
  nome: _autor.nome,
  papel: papel,
  ubsIds: papel == PapelProfissional.master ? [] : ['ubs-a', 'ubs-b'],
  ubsAtualId: papel == PapelProfissional.master ? '' : 'ubs-b',
  nomesUbs: const {'ubs-a': 'UBS A', 'ubs-b': 'UBS B'},
);

Future<void> _abrir(WidgetTester t, Widget tela, {Object? argumento}) async {
  t.view.physicalSize = const Size(800, 1800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute<void>(
          settings: RouteSettings(arguments: argumento),
          builder: (_) => tela,
        ),
      ],
      routes: {
        Routes.registroMedidas: (_) => const Scaffold(body: Text('MEDIDAS')),
        Routes.dadosCrianca: (_) => const Scaffold(body: Text('FICHA')),
        Routes.resultado: (_) => const Scaffold(body: Text('RESULTADO')),
      },
    ),
  );
  await t.pumpAndSettle();
}

Future<void> _tocar(WidgetTester t, String texto) async {
  await t.ensureVisible(find.text(texto));
  await t.tap(find.text(texto));
  await t.pumpAndSettle();
}

Future<void> _cadastro(WidgetTester t) async {
  for (final e in {
    'Nome completo': 'Criança Teste',
    'CPF da criança': '11144477735',
    'Bairro': 'Centro',
    'Responsável legal': 'Responsável Teste',
    'CPF Responsável': '52998224725',
    'Contato': '11999999999',
  }.entries) {
    await t.ensureVisible(campo(e.key));
    await t.enterText(campo(e.key), e.value);
  }
  await t.ensureVisible(find.text('Feminino'));
  await t.tap(find.text('Feminino'));
  await t.tap(campo('Nascimento'));
  await t.pumpAndSettle();
  final ctx = t.element(find.byType(DatePickerDialog));
  await t.tap(find.text(MaterialLocalizations.of(ctx).okButtonLabel));
  await t.pumpAndSettle();
}

class _CadastroControlado extends CriancaRepositoryMemoria {
  _CadastroControlado(super.banco);
  Completer<void>? pendente;
  bool falhar = false;
  final ids = <String>[];
  String? unidade;

  @override
  Future<void> cadastrar(Crianca c, {String? ubsId}) async {
    ids.add(c.id);
    unidade = ubsId;
    if (pendente != null) await pendente!.future;
    if (falhar) throw const PermissaoNegada('Gravação recusada para teste.');
    await super.cadastrar(c, ubsId: ubsId);
  }
}

void main() {
  late BancoMemoria banco;
  late TabelasOms tabelas;
  setUpAll(() => tabelas = lerTabelas());
  setUp(() {
    banco = Repositorios.usarMemoria(
      comMock: false,
      usuario: _autor,
      sessao: _sessao(PapelProfissional.acs),
    );
  });
  tearDown(Repositorios.reiniciar);

  for (final papel in PapelProfissional.values) {
    testWidgets(
      'cadastro ${papel.name} grava na UBS escolhida com CPF da criança',
      (t) async {
        banco = Repositorios.usarMemoria(
          comMock: false,
          usuario: _autor,
          sessao: _sessao(papel),
        );
        final repo = _CadastroControlado(banco);
        await _abrir(t, CadastroCriancaScreen(repositorio: repo));
        await _cadastro(t);
        if (papel == PapelProfissional.master) {
          await t.ensureVisible(find.byType(DropdownButtonFormField<String>));
          await t.tap(find.byType(DropdownButtonFormField<String>));
          await t.pumpAndSettle();
          await t.tap(find.text('UBS B').last);
          await t.pumpAndSettle();
        }
        await _tocar(t, 'Salvar e Continuar');
        expect(find.text('MEDIDAS'), findsOneWidget);
        final c = banco.criancas.values.single;
        expect(repo.unidade, 'ubs-b');
        expect(c.ubs, 'UBS B');
        expect(c.cpf, '111.444.777-35');
        expect(c.responsavel!.cpfMascarado, '529.982.247-25');
        expect(
          ModalRoute.of(t.element(find.text('MEDIDAS')))!.settings.arguments,
          c.id,
        );
        expect(c.id.startsWith('rascunho-'), isFalse);
      },
    );
  }

  testWidgets('cadastro aguarda confirmação e impede duplo envio', (t) async {
    final repo = _CadastroControlado(banco)..pendente = Completer<void>();
    await _abrir(t, CadastroCriancaScreen(repositorio: repo));
    await _cadastro(t);
    await _tocar(t, 'Salvar e Continuar');
    expect(find.textContaining('Aguardando confirmação'), findsOneWidget);
    expect(find.text('MEDIDAS'), findsNothing);
    expect(
      t
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Salvando...'),
          )
          .onPressed,
      isNull,
    );
    expect(repo.ids, hasLength(1));
    repo.pendente!.complete();
    await t.pumpAndSettle();
    expect(banco.criancas, hasLength(1));
    expect(find.text('MEDIDAS'), findsOneWidget);
  });

  testWidgets('falha mantém formulário e nova tentativa reutiliza o id', (
    t,
  ) async {
    final repo = _CadastroControlado(banco)..falhar = true;
    await _abrir(t, CadastroCriancaScreen(repositorio: repo));
    await _cadastro(t);
    await _tocar(t, 'Salvar e Continuar');
    expect(find.text('Gravação recusada para teste.'), findsOneWidget);
    expect(banco.criancas, isEmpty);
    expect(
      t.widget<TextFormField>(campo('Nome completo')).controller!.text,
      'Criança Teste',
    );
    repo.falhar = false;
    await _tocar(t, 'Salvar e Continuar');
    expect(repo.ids, hasLength(2));
    expect(repo.ids.toSet(), hasLength(1));
    expect(banco.criancas, hasLength(1));
  });

  testWidgets('edição exige motivo, mantém id e UBS e cria auditoria', (
    t,
  ) async {
    final c = criancaTeste().copyWith(
      ubs: 'UBS A',
      microarea: '03',
      cpf: '11144477735',
      responsavel: const Responsavel(
        nome: 'Responsável Teste',
        cpfMascarado: '529.982.247-25',
        telefone: '11999999999',
        email: 'teste@exemplo.test',
      ),
    );
    await Repositorios.criancas.cadastrar(c);
    await _abrir(t, const CadastroCriancaScreen(), argumento: c.id);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.text('UBS A'), findsOneWidget);
    await t.enterText(campo('Nome completo'), 'Nome corrigido');
    await _tocar(t, 'Salvar alterações');
    expect(find.text('Informe de 3 a 200 caracteres'), findsOneWidget);
    expect(banco.alteracoes, isEmpty);
    await t.ensureVisible(campo('Motivo da alteração'));
    await t.enterText(campo('Motivo da alteração'), 'Correção do nome');
    await _tocar(t, 'Salvar alterações');
    final salva = banco.criancas[c.id]!;
    expect(salva.microarea, '03');
    expect(salva.nome, 'Nome corrigido');
    expect(salva.ubs, 'UBS A');
    expect(salva.nascimento, c.nascimento);
    expect(salva.cpf, '111.444.777-35');
    expect(salva.responsavel!.email, c.responsavel!.email);
    expect(banco.alteracoes.single.motivo, 'Correção do nome');
    expect(banco.alteracoes.single.alteradoPor, _autor.uid);
    expect(find.text('FICHA'), findsOneWidget);
  });

  for (final edema in [false, true]) {
    testWidgets('avaliação salva indicadores calculados e edema=$edema', (
      t,
    ) async {
      final c = criancaTeste();
      await Repositorios.criancas.cadastrar(c);
      await _abrir(
        t,
        RegistroMedidasScreen(crianca: c, carregarTabelas: () async => tabelas),
      );
      await preencher(t, peso: '10,25', edema: edema ? 'Presente' : 'Ausente');
      await validar(t);
      expect(banco.avaliacoes, isEmpty);
      await _tocar(t, 'Salvar avaliação');
      final a = banco.avaliacoes.values.single;
      expect(a.criancaId, c.id);
      expect(a.pesoKg, 10.25);
      expect(a.alturaCm, 75);
      expect(a.tipoMedida, 'deitado');
      expect(a.edema, edema);
      expect(a.profissionalId, _autor.uid);
      expect(a.criadoEm, isNotNull);
      expect(
        a.indicadores.keys,
        unorderedEquals(edema ? ['ei'] : ['pi', 'ei', 'pe', 'imci']),
      );
      if (edema) {
        expect(a.desnutricao, isTrue);
        expect(a.situacao, Situacao.abaixo);
      }
      expect(find.text('RESULTADO'), findsOneWidget);
    });
  }

  for (final caso in ['autor', 'prazo', 'outro', 'master']) {
    testWidgets('correção: $caso, prazo e autoria respeitados pela tela', (
      t,
    ) async {
      final agora = DateTime.now();
      banco.agora = () => agora;
      final c = criancaTeste();
      await Repositorios.criancas.cadastrar(c);
      final a = await Repositorios.avaliacoes.registrar(
        Avaliacao(
          criancaId: c.id,
          data: DateUtils.dateOnly(agora),
          pesoKg: 10.25,
          alturaCm: 75,
          situacao: Situacao.normal,
          tipoMedida: 'deitado',
          edema: false,
          indicadores: const {
            'pi': Indicador('Peso para idade', 0, Situacao.normal),
          },
        ),
      );
      if (caso == 'prazo') {
        banco.agora = () => agora.add(const Duration(minutes: 15));
      }
      if (caso == 'outro') {
        banco.usuario = const UsuarioAtual(uid: 'outro', nome: 'Outro');
      }
      if (caso == 'master') {
        banco.agora = () => agora.add(const Duration(hours: 1));
        banco.usuario = const UsuarioAtual(
          uid: 'master',
          nome: 'Master',
          master: true,
        );
      }
      await _abrir(
        t,
        RegistroMedidasScreen(
          crianca: c,
          avaliacao: a,
          carregarTabelas: () async => tabelas,
        ),
      );
      expect(
        t.widget<TextFormField>(campo('Peso (kg)')).controller!.text,
        '10,25',
      );
      await t.ensureVisible(campo('Motivo da correção'));
      await t.enterText(campo('Motivo da correção'), 'Conferência da balança');
      await t.ensureVisible(campo('Peso (kg)'));
      await t.enterText(campo('Peso (kg)'), '10,5');
      await validar(t);
      await _tocar(t, 'Salvar correção');
      if (caso == 'autor' || caso == 'master') {
        final corrigida = banco.avaliacoes[a.id]!;
        expect(corrigida.pesoKg, 10.5);
        expect(corrigida.profissionalId, _autor.uid);
        expect(corrigida.criadoEm, a.criadoEm);
        expect(corrigida.indicadores, hasLength(4));
        expect(banco.alteracoes.single.alteradoPor, banco.usuario.uid);
        expect(banco.alteracoes.single.motivo, 'Conferência da balança');
      } else {
        expect(banco.avaliacoes[a.id]!.pesoKg, 10.25);
        expect(banco.alteracoes, isEmpty);
        expect(
          find.textContaining(
            caso == 'prazo' ? 'O prazo de 15 minutos' : 'Só quem registrou',
          ),
          findsOneWidget,
        );
      }
    });
  }

  testWidgets('medidas que exigem conferência não oferecem salvamento', (
    t,
  ) async {
    final c = criancaTeste();
    await Repositorios.criancas.cadastrar(c);
    await _abrir(
      t,
      RegistroMedidasScreen(crianca: c, carregarTabelas: () async => tabelas),
    );
    await preencher(t, peso: '100');
    await validar(t);
    expect(find.text('Salvar avaliação'), findsNothing);
    expect(banco.avaliacoes, isEmpty);
  });
}
