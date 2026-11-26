import '../../data/models.dart';
import '../../utils/texto.dart';
import '../busca.dart';
import '../crianca_repository.dart';
import '../excecoes.dart';
import '../validacao.dart';
import 'banco_memoria.dart';

/// [CriancaRepository] em memória (testes e app sem login). Copia as regras do
/// Firestore que fazem sentido sem servidor: motivo obrigatório, validações.
class CriancaRepositoryMemoria implements CriancaRepository {
  /// Repositório sobre [banco] (vazio se omitido). Para compartilhar dados com
  /// o repositório de avaliações, passe o mesmo [BancoMemoria] aos dois.
  CriancaRepositoryMemoria([BancoMemoria? banco])
    : banco = banco ?? BancoMemoria();

  /// Banco próprio já com os dados do mock.
  CriancaRepositoryMemoria.comMock() : banco = BancoMemoria.comMock();

  final BancoMemoria banco;

  List<Crianca> _ativas() => List.unmodifiable(
    ordenarPorNome(banco.criancas.values.where((c) => c.ativa)),
  );

  @override
  String novoId() => banco.novoId('c');

  @override
  Stream<List<Crianca>> observarTodas() => banco.observar(_ativas);

  @override
  Stream<Crianca?> observarPorId(String id) =>
      banco.observar(() => banco.criancas[id]);

  @override
  Future<Crianca?> porId(String id) async => banco.criancas[id];

  @override
  Future<List<Crianca>> buscar(String termo) async =>
      filtrarCriancas(banco.criancas.values.where((c) => c.ativa), termo);

  @override
  Future<void> cadastrar(Crianca crianca, {String? ubsId}) async {
    validarCrianca(crianca, banco.agora());
    if (crianca.id.isEmpty) {
      throw const DadosInvalidos('Use novoId() para gerar o id da criança.');
    }
    if (banco.criancas.containsKey(crianca.id)) {
      throw const EstadoInvalido('Já existe uma criança com este id.');
    }
    banco.criancas[crianca.id] = crianca.copyWith(
      nome: crianca.nome.trim(),
      ativa: true,
    );
    banco.versoes[crianca.id] = 0;
    banco.notificar();
  }

  @override
  Future<void> editar(Crianca crianca, {required String motivo}) async {
    final m = validarMotivo(motivo);
    final atual = banco.criancas[crianca.id];
    if (atual == null) throw const NaoEncontrado('Criança não encontrada.');
    validarCrianca(crianca, banco.agora());
    banco.criancas[crianca.id] = atual.copyWith(
      nome: crianca.nome.trim(),
      sexo: crianca.sexo,
      cpf: crianca.cpf,
      bairro: crianca.bairro,
      endereco: crianca.endereco,
      nascimento: crianca.nascimento,
      limparNascimento: crianca.nascimento == null,
      responsavel: _preservarMascarados(crianca.responsavel, atual.responsavel),
      limparResponsavel: crianca.responsavel == null,
    );
    _registrar(crianca.id, m, 'edicao');
    banco.notificar();
  }

  @override
  Future<void> desativar(String id, {required String motivo}) async {
    final m = validarMotivo(motivo);
    final atual = banco.criancas[id];
    if (atual == null) throw const NaoEncontrado('Criança não encontrada.');
    if (!atual.ativa) {
      throw const EstadoInvalido('Este cadastro já está desativado.');
    }
    banco.criancas[id] = atual.copyWith(ativa: false);
    _registrar(id, m, 'desativacao');
    banco.notificar();
  }

  /// Igual ao Firestore: CPF/telefone vindos mascarados com `*` mantêm o
  /// valor antigo (se este estiver completo).
  Responsavel? _preservarMascarados(Responsavel? novo, Responsavel? antigo) {
    if (novo == null || antigo == null) return novo;
    String manter(String n, String a, int minimo, int maximo) {
      final d = somenteDigitos(a).length;
      return n.contains('*') && d >= minimo && d <= maximo ? a : n;
    }

    return Responsavel(
      nome: novo.nome,
      cpfMascarado: manter(novo.cpfMascarado, antigo.cpfMascarado, 11, 11),
      telefone: manter(novo.telefone, antigo.telefone, 10, 11),
      email: novo.email,
    );
  }

  void _registrar(String id, String motivo, String acao) {
    final versao = banco.proximaVersao(id);
    banco.versoes[id] = versao;
    banco.alteracoes.add(
      AlteracaoMemoria(
        colecao: 'criancas',
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
