import 'package:flutter/material.dart';

import '../../widgets/common.dart';

/// Estrutura comum das telas 02A–02C: "‹ Voltar", logotipo e título.
class RecuperacaoLayout extends StatelessWidget {
  const RecuperacaoLayout({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: TextBackButton(),
              ),
              const SizedBox(height: 20),
              const Center(child: AppLogo(size: 140, login: true)),
              const SizedBox(height: 32),
              const Text(
                'Recuperação de Senha',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 28),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
