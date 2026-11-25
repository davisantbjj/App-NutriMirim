import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fontes.dart';
import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/repositories/repositorios.dart';
import 'package:appnutrimirim/routes.dart';
import 'package:appnutrimirim/screens/crianca/curva_crescimento_screen.dart';
import 'package:appnutrimirim/screens/crianca/dados_crianca_screen.dart';
import 'package:appnutrimirim/screens/crianca/lista_criancas_screen.dart';
import 'package:appnutrimirim/screens/historico_screen.dart';
import 'package:appnutrimirim/theme/app_theme.dart';
import 'package:appnutrimirim/widgets/bottom_nav.dart';
import 'package:appnutrimirim/widgets/estado_assincrono.dart';

// ignore_for_file: subtype_of_sealed_class

// Estados de carregamento e de erro das telas que leem dos repositórios, e
// tela pequena (360 dp) com fonte 1,3x sem overflow.

enum _Modo { erro, carregando }

/// Firestore falso: toda consulta devolve um erro de rede ('unavailable') ou
/// nunca responde (carregando). Serve para exercitar o repositório REAL do
/// Firestore e as telas, sem Firebase.
class _FirestoreFalso implements FirebaseFirestore {
  _FirestoreFalso(this.modo);
  final _Modo modo;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      invocation.memberName == #collection
      ? _ColecaoFalsa(modo)
      : super.noSuchMethod(invocation);
}

class _ColecaoFalsa implements CollectionReference<Map<String, dynamic>> {
  _ColecaoFalsa(this.modo);
  final _Modo modo;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    switch (invocation.memberName) {
      case #snapshots:
        return modo == _Modo.erro
            ? Stream<QuerySnapshot<Map<String, dynamic>>>.error(
                FirebaseException(
                  plugin: 'cloud_firestore',
                  code: 'unavailable',
                ),
              )
            : StreamController<QuerySnapshot<Map<String, dynamic>>>().stream;
      case #get:
        return modo == _Modo.erro
            ? Future<QuerySnapshot<Map<String, dynamic>>>.error(
                FirebaseException(
                  plugin: 'cloud_firestore',
                  code: 'unavailable',
                ),
              )
            : Completer<QuerySnapshot<Map<String, dynamic>>>().future;
      case #doc:
        return _DocumentoFalso(modo);
      default:
        return this; // where/orderBy/limit encadeiam
    }
  }
}

class _DocumentoFalso implements DocumentReference<Map<String, dynamic>> {
  _DocumentoFalso(this.modo);
  final _Modo modo;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #get) {
      return modo == _Modo.erro
          ? Future<DocumentSnapshot<Map<String, dynamic>>>.error(
              FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
            )
          : Completer<DocumentSnapshot<Map<String, dynamic>>>().future;
    }
    if (invocation.memberName == #snapshots) {
      return modo == _Modo.erro
          ? Stream<DocumentSnapshot<Map<String, dynamic>>>.error(
              FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
            )
          : StreamController<DocumentSnapshot<Map<String, dynamic>>>().stream;
    }
    return super.noSuchMethod(invocation);
  }
}

const _sessao = SessaoProfissional(
  uid: 'm1',
  nome: 'Mestre',
  papel: PapelProfissional.master,
  ubsIds: [],
  ubsAtualId: 'u1',
);

Future<void> _ir(
  WidgetTester t,
  Widget w, {
  Object? args,
  double escala = 1,
  Size dp = const Size(360, 800),
  bool assentar = true,
}) async {
  t.view.physicalSize = dp * 3;
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      routes: Routes.table,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(escala)),
        child: child!,
      ),
      initialRoute: '/x',
      onGenerateRoute: (s) => s.name == '/x'
          ? MaterialPageRoute(
              settings: RouteSettings(name: '/x', arguments: args),
              builder: (_) => w,
            )
          : null,
    ),
  );
  if (assentar) {
    await t.pumpAndSettle();
  } else {
    await t.pump();
    await t.pump(const Duration(milliseconds: 50));
  }
}

const _nomeLongo =
    'Maria Joaquina de Lima Santos Albuquerque Cavalcanti de Souza Neto';

