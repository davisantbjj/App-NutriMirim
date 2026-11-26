import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/repositories/firestore/conversoes.dart';
import 'package:appnutrimirim/utils/texto.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter_test/flutter_test.dart';

// Lacunas das conversões Firestore: datas de borda, nulos, CPF/telefone,
// enums desconhecidos e indicadores ausentes/parciais.

Crianca _crianca({DateTime? nascimento, Responsavel? responsavel}) => Crianca(
  id: 'c1',
  nome: 'Maria Souza',
  sexo: Sexo.feminino,
  bairro: 'Centro',
  cadastradoEm: DateTime(2026, 1, 10),
  nascimento: nascimento,
  responsavel: responsavel,
);

Responsavel _resp({String cpf = '', String tel = '', String email = ''}) =>
    Responsavel(nome: 'Mãe', cpfMascarado: cpf, telefone: tel, email: email);

void main() {
  group('datas aaaa-mm-dd em bordas', () {
    test('31/12 e 01/01 de virada de ano fazem ida e volta', () {
      for (final d in [
        DateTime(2099, 12, 31),
        DateTime(2000, 1, 1),
        DateTime(2025, 12, 31),
        DateTime(2026, 1, 1),
      ]) {
        final t = dataParaTexto(d);
        expect(textoParaData(t), d, reason: t);
      }
      expect(dataParaTexto(DateTime(2025, 12, 31)), '2025-12-31');
    });

    test('29/02 só vale em ano bissexto', () {
      expect(dataParaTexto(DateTime(2024, 2, 29)), '2024-02-29');
      expect(textoParaData('2024-02-29'), DateTime(2024, 2, 29));
      expect(textoParaData('2000-02-29'), DateTime(2000, 2, 29));
      expect(textoParaData('2023-02-29'), isNull);
      expect(textoParaData('2100-02-29'), isNull);
    });

    test('dias e meses fora do calendário viram null', () {
      for (final t in [
        '2026-04-31',
        '2026-06-31',
        '2026-13-01',
        '2026-00-10',
        '2026-01-00',
        '2026-01-32',
      ]) {
        expect(textoParaData(t), isNull, reason: t);
      }
    });

    test('formato fora do padrão (espaços, barras, hora) vira null', () {
      for (final t in [
        ' 2026-01-10',
        '2026-01-10 ',
        '2026-1-10',
        '10/01/2026',
        '2026-01-10T00:00:00',
        '',
      ]) {
        expect(textoParaData(t), isNull, reason: '"$t"');
      }
      expect(textoParaData(null), isNull);
      expect(textoParaData(20260110), isNull);
    });

    test('hora do dia é ignorada ao gravar (só o dia)', () {
      expect(dataParaTexto(DateTime(2026, 3, 5, 23, 59, 59)), '2026-03-05');
      expect(dataParaTexto(DateTime(2026, 3, 5, 0, 0, 1)), '2026-03-05');
    });

    test(
      'ano fora de 2000-2099 é lido sem validar (a validação fica nas regras)',
      () {
        // Documenta o comportamento: textoParaData não impõe a faixa do
        // Firestore (2000-2099); quem valida é validarCrianca/regras.
        expect(textoParaData('1999-12-31'), DateTime(1999, 12, 31));
        expect(dataParaTexto(DateTime(1999, 12, 31)), '1999-12-31');
      },
    );
  });

  group('nascimento e responsável nulos', () {
    test('nascimento nulo: grava null e lê de volta null', () {
      final m = criancaParaMap(_crianca(), ubsId: 'u1');
      expect(m.containsKey('nascimento'), isTrue, reason: 'null explícito');
      expect(m['nascimento'], isNull);
      expect(criancaDeMap('c1', m).nascimento, isNull);
    });

    test('nascimento ausente, vazio ou inválido no documento vira null', () {
      for (final d in <Map<String, Object?>>[
        {'nome': 'A'},
        {'nome': 'A', 'nascimento': ''},
        {'nome': 'A', 'nascimento': '2026-02-30'},
        {'nome': 'A', 'nascimento': 123},
      ]) {
        expect(criancaDeMap('c1', d).nascimento, isNull, reason: '$d');
      }
    });

    test('responsável nulo: grava null e lê de volta null', () {
      final m = criancaParaMap(_crianca(), ubsId: 'u1');
      expect(m['responsavel'], isNull);
      expect(criancaDeMap('c1', m).responsavel, isNull);
    });

    test('responsável com outro tipo no documento vira null', () {
      expect(responsavelDeMap('texto'), isNull);
      expect(responsavelDeMap(42), isNull);
      expect(responsavelDeMap(null), isNull);
    });

    test('responsável sem nome nem contatos lê com textos vazios', () {
      final r = responsavelDeMap(<String, Object?>{})!;
      expect(r.nome, '');
      expect(r.cpfMascarado, '');
      expect(r.telefone, '');
      expect(r.email, '');
    });

    test('edição: responsável nulo apaga o anterior (grava null)', () {
      final m = criancaEditavelParaMap(
        _crianca(),
        anterior: {
          'responsavel': {'nome': 'Mãe', 'cpf': '85712345654'},
        },
      );
      expect(m['responsavel'], isNull);
    });

    test('edição: nascimento nulo grava null (apaga)', () {
      final m = criancaEditavelParaMap(_crianca(nascimento: null));
      expect(m['nascimento'], isNull);
    });
  });

  group('CPF e telefone', () {
    test('CPF mascarado de privacidade (***) não é gravado', () {
      final m = responsavelParaMap(_resp(cpf: '***.123.456-**'));
      expect(m.containsKey('cpf'), isFalse);
      expect(m, {'nome': 'Mãe'});
    });

    test('CPF com 11 dígitos é gravado sem máscara', () {
      expect(
        responsavelParaMap(_resp(cpf: '857.123.456-54'))['cpf'],
        '85712345654',
      );
      expect(
        responsavelParaMap(_resp(cpf: '85712345654'))['cpf'],
        '85712345654',
      );
    });

    test('CPF com 10 ou 12 dígitos não é gravado', () {
      expect(
        responsavelParaMap(_resp(cpf: '1234567890')).containsKey('cpf'),
        isFalse,
      );
      expect(
        responsavelParaMap(_resp(cpf: '123456789012')).containsKey('cpf'),
        isFalse,
      );
    });

    test('telefone de 10 e de 11 dígitos é gravado só com dígitos', () {
      expect(
        responsavelParaMap(_resp(tel: '(11) 3456-7890'))['telefone'],
        '1134567890',
      );
      expect(
        responsavelParaMap(_resp(tel: '(11) 98765-4321'))['telefone'],
        '11987654321',
      );
    });

    test('telefone com 9 ou 12 dígitos não é gravado', () {
      expect(
        responsavelParaMap(_resp(tel: '987654321')).containsKey('telefone'),
        isFalse,
      );
      expect(
        responsavelParaMap(_resp(tel: '119876543210')).containsKey('telefone'),
        isFalse,
      );
    });

    test('telefone de 10 e 11 dígitos faz ida e volta pelos dígitos', () {
      for (final tel in ['1134567890', '11987654321']) {
        final lido = responsavelDeMap({'nome': 'Mãe', 'telefone': tel})!;
        expect(somenteDigitos(lido.telefone), tel);
        final regravado = responsavelParaMap(lido);
        expect(regravado['telefone'], tel);
      }
    });

    test('CPF lido e regravado não muda (ida e volta)', () {
      final lido = responsavelDeMap({'nome': 'Mãe', 'cpf': '85712345654'})!;
      expect(lido.cpfMascarado, '857.123.456-54');
      expect(responsavelParaMap(lido)['cpf'], '85712345654');
    });

    test(
      'CPF com tamanho errado no documento é lido sem máscara e não quebra',
      () {
        final lido = responsavelDeMap({'nome': 'Mãe', 'cpf': '123'})!;
        expect(lido.cpfMascarado, '123');
        expect(formatarCpfDigitos('123'), '123');
      },
    );

    test('CPF/telefone não-texto no documento são ignorados', () {
      final lido = responsavelDeMap({
        'nome': 'Mãe',
        'cpf': 85712345654,
        'telefone': 11987654321,
      })!;
      expect(lido.cpfMascarado, '');
      expect(lido.telefone, '');
    });

    test('edição com CPF mascarado preserva o antigo; sem antigo, omite', () {
      final r = _resp(cpf: '***.123.456-**');
      expect(
        responsavelParaMap(r, anterior: {'cpf': '85712345654'})['cpf'],
        '85712345654',
      );
      expect(
        responsavelParaMap(r, anterior: {'cpf': '123'}).containsKey('cpf'),
        isFalse,
        reason: 'antigo inválido não é preservado',
      );
    });

    test('e-mail só com espaços some; nome é aparado', () {
      final m = responsavelParaMap(
        Responsavel(
          nome: '  Mãe  ',
          cpfMascarado: '',
          telefone: '',
          email: '   ',
        ),
      );
      expect(m, {'nome': 'Mãe'});
    });
  });

  group('enums desconhecidos na leitura (comportamento documentado)', () {
    // A leitura NUNCA lança: valor desconhecido, ausente ou de outro tipo cai
    // num padrão silencioso (sexo=feminino, situação=normal). Isso evita tela
    // quebrada com documento corrompido, mas esconde o dado ruim: uma
    // avaliação de risco com `situacao` inválida aparece como "normal".
    test('sexo desconhecido, ausente ou de outro tipo vira feminino', () {
      expect(sexoDeTexto('outro'), Sexo.feminino);
      expect(sexoDeTexto(null), Sexo.feminino);
      expect(sexoDeTexto(1), Sexo.feminino);
      expect(
        sexoDeTexto('MASCULINO'),
        Sexo.feminino,
        reason: 'diferencia caixa',
      );
      expect(sexoDeTexto('masculino'), Sexo.masculino);
    });

    test('situação desconhecida ou ausente vira normal', () {
      expect(situacaoDeTexto('critico'), Situacao.normal);
      expect(situacaoDeTexto(null), Situacao.normal);
      expect(
        situacaoDeTexto('Risco'),
        Situacao.normal,
        reason: 'diferencia caixa',
      );
      for (final s in Situacao.values) {
        expect(situacaoDeTexto(s.name), s);
      }
    });

    test('criança e avaliação com enums inválidos são lidas sem exceção', () {
      final c = criancaDeMap('c1', {'nome': 'A', 'sexo': '??'});
      expect(c.sexo, Sexo.feminino);
      final a = avaliacaoDeMap('a1', {'situacao': 'xyz'});
      expect(a.situacao, Situacao.normal);
    });

    test('indicador com situação inválida lê como normal', () {
      final m = indicadoresDeMap({
        'pi': {'zScore': -3.5, 'situacao': 'xyz'},
      });
      expect(m['pi']!.situacao, Situacao.normal);
      expect(m['pi']!.zScore, -3.5);
    });
  });

  group('indicadores ausentes e parciais', () {
    test('nulo, vazio ou de outro tipo: mapa vazio', () {
      expect(indicadoresDeMap(null), isEmpty);
      expect(indicadoresDeMap(<String, Object?>{}), isEmpty);
      expect(indicadoresDeMap('x'), isEmpty);
      expect(indicadoresDeMap([1, 2]), isEmpty);
    });

    test('só um indicador presente: só ele volta, com nome por extenso', () {
      final m = indicadoresDeMap({
        'pe': {'zScore': 1, 'situacao': 'atencao'},
      });
      expect(m.keys, ['pe']);
      expect(m['pe']!.nome, 'Peso para estatura (P/E)');
      expect(m['pe']!.zScore, 1.0);
    });

    test('indicador sem zScore/situacao lê como 0 e normal', () {
      final m = indicadoresDeMap({'ei': <String, Object?>{}});
      expect(m['ei']!.zScore, 0);
      expect(m['ei']!.situacao, Situacao.normal);
    });

    test('indicador nulo ou com tipo errado é pulado', () {
      final m = indicadoresDeMap({
        'pi': null,
        'ei': 'x',
        'pe': 5,
        'imci': {'situacao': 'risco'},
      });
      expect(m.keys, ['imci']);
      expect(m['imci']!.zScore, 0);
      expect(m['imci']!.situacao, Situacao.risco);
    });

    test('zScore de tipo errado no documento não deveria lançar', () {
      final m = indicadoresDeMap({
        'pi': {'zScore': 'abc', 'situacao': 'risco'},
      });
      expect(m['pi']!.zScore, 0);
    });

    test('ordem de saída segue pi, ei, pe, imci independente do documento', () {
      final m = indicadoresDeMap({
        'imci': {'zScore': 0, 'situacao': 'normal'},
        'pi': {'zScore': 0, 'situacao': 'normal'},
      });
      expect(m.keys.toList(), ['pi', 'imci']);
    });

    test(
      'ao gravar, mapa vazio vira mapa vazio e parcial mantém só as chaves',
      () {
        expect(indicadoresParaMap(const {}), isEmpty);
        final m = indicadoresParaMap({
          'ei': const Indicador('E/I', -2.1, Situacao.risco),
        });
        expect(m, {
          'ei': {'zScore': -2.1, 'situacao': 'risco'},
        });
      },
    );

    test('avaliação sem nenhum campo lê com padrões e sem exceção', () {
      final a = avaliacaoDeMap('a1', <String, Object?>{});
      expect(a.id, 'a1');
      expect(a.criancaId, '');
      expect(a.indicadores, isEmpty);
      expect(a.pesoKg, 0);
      expect(a.alturaCm, 0);
      expect(a.desnutricao, isFalse);
      expect(a.excluida, isFalse);
      expect(a.criadoEm, isNull);
      expect(a.retornoSugerido, isNull);
      expect(a.versaoTabelaOms, 'oms-2006');
      expect(a.profissionalId, isNull);
    });

    test(
      'data da avaliação não-Timestamp cai em 2000-01-01; Timestamp é lido',
      () {
        expect(
          avaliacaoDeMap('a', {'data': '2026-01-01'}).data,
          DateTime(2000),
        );
        final d = DateTime(2026, 5, 10, 14, 30);
        expect(avaliacaoDeMap('a', {'data': Timestamp.fromDate(d)}).data, d);
      },
    );

    test(
      'avaliacaoParaMap com indicadores vazios mantém a chave (regras exigem ao menos um)',
      () {
        final a = Avaliacao(
          criancaId: 'c1',
          data: DateTime(2026, 5, 10),
          pesoKg: 12,
          alturaCm: 85,
          situacao: Situacao.normal,
        );
        final m = avaliacaoParaMap(
          a,
          ubsId: 'u1',
          profissionalId: 'p1',
          profissionalNome: 'Ana',
        );
        expect(m['indicadores'], isEmpty);
      },
    );

    test('microarea vazia ou nula fica de fora da criação', () {
      final a = Avaliacao(
        criancaId: 'c1',
        data: DateTime(2026, 5, 10),
        pesoKg: 12,
        alturaCm: 85,
        situacao: Situacao.normal,
      );
      for (final micro in [null, '']) {
        final m = avaliacaoParaMap(
          a,
          ubsId: 'u1',
          profissionalId: 'p1',
          profissionalNome: 'Ana',
          microarea: micro,
        );
        expect(m.containsKey('microarea'), isFalse);
      }
    });

    test('retornoSugerido em 31/12 e 29/02 faz ida e volta', () {
      for (final r in [DateTime(2026, 12, 31), DateTime(2028, 2, 29)]) {
        final a = Avaliacao(
          criancaId: 'c1',
          data: DateTime(2026, 5, 10),
          pesoKg: 12,
          alturaCm: 85,
          situacao: Situacao.normal,
          retornoSugerido: r,
        );
        final m = avaliacaoParaMap(
          a,
          ubsId: 'u1',
          profissionalId: 'p1',
          profissionalNome: 'Ana',
        );
        expect(avaliacaoDeMap('a', m).retornoSugerido, r);
      }
    });
  });
}
