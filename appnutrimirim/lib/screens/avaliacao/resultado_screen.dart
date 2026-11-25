import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../routes.dart';
import '../../services/classificacao.dart';
import '../../services/resultado_nutricional.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_palette.dart';
import '../../utils/formatters.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common.dart';
import '../../widgets/estado_assincrono.dart';

/// TELA 07 — Resultado da avaliação: z-scores da OMS, classificação do
/// SISVAN, alerta de encaminhamento, retorno e condutas.
///
/// Recebe um [ResultadoNutricional] pela rota (aberta pela tela 06).
class ResultadoScreen extends StatefulWidget {
  const ResultadoScreen({super.key});

  @override
  State<ResultadoScreen> createState() => _ResultadoScreenState();
}

/// Cores do cartão de estado nutricional para cada cor do semáforo.
({Color fundo, Color texto, Color circulo}) _coresSemaforo(Semaforo s) =>
    switch (s) {
      Semaforo.verde => (
        fundo: AppColors.lightGreen,
        texto: AppColors.statusNormalText,
        circulo: AppColors.green,
      ),
      Semaforo.amarelo => (
        fundo: AppColors.lightYellow,
        texto: AppColors.statusAttentionText,
        circulo: AppColors.statusRisk,
      ),
      Semaforo.vermelho => (
        fundo: AppColors.lightRed,
        texto: AppColors.alertText,
        circulo: AppColors.alertCircle,
      ),
    };

class _ResultadoScreenState extends State<ResultadoScreen> {
  bool _detalhes = false;
  bool _alertaMostrado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final r = ModalRoute.of(context)?.settings.arguments;
    final alerta = r is ResultadoNutricional ? r.alerta : null;
    if (alerta == null || _alertaMostrado) return;
    _alertaMostrado = true;
    // RF12: o alerta abre em modal assim que o resultado aparece.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded),
          iconColor: AppColors.alertCircle,
          title: Text(alerta.titulo),
          content: Text(alerta.mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = ModalRoute.of(context)?.settings.arguments;
    if (r is! ResultadoNutricional) {
      return const Scaffold(
        appBar: BackAppBar(title: 'Resultado'),
        body: MensagemCentro(
          'Nenhuma avaliação para mostrar. Registre e valide as medidas da '
          'criança para ver o resultado.',
          icone: Icons.info_outline,
        ),
        bottomNavigationBar: AppBottomNav(),
      );
    }
    final cores = context.cores;
    final c = r.classificacao;
    final semaforo = _coresSemaforo(c.semaforo);
    final titulo = c.edema
        ? 'Desnutrição aguda grave'
        : c.gravidade == Gravidade.adequado
        ? 'Adequado'
        : c.pior.diagnostico;
    final textoCorpo = TextStyle(fontSize: 12, height: 1.3, color: cores.texto);

    return Scaffold(
      appBar: const BackAppBar(title: 'Resultado'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        children: [
          // Cartão "Estado nutricional"
          Semantics(
            container: true,
            label: 'Estado nutricional: $titulo',
            excludeSemantics: true,
            child: AppCard(
              color: semaforo.fundo,
              borderColor: Colors.transparent,
              radius: 15,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: semaforo.circulo,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: c.semaforo == Semaforo.verde
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : const Text(
                            '!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
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
                            color: semaforo.texto,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          titulo,
                          style: TextStyle(
                            color: semaforo.texto,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (r.alerta != null) ...[
            const SizedBox(height: 12),
            AppCard(
              color: AppColors.lightRed,
              borderColor: AppColors.alertCircle,
              radius: 11,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.alertText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.alerta!.titulo,
                          style: const TextStyle(
                            color: AppColors.alertText,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(r.alerta!.mensagem, style: textoCorpo),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                for (final (i, linha) in [
                  for (final ind in c.indicadores)
                    _IndicadorRow.classificado(ind),
                  for (final ind in r.indisponiveis)
                    _IndicadorRow.indisponivel(ind),
                ].indexed) ...[
                  if (i > 0) Divider(height: 1, color: cores.bordaSuave),
                  linha,
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoBox(
            icon: Icons.event_outlined,
            title: 'Retorno sugerido',
            child: Text(
              r.retorno == null
                  ? 'Defina a data com a equipe: sem a data de nascimento não '
                        'é possível seguir o calendário de consultas.'
                  : formatarData(r.retorno!),
              style: r.retorno == null
                  ? textoCorpo
                  : const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          _InfoBox(
            icon: Icons.lightbulb_outline,
            title: 'Condutas',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final t in r.condutas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('•  $t', style: textoCorpo),
                  ),
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
                  Text(
                    'Z-scores pelos padrões de crescimento da OMS (2006), com '
                    'a idade em dias na data da medição'
                    '${r.idadeMeses == null ? '' : ' (${r.idadeMeses} meses)'}'
                    '${r.medidaUsadaCm == null ? '' : ' e ${formatarAltura(r.medidaUsadaCm!)} no cálculo'}'
                    '. Classificação pelos pontos de corte do SISVAN (Ministério '
                    'da Saúde, 2011) para 0 a 5 anos; o estado nutricional é o '
                    'do indicador mais alterado.',
                    style: TextStyle(
                      color: cores.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                  if (c.edema) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Edema bilateral nos pés é desnutrição aguda grave pela '
                      'OMS, em qualquer z-score.',
                      style: TextStyle(
                        color: cores.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      Routes.curvaCrescimento,
                      arguments: r.criancaId,
                    ),
                    child: const Text('Ver curva de crescimento ›'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}

class _IndicadorRow extends StatelessWidget {
  _IndicadorRow.classificado(ClassificacaoIndicador ind)
    : nome = ind.indicador.nome,
      zScore = ind.zScore,
      descricao = ind.diagnostico,
      situacao = situacaoDe(ind.gravidade, ind.desvio);

  _IndicadorRow.indisponivel(IndicadorIndisponivel ind)
    : nome = ind.indicador.nome,
      zScore = null,
      descricao = ind.motivo,
      situacao = null;

  final String nome;
  final double? zScore;
  final String descricao;
  final Situacao? situacao;

  @override
  Widget build(BuildContext context) {
    final cores = context.cores;
    final z = zScore;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (situacao != null) ...[
                      Icon(Icons.circle, size: 8, color: situacao!.color),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        descricao,
                        style: TextStyle(
                          fontSize: 12,
                          color: situacao?.textColor ?? cores.textoSecundario,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(minWidth: 61, minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: situacao?.background ?? cores.fundo,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            child: Text(
              z == null ? '—' : formatarDecimal(z, casas: 2),
              semanticsLabel: z == null ? 'indisponível' : null,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
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
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: AppColors.successBorder,
      radius: 11,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
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
