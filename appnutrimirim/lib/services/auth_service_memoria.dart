import 'auth_service.dart';

/// [AuthService] em memória, sem Firebase. Usado nos testes.
class AuthServiceMemoria implements AuthService {
  AuthServiceMemoria({
    Map<String, String>? contas,
    UsuarioLogado? logado,
    this.erroAoRestaurar,
    this.erroAoSair,
  }) : _contas = {...?contas},
       _atual = logado;

  /// Simula falha ao ler a sessão salva (lançado por [restaurarSessao]).
  final Object? erroAoRestaurar;

  /// Simula falha ao sair (lançado por [sair]).
  final AuthException? erroAoSair;

  /// E-mail → senha das contas que existem.
  final Map<String, String> _contas;
  UsuarioLogado? _atual;

  /// E-mails para os quais foi pedido o link de recuperação.
  final List<String> recuperacoesEnviadas = [];

  @override
  UsuarioLogado? get atual => _atual;

  @override
  Future<UsuarioLogado?> restaurarSessao() async {
    if (erroAoRestaurar != null) throw erroAoRestaurar!;
    return _atual;
  }

  @override
  Future<UsuarioLogado> entrar({
    required String email,
    required String senha,
  }) async {
    final e = email.trim();
    if (_contas[e] != senha) {
      throw const AuthException('E-mail ou senha incorretos.');
    }
    return _atual = UsuarioLogado(uid: 'uid-$e', email: e);
  }

  @override
  Future<void> recuperarSenha(String email) async {
    if (!emailValido(email)) {
      throw const AuthException('Informe um e-mail válido.');
    }
    // Como no Firebase, não revela se o e-mail tem conta.
    recuperacoesEnviadas.add(email.trim());
  }

  @override
  Future<void> sair() async {
    if (erroAoSair != null) throw erroAoSair!;
    _atual = null;
  }
}
