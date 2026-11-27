import 'dart:async';

import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../sessao_profissional.dart';

/// Quem está "logado" nas implementações em memória (usado na regra do autor).
class UsuarioAtual {
  const UsuarioAtual({
    required this.uid,
    required this.nome,
    this.master = false,
    this.papel,
  });

  /// Usuário padrão enquanto não existe login.
  static const local = UsuarioAtual(
    uid: 'usuario-local',
    nome: 'Profissional local',
  );

  final String uid;
  final String nome;
  final bool master;

  /// Papel gravado nas avaliações (nulo no usuário local de teste).
  final PapelProfissional? papel;
}

/// Registro de uma alteração (espelha `alteracoes/{versao}` do Firestore).
class AlteracaoMemoria {
  const AlteracaoMemoria({
    required this.colecao,
    required this.docId,
    required this.versao,
    required this.motivo,
    required this.alteradoPor,
    required this.alteradoEm,
    required this.acao,
  });

  /// `criancas` ou `avaliacoes`.
  final String colecao;
  final String docId;
  final int versao;
  final String motivo;
  final String alteradoPor;
  final DateTime alteradoEm;

  /// `edicao`, `desativacao`, `correcao` ou `exclusao`.
  final String acao;
}

/// Armazenamento em memória compartilhado pelos repositórios de crianças e de
/// avaliações (assim, registrar uma avaliação reflete na criança, etc.).
class BancoMemoria {
  BancoMemoria({DateTime Function()? agora, this.usuario = UsuarioAtual.local})
    : agora = agora ?? DateTime.now;

  /// Banco já com todas as crianças e avaliações do [MockData].
  factory BancoMemoria.comMock({
    DateTime Function()? agora,
    UsuarioAtual usuario = UsuarioAtual.local,
  }) {
    final banco = BancoMemoria(agora: agora, usuario: usuario);
    for (final c in MockData.todasCriancas) {
      banco.criancas[c.id] = c;
      for (final a in MockData.avaliacoesDe(c.id)) {
        banco.avaliacoes[a.id] = a;
      }
    }
    return banco;
  }

  /// Relógio (troque nos testes para simular a janela de 15 min).
  DateTime Function() agora;

  /// Usuário atual (troque para simular outro profissional ou o master).
  UsuarioAtual usuario;

  final Map<String, Crianca> criancas = {};
  final Map<String, Avaliacao> avaliacoes = {};
  final Map<String, int> versoes = {};
  final List<AlteracaoMemoria> alteracoes = [];

  int _contador = 0;
  final _mudancas = StreamController<void>.broadcast(sync: true);

  String novoId(String prefixo) => '$prefixo-${++_contador}';

  int proximaVersao(String id) => (versoes[id] ?? 0) + 1;

  /// Avisa os streams que algo mudou.
  void notificar() => _mudancas.add(null);

  /// Stream que emite [ler] ao assinar e a cada mudança.
  Stream<T> observar<T>(T Function() ler) => Stream<T>.multi((c) {
    c.add(ler());
    final sub = _mudancas.stream.listen((_) => c.add(ler()));
    c.onCancel = sub.cancel;
  }, isBroadcast: true);
}
