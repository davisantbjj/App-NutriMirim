import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../widgets/common.dart';
import 'recuperacao_layout.dart';

/// TELA 02C — Recuperação de senha: criação da nova senha.
class RecuperarNovaSenhaScreen extends StatefulWidget {
  const RecuperarNovaSenhaScreen({super.key});

  @override
  State<RecuperarNovaSenhaScreen> createState() =>
      _RecuperarNovaSenhaScreenState();
}

class _RecuperarNovaSenhaScreenState extends State<RecuperarNovaSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senha = TextEditingController();

  @override
  void dispose() {
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: RecuperacaoLayout(
        children: [
          LabeledField(
            controller: _senha,
            hint: 'Nova senha',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (v) => (v == null || v.length < 6)
                ? 'A senha deve ter ao menos 6 caracteres'
                : null,
          ),
          const SizedBox(height: 16),
          LabeledField(
            hint: 'Confirme sua senha',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (v) =>
                v != _senha.text ? 'As senhas não conferem' : null,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha alterada com sucesso.')),
                );
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (_) => false,
                );
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
