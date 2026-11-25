/// Papéis de acesso (iguais ao campo `papel` de `profissionais/{uid}`).
enum PapelProfissional { master, acs, medico, nutricionista }

/// Quem está logado, como o repositório do Firestore precisa saber.
/// O AuthService (task do Alexandre) monta isto a partir de
/// `profissionais/{uid}` depois do login.
class SessaoProfissional {
  const SessaoProfissional({
    required this.uid,
    required this.nome,
    required this.papel,
    required this.ubsIds,
    required this.ubsAtualId,
    this.microarea,
    this.nomesUbs = const {},
  });

  final String uid;

  /// Cópia de `profissionais/{uid}.nome` (as regras exigem que bata).
  final String nome;
  final PapelProfissional papel;

  /// UBS onde o profissional atua (`perfil.ubsIds`).
  final List<String> ubsIds;

  /// UBS onde as crianças novas são cadastradas.
  final String ubsAtualId;
  final String? microarea;

  /// id da UBS -> nome (para preencher `Crianca.ubs`).
  final Map<String, String> nomesUbs;

  bool get master => papel == PapelProfissional.master;

  String get nomePapel => switch (papel) {
    PapelProfissional.master => 'Administrador',
    PapelProfissional.acs => 'Agente Comunitário de Saúde',
    PapelProfissional.medico => 'Médico(a)',
    PapelProfissional.nutricionista => 'Nutricionista',
  };

  SessaoProfissional copyWith({String? ubsAtualId}) =>
      SessaoProfissional(
        uid: uid,
        nome: nome,
        papel: papel,
        ubsIds: ubsIds,
        ubsAtualId: ubsAtualId ?? this.ubsAtualId,
        microarea: microarea,
        nomesUbs: nomesUbs,
      );
}