Crianca _longa() => Crianca(
  id: 'longa1',
  nome: _nomeLongo,
  sexo: Sexo.feminino,
  bairro: 'Conjunto Habitacional Jardim das Flores do Sul',
  endereco:
      'Avenida Presidente Juscelino Kubitschek de Oliveira, 1234, apto 56',
  ubs: 'UBS Jardim das Flores do Sul Zona Leste',
  cadastradoEm: DateTime(2026, 1, 10),
  nascimento: DateTime(2024, 2, 29),
  responsavel: const Responsavel(
    nome: 'Responsável com Nome Bem Comprido da Silva Pereira',
    cpfMascarado: '857.123.456-54',
    telefone: '(11) 98765-4321',
    email: 'responsavel.com.email.muito.longo@exemplo-de-dominio.com.br',
  ),
);

Avaliacao _avLonga(DateTime data) => Avaliacao(
  criancaId: 'longa1',
  data: data,
  pesoKg: 12.5,
  alturaCm: 85,
  situacao: Situacao.atencao,
  indicadores: const {
    'pi': Indicador('P/I', -1.2, Situacao.atencao),
    'ei': Indicador('E/I', -0.4, Situacao.normal),
    'pe': Indicador('P/E', -1.9, Situacao.atencao),
    'imci': Indicador('IMC/I', -1.8, Situacao.atencao),
  },
  retornoSugerido: DateTime(2026, 8, 31),
);

