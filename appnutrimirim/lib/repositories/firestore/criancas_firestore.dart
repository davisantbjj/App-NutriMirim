import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models.dart';
import '../busca.dart';
import '../crianca_repository.dart';
import '../excecoes.dart';
import '../sessao_profissional.dart';
import '../validacao.dart';
import 'conversoes.dart';
import 'erros_firestore.dart';

/// [CriancaRepository] sobre o Cloud Firestore, seguindo `docs/firestore.md`
/// e `firestore.rules`.
///
/// - Profissional (não master): toda consulta leva
///   `where('ubsId', whereIn: sessao.ubsIds)` (as regras negam sem isso; o
///   `whereIn` aceita até 30 UBS). Master consulta sem filtro de UBS.
/// - A ordenação por nome é feita no app (sobre `nomeBusca`), o que evita
///   exigir um índice composto a mais para o master.
/// - Edição e desativação gravam o log `alteracoes/{versao}` no MESMO
///   `WriteBatch` (sem transação, para funcionar offline). O Future de
///   gravação só completa quando o servidor confirma.
class CriancaRepositoryFirestore implements CriancaRepository {
  CriancaRepositoryFirestore({
    required this.sessao,
    FirebaseFirestore? firestore,
    DateTime Function()? agora,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _agora = agora ?? DateTime.now;

  final SessaoProfissional sessao;
  final FirebaseFirestore _db;
  final DateTime Function() _agora;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('criancas');

  /// Consulta base com o filtro de UBS; null se o usuário não tem UBS.
  Query<Map<String, dynamic>>? get _escopo {
    if (sessao.master) return _col;
    if (sessao.ubsIds.isEmpty) return null;
    return _col.where('ubsId', whereIn: sessao.ubsIds);
  }

  Crianca _converter(DocumentSnapshot<Map<String, dynamic>> doc) =>
      criancaDeMap(doc.id, doc.data()!, nomesUbs: sessao.nomesUbs);

  List<Crianca> _ativas(QuerySnapshot<Map<String, dynamic>> snap) =>
      ordenarPorNome(snap.docs.map(_converter));

  @override
  String novoId() => _col.doc().id;

  @override
  Stream<List<Crianca>> observarTodas() {
    final q = _escopo;
    if (q == null) return Stream.value(const []);
    return q
        .where('ativa', isEqualTo: true)
        .snapshots()
        .map(_ativas)
        .handleError(traduzirErro);
  }

  /// Usa `doc.snapshots()`. `permission-denied` emite `null` e o stream termina
  /// (o Firestore encerra a escuta); outros erros viram `RepositorioException`.
  @override
  Stream<Crianca?> observarPorId(String id) => _col
      .doc(id)
      .snapshots()
      .transform(
        StreamTransformer<
          DocumentSnapshot<Map<String, dynamic>>,
          Crianca?
        >.fromHandlers(
          handleData: (doc, sink) =>
              sink.add(doc.exists ? _converter(doc) : null),
          handleError: (erro, pilha, sink) {
            if (erro is FirebaseException && erro.code == 'permission-denied') {
              sink.add(null);
            } else {
              sink.addError(erroTraduzido(erro), pilha);
            }
          },
        ),
      );

  @override
  Future<Crianca?> porId(String id) => traduzir(() async {
    try {
      final doc = await _col.doc(id).get();
      return doc.exists ? _converter(doc) : null;
    } on FirebaseException catch (e) {
      // Doc inexistente ou de outra UBS: as regras respondem permission-denied.
      if (e.code == 'permission-denied') return null;
      rethrow;
    }
  });

  @override
  Future<List<Crianca>> buscar(String termo) => traduzir(() async {
    final q = _escopo;
    if (q == null) return const <Crianca>[];
    final cpf = cpfDoTermo(termo);
    if (cpf != null) {
      // CPF: igualdade no servidor (e no cache, offline).
      final snap = await q
          .where('ativa', isEqualTo: true)
          .where('responsavel.cpf', isEqualTo: cpf)
          .get();
      return _ativas(snap);
    }
    // Nome parcial: lê as ativas (cache offline) e filtra no app.
    final snap = await q.where('ativa', isEqualTo: true).get();
    return filtrarCriancas(snap.docs.map(_converter), termo);
  });

  @override
  Future<void> cadastrar(Crianca crianca) => traduzir(() async {
    validarCrianca(crianca, _agora());
    if (crianca.id.isEmpty) {
      throw const DadosInvalidos('Use novoId() para gerar o id da criança.');
    }
    if (sessao.ubsAtualId.isEmpty) {
      throw const DadosInvalidos('Nenhuma UBS selecionada para o cadastro.');
    }
    await _col.doc(crianca.id).set({
      ...criancaParaMap(crianca, ubsId: sessao.ubsAtualId),
      'versao': 0,
      'criadoPor': sessao.uid,
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  });

  @override
  Future<void> editar(Crianca crianca, {required String motivo}) =>
      traduzir(() async {
        final m = validarMotivo(motivo);
        validarCrianca(crianca, _agora());
        final (ref, antes) = await _lerAtual(crianca.id);
        await _gravarAlteracao(
          ref,
          antes,
          criancaEditavelParaMap(crianca, anterior: antes),
          m,
        );
      });

  @override
  Future<void> desativar(String id, {required String motivo}) =>
      traduzir(() async {
        final m = validarMotivo(motivo);
        final (ref, antes) = await _lerAtual(id);
        if (antes['ativa'] == false) {
          throw const EstadoInvalido('Este cadastro já está desativado.');
        }
        await _gravarAlteracao(ref, antes, {'ativa': false}, m);
      });

  Future<(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>
  _lerAtual(String id) async {
    final ref = _col.doc(id);
    final DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await ref.get();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const NaoEncontrado('Criança não encontrada.');
      }
      rethrow;
    }
    if (!doc.exists) throw const NaoEncontrado('Criança não encontrada.');
    return (ref, doc.data()!);
  }

  /// Atualiza a criança e cria `alteracoes/{versao}` no mesmo lote, com os
  /// valores anteriores que as regras conferem.
  Future<void> _gravarAlteracao(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> antes,
    Map<String, Object?> mudancas,
    String motivo,
  ) {
    final versao = ((antes['versao'] as num?) ?? 0).toInt() + 1;
    final lote = _db.batch();
    lote.update(ref, {
      ...mudancas,
      'versao': versao,
      'atualizadoEm': FieldValue.serverTimestamp(),
      'alteradoPor': sessao.uid,
      'alteradoEm': FieldValue.serverTimestamp(),
      'motivoAlteracao': motivo,
    });
    lote.set(ref.collection('alteracoes').doc('$versao'), {
      'alteradoPor': sessao.uid,
      'alteradoEm': FieldValue.serverTimestamp(),
      'motivo': motivo,
      'versao': versao,
      'nomeAnterior': antes['nome'],
      'responsavelAnterior': antes['responsavel'],
      'ativaAnterior': antes['ativa'],
      'nascimentoAnterior': antes['nascimento'],
      'sexoAnterior': antes['sexo'],
      'bairroAnterior': antes['bairro'],
      'enderecoAnterior': antes['endereco'],
    });
    return lote.commit();
  }
}
