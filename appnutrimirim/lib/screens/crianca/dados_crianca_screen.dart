import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common.dart';

/// TELA 10 — Dados da criança.
class DadosCriancaScreen extends StatelessWidget {
  const DadosCriancaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments as Crianca?;
    final c = arg ?? MockData.criancaDestaque;
    final r = c.responsavel;
    final ultima = MockData.ultimaAvaliacaoDe(c.nome);

    return Scaffold(
      appBar: const BackAppBar(title: 'Dados da criança'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                InfoRow(
                  'Endereço',
                  c.endereco.isEmpty ? 'Bairro ${c.bairro}' : c.endereco,
                ),
                InfoRow('UBS Vinculada', c.ubs),
                InfoRow(
                  'Data de nascimento',
                  c.nascimento.isEmpty ? 'Não informado' : c.nascimento,
                ),
                InfoRow(
                  'Última avaliação',
                  ultima?.data ?? 'Sem avaliações registradas',
                ),
              ],
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.cadastroCrianca),
              child: const Text('Editar dados'),
            ),
          ),
          if (ultima == null)
            const AppCard(
              child: Text(
                'Sem avaliações registradas',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            LastEvaluationCard(
              data: ultima.data,
              peso:
                  '${ultima.pesoKg.toStringAsFixed(1).replaceAll('.', ',')} kg',
              situacao: ultima.situacao,
              footer: TextButton(
                onPressed: () => Navigator.pushNamed(context, Routes.historico),
                child: const Text(
                  'Ver histórico',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
          _ArrowButton(
            label: 'Curva de Crescimento',
            onPressed: () =>
                Navigator.pushNamed(context, Routes.curvaCrescimento),
          ),
          const SizedBox(height: 18),
          const Text(
            'Dados do Responsável',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: r == null
                  ? const [
                      Text(
                        'Não informado',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ]
                  : [
                      Text(
                        r.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CPF: ${r.cpfMascarado}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _contato(Icons.phone_outlined, r.telefone),
                      const SizedBox(height: 6),
                      _contato(Icons.mail_outline, r.email),
                    ],
            ),
          ),
          const SizedBox(height: 18),
          _ArrowButton(
            label: 'Registrar Avaliação',
            onPressed: () =>
                Navigator.pushNamed(context, Routes.registroMedidas),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }

  Widget _contato(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.textMuted),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ),
    ],
  );
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Expanded(child: Text(label, textAlign: TextAlign.center)),
          const Icon(Icons.arrow_forward, size: 24),
        ],
      ),
    );
  }
}
