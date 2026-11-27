import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/repositories/firestore/conversoes.dart';
import 'package:appnutrimirim/repositories/sessao_profissional.dart';
import 'package:appnutrimirim/utils/texto.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter_test/flutter_test.dart';

Crianca _crianca({Responsavel? responsavel, DateTime? nascimento}) => Crianca(
  id: 'k1',
  nome: '  Larissa Mendonça ',
  sexo: Sexo.feminino,
  bairro: 'Rosa Maria',
  endereco: 'Rua A, 10',
  cadastradoEm: DateTime(2025, 1, 10),
  nascimento: nascimento,
  responsavel: responsavel,
);

void main() {
  group('datas sem hora', () {
    test('dataParaTexto usa o dia local, sem virar o dia anterior', () {
      expect(dataParaTexto(DateTime(2025, 1, 10)), '2025-01-10');
      expect(dataParaTexto(DateTime(2024, 12, 31, 23, 59)), '2024-12-31');
      expect(dataParaTexto(DateTime(2025, 3, 5, 12)), '2025-03-05');
    });
    test('textoParaData monta DateTime local à meia-noite', () {
      final d = textoParaData('2025-01-10')!;
      expect(d, DateTime(2025, 1, 10));
      expect(d.isUtc, isFalse);
      expect(d.hour, 0);
    });
    test('ida e volta preserva o dia', () {
      for (final d in [DateTime(2024, 2, 29), DateTime(2026, 11, 1)]) {
        expect(textoParaData(dataParaTexto(d)), d);
      }
    });
    test('valores inválidos viram null', () {
      expect(textoParaData(null), isNull);
      expect(textoParaData(''), isNull);
      expect(textoParaData('10/01/2025'), isNull);
      expect(textoParaData('2025-02-31'), isNull);
      expect(textoParaData(5), isNull);
    });
  });

  group('responsável: CPF e telefone só dígitos', () {
    test('grava apenas dígitos', () {
      final m = responsavelParaMap(
        const Responsavel(
          nome: ' Joana ',
          cpfMascarado: '529.982.247-25',
          telefone: '(79) 91234-5678',
          email: ' a@b.com ',
        ),
      );
      expect(m, {
        'nome': 'Joana',
        'cpf': '52998224725',
        'telefone': '79912345678',
        'email': 'a@b.com',
      });
    });
    test('CPF mascarado com * não é gravado; vazios somem', () {
      final m = responsavelParaMap(
        const Responsavel(
          nome: 'Joana',
          cpfMascarado: '857.***.***-54',
          telefone: '',
          email: '',
        ),
      );
      expect(m, {'nome': 'Joana'});
    });
    test('telefone fora de 10 ou 11 dígitos não é gravado', () {
      final m = responsavelParaMap(
        const Responsavel(
          nome: 'Joana',
          cpfMascarado: '',
          telefone: '(79) 1234',
          email: '',
        ),
      );
      expect(m.containsKey('telefone'), isFalse);
    });
    test('na edição, só valores mascarados com * preservam o antigo', () {
      final m = responsavelParaMap(
        const Responsavel(
          nome: 'Joana',
          cpfMascarado: '857.***.***-54',
          telefone: '(79) 9****-**78',
          email: '',
        ),
        anterior: {'cpf': '52998224725', 'telefone': '7933334444'},
      );
      expect(m['cpf'], '52998224725');
      expect(m['telefone'], '7933334444');
    });
    test('campo vazio na edição apaga o valor antigo', () {
      final m = responsavelParaMap(
        const Responsavel(
          nome: 'Joana',
          cpfMascarado: '',
          telefone: '',
          email: '',
        ),
        anterior: {'cpf': '52998224725', 'telefone': '7933334444'},
      );
      expect(m, {'nome': 'Joana'});
    });
    test('leitura monta CPF e telefone com máscara', () {
      final r = responsavelDeMap({
        'nome': 'Joana',
        'cpf': '52998224725',
        'telefone': '79912345678',
      })!;
      expect(r.cpfMascarado, '529.982.247-25');
      expect(r.telefone, '(79) 91234-5678');
      expect(r.email, '');
      expect(responsavelDeMap(null), isNull);
    });
  });

  group('criança', () {
    test('criancaParaMap: nomeBusca, enum por .name, datas texto', () {
      final m = criancaParaMap(
        _crianca(nascimento: DateTime(2024, 8, 15)),
        ubsId: 'ubs-1',
      );
      expect(m['ubsId'], 'ubs-1');
      expect(m['nome'], 'Larissa Mendonça');
      expect(m['nomeBusca'], 'larissa mendonca');
      expect(m['nomeBusca'], normalizarBusca('Larissa Mendonça'));
      expect(m['sexo'], 'feminino');
      expect(m['nascimento'], '2024-08-15');
      expect(m['cadastradoEm'], '2025-01-10');
      expect(m['ativa'], isTrue);
      expect(m['responsavel'], isNull);
      expect(m.containsKey('id'), isFalse);
    });
    test('nascimento nulo vira null (Não informado)', () {
      expect(criancaParaMap(_crianca(), ubsId: 'u')['nascimento'], isNull);
    });
    test('criancaDeMap: ida e volta e nome da UBS', () {
      final original = _crianca(
        nascimento: DateTime(2024, 8, 15),
        responsavel: const Responsavel(
          nome: 'Joana',
          cpfMascarado: '529.982.247-25',
          telefone: '(79) 91234-5678',
          email: 'j@x.com',
        ),
      );
      final c = criancaDeMap(
        'k1',
        criancaParaMap(original, ubsId: 'ubs-1'),
        nomesUbs: {'ubs-1': 'UBS Jardim das Flores'},
      );
      expect(c.id, 'k1');
      expect(c.nome, 'Larissa Mendonça');
      expect(c.sexo, Sexo.feminino);
      expect(c.nascimento, DateTime(2024, 8, 15));
      expect(c.cadastradoEm, DateTime(2025, 1, 10));
      expect(c.ubs, 'UBS Jardim das Flores');
      expect(c.ativa, isTrue);
      expect(c.responsavel!.cpfMascarado, '529.982.247-25');
      expect(c.responsavel!.telefone, '(79) 91234-5678');
      expect(c.responsavel!.email, 'j@x.com');
    });
    test('UBS sem nome conhecido mostra o id; ativa false é lido', () {
      final c = criancaDeMap('k', {
        'ubsId': 'ubs-9',
        'nome': 'X Y',
        'sexo': 'masculino',
        'cadastradoEm': '2025-01-10',
        'ativa': false,
      });
      expect(c.ubs, 'ubs-9');
      expect(c.ativa, isFalse);
      expect(c.sexo, Sexo.masculino);
    });
  });

  group('avaliação e indicadores pi/ei/pe/imci', () {
    final indicadores = {
      'pi': const Indicador('x', -0.5, Situacao.normal),
      'ei': const Indicador('x', -2.3, Situacao.risco),
      'pe': const Indicador('x', 0.1, Situacao.normal),
      'imci': const Indicador('x', -3.2, Situacao.abaixo),
    };

    test('indicadoresParaMap grava {zScore, situacao} por chave', () {
      final m = indicadoresParaMap(indicadores);
      expect(m.keys, ['pi', 'ei', 'pe', 'imci']);
      expect(m['ei'], {'zScore': -2.3, 'situacao': 'risco'});
      expect(m['imci'], {'zScore': -3.2, 'situacao': 'abaixo'});
    });
    test('indicadoresDeMap lê e dá o nome por extenso', () {
      final lidos = indicadoresDeMap(indicadoresParaMap(indicadores));
      expect(lidos.keys, ['pi', 'ei', 'pe', 'imci']);
      expect(lidos['pi']!.nome, 'Peso para idade (P/I)');
      expect(lidos['imci']!.nome, 'IMC para idade (IMC/I)');
      expect(lidos['ei']!.zScore, -2.3);
      expect(lidos['imci']!.situacao, Situacao.abaixo);
    });
    test('indicadoresDeMap ignora chaves estranhas, aceita int e nulo', () {
      final lidos = indicadoresDeMap({
        'pi': {'zScore': 1, 'situacao': 'normal'},
        'lixo': {'zScore': 1, 'situacao': 'normal'},
      });
      expect(lidos.keys, ['pi']);
      expect(lidos['pi']!.zScore, 1.0);
      expect(indicadoresDeMap(null), isEmpty);
    });

    final avaliacao = Avaliacao(
      criancaId: 'k1',
      data: DateTime(2026, 11, 11, 9, 30),
      pesoKg: 12.5,
      alturaCm: 90,
      situacao: Situacao.atencao,
      tipoMedida: 'em_pe',
      indicadores: indicadores,
      desnutricao: true,
      retornoSugerido: DateTime(2026, 12, 11),
    );

    test('avaliacaoParaMap: tipos e campos do Firestore', () {
      final m = avaliacaoParaMap(
        avaliacao,
        ubsId: 'ubs-1',
        profissionalId: 'uid1',
        profissionalNome: 'Ana Souza',
        microarea: '03',
      );
      expect(m['ubsId'], 'ubs-1');
      expect(m['criancaId'], 'k1');
      expect(m['profissionalId'], 'uid1');
      expect(m['profissionalNome'], 'Ana Souza');
      expect(m['microarea'], '03');
      expect(m['data'], isA<Timestamp>());
      expect((m['data'] as Timestamp).toDate(), DateTime(2026, 11, 11, 9, 30));
      expect(m['pesoKg'], 12.5);
      expect(m['alturaCm'], 90.0);
      expect(m['tipoMedida'], 'em_pe');
      expect(m['situacao'], 'atencao');
      expect(m['desnutricao'], isTrue);
      expect(m['versaoTabelaOms'], 'oms-2006');
      expect(m['retornoSugerido'], '2026-12-11');
      expect(m['excluida'], isFalse);
      expect(m.containsKey('id'), isFalse);
    });
    test('campos opcionais nulos ficam de fora na criação', () {
      final m = avaliacaoParaMap(
        avaliacao.copyWith(limparTipoMedida: true, limparRetornoSugerido: true),
        ubsId: 'u',
        profissionalId: 'p',
        profissionalNome: 'Ana Souza',
      );
      expect(m.containsKey('tipoMedida'), isFalse);
      expect(m.containsKey('retornoSugerido'), isFalse);
      expect(m.containsKey('microarea'), isFalse);
    });
    test('na correção os opcionais nulos viram null (apagam o valor)', () {
      final m = avaliacaoCorrigivelParaMap(
        avaliacao.copyWith(limparTipoMedida: true),
      );
      expect(m.containsKey('tipoMedida'), isTrue);
      expect(m['tipoMedida'], isNull);
      expect(m.keys, containsAll(['data', 'pesoKg', 'alturaCm', 'situacao']));
      expect(m.containsKey('excluida'), isFalse);
      expect(m.containsKey('criancaId'), isFalse);
    });
    test('papel do autor: gravado pelo nome e lido de volta', () {
      final m = avaliacaoParaMap(
        avaliacao,
        ubsId: 'u',
        profissionalId: 'p',
        profissionalNome: 'Ana Souza',
        profissionalPapel: PapelProfissional.acs,
      );
      expect(m['profissionalPapel'], 'acs');
      expect(avaliacaoDeMap('a', m).profissionalPapel, PapelProfissional.acs);
    });
    test('papel do autor ausente ou desconhecido fica nulo', () {
      final m = avaliacaoParaMap(
        avaliacao,
        ubsId: 'u',
        profissionalId: 'p',
        profissionalNome: 'Ana Souza',
      );
      expect(m.containsKey('profissionalPapel'), isFalse);
      expect(avaliacaoDeMap('a', m).profissionalPapel, isNull);
      expect(
        avaliacaoDeMap('a', {
          ...m,
          'profissionalPapel': 'chefe',
        }).profissionalPapel,
        isNull,
      );
    });
    test('avaliacaoDeMap: ida e volta', () {
      final m = avaliacaoParaMap(
        avaliacao,
        ubsId: 'ubs-1',
        profissionalId: 'uid1',
        profissionalNome: 'Ana Souza',
      )..['criadoEm'] = Timestamp.fromDate(DateTime(2026, 11, 11, 9, 31));
      final a = avaliacaoDeMap('av1', m);
      expect(a.id, 'av1');
      expect(a.criancaId, 'k1');
      expect(a.data, DateTime(2026, 11, 11, 9, 30));
      expect(a.criadoEm, DateTime(2026, 11, 11, 9, 31));
      expect(a.pesoKg, 12.5);
      expect(a.alturaCm, 90);
      expect(a.situacao, Situacao.atencao);
      expect(a.profissionalId, 'uid1');
      expect(a.profissionalNome, 'Ana Souza');
      expect(a.tipoMedida, 'em_pe');
      expect(a.indicadores.keys, ['pi', 'ei', 'pe', 'imci']);
      expect(a.desnutricao, isTrue);
      expect(a.versaoTabelaOms, 'oms-2006');
      expect(a.retornoSugerido, DateTime(2026, 12, 11));
      expect(a.excluida, isFalse);
    });
    test('criadoEm pendente (null) e números inteiros são tolerados', () {
      final a = avaliacaoDeMap('x', {
        'criancaId': 'k1',
        'data': Timestamp.fromDate(DateTime(2026, 1, 2)),
        'pesoKg': 12,
        'alturaCm': 90,
        'situacao': 'normal',
        'criadoEm': null,
      });
      expect(a.criadoEm, isNull);
      expect(a.pesoKg, 12.0);
      expect(a.excluida, isFalse);
    });
  });
}
