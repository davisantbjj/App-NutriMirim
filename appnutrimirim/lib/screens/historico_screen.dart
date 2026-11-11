import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';
import '../utils/formatters.dart';

/// TELA 09 — Histórico de avaliações (mais recente primeiro).
class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  Situacao? _filtro; // nulo = Todas

  @override
  Widget build(BuildContext context) {
    final itens = MockData.avaliacoes
        .where((a) => _filtro == null || a.situacao == _filtro)
        .toList();

    return Scaffold(
      appBar: const BackAppBar(title: 'Histórico'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        children: [
          Align(alignment: Alignment.centerLeft, child: _chip('Todas', null)),
          const SizedBox(height: 8),
          for (final a in itens)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                onTap: () => Navigator.pushNamed(context, Routes.dadosCrianca),
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

  Widget _chip(String label, Situacao? s) {
    final selected = _filtro == s;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _filtro = s),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textMuted,
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
