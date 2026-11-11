import 'package:flutter_test/flutter_test.dart';

import 'package:appnutrimirim/data/mock_data.dart';

void main() {
  group('MockData.todasCriancas', () {
    test('ids são únicos e não vazios', () {
      final ids = MockData.todasCriancas.map((c) => c.id).toList();
      expect(ids.every((i) => i.isNotEmpty), isTrue);
      expect(ids.toSet().length, ids.length);
    });

    test('inclui a criança em destaque e as da lista', () {
      final ids = MockData.todasCriancas.map((c) => c.id).toSet();
      expect(ids, contains(MockData.criancaDestaque.id));
      expect(ids, containsAll(MockData.criancas.map((c) => c.id)));
    });
  });

  group('MockData.criancaPorId', () {
    test('acha a criança pelo id', () {
      final c = MockData.criancaPorId(MockData.criancaDestaque.id);
      expect(c, same(MockData.criancaDestaque));
    });

    test('id inexistente ou vazio retorna null', () {
      expect(MockData.criancaPorId('nao-existe'), isNull);
      expect(MockData.criancaPorId(''), isNull);
    });

    test('nomes parecidos não se misturam (busca por id)', () {
      final feitosas = MockData.todasCriancas
          .where((c) => c.nome.endsWith('Feitosa'))
          .toList();
      expect(feitosas.length, greaterThanOrEqualTo(2));
      for (final c in feitosas) {
        expect(MockData.criancaPorId(c.id)!.nome, c.nome);
        expect(MockData.criancaPorId(c.id)!.id, c.id);
      }
    });
  });

  group('Avaliações', () {
    test('toda criancaId aponta para uma criança existente', () {
      final todas = [
        ...MockData.avaliacoes,
        ...MockData.avaliacoesDe(MockData.criancaDestaque.id),
      ];
      expect(todas, isNotEmpty);
      for (final a in todas) {
        expect(
          MockData.criancaPorId(a.criancaId),
          isNotNull,
          reason: 'criancaId ${a.criancaId} órfã',
        );
      }
    });

    test(
      'avaliacoesDe traz só as da criança, da mais recente à mais antiga',
      () {
        for (final c in MockData.todasCriancas) {
          final lista = MockData.avaliacoesDe(c.id);
          expect(lista.every((a) => a.criancaId == c.id), isTrue);
          for (var i = 1; i < lista.length; i++) {
            expect(lista[i - 1].data.isBefore(lista[i].data), isFalse);
          }
        }
      },
    );

    test('avaliacoesDe da criança em destaque inclui a avaliação dela', () {
      expect(MockData.avaliacoesDe(MockData.criancaDestaque.id), isNotEmpty);
    });

    test('ultimaAvaliacaoDe é a primeira de avaliacoesDe', () {
      for (final c in MockData.todasCriancas) {
        final lista = MockData.avaliacoesDe(c.id);
        final ultima = MockData.ultimaAvaliacaoDe(c.id);
        if (lista.isEmpty) {
          expect(ultima, isNull);
        } else {
          expect(ultima, same(lista.first));
        }
      }
    });

    test('id inexistente: lista vazia e última nula', () {
      expect(MockData.avaliacoesDe('nao-existe'), isEmpty);
      expect(MockData.ultimaAvaliacaoDe('nao-existe'), isNull);
    });

    test('avaliações de crianças com nome parecido não se misturam', () {
      final talita = MockData.todasCriancas.firstWhere(
        (c) => c.nome == 'Talita Feitosa',
      );
      final vinicius = MockData.todasCriancas.firstWhere(
        (c) => c.nome == 'Vinicius Feitosa',
      );
      expect(MockData.ultimaAvaliacaoDe(talita.id)!.criancaId, talita.id);
      expect(MockData.ultimaAvaliacaoDe(vinicius.id)!.criancaId, vinicius.id);
      expect(
        MockData.ultimaAvaliacaoDe(talita.id),
        isNot(same(MockData.ultimaAvaliacaoDe(vinicius.id))),
      );
    });
  });
}
