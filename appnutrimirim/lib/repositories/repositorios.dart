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
/// mock. Depois do login, `iniciarSessao` (`app_state.dart`) chama
/// [usarFirestore]; ao sair, `encerrarSessao` chama [reiniciar].
/// Nos testes, chame [reiniciar] (ou [usarMemoria]) no `setUp` para começar de
/// um estado limpo. Nada aqui inicializa o Firebase.
class Repositorios {
  Repositorios._();

  static CriancaRepository? _criancas;
  static AvaliacaoRepository? _avaliacoes;
  static SessaoProfissional? _sessao;

  /// Firestore em uso depois de [usarFirestore] (nulo na memória), para
  /// [trocarUbsAtual] recriar os repositórios com a sessão nova.
  static bool _noFirestore = false;
  static FirebaseFirestore? _firestore;

  /// Profissional logado (papel, UBS, microárea), ou `null` sem login ou na
  /// memória sem sessão. Para o Perfil e as telas que dependem do papel.
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
  /// `MockData`; [agora] e [usuario] servem para simular relógio e login, e
  /// [sessao] preenche [Repositorios.sessao] nos testes de tela.
  /// Devolve o banco, para testes que queiram inspecioná-lo.
  static BancoMemoria usarMemoria({
    bool comMock = true,
    DateTime Function()? agora,
    UsuarioAtual usuario = UsuarioAtual.local,
    SessaoProfissional? sessao,
  }) {
    _sessao = sessao;
    _noFirestore = false;
    _firestore = null;
    final banco = comMock
        ? BancoMemoria.comMock(agora: agora, usuario: usuario)
        : BancoMemoria(agora: agora, usuario: usuario);
    _criancas = CriancaRepositoryMemoria(banco);
    _avaliacoes = AvaliacaoRepositoryMemoria(banco);
    return banco;
  }

  /// Troca para o Cloud Firestore com a [sessao] do profissional logado.
  /// No app, quem chama é o `SessaoServiceFirestore` (via `iniciarSessao` de
  /// `app_state.dart`), depois do login e antes de abrir o Início.
  static void usarFirestore(
    SessaoProfissional sessao, {
    FirebaseFirestore? firestore,
  }) {
    _sessao = sessao;
    _noFirestore = true;
    _firestore = firestore;
    _criancas = CriancaRepositoryFirestore(
      sessao: sessao,
      firestore: firestore,
    );
    _avaliacoes = AvaliacaoRepositoryFirestore(
      sessao: sessao,
      firestore: firestore,
    );
  }

  /// Volta ao padrão: memória com o mock, estado novo e sem sessão.
  static void reiniciar() => usarMemoria();

  /// Troca a UBS onde as crianças novas são cadastradas (médico em mais de
  /// uma UBS). Ignora UBS fora de `ubsIds`. No Firestore, recria os
  /// repositórios, porque eles guardam a sessão com que foram criados.
  static void trocarUbsAtual(String ubsId) {
    final atual = _sessao;
    if (atual == null || !atual.ubsIds.contains(ubsId)) return;
    final nova = atual.copyWith(ubsAtualId: ubsId);
    if (_noFirestore) {
      usarFirestore(nova, firestore: _firestore);
    } else {
      _sessao = nova;
    }
  }
}
