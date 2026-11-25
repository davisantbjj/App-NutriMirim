/// Sessão do profissional depois do login: lê `profissionais/{uid}`, monta a
/// [SessaoProfissional] e liga os repositórios ao Firestore. Ao sair,
/// desliga os repositórios e apaga o cache local (LGPD).
///
/// Há duas implementações:
/// - `SessaoServiceFirestore` (`sessao_service_firestore.dart`), usada no app;
/// - `SessaoServiceMemoria` (`sessao_service_memoria.dart`), usada nos testes.
///
/// As telas não chamam este serviço direto: usam `iniciarSessao` e
/// `encerrarSessao` de `app_state.dart`, que também falam com o AuthService.
library;

import '../repositories/sessao_profissional.dart';
import 'auth_service.dart';

const mensagemAcessoNaoLiberado =
    'Seu acesso não está liberado. Procure o responsável pela UBS.';

const mensagemPerfilIndisponivel =
    'Não foi possível carregar seu perfil. Verifique a conexão e tente de novo.';

const mensagemRegistrosPendentes =
    'Há registros que ainda não foram enviados. Conecte-se à internet e '
    'tente sair de novo, para não perder esses registros.';

/// Perfil ausente, inativo ou inválido em `profissionais/{uid}`.
class AcessoNaoLiberadoException extends AuthException {
  const AcessoNaoLiberadoException() : super(mensagemAcessoNaoLiberado);
}

abstract class SessaoService {
  /// Lê o perfil de [usuario] e monta a sessão.
  ///
  /// Lança [AcessoNaoLiberadoException] se o perfil não existe, está com
  /// `ativo: false` ou é inválido, e [AuthException] se não conseguiu ler.
  Future<SessaoProfissional> carregar(UsuarioLogado usuario);

  /// Liga os repositórios à [sessao] (chamar antes de abrir o Início, porque
  /// as telas criam os Streams no `initState`).
  Future<void> ligar(SessaoProfissional sessao);

  /// `true` se não há gravação esperando envio ao servidor. O [desligar]
  /// apaga o cache, e com ele o que ainda não foi enviado.
  Future<bool> semRegistrosPendentes();

  /// Volta os repositórios à memória e apaga o cache local do Firestore.
  /// Chamar depois de sair da conta e de abrir o Login. Não lança erro.
  Future<void> desligar();
}

/// Monta a sessão a partir dos dados de `profissionais/{uid}`
/// (`docs/firestore.md`). Lança [AcessoNaoLiberadoException] se [perfil] é
/// nulo (documento não existe), está inativo ou tem campos inválidos.
///
/// A UBS atual (onde as crianças novas são cadastradas) é a primeira de
/// `ubsIds`; o master sem UBS fica com `ubsAtualId` vazio.
SessaoProfissional sessaoDePerfil(
  String uid,
  Map<String, dynamic>? perfil, {
  Map<String, String> nomesUbs = const {},
}) {
  if (perfil == null || perfil['ativo'] != true) {
    throw const AcessoNaoLiberadoException();
  }
  final papel = PapelProfissional.values.asNameMap()[perfil['papel']];
  final nome = perfil['nome'];
  final ubsIds = perfil['ubsIds'];
  if (papel == null || nome is! String || nome.trim().isEmpty) {
    throw const AcessoNaoLiberadoException();
  }
  if (ubsIds is! List || ubsIds.any((id) => id is! String || id.isEmpty)) {
    throw const AcessoNaoLiberadoException();
  }
  final ids = List<String>.unmodifiable(ubsIds.cast<String>());
  if (ids.isEmpty && papel != PapelProfissional.master) {
    throw const AcessoNaoLiberadoException();
  }
  final microarea = perfil['microarea'];
  return SessaoProfissional(
    uid: uid,
    nome: nome,
    papel: papel,
    ubsIds: ids,
    ubsAtualId: ids.isEmpty ? '' : ids.first,
    microarea: microarea is String && microarea.isNotEmpty ? microarea : null,
    nomesUbs: Map.unmodifiable(nomesUbs),
  );
}
