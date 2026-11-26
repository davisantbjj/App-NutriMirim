import '../data/models.dart';

/// Acesso às avaliações. Erros de regra de negócio são `RepositorioException`
/// (ver `excecoes.dart`). Avaliações excluídas nunca aparecem nas listas.
abstract interface class AvaliacaoRepository {
  /// Gera um id novo (funciona offline).
  String novoId();

  /// Histórico geral, da mais recente para a mais antiga (por `data`).
  /// Emite o estado atual ao assinar e a cada mudança.
  Stream<List<Avaliacao>> observarTodas();

  /// Histórico de uma criança, da mais recente para a mais antiga.
  Stream<List<Avaliacao>> observarDe(String criancaId);

  /// Avaliação mais recente da criança, ou null se não houver.
  Future<Avaliacao?> ultimaDe(String criancaId);

  /// Registra uma avaliação e atualiza o resumo da criança
  /// (`ultimaSituacao`/`ultimaAvaliacaoEm`, no mesmo lote no Firestore).
  /// `profissionalId`, `profissionalNome` e `criadoEm` vêm do usuário atual;
  /// o que vier no objeto é ignorado. Se `avaliacao.id` estiver vazio, gera um.
  /// Devolve a avaliação como gravada. A criança precisa existir e estar ativa.
  ///
  /// No Firestore o Future só completa quando o servidor confirma; offline
  /// a gravação fica na fila local e o Future espera a reconexão.
  Future<Avaliacao> registrar(Avaliacao avaliacao);

  /// Corrige peso, altura, data, tipo de medida, situação, indicadores,
  /// desnutrição, versão da tabela e retorno (RF14). Só o autor, em até 15
  /// minutos após o registro; o master sempre. [motivo] de 3 a 200 caracteres.
  /// Lança `PrazoCorrecaoExpirado`, `PermissaoNegada`, `MotivoObrigatorio`,
  /// `NaoEncontrado`, `EstadoInvalido` (já excluída) ou `DadosInvalidos`.
  Future<void> corrigir(Avaliacao avaliacao, {required String motivo});

  /// Exclusão lógica (some das listas). Mesmas regras de autor/prazo de
  /// [corrigir].
  Future<void> excluir(String id, {required String motivo});
}