void main() {
  setUpAll(carregarFontes);
  setUp(Repositorios.reiniciar);
  tearDown(Repositorios.reiniciar);

  group('erro de leitura: mensagem em português, sem exceção', () {
    setUp(
      () => Repositorios.usarFirestore(
        _sessao,
        firestore: _FirestoreFalso(_Modo.erro),
      ),
    );

    testWidgets('lista de crianças', (t) async {
      await _ir(t, const ListaCriancasScreen());
      expect(
        find.text('Não foi possível carregar a lista de crianças.'),
        findsOneWidget,
      );
      expect(find.byType(CarregandoCentro), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('histórico geral', (t) async {
      await _ir(t, const HistoricoScreen());
      expect(
        find.text('Não foi possível carregar o histórico.'),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('histórico de uma criança', (t) async {
      await _ir(t, const HistoricoScreen(), args: 'c1');
      expect(
        find.text('Não foi possível carregar o histórico.'),
        findsOneWidget,
      );
      expect(find.byType(CarregandoCentro), findsNothing);
      expect(find.text('Nenhuma avaliação registrada.'), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('erro no histórico mantém a barra inferior', (t) async {
      await _ir(t, const HistoricoScreen());
      expect(find.byType(AppBottomNav), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Histórico'), findsOneWidget);
      expect(find.byType(MensagemCentro), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('erro no histórico em 360 dp com fonte 2x', (t) async {
      await _ir(t, const HistoricoScreen(), escala: 2);
      expect(find.byType(MensagemCentro), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('dados da criança', (t) async {
      await _ir(t, const DadosCriancaScreen(), args: 'c1');
      expect(
        find.text('Não foi possível carregar os dados da criança.'),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('curva de crescimento', (t) async {
      await _ir(t, const CurvaCrescimentoScreen(), args: 'c1');
      expect(
        find.text('Não foi possível carregar os dados da criança.'),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('erro em 360 dp com fonte 2x não estoura o layout', (t) async {
      await _ir(t, const ListaCriancasScreen(), escala: 2);
      expect(find.byType(MensagemCentro), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('carregando: indicador de progresso, sem mensagem de erro', () {
    setUp(
      () => Repositorios.usarFirestore(
        _sessao,
        firestore: _FirestoreFalso(_Modo.carregando),
      ),
    );

    testWidgets('lista de crianças', (t) async {
      await _ir(t, const ListaCriancasScreen(), assentar: false);
      expect(find.byType(CarregandoCentro), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('Não foi possível'), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('histórico geral', (t) async {
      await _ir(t, const HistoricoScreen(), assentar: false);
      expect(find.byType(CarregandoCentro), findsOneWidget);
      expect(find.textContaining('Não foi possível'), findsNothing);
    });

    testWidgets('histórico de uma criança', (t) async {
      await _ir(t, const HistoricoScreen(), args: 'c1', assentar: false);
      expect(find.byType(CarregandoCentro), findsOneWidget);
      expect(find.textContaining('Não foi possível'), findsNothing);
      expect(find.text('Nenhuma avaliação registrada.'), findsNothing);
    });

    testWidgets('dados da criança', (t) async {
      await _ir(t, const DadosCriancaScreen(), args: 'c1', assentar: false);
      expect(find.byType(CarregandoCentro), findsOneWidget);
    });

    testWidgets('curva de crescimento', (t) async {
      await _ir(t, const CurvaCrescimentoScreen(), args: 'c1', assentar: false);
      expect(find.byType(CarregandoCentro), findsOneWidget);
    });

    testWidgets('carregando tem rótulo de acessibilidade', (t) async {
      await _ir(t, const ListaCriancasScreen(), assentar: false);
      expect(find.bySemanticsLabel('Carregando'), findsOneWidget);
    });
  });

  group('memória: vazio e inexistente', () {
    testWidgets('lista vazia mostra a tela sem erro', (t) async {
      Repositorios.usarMemoria(comMock: false);
      await _ir(t, const ListaCriancasScreen());
      expect(find.byType(CarregandoCentro), findsNothing);
      expect(find.textContaining('Não foi possível'), findsNothing);
      expect(t.takeException(), isNull);
    });

    testWidgets('histórico vazio mostra "Nenhuma avaliação registrada."', (
      t,
    ) async {
      Repositorios.usarMemoria(comMock: false);
      await _ir(t, const HistoricoScreen());
      expect(find.text('Nenhuma avaliação registrada.'), findsOneWidget);
    });

    testWidgets(
      'curva de criança inexistente mostra "Criança não encontrada."',
      (t) async {
        await _ir(t, const CurvaCrescimentoScreen(), args: 'nao-existe');
        expect(find.text('Criança não encontrada.'), findsOneWidget);
        expect(t.takeException(), isNull);
      },
    );
  });

  group('360 dp com fonte 1,3x: sem overflow', () {
    for (final escala in [1.3, 2.0]) {
      testWidgets('lista de crianças (mock) em ${escala}x', (t) async {
        await _ir(t, const ListaCriancasScreen(), escala: escala);
        expect(t.takeException(), isNull);
      });

      testWidgets('lista com nome muito longo em ${escala}x', (t) async {
        await Repositorios.criancas.cadastrar(_longa());
        await _ir(
          t,
          const ListaCriancasScreen(),
          escala: escala,
          dp: const Size(360, 4000),
        );
        expect(
          find.textContaining('Maria Joaquina de Lima Santos'),
          findsWidgets,
        );
        expect(t.takeException(), isNull);
      });

      testWidgets('histórico (mock) em ${escala}x', (t) async {
        await _ir(t, const HistoricoScreen(), escala: escala);
        expect(t.takeException(), isNull);
      });

      testWidgets('histórico com nome longo em ${escala}x', (t) async {
        await Repositorios.criancas.cadastrar(_longa());
        await Repositorios.avaliacoes.registrar(
          _avLonga(DateTime(2026, 5, 20)),
        );
        await _ir(t, const HistoricoScreen(), escala: escala);
        expect(t.takeException(), isNull);
      });

      testWidgets('dados da criança (destaque) em ${escala}x', (t) async {
        await _ir(t, const DadosCriancaScreen(), escala: escala);
        expect(t.takeException(), isNull);
      });

      testWidgets('dados da criança com dados longos em ${escala}x', (t) async {
        await Repositorios.criancas.cadastrar(_longa());
        await Repositorios.avaliacoes.registrar(
          _avLonga(DateTime(2026, 5, 20)),
        );
        await _ir(
          t,
          const DadosCriancaScreen(),
          args: 'longa1',
          escala: escala,
        );
        expect(t.takeException(), isNull);
      });

      testWidgets(
        'dados da criança sem avaliação nem nascimento em ${escala}x',
        (t) async {
          await Repositorios.criancas.cadastrar(
            Crianca(
              id: 'z',
              nome: _nomeLongo,
              sexo: Sexo.masculino,
              bairro: '',
              cadastradoEm: DateTime(2026, 1, 10),
            ),
          );
          await _ir(t, const DadosCriancaScreen(), args: 'z', escala: escala);
          expect(t.takeException(), isNull);
        },
      );

      testWidgets('curva de crescimento (destaque) em ${escala}x', (t) async {
        await _ir(t, const CurvaCrescimentoScreen(), escala: escala);
        expect(t.takeException(), isNull);
      });

      testWidgets('curva com criança de nome longo em ${escala}x', (t) async {
        await Repositorios.criancas.cadastrar(_longa());
        await Repositorios.avaliacoes.registrar(
          _avLonga(DateTime(2026, 5, 20)),
        );
        await _ir(
          t,
          const CurvaCrescimentoScreen(),
          args: 'longa1',
          escala: escala,
        );
        expect(t.takeException(), isNull);
      });
    }
  });
}
