import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

/// [AuthService] com o Firebase Authentication (projeto `app-nutrimirim`).
///
/// A sessão fica salva pelo próprio Firebase (no celular e no navegador),
/// então quem já entrou continua logado ao reabrir o app.
///
/// Todo erro (do Firebase ou não) vira [AuthException] com mensagem em
/// português, para as telas nunca receberem uma exceção inesperada.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService([FirebaseAuth? auth, this.limiteRestaurar = _limite])
    : _auth = auth ?? FirebaseAuth.instance;

  static const _limite = Duration(seconds: 10);

  final FirebaseAuth _auth;

  /// Tempo máximo esperando a sessão salva na Abertura.
  final Duration limiteRestaurar;

  static const _erroGenerico = 'Não foi possível concluir. Tente de novo.';

  static UsuarioLogado? _converter(User? u) =>
      u == null ? null : UsuarioLogado(uid: u.uid, email: u.email ?? '');

  @override
  UsuarioLogado? get atual => _converter(_auth.currentUser);

  @override
  Future<UsuarioLogado?> restaurarSessao() async {
    try {
      // O primeiro evento chega depois que a sessão salva foi carregada.
      final u = await _auth.authStateChanges().first.timeout(limiteRestaurar);
      return _converter(u);
    } catch (_) {
      // Sem conseguir ler a sessão (erro ou demora), o app segue para o
      // Login em vez de ficar parado na Abertura.
      return null;
    }
  }

  @override
  Future<UsuarioLogado> entrar({
    required String email,
    required String senha,
  }) async {
    final UserCredential cred;
    try {
      cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensagemDoErro(e.code));
    } catch (_) {
      throw const AuthException(_erroGenerico);
    }
    final usuario = _converter(cred.user);
    if (usuario == null) throw const AuthException(_erroGenerico);
    return usuario;
  }

  @override
  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      // E-mail sem conta segue como se o link tivesse sido enviado, para
      // não revelar quais e-mails têm conta (enumeração de e-mails). Com a
      // "Email enumeration protection" ligada no Console, o Firebase já nem
      // devolve esse erro.
      if (e.code == 'user-not-found') return;
      throw AuthException(mensagemDoErro(e.code));
    } catch (_) {
      throw const AuthException(_erroGenerico);
    }
  }

  @override
  Future<void> sair() async {
    try {
      await _auth.signOut();
    } catch (_) {
      throw const AuthException(
        'Não foi possível sair da conta. Tente de novo.',
      );
    }
  }

  /// Traduz os códigos do Firebase para mensagens em português.
  ///
  /// "Usuário não encontrado" e "senha errada" têm a mesma mensagem de
  /// propósito, para não revelar quais e-mails têm conta.
  static String mensagemDoErro(String codigo) {
    switch (codigo) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'wrong-password':
      case 'user-not-found':
        return 'E-mail ou senha incorretos.';
      case 'invalid-email':
        return 'Informe um e-mail válido.';
      case 'user-disabled':
        return 'Esta conta está desativada. Fale com o responsável pelo app.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente de novo.';
      case 'network-request-failed':
        return 'Sem conexão com a internet. Verifique a rede e tente de novo.';
      default:
        return _erroGenerico;
    }
  }
}
