import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_palette.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common.dart';
import '../../widgets/estado_assincrono.dart';
import '../../utils/formatters.dart';

/// TELA 10 — Dados da criança.
class DadosCriancaScreen extends StatelessWidget {
  const DadosCriancaScreen({super.key});

  /// Sem argumento mostra a criança em destaque (`c0`); id inexistente mostra
  /// "Criança não encontrada".
  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    return CriancaComAvaliacoes(
      argumento: arg,
      titulo: 'Dados da criança',
      builder: (context, c, avaliacoes) => _conteudo(
        context,
        arg,
        c,
        avaliacoes.isEmpty ? null : avaliacoes.first,
      ),
    );
  }

  Widget _conteudo(
    BuildContext context,
    Object? arg,
    Crianca c,
    Avaliacao? ultima,
  ) {
    final r = c.responsavel;

    return Scaffold(
      appBar: const BackAppBar(title: 'Dados da criança'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        children: [
          if (!c.ativa) ...[
            const AvisoDesativado(),
            const SizedBox(height: 12),
          ],
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
                  c.nascimento == null
                      ? 'Não informado'
                      : formatarData(c.nascimento!),
                ),
                InfoRow(
                  'Última avaliação',
                  ultima == null
                      ? 'Sem avaliações registradas'
                      : formatarData(ultima.data),
                ),
              ],
            ),
          ),
          Center(
            child: TextButton(
              onPressed: c.ativa
                  ? () => Navigator.pushNamed(
                      context,
                      Routes.cadastroCrianca,
                      arguments: c.id,
                    )
                  : null,
              child: const Text('Editar dados'),
            ),
          ),
          if (ultima == null)
            AppCard(
              child: Text(
                'Sem avaliações registradas',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.cores.textoSecundario),
              ),
            )
          else
            LastEvaluationCard(
              data: formatarData(ultima.data),
              peso: formatarPeso(ultima.pesoKg),
              situacao: ultima.situacao,
              footer: TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  Routes.historico,
                  arguments: c.id,
                ),
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
            onPressed: () => Navigator.pushNamed(
              context,
              Routes.curvaCrescimento,
              arguments: c.id,
            ),
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
                        style: TextStyle(
                          color: context.cores.textoSecundario,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _contato(context, Icons.phone_outlined, r.telefone),
                      const SizedBox(height: 6),
                      _contato(context, Icons.mail_outline, r.email),
                    ],
            ),
          ),
          const SizedBox(height: 18),
          _ArrowButton(
            label: 'Registrar Avaliação',
            onPressed: c.ativa
                ? () => Navigator.pushNamed(
                    context,
                    Routes.registroMedidas,
                    arguments: arg is Crianca ? c : c.id,
                  )
                : null,
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }

  Widget _contato(BuildContext context, IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 16, color: context.cores.icone),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            color: context.cores.textoSecundario,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

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
