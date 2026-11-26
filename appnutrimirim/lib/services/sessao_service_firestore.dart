import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/repositorios.dart';
import 'auth_service.dart';
import 'sessao_service.dart';

/// [SessaoService] sobre o Cloud Firestore.
///
/// - `carregar` lê `profissionais/{uid}` e os nomes das UBS da lista (o
///   master lê todas). Offline, o Firestore usa o perfil do cache, então quem
///   já entrou antes no aparelho continua conseguindo abrir o app.
/// - `desligar` faz `terminate()` e `clearPersistence()`: o cache offline
///   guarda nome, CPF e endereço de crianças e responsáveis e não pode ficar
///   para a próxima conta do aparelho.
class SessaoServiceFirestore implements SessaoService {
  SessaoServiceFirestore({
    FirebaseFirestore? firestore,
    this.limiteCarregar = const Duration(seconds: 15),
    this.limitePendentes = const Duration(seconds: 5),
  }) : _informado = firestore;

  final FirebaseFirestore? _informado;

  /// Tempo máximo lendo o perfil.
  final Duration limiteCarregar;

  /// Tempo máximo esperando as gravações pendentes chegarem ao servidor.
  final Duration limitePendentes;

  // Lido a cada uso: depois do `terminate()` a instância é recriada.
  FirebaseFirestore get _db => _informado ?? FirebaseFirestore.instance;

  @override
  Future<SessaoProfissional> carregar(UsuarioLogado usuario) async {
    final Map<String, dynamic>? perfil;
    try {
      final doc = await _db
          .collection('profissionais')
          .doc(usuario.uid)
          .get()
          .timeout(limiteCarregar);
      perfil = doc.data();
    } on FirebaseException catch (e) {
      // As regras deixam ler o próprio perfil; negado = conta sem acesso.
      if (e.code == 'permission-denied') {
        throw const AcessoNaoLiberadoException();
      }
      throw const AuthException(mensagemPerfilIndisponivel);
    } catch (_) {
      throw const AuthException(mensagemPerfilIndisponivel);
    }
    // Valida antes de ler as UBS (lança se não tiver acesso).
    final sessao = sessaoDePerfil(usuario.uid, perfil);
    return sessaoDePerfil(
      usuario.uid,
      perfil,
      nomesUbs: await _nomesUbs(sessao),
    );
  }

  /// id → nome das UBS da sessão. Sem os nomes o app funciona (a criança
  /// mostra a UBS vazia), então uma falha aqui não impede o login.
  Future<Map<String, String>> _nomesUbs(SessaoProfissional sessao) async {
    try {
      final docs = sessao.master
          ? (await _db.collection('ubs').get().timeout(limiteCarregar)).docs
          : await Future.wait(
              sessao.ubsIds.map(
                (id) =>
                    _db.collection('ubs').doc(id).get().timeout(limiteCarregar),
              ),
            );
      return {
        for (final d in docs)
          if (d.data()?['nome'] case final String nome) d.id: nome,
      };
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<void> ligar(SessaoProfissional sessao) async =>
      Repositorios.usarFirestore(sessao, firestore: _informado);

  @override
  Future<bool> semRegistrosPendentes() async {
    try {
      await _db.waitForPendingWrites().timeout(limitePendentes);
      return true;
    } on TimeoutException {
      return false;
    } catch (_) {
      // Sem como conferir (ex.: instância já encerrada): não bloqueia a saída.
      return true;
    }
  }

  @override
  Future<void> desligar() async {
    Repositorios.reiniciar();
    try {
      await _db.terminate();
      await _db.clearPersistence();
    } catch (_) {
      // O logout já aconteceu; uma falha aqui não deve prender o usuário.
    }
  }
}
