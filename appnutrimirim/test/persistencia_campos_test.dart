import 'package:appnutrimirim/data/models.dart';
import 'package:appnutrimirim/repositories/firestore/conversoes.dart';
import 'package:appnutrimirim/repositories/repositorios.dart';
import 'package:appnutrimirim/services/antropometria_oms.dart';
import 'package:appnutrimirim/services/zscore_avaliacao.dart';
import 'package:flutter_test/flutter_test.dart';

import 'antropometria_oms_test.dart' show lerTabelas;

void main() {
  final crianca = Crianca(
    id: 'crianca',
    nome: 'Criança Teste',
    sexo: Sexo.masculino,
    bairro: 'Centro',
    nascimento: DateTime(2025, 1, 1),
    cadastradoEm: DateTime(2026, 1, 1),
    cpf: '111.444.777-35',
  );
  final avaliacao = Avaliacao(
    criancaId: crianca.id,
    data: DateTime(2026, 5, 16),
    pesoKg: 10.25,
    alturaCm: 75,
    situacao: Situacao.abaixo,
    edema: true,
    tipoMedida: 'deitado',
    desnutricao: true,
    indicadores: const {
      'ei': Indicador('Estatura para idade', -1, Situacao.normal),
    },
  );

  tearDown(Repositorios.reiniciar);

  test('CPF da criança e edema sobrevivem à conversão Firestore', () {
    final mapaCrianca = criancaParaMap(crianca, ubsId: 'ubs-a');
    expect(mapaCrianca['cpf'], '11144477735');
    expect(criancaDeMap(crianca.id, mapaCrianca).cpf, '11144477735');
    final mapaAvaliacao = avaliacaoParaMap(
      avaliacao,
      ubsId: 'ubs-a',
      profissionalId: 'autor',
      profissionalNome: 'Autor Teste',
    );
    final restaurada = avaliacaoDeMap('a', mapaAvaliacao);
    expect(restaurada.edema, isTrue);
    expect(restaurada.pesoKg, 10.25);
    expect(restaurada.tipoMedida, 'deitado');
    expect(restaurada.indicadores.keys, ['ei']);
    expect(
      avaliacaoDeMap('antiga', {...mapaAvaliacao}..remove('edema')).edema,
      isNull,
    );
  });

  test(
    'correção persiste ausência de edema sem manter o valor anterior',
    () async {
      final banco = Repositorios.usarMemoria(
        comMock: false,
        agora: () => DateTime(2026, 6, 1),
      );
      await Repositorios.criancas.cadastrar(crianca);
      final salva = await Repositorios.avaliacoes.registrar(avaliacao);
      await Repositorios.avaliacoes.corrigir(
        salva.copyWith(edema: false),
        motivo: 'Conferência dos pés',
      );
      expect(banco.avaliacoes[salva.id]!.edema, isFalse);
      expect(banco.alteracoes.single.motivo, 'Conferência dos pés');
    },
  );

  test('curva não recalcula indicadores de peso indisponíveis por edema', () {
    final tabelas = lerTabelas();
    for (final i in [
      IndicadorOms.pesoIdade,
      IndicadorOms.pesoAltura,
      IndicadorOms.imcIdade,
    ]) {
      expect(zScoreDaAvaliacao(tabelas, crianca, avaliacao, i), isNull);
    }
    expect(
      zScoreDaAvaliacao(tabelas, crianca, avaliacao, IndicadorOms.alturaIdade),
      -1,
    );
  });
}
