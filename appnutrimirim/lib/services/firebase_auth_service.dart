import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

/// [AuthService] com o Firebase Authentication (projeto `app-nutrimirim`).
///
/// A sessão fica salva pelo próprio Firebase (no celular e no navegador),
/// então quem já entrou continua logado ao reabrir o app.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService([FirebaseAuth? auth])
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static UsuarioLogado? _converter(User? u) =>
      u == null ? null : UsuarioLogado(uid: u.uid, email: u.email ?? '');

  @override
  UsuarioLogado? get atual => _converter(_auth.currentUser);

  @override
  Future<UsuarioLogado?> restaurarSessao() async {
    // O primeiro evento chega depois que a sessão salva foi carregada.
    final u = await _auth.authStateChanges().first;
    return _converter(u);
  }

  @override
  Future<UsuarioLogado> entrar({
    required String email,
    required String senha,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      return _converter(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensagemDoErro(e.code));
    }
  }

  @override
  Future<void> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensagemDoErro(e.code));
    }
  }

  @override
  Future<void> sair() => _auth.signOut();

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
        return 'Não foi possível concluir. Tente de novo.';
    }
  }
}
