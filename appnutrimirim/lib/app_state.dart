import 'package:flutter/foundation.dart';

import 'repositories/sessao_profissional.dart';
import 'services/auth_service.dart';
import 'services/auth_service_memoria.dart';
import 'services/sessao_service.dart';
import 'services/sessao_service_memoria.dart';

/// Preferência global de alto contraste (Perfil Profissional > Preferências).
final highContrast = ValueNotifier<bool>(false);

/// Serviço de autenticação usado pelas telas.
///
/// O `main.dart` troca pelo `FirebaseAuthService`. Nos testes fica a versão
/// em memória, sem Firebase; para simular contas, atribua outra
/// `AuthServiceMemoria(contas: {...})`.
AuthService authService = AuthServiceMemoria();

/// Serviço que lê o perfil e liga os repositórios depois do login.
///
/// O `main.dart` troca pelo `SessaoServiceFirestore`. Nos testes fica a
/// versão em memória, que deixa qualquer conta entrar; para simular perfis,
/// atribua outra `SessaoServiceMemoria(perfis: {...})`.
SessaoService sessaoService = SessaoServiceMemoria();

/// Depois do login (ou da sessão restaurada na Abertura): carrega
/// `profissionais/{uid}` e liga os repositórios, antes de abrir o Início.
///
/// Se não conseguir (perfil ausente, inativo ou sem conexão), sai da conta
/// do Firebase, para o app não ficar logado sem sessão, e relança a
/// [AuthException] com a mensagem para o Login.
Future<SessaoProfissional> iniciarSessao(UsuarioLogado usuario) async {
  final SessaoProfissional sessao;
  try {
    sessao = await sessaoService.carregar(usuario);
  } on AuthException {
    try {
      await authService.sair();
    } catch (_) {
      // Continua: a mensagem que importa é a do perfil.
    }
    rethrow;
  }
  await sessaoService.ligar(sessao);
  return sessao;
}

/// Sai da conta. Lança [AuthException] (e continua logado) se houver
/// registros ainda não enviados ou se o logout falhar.
///
/// Depois de abrir o Login (que não usa os repositórios), chame
/// [desligarSessao]. Antes disso, as telas ainda abertas perderiam os dados.
Future<void> sairDaConta() async {
  if (!await sessaoService.semRegistrosPendentes()) {
    throw const AuthException(mensagemRegistrosPendentes);
  }
  await authService.sair();
}

/// Confirma se os registros pendentes foram enviados ao servidor.
Future<bool> sincronizarSessao() => sessaoService.semRegistrosPendentes();

/// Volta os repositórios à memória e apaga o cache do Firestore (LGPD).
Future<void> desligarSessao() => sessaoService.desligar();
