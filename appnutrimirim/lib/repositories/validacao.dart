import '../data/models.dart';
import '../utils/texto.dart';
import '../services/validadores.dart';
import 'excecoes.dart';

/// RF14: tempo em que o autor ainda pode corrigir/excluir a avaliação.
const janelaCorrecao = Duration(minutes: 15);

/// Chaves dos indicadores no Firestore (e em `Avaliacao.indicadores`).
const chavesIndicadores = ['pi', 'ei', 'pe', 'imci'];

const _tiposMedida = ['deitado', 'em_pe'];

// Mesma expressão das regras do Firestore.
final _emailRegex = RegExp(r'^[^@ ]+@[^@ ]+[.][^@ ]+$');

/// Motivo sem espaços nas pontas, de 3 a 200 caracteres.
String validarMotivo(String? motivo) {
  final m = (motivo ?? '').trim();
  if (m.length < 3 || m.length > 200) throw const MotivoObrigatorio();
  return m;
}

bool _anoValido(DateTime d) => d.year >= 2000 && d.year <= 2099;

DateTime _soData(DateTime d) => DateTime(d.year, d.month, d.day);

/// Valida os campos de uma criança (cadastro e edição), com as mesmas faixas
/// das regras do Firestore.
void validarCrianca(Crianca c, DateTime agora) {
  final erroCpf = validarCpf(c.cpf, obrigatorio: false);
  if (erroCpf != null) throw DadosInvalidos('CPF da criança inválido.');
  final nome = c.nome.trim();
  if (nome.length < 2 || nome.length > 120) {
    throw const DadosInvalidos('O nome da criança deve ter de 2 a 120 letras.');
  }
  if (c.bairro.length > 80) {
    throw const DadosInvalidos('O bairro deve ter até 80 caracteres.');
  }
  if (c.endereco.length > 200) {
    throw const DadosInvalidos('O endereço deve ter até 200 caracteres.');
  }
  final hoje = _soData(agora);
  final nasc = c.nascimento;
  if (nasc != null && (!_anoValido(nasc) || _soData(nasc).isAfter(hoje))) {
    throw const DadosInvalidos('Data de nascimento inválida.');
  }
  if (!_anoValido(c.cadastradoEm) || _soData(c.cadastradoEm).isAfter(hoje)) {
    throw const DadosInvalidos('Data de cadastro inválida.');
  }
  final r = c.responsavel;
  if (r != null) {
    final n = r.nome.trim();
    if (n.length < 2 || n.length > 120) {
      throw const DadosInvalidos(
        'O nome do responsável deve ter de 2 a 120 letras.',
      );
    }
    // Vazio apaga o valor; com `*` (CPF escondido) o valor antigo é mantido.
    final cpf = r.cpf.trim();
    if (cpf.isNotEmpty &&
        !cpf.contains('*') &&
        somenteDigitos(cpf).length != 11) {
      throw const DadosInvalidos('CPF do responsável deve ter 11 dígitos.');
    }
    final tel = r.telefone.trim();
    final digitosTel = somenteDigitos(tel).length;
    if (tel.isNotEmpty &&
        !tel.contains('*') &&
        digitosTel != 10 &&
        digitosTel != 11) {
      throw const DadosInvalidos(
        'Telefone do responsável deve ter 10 ou 11 dígitos (com DDD).',
      );
    }
    final email = r.email.trim();
    if (email.isNotEmpty &&
        (email.length > 160 || !_emailRegex.hasMatch(email))) {
      throw const DadosInvalidos('E-mail do responsável inválido.');
    }
  }
}

/// Valida os campos de uma avaliação (registro e correção).
void validarAvaliacao(Avaliacao a, DateTime agora) {
  if (a.criancaId.isEmpty) {
    throw const DadosInvalidos('Avaliação sem criança.');
  }
  if (!(a.pesoKg >= 0.5 && a.pesoKg <= 60)) {
    throw const DadosInvalidos('O peso deve estar entre 0,5 e 60 kg.');
  }
  if (!(a.alturaCm >= 40 && a.alturaCm <= 130)) {
    throw const DadosInvalidos('A altura deve estar entre 40 e 130 cm.');
  }
  if (a.data.isBefore(DateTime(2000)) ||
      a.data.isAfter(agora.add(const Duration(days: 1)))) {
    throw const DadosInvalidos('Data da medição inválida.');
  }
  final tipo = a.tipoMedida;
  if (tipo != null && !_tiposMedida.contains(tipo)) {
    throw const DadosInvalidos('Tipo de medida deve ser "deitado" ou "em_pe".');
  }
  if (a.indicadores.isEmpty) {
    throw const DadosInvalidos('Informe pelo menos um indicador calculado.');
  }
  for (final e in a.indicadores.entries) {
    if (!chavesIndicadores.contains(e.key)) {
      throw DadosInvalidos('Indicador desconhecido: ${e.key}.');
    }
    final z = e.value.zScore;
    if (!(z >= -10 && z <= 10)) {
      throw DadosInvalidos('Z-score fora da faixa (-10 a 10): ${e.key}.');
    }
  }
  final v = a.versaoTabelaOms;
  if (v.isEmpty || v.length > 40) {
    throw const DadosInvalidos('Versão da tabela OMS inválida.');
  }
  final retorno = a.retornoSugerido;
  if (retorno != null && !_anoValido(retorno)) {
    throw const DadosInvalidos('Data de retorno inválida.');
  }
}

/// Decide se o usuário pode corrigir/excluir [a] agora (RF14): o master
/// sempre; o autor só até [janelaCorrecao] depois de `criadoEm`. Avaliação sem
/// autor ou sem `criadoEm` (dados antigos do mock) só o master.
void validarPodeCorrigir(
  Avaliacao a, {
  required String usuarioUid,
  required bool master,
  required DateTime agora,
}) {
  if (master) return;
  if (a.profissionalId == null || a.profissionalId != usuarioUid) {
    throw const PermissaoNegada(
      'Só quem registrou a avaliação pode corrigi-la ou excluí-la.',
    );
  }
  final criado = a.criadoEm;
  if (criado == null || !agora.isBefore(criado.add(janelaCorrecao))) {
    throw const PrazoCorrecaoExpirado();
  }
}
