import '../data/models.dart';

/// Acesso às crianças. As telas usam só esta interface (via `Repositorios`),
/// nunca o Firebase direto. Erros de regra de negócio são
/// `RepositorioException` (ver `excecoes.dart`).
abstract interface class CriancaRepository {
  /// Gera um id novo (funciona offline). Use-o em `Crianca.id` antes de
  /// [cadastrar].
  String novoId();

  /// Crianças ATIVAS (das UBS do usuário), ordenadas por nome sem acento.
  /// Emite o estado atual ao assinar e a cada mudança.
  Stream<List<Crianca>> observarTodas();

  /// Criança pelo [id], INCLUINDO desativadas (o histórico de avaliações
  /// continua apontando para elas; confira [Crianca.ativa]). Null se não existe.
  Future<Crianca?> porId(String id);

  /// Acompanha uma criança (inclui desativadas). Emite a criança atual ao
  /// assinar e a cada mudança (ex.: depois de [editar] ou [desativar]), ou
  /// `null` se não existe. No Firestore, `permission-denied` (documento de outra
  /// UBS ou inexistente) emite `null` e encerra o stream; outros erros viram
  /// `RepositorioException` no stream.
  Stream<Crianca?> observarPorId(String id);

  /// Busca entre as ativas. Com 11 dígitos (CPF, com ou sem máscara) procura
  /// o CPF do responsável; senão, nome parcial sem acento nem caixa. Termo
  /// vazio devolve todas. Ordenadas por nome.
  Future<List<Crianca>> buscar(String termo);

  /// Cadastra uma criança nova (`crianca.id` vem de [novoId]). No Firestore a
  /// criança é gravada em `sessao.ubsAtualId`; o campo `Crianca.ubs` do objeto
  /// recebido é ignorado. Por isso o dropdown "UBS de Referência" do cadastro
  /// precisa listar as UBS da sessão (decisão pendente com Larissa e Alexandre). Lança `DadosInvalidos` / `EstadoInvalido`.
  Future<void> cadastrar(Crianca crianca);

  /// Edita os dados da criança (nome, sexo, bairro, endereço, nascimento,
  /// responsável). `ativa`, `ubs` e `cadastradoEm` são ignorados. [motivo]
  /// de 3 a 200 caracteres, gravado no histórico de alterações.
  Future<void> editar(Crianca crianca, {required String motivo});

  /// Desativa o cadastro (exclusão lógica). Some de [observarTodas] e
  /// [buscar], e não recebe novas avaliações.
  Future<void> desativar(String id, {required String motivo});
}
