import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../routes.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';

/// TELA 02 — Login.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _obscure = true;
  bool _entrando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_entrando || !_formKey.currentState!.validate()) return;
    setState(() {
      _entrando = true;
      _erro = null;
    });
    try {
      await authService.entrar(email: _email.text, senha: _senha.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.home);
    } on AuthException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      const Center(child: AppLogo(size: 222, login: true)),
                      const SizedBox(height: 12),
                      const Text(
                        'Monitoramento Nutricional Infantil',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Bem-vindo ao NutriMirim',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Acesse sua conta para acompanhar o crescimento e a saúde das crianças.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 36),
                      LabeledField(
                        label: 'E-mail',
                        required: true,
                        hint: 'Digite seu e-mail',
                        icon: Icons.mail_outline,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            emailValido(v) ? null : 'Informe um e-mail válido',
                      ),
                      const SizedBox(height: 18),
                      LabeledField(
                        label: 'Senha',
                        required: true,
                        hint: 'Digite sua senha',
                        icon: Icons.lock_outline,
                        controller: _senha,
                        obscureText: _obscure,
                        suffix: IconButton(
                          tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            Routes.recuperarEmail,
                          ),
                          child: const Text('Esqueci minha senha'),
                        ),
                      ),
                      if (_erro != null)
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            _erro!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.statusBadText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _entrando ? null : _entrar,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Almarai',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: _entrando
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                  semanticsLabel: 'Entrando',
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                      const SizedBox(height: 28),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Seus dados são tratados com segurança e privacidade.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
