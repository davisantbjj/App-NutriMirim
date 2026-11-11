import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common.dart';

/// TELA 07 — Resultado (variações Normal e Desnutrição).
class ResultadoScreen extends StatefulWidget {
  const ResultadoScreen({super.key});

  @override
  State<ResultadoScreen> createState() => _ResultadoScreenState();
}

class _ResultadoScreenState extends State<ResultadoScreen> {
  bool _detalhes = false;

  @override
  Widget build(BuildContext context) {
    final r =
        ModalRoute.of(context)?.settings.arguments as ResultadoAvaliacao? ??
        MockData.resultadoNormal;
    final ruim = r.desnutricao;
    // Textos escuros garantem contraste AA sobre o fundo do cartão.
    final corTexto = ruim ? AppColors.alertText : AppColors.statusNormalText;
    final fundo = ruim ? AppColors.lightRed : AppColors.lightGreen;

    return Scaffold(
      appBar: const BackAppBar(title: 'Resultado'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        children: [
          // Cartão "Estado nutricional"
          AppCard(
            color: fundo,
            borderColor: Colors.transparent,
            radius: 15,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: ruim ? AppColors.alertCircle : AppColors.green,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: ruim
                          ? const Text(
                              '!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado nutricional',
                            style: TextStyle(
                              color: corTexto,
                              fontWeight: FontWeight.w700,
                              fontSize: ruim ? 14 : 12,
                            ),
                          ),
                          Text(
                            ruim ? 'Desnutrição' : 'Normal',
                            style: TextStyle(
                              color: corTexto,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (ruim) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Um ou mais indicadores estão abaixo da faixa esperada para a idade.',
                    style: TextStyle(fontSize: 12, color: AppColors.textBody),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Resultado ilustrativo – cálculo pela OMS ainda não implementado',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          const Text(
            'Indicadores (Z-score)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Column(
              children: [
                for (var i = 0; i < r.indicadores.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.border),
                  _IndicadorRow(r.indicadores[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusNormalText,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
                side: const BorderSide(color: AppColors.greenBorder),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () => setState(() => _detalhes = !_detalhes),
            icon: const Icon(Icons.calculate_outlined),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Flexible(
                  child: Text(
                    'Ver detalhes do cálculo',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(_detalhes ? Icons.arrow_upward : Icons.arrow_downward),
              ],
            ),
          ),
          if (_detalhes) ...[
            const SizedBox(height: 12),
            AppCard(
              radius: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Como o cálculo foi feito',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Valores ilustrativos; a comparação com as curvas de referência da OMS será implementada. '
                    'Quando estiver pronta, Z-score entre -2 e +2 será considerado normal e abaixo de -2, abaixo da faixa esperada.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.curvaCrescimento),
                    child: const Text('Ver curva de crescimento ›'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _InfoBox(
            icon: Icons.menu_book_outlined,
            title: 'O que isso significa?',
            color: AppColors.surface,
            border: AppColors.successBorder,
            child: Text(
              ruim
                  ? 'A criança apresenta sinais de desnutrição, identificados pelos indicadores de crescimento abaixo do esperado para a idade. Recomenda-se acompanhamento para avaliar sua evolução nutricional.'
                  : 'O crescimento da criança está adequado para a idade, com todos os indicadores dentro da faixa de normalidade (valores ilustrativos).',
              style: const TextStyle(
                fontSize: 12,
                height: 1.25,
                color: AppColors.textBody,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoBox(
            icon: Icons.lightbulb_outline,
            title: 'Orientações',
            color: fundo,
            border: AppColors.successBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final t in [
                  'Mantenha uma alimentação equilibrada.',
                  'Continue o acompanhamento periódico.',
                  'Estimule atividades físicas adequadas para a idade.',
                  'Em caso de dúvidas, consulte um profissional de saúde.',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '•  $t',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textBody,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}

class _IndicadorRow extends StatelessWidget {
  const _IndicadorRow(this.ind);
  final Indicador ind;

  @override
  Widget build(BuildContext context) {
    final z = ind.zScore.toStringAsFixed(1).replaceAll('.', ',');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              ind.nome,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          Container(
            width: 61,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: ind.situacao.background,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            child: Text(
              z,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.circle, size: 7, color: ind.situacao.color),
          const SizedBox(width: 6),
          SizedBox(
            width: 62,
            child: Text(
              ind.situacao.label,
              style: const TextStyle(fontSize: 12, color: AppColors.textBody),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.title,
    required this.color,
    required this.border,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color color, border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color,
      borderColor: border,
      radius: 11,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
