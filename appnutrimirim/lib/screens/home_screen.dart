import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';

/// TELA 03 — Início (menu principal).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 32),
            const Wordmark(),
            const SizedBox(height: 48),
            _MenuCard(
              icon: Icons.manage_search,
              iconBg: AppColors.primaryLight,
              bg: AppColors.lightSky,
              arrow: AppColors.primary,
              title: 'Lista de crianças',
              subtitle: 'Selecione uma opção para continuar.',
              onTap: () => Navigator.pushNamed(context, Routes.listaCriancas),
            ),
            _MenuCard(
              icon: Icons.assignment_add,
              iconBg: AppColors.primary,
              bg: AppColors.lightBlue,
              arrow: const Color(0xFF2B3E7D),
              title: 'Nova Avaliação',
              subtitle: 'Registre os dados da criança',
              onTap: () => Navigator.pushNamed(context, Routes.novaAvaliacao),
            ),
            _MenuCard(
              icon: Icons.format_list_bulleted,
              iconBg: AppColors.green,
              bg: AppColors.lightMint,
              arrow: const Color(0xFF2E8626),
              title: 'Histórico',
              subtitle: 'Veja as avaliações anteriores',
              onTap: () => Navigator.pushNamed(context, Routes.historico),
            ),
            _MenuCard(
              icon: Icons.settings_outlined,
              iconBg: AppColors.orange,
              bg: AppColors.lightOrange,
              arrow: AppColors.orange,
              title: 'Configurações',
              subtitle: 'Ajustes do aplicativo',
              onTap: () => Navigator.pushNamed(context, Routes.perfil),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.inicio),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.iconBg,
    required this.bg,
    required this.arrow,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg, bg, arrow;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        color: bg,
        borderColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        radius: 16,
        onTap: onTap,
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iconBg,
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMutedOnTint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: arrow, size: 24),
          ],
        ),
      ),
    );
  }
}
