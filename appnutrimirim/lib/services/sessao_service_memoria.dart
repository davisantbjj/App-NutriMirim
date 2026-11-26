import '../repositories/repositorios.dart';
import 'auth_service.dart';
import 'sessao_service.dart';

/// [SessaoService] em memória, para os testes (sem Firebase).
///
/// Sem [perfis], qualquer usuário entra com uma sessão de ACS de teste
/// ([sessaoDeTeste]) e os repositórios continuam na memória com o mock. Com
/// [perfis] (uid → dados de `profissionais/{uid}`), só entra quem tiver um
/// perfil ativo, como no Firestore.
class SessaoServiceMemoria implements SessaoService {
  SessaoServiceMemoria({
    Map<String, Map<String, dynamic>>? perfis,
    this.erroAoCarregar,
    this.registrosPendentes = false,
  }) : _perfis = perfis;

  final Map<String, Map<String, dynamic>>? _perfis;

  /// Simula falha ao ler o perfil (lançado por [carregar]).
  final AuthException? erroAoCarregar;

  /// Simula gravações ainda não enviadas (offline).
  bool registrosPendentes;

  /// Sessão ligada agora (depois do [ligar] e antes do [desligar]).
  SessaoProfissional? ligada;

  /// Quantas vezes o [desligar] foi chamado (cache apagado).
  int desligamentos = 0;

  static SessaoProfissional sessaoDeTeste(String uid) => SessaoProfissional(
    uid: uid,
    nome: 'Profissional de Teste',
    papel: PapelProfissional.acs,
    ubsIds: const ['ubs-teste'],
    ubsAtualId: 'ubs-teste',
    nomesUbs: const {'ubs-teste': 'UBS de Teste'},
  );

  @override
  Future<SessaoProfissional> carregar(UsuarioLogado usuario) async {
    if (erroAoCarregar != null) throw erroAoCarregar!;
    final perfis = _perfis;
    if (perfis == null) return sessaoDeTeste(usuario.uid);
    return sessaoDePerfil(usuario.uid, perfis[usuario.uid]);
  }

  /// Só guarda a sessão: os repositórios continuam no banco em memória que o
  /// teste montou (com ou sem o mock).
  @override
  Future<void> ligar(SessaoProfissional sessao) async => ligada = sessao;

  @override
  Future<bool> semRegistrosPendentes() async => !registrosPendentes;

  @override
  Future<void> desligar() async {
    Repositorios.reiniciar();
    ligada = null;
    desligamentos++;
  }
}
