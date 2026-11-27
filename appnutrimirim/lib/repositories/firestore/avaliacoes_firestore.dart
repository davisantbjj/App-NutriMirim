import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models.dart';
import '../avaliacao_repository.dart';
import '../excecoes.dart';
import '../sessao_profissional.dart';
import '../validacao.dart';
import 'conversoes.dart';
import 'erros_firestore.dart';

/// [AvaliacaoRepository] sobre o Cloud Firestore, seguindo `docs/firestore.md`
/// e `firestore.rules`.
///
/// - Profissional (não master): toda consulta leva
///   `where('ubsId', whereIn: sessao.ubsIds)`; master consulta sem filtro.
/// - Listas: `excluida == false` e `orderBy('data', descending: true)` (índices
///   em `firestore.indexes.json`).
/// - Correção e exclusão gravam o log `alteracoes/{versao}` no MESMO
///   `WriteBatch`, um registro por lote. O resumo da criança
///   (`ultimaSituacao`/`ultimaAvaliacaoEm`/`ultimaAvaliacaoId`; as regras
///   conferem os dois primeiros com a avaliação apontada) é gravado no mesmo lote do
///   registro; após correção/exclusão é refeito em um segundo lote (as regras
///   limitam os acessos por lote) e, se falhar, fica como estava (o resumo é só
///   uma dica; a verdade são as avaliações).
/// - Sem transações (não funcionam offline). O Future de gravação só completa
///   quando o servidor confirma.
class AvaliacaoRepositoryFirestore implements AvaliacaoRepository {
  AvaliacaoRepositoryFirestore({
    required this.sessao,
    FirebaseFirestore? firestore,
    DateTime Function()? agora,
    this.limiteHistorico = 500,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _agora = agora ?? DateTime.now;

  final SessaoProfissional sessao;

  /// Máximo de avaliações lidas no histórico geral ([observarTodas]).
  final int limiteHistorico;
  final FirebaseFirestore _db;
  final DateTime Function() _agora;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('avaliacoes');

  /// Consulta base (UBS do usuário + só não excluídas); null sem UBS.
  Query<Map<String, dynamic>>? get _escopo {
    final Query<Map<String, dynamic>> q;
    if (sessao.master) {
      q = _col;
    } else if (sessao.ubsIds.isEmpty) {
      return null;
    } else {
      q = _col.where('ubsId', whereIn: sessao.ubsIds);
    }
    return q.where('excluida', isEqualTo: false);
  }

  Avaliacao _converter(DocumentSnapshot<Map<String, dynamic>> doc) =>
      avaliacaoDeMap(doc.id, doc.data()!);

  List<Avaliacao> _lista(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map(_converter).toList();

  Query<Map<String, dynamic>>? _daCrianca(String criancaId) => _escopo
      ?.where('criancaId', isEqualTo: criancaId)
      .orderBy('data', descending: true);

  @override
  String novoId() => _col.doc().id;

  @override
  Stream<List<Avaliacao>> observarTodas() {
    final q = _escopo;
    if (q == null) return Stream.value(const []);
    return q
        .orderBy('data', descending: true)
        .limit(limiteHistorico)
        .snapshots()
        .map(_lista)
        .handleError(traduzirErro);
  }

  @override
  Stream<List<Avaliacao>> observarDe(String criancaId) {
    final q = _daCrianca(criancaId);
    if (q == null) return Stream.value(const []);
    return q.snapshots().map(_lista).handleError(traduzirErro);
  }

  @override
  Future<Avaliacao?> ultimaDe(String criancaId) => traduzir(() async {
    final q = _daCrianca(criancaId);
    if (q == null) return null;
    final snap = await q.limit(1).get();
    return snap.docs.isEmpty ? null : _converter(snap.docs.first);
  });

  @override
  Future<Avaliacao> registrar(Avaliacao avaliacao) => traduzir(() async {
    validarAvaliacao(avaliacao, _agora());
    final criancaRef = _db.collection('criancas').doc(avaliacao.criancaId);
    final criancaDoc = await _lerCrianca(criancaRef);
    final crianca = criancaDoc.data()!;
    if (crianca['ativa'] == false) {
      throw const EstadoInvalido(
        'Esta criança está desativada e não recebe novas avaliações.',
      );
    }
    final id = avaliacao.id.isEmpty ? novoId() : avaliacao.id;
    final ref = _col.doc(id);

    final lote = _db.batch();
    lote.set(ref, {
      ...avaliacaoParaMap(
        avaliacao,
        ubsId: crianca['ubsId'] as String,
        profissionalId: sessao.uid,
        profissionalNome: sessao.nome,
        profissionalPapel: sessao.papel,
        microarea: sessao.microarea,
      ),
      'versao': 0,
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });

    // Resumo da criança, no mesmo lote, só se esta for a avaliação mais nova
    // (registrar uma medição antiga não pode sobrescrever o resumo).
    final resumoAtual = crianca['ultimaAvaliacaoEm'];
    final maisNova =
        resumoAtual is! Timestamp ||
        !resumoAtual.toDate().isAfter(avaliacao.data);
    if (maisNova) {
      lote.update(criancaRef, {
        'ultimaSituacao': avaliacao.situacao.name,
        'ultimaAvaliacaoEm': Timestamp.fromDate(avaliacao.data),
        'ultimaAvaliacaoId': id,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    }
    await lote.commit();
    return avaliacao.copyWith(
      id: id,
      criadoEm: _agora(),
      profissionalId: sessao.uid,
      profissionalNome: sessao.nome,
      profissionalPapel: sessao.papel,
      excluida: false,
    );
  });

  @override
  Future<void> corrigir(Avaliacao avaliacao, {required String motivo}) =>
      traduzir(() async {
        final m = validarMotivo(motivo);
        final (ref, antes) = await _lerParaAlterar(avaliacao.id);
        validarAvaliacao(
          avaliacao.copyWith(criancaId: antes['criancaId'] as String),
          _agora(),
        );
        await _gravarAlteracao(
          ref,
          antes,
          avaliacaoCorrigivelParaMap(avaliacao),
          m,
          acao: 'correcao',
        );
        await _atualizarResumo(antes['criancaId'] as String);
      });

  @override
  Future<void> excluir(String id, {required String motivo}) =>
      traduzir(() async {
        final m = validarMotivo(motivo);
        final (ref, antes) = await _lerParaAlterar(id);
        await _gravarAlteracao(
          ref,
          antes,
          {'excluida': true, 'motivoExclusao': m},
          m,
          acao: 'exclusao',
        );
        await _atualizarResumo(antes['criancaId'] as String);
      });

  Future<DocumentSnapshot<Map<String, dynamic>>> _lerCrianca(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    const naoAchou = NaoEncontrado('Criança não encontrada.');
    final DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await ref.get();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw naoAchou;
      rethrow;
    }
    if (!doc.exists) throw naoAchou;
    return doc;
  }

  /// Lê a avaliação e confere, antes de ir ao servidor, existência, exclusão e
  /// autor/prazo (o servidor confere de novo: relógio local pode divergir).
  Future<(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>
  _lerParaAlterar(String id) async {
    const naoAchou = NaoEncontrado('Avaliação não encontrada.');
    final ref = _col.doc(id);
    final DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await ref.get();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw naoAchou;
      rethrow;
    }
    if (!doc.exists) throw naoAchou;
    final dados = doc.data()!;
    final atual = avaliacaoDeMap(id, dados);
    if (atual.excluida) {
      throw const EstadoInvalido('Esta avaliação já foi excluída.');
    }
    // criadoEm ainda pendente (null): deixa o servidor decidir.
    if (atual.criadoEm != null || sessao.master) {
      validarPodeCorrigir(
        atual,
        usuarioUid: sessao.uid,
        master: sessao.master,
        agora: _agora(),
      );
    } else if (atual.profissionalId != sessao.uid) {
      throw const PermissaoNegada(
        'Só quem registrou a avaliação pode corrigi-la ou excluí-la.',
      );
    }
    return (ref, dados);
  }

  /// Atualiza a avaliação e cria `alteracoes/{versao}` no mesmo lote, com os
  /// valores anteriores que as regras conferem.
  Future<void> _gravarAlteracao(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> antes,
    Map<String, Object?> mudancas,
    String motivo, {
    required String acao,
  }) {
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
      'acao': acao,
      'pesoKgAnterior': antes['pesoKg'],
      'alturaCmAnterior': antes['alturaCm'],
      'dataAnterior': antes['data'],
      'situacaoAnterior': antes['situacao'],
      'indicadoresAnterior': antes['indicadores'],
      'desnutricaoAnterior': antes['desnutricao'],
      'edemaAnterior': antes['edema'],
    });
    return lote.commit();
  }

  /// Refaz `ultimaSituacao`/`ultimaAvaliacaoEm` da criança a partir da
  /// avaliação mais recente que sobrou. Melhor esforço: o resumo é só uma dica.
  Future<void> _atualizarResumo(String criancaId) async {
    try {
      final criancaRef = _db.collection('criancas').doc(criancaId);
      final criancaDoc = await criancaRef.get();
      if (!criancaDoc.exists || criancaDoc.data()!['ativa'] == false) return;
      final ultima = await ultimaDe(criancaId);
      await criancaRef.update({
        'ultimaSituacao': ultima == null
            ? FieldValue.delete()
            : ultima.situacao.name,
        'ultimaAvaliacaoEm': ultima == null
            ? FieldValue.delete()
            : Timestamp.fromDate(ultima.data),
        'ultimaAvaliacaoId': ultima == null ? FieldValue.delete() : ultima.id,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      // Mantém o resumo anterior.
    } on RepositorioException {
      // Idem.
    }
  }
}
