import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import '../../data/models.dart';
import '../../utils/input_formatters.dart';
import '../../utils/texto.dart';

/// Conversões puras entre os modelos e os mapas do Firestore (ver
/// `docs/firestore.md`). Não usam Firebase além da classe [Timestamp], então
/// testam sem inicializar nada. Os campos de servidor (`criadoEm`,
/// `atualizadoEm`, `alteradoEm`, `versao`...) são acrescentados pelos
/// repositórios.

// ---------------------------------------------------------------- leitura tolerante

// Campo com tipo errado vira null (e o chamador usa o padrão), sem TypeError.
String? _texto(Object? v) => v is String ? v : null;
bool? _booleano(Object? v) => v is bool ? v : null;
double? _numero(Object? v) => v is num ? v.toDouble() : null;

// ---------------------------------------------------------------- datas

String _dois(int v) => v.toString().padLeft(2, '0');

/// Data sem hora como `aaaa-mm-dd`, pelos componentes LOCAIS (nunca converte
/// para UTC, para não virar o dia anterior no fuso de Brasília).
String dataParaTexto(DateTime d) {
  final l = d.isUtc ? d.toLocal() : d;
  return '${l.year.toString().padLeft(4, '0')}-${_dois(l.month)}-${_dois(l.day)}';
}

final _regexData = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// `aaaa-mm-dd` -> `DateTime` local à meia-noite; null se vazio ou inválido.
DateTime? textoParaData(Object? valor) {
  if (valor is! String) return null;
  final m = _regexData.firstMatch(valor);
  if (m == null) return null;
  final ano = int.parse(m.group(1)!);
  final mes = int.parse(m.group(2)!);
  final dia = int.parse(m.group(3)!);
  final d = DateTime(ano, mes, dia);
  // Rejeita datas que "rolam" (31/02 viraria 03/03).
  if (d.year != ano || d.month != mes || d.day != dia) return null;
  return d;
}

/// Instante (`Timestamp`) -> `DateTime` local; null se não for Timestamp.
DateTime? timestampParaData(Object? valor) =>
    valor is Timestamp ? valor.toDate() : null;

// ---------------------------------------------------------------- enums

Sexo sexoDeTexto(Object? valor) =>
    Sexo.values.firstWhere((s) => s.name == valor, orElse: () => Sexo.feminino);

Situacao situacaoDeTexto(Object? valor) => Situacao.values.firstWhere(
  (s) => s.name == valor,
  orElse: () => Situacao.normal,
);

// ---------------------------------------------------------------- CPF/telefone

/// `00000000000` -> `000.000.000-00` (a tela do cadastro usa essa máscara).
String formatarCpfDigitos(String digitos) {
  if (digitos.length != 11) return digitos;
  return '${digitos.substring(0, 3)}.${digitos.substring(3, 6)}.'
      '${digitos.substring(6, 9)}-${digitos.substring(9)}';
}

String _formatarTelefoneDigitos(String digitos) =>
    const TelefoneInputFormatter().formatar(digitos);

bool _cpfGravavel(String digitos) => digitos.length == 11;
bool _telefoneGravavel(String digitos) =>
    digitos.length == 10 || digitos.length == 11;

// ---------------------------------------------------------------- responsável

/// Mapa `responsavel`: CPF e telefone só com dígitos.
/// - Campo vazio: o valor some do mapa (apaga o que havia).
/// - Campo mascarado com `*` (CPF escondido por privacidade): não é gravado e,
///   se houver um valor válido em [anterior] (edição), ele é preservado.
/// - Qualquer outro valor com tamanho errado NÃO é gravado aqui; quem chama deve
///   ter validado antes com `validarCrianca`, que lança `DadosInvalidos`.
/// E-mail vazio some do mapa.
Map<String, Object?> responsavelParaMap(
  Responsavel r, {
  Map<String, Object?>? anterior,
}) {
  final mapa = <String, Object?>{'nome': r.nome.trim()};

  final cpf = _digitosOuAnterior(
    r.cpfMascarado,
    anterior?['cpf'],
    _cpfGravavel,
  );
  if (cpf != null) mapa['cpf'] = cpf;

  final tel = _digitosOuAnterior(
    r.telefone,
    anterior?['telefone'],
    _telefoneGravavel,
  );
  if (tel != null) mapa['telefone'] = tel;

  final email = r.email.trim();
  if (email.isNotEmpty) mapa['email'] = email;
  return mapa;
}

String? _digitosOuAnterior(
  String texto,
  Object? anterior,
  bool Function(String) valido,
) {
  final digitos = somenteDigitos(texto);
  if (texto.contains('*')) {
    return anterior is String && valido(anterior) ? anterior : null;
  }
  return valido(digitos) ? digitos : null;
}

Responsavel? responsavelDeMap(Object? valor) {
  if (valor is! Map) return null;
  final cpf = valor['cpf'];
  final tel = valor['telefone'];
  return Responsavel(
    nome: _texto(valor['nome']) ?? '',
    cpfMascarado: cpf is String ? formatarCpfDigitos(cpf) : '',
    telefone: tel is String ? _formatarTelefoneDigitos(tel) : '',
    email: _texto(valor['email']) ?? '',
  );
}

// ---------------------------------------------------------------- criança

/// Campos que a edição pode mudar (sem versão/auditoria, que o repositório
/// acrescenta). [anterior] é o documento atual (para preservar CPF/telefone).
Map<String, Object?> criancaEditavelParaMap(
  Crianca c, {
  Map<String, Object?>? anterior,
}) {
  final nome = c.nome.trim();
  final anteriorResp = anterior?['responsavel'];
  return {
    'nome': nome,
    'nomeBusca': normalizarBusca(nome),
    'sexo': c.sexo.name,
    'bairro': c.bairro,
    'endereco': c.endereco,
    'nascimento': c.nascimento == null ? null : dataParaTexto(c.nascimento!),
    'responsavel': c.responsavel == null
        ? null
        : responsavelParaMap(
            c.responsavel!,
            anterior: anteriorResp is Map
                ? Map<String, Object?>.from(anteriorResp)
                : null,
          ),
  };
}

