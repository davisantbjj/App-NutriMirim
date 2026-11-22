// Utilitários de texto para busca (RF11) e para campos só com números.

const _comAcento = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
const _semAcento = 'aaaaaaceeeeiiiinooooouuuuyy';

/// Minúsculas, sem acento e sem espaços sobrando ("  João  Rocha " vira
/// "joao rocha"). É o valor gravado em `nomeBusca` e usado para comparar buscas.
String normalizarBusca(String texto) {
  final minusculo = texto.toLowerCase();
  final saida = StringBuffer();
  for (final r in minusculo.runes) {
    final c = String.fromCharCode(r);
    final i = _comAcento.indexOf(c);
    saida.write(i >= 0 ? _semAcento[i] : c);
  }
  return saida.toString().trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Só os dígitos de [texto] (CPF e telefone são gravados assim).
String somenteDigitos(String texto) => texto.replaceAll(RegExp(r'\D'), '');
