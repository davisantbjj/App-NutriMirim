import 'package:appnutrimirim/services/classificacao.dart';
import 'package:flutter_test/flutter_test.dart';

const pi = IndicadorAntropometrico.pesoIdade;
const ei = IndicadorAntropometrico.estaturaIdade;
const pe = IndicadorAntropometrico.pesoEstatura;
const imc = IndicadorAntropometrico.imcIdade;

void main() {
  group('classificarIndicador (RF04, pontos de corte do SISVAN)', () {
    void espera(
      IndicadorAntropometrico ind,
      double z,
      String diagnostico,
      Gravidade gravidade,
    ) {
      final c = classificarIndicador(ind, z);
      expect(c.diagnostico, diagnostico, reason: '${ind.chave} z=$z');
      expect(c.gravidade, gravidade, reason: '${ind.chave} z=$z');
    }

    test('peso para idade', () {
      espera(pi, -3.01, 'Muito baixo peso para a idade', Gravidade.grave);
      espera(pi, -3, 'Baixo peso para a idade', Gravidade.risco);
      espera(pi, -2.01, 'Baixo peso para a idade', Gravidade.risco);
      espera(pi, -2, 'Peso adequado para a idade', Gravidade.adequado);
      espera(pi, -1.5, 'Peso adequado para a idade', Gravidade.adequado);
      espera(pi, 2, 'Peso adequado para a idade', Gravidade.adequado);
      espera(pi, 2.01, 'Peso elevado para a idade', Gravidade.atencao);
    });

    test('estatura para idade não penaliza estatura alta', () {
      espera(ei, -3.01, 'Muito baixa estatura para a idade', Gravidade.grave);
      espera(ei, -3, 'Baixa estatura para a idade', Gravidade.risco);
      espera(ei, -2, 'Estatura adequada para a idade', Gravidade.adequado);
      espera(ei, 4, 'Estatura adequada para a idade', Gravidade.adequado);
    });

    test('peso para estatura e IMC usam as mesmas faixas', () {
      for (final ind in [pe, imc]) {
        espera(ind, -3.01, 'Magreza acentuada', Gravidade.grave);
        espera(ind, -3, 'Magreza', Gravidade.risco);
        espera(ind, -2, 'Eutrofia', Gravidade.adequado);
        espera(ind, 1, 'Eutrofia', Gravidade.adequado);
        espera(ind, 1.01, 'Risco de sobrepeso', Gravidade.atencao);
        espera(ind, 2, 'Risco de sobrepeso', Gravidade.atencao);
        espera(ind, 2.01, 'Sobrepeso', Gravidade.atencao);
        espera(ind, 3, 'Sobrepeso', Gravidade.atencao);
        espera(ind, 3.01, 'Obesidade', Gravidade.risco);
      }
    });

    test('cor do semáforo', () {
      expect(classificarIndicador(pe, 0).semaforo, Semaforo.verde);
      expect(classificarIndicador(pe, -1.9).semaforo, Semaforo.verde);
      expect(classificarIndicador(pe, 1.5).semaforo, Semaforo.amarelo);
      expect(classificarIndicador(pe, 2.5).semaforo, Semaforo.amarelo);
      expect(classificarIndicador(pe, -2.5).semaforo, Semaforo.vermelho);
      expect(classificarIndicador(pe, -4).semaforo, Semaforo.vermelho);
      expect(classificarIndicador(pe, 4).semaforo, Semaforo.vermelho);
    });

    test('desnutrição aguda grave é só magreza acentuada', () {
      expect(classificarIndicador(pe, -3.5).desnutricaoAgudaGrave, isTrue);
      expect(classificarIndicador(imc, -3.5).desnutricaoAgudaGrave, isTrue);
      expect(classificarIndicador(pi, -3.5).desnutricaoAgudaGrave, isFalse);
      expect(classificarIndicador(ei, -3.5).desnutricaoAgudaGrave, isFalse);
      expect(classificarIndicador(pe, -2.5).desnutricaoAgudaGrave, isFalse);
    });

    test('z-score não finito lança ArgumentError', () {
      expect(() => classificarIndicador(pi, double.nan), throwsArgumentError);
      expect(
        () => classificarIndicador(pi, double.infinity),
        throwsArgumentError,
      );
    });

    test('chaves dos indicadores batem com o Firestore', () {
      expect(IndicadorAntropometrico.values.map((i) => i.chave), [
        'pi',
        'ei',
        'pe',
        'imci',
      ]);
    });
  });

  group('classificarAvaliacao', () {
    test('a classificação geral é a do pior indicador', () {
      final c = classificarAvaliacao({pi: -0.5, ei: -2.4, pe: 0.1});
      expect(c.gravidade, Gravidade.risco);
      expect(c.pior.indicador, ei);
      expect(c.semaforo, Semaforo.vermelho);
      expect(c.desnutricao, isTrue);
    });

    test('no empate de gravidade, o déficit vence o excesso', () {
      final c = classificarAvaliacao({imc: 3.5, pi: -2.5});
      expect(c.gravidade, Gravidade.risco);
      expect(c.pior.desvio, Desvio.deficit);
    });

    test('desnutrição só abaixo de -2; excesso não conta', () {
      expect(classificarAvaliacao({pi: -2}).desnutricao, isFalse);
      expect(classificarAvaliacao({imc: 3.5}).desnutricao, isFalse);
      expect(classificarAvaliacao({pe: -2.01}).desnutricao, isTrue);
    });

    test('mapa vazio lança ArgumentError', () {
      expect(() => classificarAvaliacao({}), throwsArgumentError);
    });

    test('a lista de indicadores não pode ser alterada', () {
      final c = classificarAvaliacao({pi: 0});
      expect(() => c.indicadores.clear(), throwsUnsupportedError);
    });
  });

  group('microCondutas (RF13)', () {
    test('cada faixa tem orientações', () {
      for (final z in [0.0, 1.5, 2.5, 3.5, -2.5, -3.5]) {
        expect(
          microCondutas(classificarAvaliacao({pe: z})),
          isNotEmpty,
          reason: 'z=$z',
        );
      }
    });

    test('magreza acentuada orienta encaminhar no mesmo dia', () {
      final condutas = microCondutas(classificarAvaliacao({pe: -3.5}));
      expect(condutas.first, contains('no mesmo dia'));
    });

    test('muito baixo peso agenda consulta, sem urgência', () {
      final condutas = microCondutas(classificarAvaliacao({pi: -3.5}));
      expect(condutas.first, contains('próximos dias'));
      expect(condutas.join(' '), isNot(contains('mesmo dia')));
    });

    test('déficit pede verificar sinais de perigo (edema)', () {
      final condutas = microCondutas(classificarAvaliacao({ei: -2.5}));
      expect(condutas.join(' '), contains('inchaço nos dois pés'));
    });

    test('excesso e déficit recebem orientações diferentes', () {
      final excesso = microCondutas(classificarAvaliacao({imc: 1.5}));
      final deficit = microCondutas(classificarAvaliacao({imc: -2.5}));
      expect(excesso.join(' '), contains('ultraprocessados'));
      expect(deficit.join(' '), contains('segurança alimentar'));
    });

    test('só a obesidade pede consulta entre os casos de excesso', () {
      expect(
        microCondutas(classificarAvaliacao({imc: 3.5})).first,
        contains('Agendar consulta'),
      );
      expect(
        microCondutas(classificarAvaliacao({imc: 2.5})).join(' '),
        isNot(contains('Agendar consulta')),
      );
    });

    test('orientação de alimentação muda com a idade', () {
      final normal = classificarAvaliacao({pi: 0});
      expect(
        microCondutas(normal, idadeMeses: 3).last,
        contains('aleitamento materno exclusivo'),
      );
      expect(
        microCondutas(normal, idadeMeses: 12).last,
        contains('Manter o aleitamento'),
      );
      expect(
        microCondutas(normal, idadeMeses: 36).last,
        contains('refeições da família'),
      );
    });

    test('sem idade, não acrescenta a orientação por idade', () {
      final normal = classificarAvaliacao({pi: 0});
      expect(
        microCondutas(normal).length,
        microCondutas(normal, idadeMeses: 12).length - 1,
      );
    });
  });

  group('sugestão de retorno (RF17)', () {
    final avaliacao = DateTime(2026, 11, 18, 9, 30);

    test('grave volta em 5 dias (AIDPI, peso muito baixo)', () {
      expect(
        sugerirRetorno(avaliacao, Gravidade.grave),
        DateTime(2026, 11, 23),
      );
    });

    test('risco e atenção voltam em 30 dias', () {
      expect(
        sugerirRetorno(avaliacao, Gravidade.risco),
        DateTime(2026, 12, 18),
      );
      expect(
        sugerirRetorno(avaliacao, Gravidade.atencao),
        DateTime(2026, 12, 18),
      );
    });

    test('a data vira o ano e não tem hora', () {
      expect(
        sugerirRetorno(DateTime(2026, 12, 28, 23, 59), Gravidade.grave),
        DateTime(2027, 1, 2),
      );
    });

    test('adequado sem nascimento: o profissional define', () {
      expect(sugerirRetorno(avaliacao, Gravidade.adequado), isNull);
    });

    test('adequado segue o calendário mínimo do MS', () {
      final nasc = DateTime(2026, 1, 10);
      DateTime? retorno(DateTime d) =>
          sugerirRetorno(d, Gravidade.adequado, nascimento: nasc);

      expect(retorno(DateTime(2026, 1, 17)), DateTime(2026, 2, 10)); // 1 sem
      expect(retorno(DateTime(2026, 2, 10)), DateTime(2026, 3, 10)); // 1 m
      expect(retorno(DateTime(2026, 3, 12)), DateTime(2026, 5, 10)); // 2 m
      expect(retorno(DateTime(2026, 7, 10)), DateTime(2026, 10, 10)); // 6 m
      expect(retorno(DateTime(2027, 1, 10)), DateTime(2027, 7, 10)); // 12 m
      expect(retorno(DateTime(2028, 1, 10)), DateTime(2029, 1, 10)); // 24 m
      expect(retorno(DateTime(2029, 1, 15)), DateTime(2030, 1, 10)); // 36 m
    });

    test('a avaliação perto do marco seguinte conta como esse marco', () {
      final nasc = DateTime(2026, 1, 10);
      // 5 meses e 28 dias: é a consulta dos 6 meses, volta aos 9.
      expect(
        sugerirRetorno(
          DateTime(2026, 7, 8),
          Gravidade.adequado,
          nascimento: nasc,
        ),
        DateTime(2026, 10, 10),
      );
      // 4 meses e 10 dias: é a consulta dos 4 meses, volta aos 6.
      expect(
        sugerirRetorno(
          DateTime(2026, 5, 20),
          Gravidade.adequado,
          nascimento: nasc,
        ),
        DateTime(2026, 7, 10),
      );
    });

    test('nascimento no dia 31 usa o último dia do mês', () {
      expect(
        proximaConsultaDoCalendario(
          DateTime(2025, 12, 31),
          DateTime(2026, 1, 31),
        ),
        DateTime(2026, 2, 28),
      );
    });
  });

  group('alerta de encaminhamento (RF12)', () {
    test('sem vermelho não há alerta', () {
      expect(
        alertaEncaminhamento(classificarAvaliacao({pi: -1.9, imc: 2.5})),
        isNull,
      );
    });

    test('magreza acentuada gera alerta urgente', () {
      final alerta = alertaEncaminhamento(
        classificarAvaliacao({pe: -3.2, ei: -0.5}),
      );
      expect(alerta!.urgente, isTrue);
      expect(alerta.titulo, 'Encaminhamento urgente');
      expect(alerta.mensagem, contains('magreza acentuada'));
      expect(alerta.indicadores.map((i) => i.indicador), [pe]);
    });

    test('muito baixo peso e baixa estatura grave: prioritário', () {
      for (final ind in [pi, ei]) {
        final alerta = alertaEncaminhamento(classificarAvaliacao({ind: -3.5}));
        expect(alerta!.urgente, isFalse, reason: ind.chave);
        expect(alerta.titulo, 'Encaminhamento prioritário');
      }
    });

    test('obesidade gera alerta prioritário', () {
      final alerta = alertaEncaminhamento(classificarAvaliacao({imc: 3.5}));
      expect(alerta!.urgente, isFalse);
    });

    test('lista os indicadores críticos do mais grave ao menos grave', () {
      final alerta = alertaEncaminhamento(
        classificarAvaliacao({ei: -2.5, pi: -0.5, imc: -3.5}),
      );
      expect(alerta!.urgente, isTrue);
      expect(alerta.indicadores.map((i) => i.indicador), [imc, ei]);
    });
  });
}