/// Campos de um cadastro novo (o repositório soma `versao: 0`, `criadoPor`,
/// `criadoEm` e `atualizadoEm`). A criança sempre nasce ativa.
Map<String, Object?> criancaParaMap(Crianca c, {required String ubsId}) => {
  'ubsId': ubsId,
  ...criancaEditavelParaMap(c),
  'cadastradoEm': dataParaTexto(c.cadastradoEm),
  'ativa': true,
};

/// Documento -> [Crianca]. [nomesUbs] traduz `ubsId` em `Crianca.ubs`.
Crianca criancaDeMap(
  String id,
  Map<String, Object?> d, {
  Map<String, String> nomesUbs = const {},
}) {
  final ubsId = _texto(d['ubsId']) ?? '';
  return Crianca(
    id: id,
    nome: _texto(d['nome']) ?? '',
    sexo: sexoDeTexto(d['sexo']),
    bairro: _texto(d['bairro']) ?? '',
    endereco: _texto(d['endereco']) ?? '',
    ubs: nomesUbs[ubsId] ?? ubsId,
    microarea: _texto(d['microarea']),
    cadastradoEm: textoParaData(d['cadastradoEm']) ?? DateTime(2000),
    nascimento: textoParaData(d['nascimento']),
    responsavel: responsavelDeMap(d['responsavel']),
    ativa: _booleano(d['ativa']) ?? true,
  );
}

// ---------------------------------------------------------------- indicadores

/// Nome por extenso mostrado na tela de Resultado para cada chave.
const nomesIndicadores = {
  'pi': 'Peso para idade (P/I)',
  'ei': 'Estatura para idade (E/I)',
  'pe': 'Peso para estatura (P/E)',
  'imci': 'IMC para idade (IMC/I)',
};

/// `{pi: Indicador}` -> `{pi: {zScore, situacao}}`.
Map<String, Object?> indicadoresParaMap(Map<String, Indicador> indicadores) => {
  for (final e in indicadores.entries)
    e.key: {'zScore': e.value.zScore, 'situacao': e.value.situacao.name},
};

Map<String, Indicador> indicadoresDeMap(Object? valor) {
  if (valor is! Map) return const {};
  final saida = <String, Indicador>{};
  for (final chave in ['pi', 'ei', 'pe', 'imci']) {
    final i = valor[chave];
    if (i is Map) {
      saida[chave] = Indicador(
        nomesIndicadores[chave]!,
        _numero(i['zScore']) ?? 0,
        situacaoDeTexto(i['situacao']),
      );
    }
  }
  return saida;
}

// ---------------------------------------------------------------- avaliação

/// Campos que a correção pode mudar (sem versão/auditoria).
Map<String, Object?> avaliacaoCorrigivelParaMap(Avaliacao a) => {
  'data': Timestamp.fromDate(a.data),
  'pesoKg': a.pesoKg,
  'alturaCm': a.alturaCm,
  'tipoMedida': a.tipoMedida,
  'situacao': a.situacao.name,
  'indicadores': indicadoresParaMap(a.indicadores),
  'desnutricao': a.desnutricao,
  'versaoTabelaOms': a.versaoTabelaOms,
  'retornoSugerido': a.retornoSugerido == null
      ? null
      : dataParaTexto(a.retornoSugerido!),
};

/// Campos de uma avaliação nova (o repositório soma `versao: 0`, `criadoEm` e
/// `atualizadoEm`). `profissionalId`/`profissionalNome`/`microarea` vêm da
/// sessão, não do modelo. Campos opcionais nulos ficam de fora.
Map<String, Object?> avaliacaoParaMap(
  Avaliacao a, {
  required String ubsId,
  required String profissionalId,
  required String profissionalNome,
  String? microarea,
}) {
  final corrigivel = avaliacaoCorrigivelParaMap(a)
    ..removeWhere((k, v) => v == null);
  return {
    'ubsId': ubsId,
    'criancaId': a.criancaId,
    'profissionalId': profissionalId,
    'profissionalNome': profissionalNome,
    if (microarea != null && microarea.isNotEmpty) 'microarea': microarea,
    ...corrigivel,
    'excluida': false,
  };
}

/// Documento -> [Avaliacao].
Avaliacao avaliacaoDeMap(String id, Map<String, Object?> d) => Avaliacao(
  id: id,
  criancaId: _texto(d['criancaId']) ?? '',
  data: timestampParaData(d['data']) ?? DateTime(2000),
  pesoKg: _numero(d['pesoKg']) ?? 0,
  alturaCm: _numero(d['alturaCm']) ?? 0,
  situacao: situacaoDeTexto(d['situacao']),
  criadoEm: timestampParaData(d['criadoEm']),
  profissionalId: _texto(d['profissionalId']),
  profissionalNome: _texto(d['profissionalNome']),
  microarea: _texto(d['microarea']),
  tipoMedida: _texto(d['tipoMedida']),
  indicadores: indicadoresDeMap(d['indicadores']),
  desnutricao: _booleano(d['desnutricao']) ?? false,
  versaoTabelaOms: _texto(d['versaoTabelaOms']) ?? 'oms-2006',
  retornoSugerido: textoParaData(d['retornoSugerido']),
  excluida: _booleano(d['excluida']) ?? false,
);
