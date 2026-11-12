import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';
import '../utils/formatters.dart';

/// TELA 09 — Histórico de avaliações (mais recente primeiro).
class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final itens = [...MockData.avaliacoes]
      ..sort((a, b) => b.data.compareTo(a.data));

    return Scaffold(
      appBar: const BackAppBar(title: 'Histórico'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        children: [
          for (final a in itens)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.dadosCrianca,
                  arguments: MockData.criancaPorId(a.criancaId),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MockData.criancaPorId(a.criancaId)?.nome ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            formatarData(a.data),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Peso: ${formatarNumero(a.pesoKg)} kg  |  Altura: ${formatarAltura(a.alturaCm)}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(a.situacao, dense: true),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.historico),
    );
  }
}
