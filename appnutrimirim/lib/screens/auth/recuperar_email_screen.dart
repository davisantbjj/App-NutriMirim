import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../routes.dart';
import '../../theme/app_palette.dart';
import '../../services/auth_service.dart';
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
  final _email = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    if (_enviando || !_formKey.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      await authService.recuperarSenha(_email.text);
      if (!mounted) return;
      Navigator.pushNamed(context, Routes.recuperarEnviado);
    } on AuthException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: RecuperacaoLayout(
        children: [
          Text(
            'Digite seu e-mail ou número de telefone para redefinir a senha!',
            style: TextStyle(
              color: context.cores.textoSecundario,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          LabeledField(
            hint: 'E-mail ou telefone',
            required: true,
            icon: Icons.mail_outline,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            // O Firebase só envia o link por e-mail (o telefone fica para
            // quando houver login por SMS).
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Campo obrigatório';
              if (!emailValido(v)) return 'Informe o e-mail cadastrado';
              return null;
            },
          ),
          if (_erro != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                _erro!,
                style: const TextStyle(
                  color: AppColors.statusBadText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _enviando ? null : _continuar,
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
