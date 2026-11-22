import 'package:cloud_firestore/cloud_firestore.dart';

import '../excecoes.dart';

/// Traduz um erro do Firestore em [RepositorioException]; o que já for um
/// [RepositorioException] (ou outro tipo de erro) volta como está.
Object erroTraduzido(Object erro) {
  if (erro is! FirebaseException) return erro;
  switch (erro.code) {
    case 'permission-denied':
      // Texto neutro: o servidor não diz o motivo (UBS, autor ou prazo). O
      // `PrazoCorrecaoExpirado` vem da checagem local, antes de ir ao servidor.
      return const PermissaoNegada(
        'O servidor recusou a operação. Recarregue os dados e tente de novo.',
      );
    case 'unavailable':
      return const RepositorioException(
        'Sem conexão com o servidor. Tente de novo.',
      );
    case 'not-found':
      return const NaoEncontrado('Registro não encontrado.');
    default:
      return RepositorioException('Erro ao acessar os dados (${erro.code}).');
  }
}

/// Lança o erro traduzido por [erroTraduzido], preservando a pilha.
Never traduzirErro(Object erro, StackTrace pilha) =>
    Error.throwWithStackTrace(erroTraduzido(erro), pilha);

/// Executa [acao] traduzindo erros do Firestore.
Future<T> traduzir<T>(Future<T> Function() acao) async {
  try {
    return await acao();
  } catch (e, s) {
    traduzirErro(e, s);
  }
}
