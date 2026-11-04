import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';

/// TELA 05 — Cadastro da Criança (ficha de identificação).
class CadastroCriancaScreen extends StatefulWidget {
  const CadastroCriancaScreen({super.key});

  @override
  State<CadastroCriancaScreen> createState() => _CadastroCriancaScreenState();
}

class _CadastroCriancaScreenState extends State<CadastroCriancaScreen> {
  final _formKey = GlobalKey<FormState>();
  Sexo _sexo = Sexo.masculino;
  String? _ubs;

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
            const LabeledField(
              label: 'Nome completo',
              required: true,
              hint: 'Digite o nome da criança',
            ),
            gap,
            const LabeledField(
              label: 'CPF da criança',
              hint: '000.000.000-00',
              icon: Icons.child_care_outlined,
              keyboardType: TextInputType.number,
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: LabeledField(
                    label: 'Nascimento',
                    required: true,
                    hint: 'DD/MM/AAAA',
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.datetime,
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
                const Expanded(
                  child: LabeledField(
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
            const LabeledField(
              label: 'Responsável legal',
              required: true,
              hint: 'Nome do pai, mãe ou tutor',
            ),
            gap,
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LabeledField(
                    label: 'CPF Responsável',
                    required: true,
                    hint: '000.000.000-00',
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: LabeledField(
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
                  Navigator.pushNamed(context, Routes.registroMedidas);
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
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: s == Sexo.feminino ? 4 : 0),
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
              onTap: () => setState(() => _sexo = s),
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
