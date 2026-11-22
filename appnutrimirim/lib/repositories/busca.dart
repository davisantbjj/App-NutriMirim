import '../data/models.dart';
import '../utils/texto.dart';

/// Ordena por nome sem acento/caixa (desempate pelo id), como `nomeBusca`.
List<Crianca> ordenarPorNome(Iterable<Crianca> criancas) {
  final lista = criancas.toList();
  lista.sort((a, b) {
    final c = normalizarBusca(a.nome).compareTo(normalizarBusca(b.nome));
    return c != 0 ? c : a.id.compareTo(b.id);
  });
  return lista;
}

/// Se [termo] tem 11 dígitos, devolve-os (busca por CPF); senão null.
String? cpfDoTermo(String termo) {
  final d = somenteDigitos(termo);
  return d.length == 11 ? d : null;
}

/// Filtra [criancas] pelo [termo] (RF11): CPF do responsável (11 dígitos) ou
/// nome parcial sem acento nem caixa. Termo vazio mantém todas. Já ordenado.
List<Crianca> filtrarCriancas(Iterable<Crianca> criancas, String termo) {
  final cpf = cpfDoTermo(termo);
  final nome = normalizarBusca(termo);
  final filtradas = criancas.where((c) {
    if (cpf != null) {
      return somenteDigitos(c.responsavel?.cpfMascarado ?? '') == cpf;
    }
    return nome.isEmpty || normalizarBusca(c.nome).contains(nome);
  });
  return ordenarPorNome(filtradas);
}
