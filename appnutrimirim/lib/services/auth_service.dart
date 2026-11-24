/// Autenticação do profissional (RNF04): login com e-mail e senha,
/// recuperação de senha, logout e sessão mantida entre aberturas do app.
///
/// As telas falam só com esta interface. Há duas implementações:
/// - `FirebaseAuthService` (`firebase_auth_service.dart`), usada no app;
/// - `AuthServiceMemoria` (`auth_service_memoria.dart`), usada nos testes.
library;

/// Profissional logado. Os dados do perfil (papel, UBS etc.) ficam em
/// `profissionais/{uid}` no Firestore, ver `docs/firestore.md`.
class UsuarioLogado {
  const UsuarioLogado({required this.uid, required this.email});

  final String uid;
  final String email;
}

/// Erro de autenticação com mensagem pronta para mostrar ao usuário.
class AuthException implements Exception {
  const AuthException(this.mensagem);

  final String mensagem;

  @override
  String toString() => 'AuthException: $mensagem';
}

abstract class AuthService {
  /// Usuário logado agora, ou `null`.
  UsuarioLogado? get atual;

  /// Espera a sessão salva ser restaurada (no início do app) e devolve o
  /// usuário logado, ou `null` se ninguém entrou ainda.
  Future<UsuarioLogado?> restaurarSessao();

  /// Entra com e-mail e senha. Lança [AuthException] se não conseguir.
  Future<UsuarioLogado> entrar({required String email, required String senha});

  /// Envia o e-mail com o link para criar uma senha nova.
  /// Lança [AuthException] se não conseguir.
  Future<void> recuperarSenha(String email);

  /// Sai da conta.
  Future<void> sair();
}

/// Validação simples de e-mail, igual para o Login e a Recuperação.
bool emailValido(String? email) {
  final v = email?.trim() ?? '';
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
}
