import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_colors.dart';

enum NavTab { inicio, historico, avaliacao, perfil }

/// Barra inferior fixa (Início, Histórico, Avaliação, Perfil).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, this.current});

  /// Aba destacada; nulo quando a tela não é raiz de nenhuma aba.
  final NavTab? current;

  static const _items = [
    (NavTab.inicio, Icons.home_outlined, Icons.home, 'Início', Routes.home),
    (
      NavTab.historico,
      Icons.bookmark_border,
      Icons.bookmark,
      'Histórico',
      Routes.historico,
    ),
    (
      NavTab.avaliacao,
      Icons.add_circle_outline,
      Icons.add_circle,
      'Avaliação',
      Routes.novaAvaliacao,
    ),
    (NavTab.perfil, Icons.person, Icons.person, 'Perfil', Routes.perfil),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(11, 0, 11, 14),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.iconMuted),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final (tab, icon, activeIcon, label, route) in _items)
              _NavButton(
                icon: tab == current ? activeIcon : icon,
                label: label,
                selected: tab == current,
                onTap: tab == current
                    ? null
                    : () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        route,
                        (r) => r.settings.name == Routes.home,
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.iconMuted;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
