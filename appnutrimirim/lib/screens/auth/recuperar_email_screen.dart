import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import 'recuperacao_layout.dart';

/// TELA 02A — Recuperação de senha: informar e-mail ou telefone.
class RecuperarEmailScreen extends StatefulWidget {
  const RecuperarEmailScreen({super.key});

  @override
  State<RecuperarEmailScreen> createState() => _RecuperarEmailScreenState();
}

class _RecuperarEmailScreenState extends State<RecuperarEmailScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: RecuperacaoLayout(
        children: [
          const Text(
            'Digite seu e-mail ou número de telefone para redefinir a senha!',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
          const SizedBox(height: 14),
          const LabeledField(
            hint: 'E-mail ou telefone',
            required: true,
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pushNamed(context, Routes.recuperarEnviado);
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
