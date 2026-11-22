/// Erros de regra de negócio dos repositórios. As telas podem tratar cada tipo
/// (ou só [RepositorioException]) e mostrar [mensagem] ao usuário.
class RepositorioException implements Exception {
  const RepositorioException(this.mensagem);

  /// Texto em português, pronto para exibir.
  final String mensagem;

  @override
  String toString() => '$runtimeType: $mensagem';
}

/// Motivo ausente ou fora de 3 a 200 caracteres (edição, correção, exclusão).
class MotivoObrigatorio extends RepositorioException {
  const MotivoObrigatorio()
    : super('Informe o motivo (de 3 a 200 caracteres).');
}

/// Criança ou avaliação inexistente (ou fora do alcance do usuário).
class NaoEncontrado extends RepositorioException {
  const NaoEncontrado(super.mensagem);
}

/// RF14: passaram os 15 minutos para o autor corrigir ou excluir.
class PrazoCorrecaoExpirado extends RepositorioException {
  const PrazoCorrecaoExpirado()
    : super(
        'O prazo de 15 minutos para corrigir ou excluir esta avaliação '
        'terminou.',
      );
}

/// O usuário não pode fazer a operação (ex.: não é o autor da avaliação).
class PermissaoNegada extends RepositorioException {
  const PermissaoNegada(super.mensagem);
}

/// Dados fora das regras (peso, nome, indicadores...).
class DadosInvalidos extends RepositorioException {
  const DadosInvalidos(super.mensagem);
}

/// Operação incompatível com o estado atual (avaliação já excluída, criança
/// desativada, id repetido...).
class EstadoInvalido extends RepositorioException {
  const EstadoInvalido(super.mensagem);
}
