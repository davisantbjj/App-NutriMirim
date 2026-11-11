import 'package:flutter/material.dart';

import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common.dart';

/// TELA 04 — Nova Avaliação: escolha do tipo de registro.
class NovaAvaliacaoScreen extends StatelessWidget {
  const NovaAvaliacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BackAppBar(title: 'NOVA AVALIAÇÃO'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        children: [
          const Text(
            'Selecione uma das opções abaixo para iniciar o registro das medidas antropométricas.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _OptionCard(
            color: AppColors.primary,
            textColor: AppColors.primary,
            bg: AppColors.lightSky,
            icon: Icons.person_search_outlined,
            title: 'Vincular Criança',
            text:
                'Busque uma criança já cadastrada na sua UBS para adicionar novas pesagens e medidas de crescimento.',
            action: 'Selecionar criança',
            onTap: () => Navigator.pushNamed(context, Routes.listaCriancas),
          ),
          const SizedBox(height: 20),
          _OptionCard(
            color: AppColors.green,
            textColor: AppColors.statusNormalText,
            bg: AppColors.lightMint,
            icon: Icons.add,
            title: 'Cadastrar Nova Criança',
            text:
                'Abra uma nova ficha de acompanhamento para uma criança que está sendo atendida pela primeira vez.',
            action: 'Cadastrar novo',
            onTap: () => Navigator.pushNamed(context, Routes.cadastroCrianca),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.avaliacao),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.color,
    required this.textColor,
    required this.bg,
    required this.icon,
    required this.title,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final Color color, textColor, bg;
  final IconData icon;
  final String title, text, action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: bg,
      borderColor: color,
      radius: 16,
      padding: const EdgeInsets.all(20),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textMutedOnTint,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$action ›',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
