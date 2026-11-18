import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../routes.dart';
import '../../services/validadores.dart';
import '../../theme/app_colors.dart';
import '../../utils/cpf_input_formatter.dart';
import '../../widgets/common.dart';

/// TELA 05 — Cadastro da Criança (ficha de identificação).
class CadastroCriancaScreen extends StatefulWidget {
  const CadastroCriancaScreen({super.key});

  @override
  State<CadastroCriancaScreen> createState() => _CadastroCriancaScreenState();
}

class _CadastroCriancaScreenState extends State<CadastroCriancaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cpfCrianca = TextEditingController();
  final _nascimento = TextEditingController();
  final _bairro = TextEditingController();
  final _responsavel = TextEditingController();
  final _cpfResponsavel = TextEditingController();
  final _contato = TextEditingController();
  final _nascimentoKey = GlobalKey<FormFieldState<String>>();
  final _sexoKey = GlobalKey<FormFieldState<Sexo>>();
  DateTime? _dataNascimento;
  String? _ubs;

  @override
  void dispose() {
    for (final controller in [
      _nome,
      _cpfCrianca,
      _nascimento,
      _bairro,
      _responsavel,
      _cpfResponsavel,
      _contato,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _escolherNascimento() async {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final data = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? hoje,
      firstDate: DateTime(1900),
      lastDate: hoje,
    );
    if (!mounted || data == null) return;
    _dataNascimento = data;
    _nascimento.text =
        '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/${data.year}';
    _nascimentoKey.currentState?.validate();
  }

  static const _ubsOpcoes = [
    'UBS Jardim das Flores',
    'UBS Rosa Elze',
    'UBS Ponto Novo',
    'UBS Centro',
  ];

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    return Scaffold(
      appBar: const BackAppBar(title: 'Cadastro da Criança'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const Text(
              'Dados de Identificação',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            gap,
            LabeledField(
              controller: _nome,
              label: 'Nome completo',
              required: true,
              hint: 'Digite o nome da criança',
            ),
            gap,
            LabeledField(
              controller: _cpfCrianca,
              label: 'CPF da criança',
              hint: '000.000.000-00',
              icon: Icons.child_care_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [CpfInputFormatter()],
              validator: (v) => validarCpf(v, obrigatorio: false),
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabeledField(
                    controller: _nascimento,
                    fieldKey: _nascimentoKey,
                    label: 'Nascimento',
                    required: true,
                    hint: 'DD/MM/AAAA',
                    icon: Icons.cake_outlined,
                    readOnly: true,
                    onTap: _escolherNascimento,
                    validator: (_) => _dataNascimento == null
                        ? 'Escolha a data de nascimento'
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _sexoToggle()),
              ],
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabeledField(
                    controller: _bairro,
                    label: 'Bairro',
                    required: true,
                    hint: 'Ex.: Centro',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('UBS de Referência', required: true),
                      DropdownButtonFormField<String>(
                        initialValue: _ubs,
                        isExpanded: true,
                        hint: const Text(
                          'Selecione',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: [
                          for (final u in _ubsOpcoes)
                            DropdownMenuItem(
                              value: u,
                              child: Text(u, overflow: TextOverflow.ellipsis),
                            ),
                        ],
                        validator: (v) => v == null ? 'Selecione' : null,
                        onChanged: (v) => setState(() => _ubs = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            gap,
            LabeledField(
              controller: _responsavel,
              label: 'Responsável legal',
              required: true,
              hint: 'Nome do pai, mãe ou tutor',
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabeledField(
                    controller: _cpfResponsavel,
                    label: 'CPF Responsável',
                    required: true,
                    hint: '000.000.000-00',
                    keyboardType: TextInputType.number,
                    inputFormatters: [CpfInputFormatter()],
                    validator: validarCpf,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LabeledField(
                    controller: _contato,
                    label: 'Contato',
                    required: true,
                    hint: '(00) 00000-0000',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pushNamed(
                    context,
                    Routes.registroMedidas,
                    arguments: Crianca(
                      nome: _nome.text.trim(),
                      sexo: _sexoKey.currentState!.value!,
                      bairro: _bairro.text.trim(),
                      cadastradoEm: '',
                      nascimento: _nascimento.text,
                      ubs: _ubs!,
                      responsavel: Responsavel(
                        nome: _responsavel.text.trim(),
                        cpfMascarado: _cpfResponsavel.text,
                        telefone: _contato.text.trim(),
                        email: '',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Salvar e Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sexoToggle() {
    return FormField<Sexo>(
      key: _sexoKey,
      validator: (sexo) => sexo == null ? 'Selecione o sexo' : null,
      builder: (field) {
        Widget option(Sexo s, String label) {
          final selected = field.value == s;
          void selecionar() {
            field.didChange(s);
            field.validate();
          }

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: s == Sexo.feminino ? 4 : 0),
              child: Semantics(
                label: label,
                button: true,
                selected: selected,
                inMutuallyExclusiveGroup: true,
                onTap: selecionar,
                excludeSemantics: true,
                child: Material(
                  color: selected ? AppColors.primary : AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: selecionar,
                    child: SizedBox(
                      height: 48,
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: selected
                                ? Colors.white
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Sexo', required: true),
            Row(
              children: [
                option(Sexo.masculino, 'Masculino'),
                option(Sexo.feminino, 'Feminino'),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
