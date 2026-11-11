// Formatação de números e datas no padrão brasileiro (funções puras).

String _dois(int v) => v.toString().padLeft(2, '0');

/// Número com vírgula decimal: `formatarDecimal(9.8)` -> `9,8`.
String formatarDecimal(double valor, {int casas = 1}) =>
    valor.toStringAsFixed(casas).replaceAll('.', ',');

/// Como [formatarDecimal], mas sem casas quando o valor é inteiro:
/// 85.0 -> `85`, 12.5 -> `12,5`.
String formatarNumero(double valor, {int casas = 1}) {
  final texto = formatarDecimal(valor, casas: casas);
  // Tira os zeros finais depois de arredondar: 85,0 -> 85; 85,04 -> 85.
  return texto.contains(',') ? texto.replaceFirst(RegExp(r',?0+$'), '') : texto;
}

/// Peso em kg com uma casa: `9,8 kg`.
String formatarPeso(double kg) => '${formatarDecimal(kg)} kg';

/// Altura em cm, sem casas quando inteira: `85 cm`, `85,5 cm`.
String formatarAltura(double cm) => '${formatarNumero(cm)} cm';

/// Data no formato `dd/mm/aaaa`: `05/11/2026`.
String formatarData(DateTime data) =>
    '${_dois(data.day)}/${_dois(data.month)}/${data.year}';

/// Data e hora: `28/09/2026 às 08:42`.
String formatarDataHora(DateTime d) =>
    '${formatarData(d)} às ${_dois(d.hour)}:${_dois(d.minute)}';

/// Idade em meses completos entre [nascimento] e [hoje] (padrão: agora).
int idadeEmMeses(DateTime nascimento, {DateTime? hoje}) {
  final ref = hoje ?? DateTime.now();
  var meses = (ref.year - nascimento.year) * 12 + ref.month - nascimento.month;
  if (ref.day < nascimento.day) meses--;
  return meses < 0 ? 0 : meses;
}

/// Idade legível: `8 meses`, `1 mês`, `2 anos`, `2 anos e 3 meses`.
/// Abaixo de 24 meses a idade fica só em meses, como na caderneta da criança
/// e nas curvas da OMS (ex.: `18 meses`, não `1 ano e 6 meses`).
String formatarIdade(DateTime nascimento, {DateTime? hoje}) {
  final meses = idadeEmMeses(nascimento, hoje: hoje);
  if (meses < 24) return meses == 1 ? '1 mês' : '$meses meses';
  final anos = meses ~/ 12;
  final resto = meses % 12;
  final a = '$anos anos';
  if (resto == 0) return a;
  return '$a e $resto ${resto == 1 ? 'mês' : 'meses'}';
}
