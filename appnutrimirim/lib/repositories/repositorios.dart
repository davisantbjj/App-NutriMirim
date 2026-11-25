import 'package:cloud_firestore/cloud_firestore.dart';

import 'avaliacao_repository.dart';
import 'crianca_repository.dart';
import 'firestore/avaliacoes_firestore.dart';
import 'firestore/criancas_firestore.dart';
import 'memoria/avaliacoes_memoria.dart';
import 'memoria/banco_memoria.dart';
import 'memoria/criancas_memoria.dart';
import 'sessao_profissional.dart';

export 'avaliacao_repository.dart';
export 'crianca_repository.dart';
export 'excecoes.dart';
export 'memoria/banco_memoria.dart' show BancoMemoria, UsuarioAtual;
export 'sessao_profissional.dart';

/// Ponto de acesso único aos repositórios. As telas usam
/// `Repositorios.criancas` e `Repositorios.avaliacoes`, nunca o Firebase.
///
/// Por padrão (sem login) usa a implementação em memória já com os dados do
/// mock. Depois do login chame [usarFirestore]; ao sair, [reiniciar].
/// Nos testes, chame [reiniciar] (ou [usarMemoria]) no `setUp` para começar de
/// um estado limpo. Nada aqui inicializa o Firebase.
class Repositorios {
  Repositorios._();

  static CriancaRepository? _criancas;
  static AvaliacaoRepository? _avaliacoes;
  static SessaoProfissional? _sessao;

  static SessaoProfissional? get sessao => _sessao;

  static CriancaRepository get criancas {
    _garantir();
    return _criancas!;
  }

  static AvaliacaoRepository get avaliacoes {
    _garantir();
    return _avaliacoes!;
  }

  static void _garantir() {
    if (_criancas == null || _avaliacoes == null) usarMemoria();
  }

  /// Troca para a implementação em memória (os dois repositórios compartilham
  /// o mesmo [BancoMemoria]). [comMock] carrega as crianças e avaliações do
  /// `MockData`; [agora] e [usuario] servem para simular relógio e login.
  /// Devolve o banco, para testes que queiram inspecioná-lo.
  static BancoMemoria usarMemoria({
    bool comMock = true,
    DateTime Function()? agora,
    UsuarioAtual usuario = UsuarioAtual.local,
    SessaoProfissional? sessao,
  }) {
    _sessao = sessao;
    final banco = comMock
        ? BancoMemoria.comMock(agora: agora, usuario: usuario)
        : BancoMemoria(agora: agora, usuario: usuario);
    _criancas = CriancaRepositoryMemoria(banco);
    _avaliacoes = AvaliacaoRepositoryMemoria(banco);
    return banco;
  }

  /// Troca para o Cloud Firestore com a [sessao] do profissional logado
  /// (chamar depois do login, com o Firebase já inicializado).
  static void usarFirestore(
    SessaoProfissional sessao, {
    FirebaseFirestore? firestore,
  }) {
    _sessao = sessao;
    _criancas = CriancaRepositoryFirestore(
      sessao: sessao,
      firestore: firestore,
    );
    _avaliacoes = AvaliacaoRepositoryFirestore(
      sessao: sessao,
      firestore: firestore,
    );
  }

  /// Volta ao padrão: memória com o mock, estado novo.
  static void reiniciar() {
    _sessao = null;
    usarMemoria();
  }

  static void trocarUbsAtual(String ubsId) {
    final atual = _sessao;
    if (atual == null || !atual.ubsIds.contains(ubsId)) return;
    _sessao = atual.copyWith(ubsAtualId: ubsId);
  }
}
