import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/mock_data.dart';
import '../../routes.dart';
import '../../services/validadores.dart';
import '../../theme/app_colors.dart';
import '../../utils/input_formatters.dart';
import '../../widgets/common.dart';
import '../../utils/formatters.dart';

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
  Sexo? _sexo;
  String? _ubs;
  String? _criancaId;
  bool _preenchido = false;

  static const _ubsOpcoes = [
    'UBS Jardim das Flores',
    'UBS Rosa Elze',
    'UBS Ponto Novo',
    'UBS Centro',
  ];

  @override
  void dispose() {
    _nome.dispose();
    _cpfCrianca.dispose();
    _nascimento.dispose();
    _bairro.dispose();
    _responsavel.dispose();
    _cpfResponsavel.dispose();
    _contato.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_preenchido) return;

    final arg = ModalRoute.of(context)?.settings.arguments;
    final criancaId = arg is String
        ? arg
        : arg is Crianca
        ? arg.id
        : null;
    if (criancaId == null) return;

    final crianca = MockData.criancaPorId(criancaId);
    if (crianca == null) return;

    _preenchido = true;
    _criancaId = crianca.id;
    _nome.text = crianca.nome;
    _nascimento.text = crianca.nascimento == null
        ? ''
        : formatarData(crianca.nascimento!);
    _sexo = crianca.sexo;
    _bairro.text = crianca.bairro;
    _ubs = crianca.ubs;
    final responsavel = crianca.responsavel;
    if (responsavel != null) {
      _responsavel.text = responsavel.nome;
      _cpfResponsavel.text = responsavel.cpfMascarado;
      _contato.text = responsavel.telefone;
    }
  }

  Future<void> _escolherNascimento() async {
    final hoje = DateTime.now();
    final data = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: DateTime(hoje.year - 6),
      lastDate: hoje,
    );
    if (!mounted || data == null) return;

    _nascimento.text = formatarData(data);
  }

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
              inputFormatters: const [CpfInputFormatter()],
              validator: (valor) => validarCpf(valor, obrigatorio: false),
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabeledField(
                    controller: _nascimento,
                    label: 'Nascimento',
                    required: true,
                    hint: 'DD/MM/AAAA',
                    icon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: _escolherNascimento,
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
                    inputFormatters: const [CpfInputFormatter()],
                    validator: validarCpf,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: LabeledField(
                    controller: _contato,
                    label: 'Contato',
                    required: true,
                    hint: '(00) 00000-0000',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: const [TelefoneInputFormatter()],
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
                    arguments: _criancaId,
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
    Widget option(Sexo s, String label) {
      final selected = _sexo == s;
      void selecionar() => setState(() => _sexo = s);

      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: s == Sexo.feminino ? 4 : 0),
          child: Semantics(
            button: true,
            selected: selected,
            label: label,
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
                        color: selected ? Colors.white : AppColors.textMuted,
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
      ],
    );
  }
}
