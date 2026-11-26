import '../../data/models.dart';
import '../avaliacao_repository.dart';
import '../excecoes.dart';
import '../validacao.dart';
import 'banco_memoria.dart';

/// [AvaliacaoRepository] em memória (testes e app sem login). Copia as regras
/// do Firestore: motivo obrigatório, 15 minutos só para o autor (master
/// sempre), avaliação excluída não é editada, criança inativa não recebe
/// avaliação. O resumo da criança (última avaliação) é sempre derivado das
/// avaliações, então já fica coerente com o banco compartilhado.
class AvaliacaoRepositoryMemoria implements AvaliacaoRepository {
  /// Repositório sobre [banco] (vazio se omitido). Passe o mesmo
  /// [BancoMemoria] do repositório de crianças para compartilhar dados.
  AvaliacaoRepositoryMemoria([BancoMemoria? banco])
    : banco = banco ?? BancoMemoria();

  /// Banco próprio já com os dados do mock.
  AvaliacaoRepositoryMemoria.comMock() : banco = BancoMemoria.comMock();

  final BancoMemoria banco;

  /// Não excluídas, da mais recente para a mais antiga. Desempate: `criadoEm`
  /// e, se igual, a registrada por último (ordem de inserção no banco).
  List<Avaliacao> _visiveis({String? criancaId}) {
    final ordem = <String, int>{};
    var n = 0;
    for (final id in banco.avaliacoes.keys) {
      ordem[id] = n++;
    }
    final lista = banco.avaliacoes.values
        .where(
          (a) => !a.excluida && (criancaId == null || a.criancaId == criancaId),
        )
        .toList();
    lista.sort((a, b) {
      final c = b.data.compareTo(a.data);
      if (c != 0) return c;
      final ca = a.criadoEm, cb = b.criadoEm;
      if (ca != null && cb != null) {
        final d = cb.compareTo(ca);
        if (d != 0) return d;
      }
      return ordem[b.id]!.compareTo(ordem[a.id]!);
    });
    return List.unmodifiable(lista);
  }

  @override
  String novoId() => banco.novoId('a');

  @override
  Stream<List<Avaliacao>> observarTodas() => banco.observar(_visiveis);

  @override
  Stream<List<Avaliacao>> observarDe(String criancaId) =>
      banco.observar(() => _visiveis(criancaId: criancaId));

  @override
  Future<Avaliacao?> ultimaDe(String criancaId) async {
    final lista = _visiveis(criancaId: criancaId);
    return lista.isEmpty ? null : lista.first;
  }

  @override
  Future<Avaliacao> registrar(Avaliacao avaliacao) async {
    final agora = banco.agora();
    validarAvaliacao(avaliacao, agora);
    final crianca = banco.criancas[avaliacao.criancaId];
    if (crianca == null) throw const NaoEncontrado('Criança não encontrada.');
    if (!crianca.ativa) {
      throw const EstadoInvalido(
        'Esta criança está desativada e não recebe novas avaliações.',
      );
    }
    final id = avaliacao.id.isEmpty ? novoId() : avaliacao.id;
    if (banco.avaliacoes.containsKey(id)) {
      throw const EstadoInvalido('Já existe uma avaliação com este id.');
    }
    final salva = avaliacao.copyWith(
      id: id,
      criadoEm: agora,
      profissionalId: banco.usuario.uid,
      profissionalNome: banco.usuario.nome,
      excluida: false,
    );
    banco.avaliacoes[id] = salva;
    banco.versoes[id] = 0;
    banco.notificar();
    return salva;
  }

  @override
  Future<void> corrigir(Avaliacao avaliacao, {required String motivo}) async {
    final m = validarMotivo(motivo);
    final atual = _paraAlterar(avaliacao.id);
    validarAvaliacao(
      avaliacao.copyWith(criancaId: atual.criancaId),
      banco.agora(),
    );
    // Só os campos corrigíveis mudam; criança, autor e criadoEm ficam.
    banco.avaliacoes[atual.id] = atual.copyWith(
      data: avaliacao.data,
      pesoKg: avaliacao.pesoKg,
      alturaCm: avaliacao.alturaCm,
      situacao: avaliacao.situacao,
      tipoMedida: avaliacao.tipoMedida,
      limparTipoMedida: avaliacao.tipoMedida == null,
      indicadores: avaliacao.indicadores,
      desnutricao: avaliacao.desnutricao,
      edema: avaliacao.edema,
      versaoTabelaOms: avaliacao.versaoTabelaOms,
      retornoSugerido: avaliacao.retornoSugerido,
      limparRetornoSugerido: avaliacao.retornoSugerido == null,
    );
    _registrarAlteracao(atual.id, m, 'correcao');
    banco.notificar();
  }

  @override
  Future<void> excluir(String id, {required String motivo}) async {
    final m = validarMotivo(motivo);
    final atual = _paraAlterar(id);
    banco.avaliacoes[id] = atual.copyWith(excluida: true);
    _registrarAlteracao(id, m, 'exclusao');
    banco.notificar();
  }

  /// Avaliação existente, não excluída e que o usuário pode alterar agora.
  Avaliacao _paraAlterar(String id) {
    final atual = banco.avaliacoes[id];
    if (atual == null) throw const NaoEncontrado('Avaliação não encontrada.');
    if (atual.excluida) {
      throw const EstadoInvalido('Esta avaliação já foi excluída.');
    }
    validarPodeCorrigir(
      atual,
      usuarioUid: banco.usuario.uid,
      master: banco.usuario.master,
      agora: banco.agora(),
    );
    return atual;
  }

  void _registrarAlteracao(String id, String motivo, String acao) {
    final versao = banco.proximaVersao(id);
    banco.versoes[id] = versao;
    banco.alteracoes.add(
      AlteracaoMemoria(
        colecao: 'avaliacoes',
        docId: id,
        versao: versao,
        motivo: motivo,
        alteradoPor: banco.usuario.uid,
        alteradoEm: banco.agora(),
        acao: acao,
      ),
    );
  }
}
