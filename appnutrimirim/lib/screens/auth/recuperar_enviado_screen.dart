import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_colors.dart';
import 'recuperacao_layout.dart';

/// TELA 02B — Recuperação de senha: confirmação de envio.
class RecuperarEnviadoScreen extends StatelessWidget {
  const RecuperarEnviadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RecuperacaoLayout(
      children: [
        const SizedBox(height: 16),
        const Text(
          'Enviamos um link de recuperação para o seu e-mail ou sms.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted, fontSize: 15),
        ),
        const SizedBox(height: 40),
        // Atalho do protótipo: simula o usuário abrindo o link recebido.
        TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, Routes.recuperarNovaSenha),
          child: const Text('Já recebi o link'),
        ),
      ],
    );
  }
}
