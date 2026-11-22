import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/curvas_referencia.dart';
import '../../data/models.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common.dart';
import '../../widgets/estado_assincrono.dart';

/// Dados de um gráfico: curvas de referência, medidas da criança e textos.
class _ChartSpec {
  const _ChartSpec({
    required this.title,
    required this.xLabel,
    required this.ref,
    required this.pontos,
    this.tooltip,
    this.xTickLabels = const {},
  });

  final String title, xLabel;
  final CurvaReferencia ref;

  /// Medidas da criança, da mais antiga para a mais recente.
  final List<Offset> pontos;

  /// Linhas do balão da medida mais recente (nulo quando não há ponto).
  final List<String>? tooltip;
  final Map<int, String> xTickLabels;
}

const _labelsMeses = {
  0: 'Nascimento',
  12: '1 ano',
  24: '2 anos',
  36: '3 anos',
  48: '4 anos',
  60: '5 anos',
};

String _meses(int m) => m == 1 ? '1 mês' : '$m meses';

/// TELA 08 — Curva de Crescimento.
///
/// Recebe a criança pela rota: o `id` (recomendado) ou o objeto [Crianca].
/// Sem argumento, mostra a criança em destaque (`c0`); os dados vêm dos
/// repositórios.
class CurvaCrescimentoScreen extends StatefulWidget {
  const CurvaCrescimentoScreen({super.key});

  @override
  State<CurvaCrescimentoScreen> createState() => _CurvaCrescimentoScreenState();
}

class _CurvaCrescimentoScreenState extends State<CurvaCrescimentoScreen> {
  int _tab = 0;
  static const _tabs = ['Peso/Idade', 'Altura/Idade', 'Peso/Altura'];

  /// Monta o gráfico do indicador com as avaliações da criança.
  _ChartSpec _spec(IndicadorCurva ind, Crianca c, List<Avaliacao> avs) {
    final ref = CurvaReferencia.de(ind, c.sexo);
    final porIdade = ind != IndicadorCurva.pesoAltura;
    final nasc = c.nascimento;

    // Da mais antiga para a mais recente, para ligar os pontos em ordem.
    final pontos = <Offset>[];
    Avaliacao? ultima;
    for (final a in avs.reversed) {
      final double x;
      if (porIdade) {
        if (nasc == null) continue;
        x = idadeEmMeses(nasc, hoje: a.data).toDouble();
      } else {
        x = a.alturaCm;
      }
      final y = ind == IndicadorCurva.alturaIdade ? a.alturaCm : a.pesoKg;
      if (!ref.contem(x, y)) continue;
      pontos.add(Offset(x, y));
      ultima = a;
    }

    List<String>? tooltip;
    if (ultima != null) {
      final xTexto = porIdade
          ? _meses(idadeEmMeses(nasc!, hoje: ultima.data))
          : formatarAltura(ultima.alturaCm);
      final yTexto = ind == IndicadorCurva.alturaIdade
          ? formatarAltura(ultima.alturaCm)
          : formatarPeso(ultima.pesoKg);
      tooltip = [xTexto, yTexto, formatarData(ultima.data)];
    }

    return switch (ind) {
      IndicadorCurva.pesoIdade => _ChartSpec(
        title: 'Peso para idade (kg)',
        xLabel: 'Idade (meses)',
        ref: ref,
        pontos: pontos,
        tooltip: tooltip,
        xTickLabels: _labelsMeses,
      ),
      IndicadorCurva.alturaIdade => _ChartSpec(
        title: 'Altura para idade (cm)',
        xLabel: 'Idade (meses)',
        ref: ref,
        pontos: pontos,
        tooltip: tooltip,
        xTickLabels: _labelsMeses,
      ),
      IndicadorCurva.pesoAltura => _ChartSpec(
        title: 'Peso para altura (kg)',
        xLabel: 'Altura (cm)',
        ref: ref,
        pontos: pontos,
        tooltip: tooltip,
      ),
    };
  }

  /// Por que a medida não aparece no gráfico (nulo quando aparece).
  String? _aviso(_ChartSpec spec, Crianca c, List<Avaliacao> avs) {
    if (spec.tooltip != null) return null;
    if (avs.isEmpty) return 'Sem avaliações registradas para marcar na curva.';
    if (_tab != IndicadorCurva.pesoAltura.index && c.nascimento == null) {
      return 'Data de nascimento não informada: não é possível marcar a '
          'medida por idade.';
    }
    return 'A medida está fora da faixa deste gráfico (0 a 5 anos).';
  }

  @override
  Widget build(BuildContext context) {
    return CriancaComAvaliacoes(
      argumento: ModalRoute.of(context)?.settings.arguments,
      titulo: 'Curva de Crescimento',
      builder: _conteudo,
    );
  }

  Widget _conteudo(BuildContext context, Crianca c, List<Avaliacao> avs) {
    final ultima = avs.isEmpty ? null : avs.first;
    final spec = _spec(IndicadorCurva.values[_tab], c, avs);
    final aviso = _aviso(spec, c, avs);
    final textScaler = MediaQuery.textScalerOf(context);
    final sexo = c.sexo == Sexo.feminino ? 'Menina' : 'Menino';

    final idadeMeses = (ultima != null && c.nascimento != null)
        ? idadeEmMeses(c.nascimento!, hoje: ultima.data)
        : null;

    return Scaffold(
      appBar: const BackAppBar(
        title: 'Curva de Crescimento',
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        children: [
          Row(
            children: [
              for (var i = 0; i < _tabs.length; i++) ...[
                if (i > 0) const SizedBox(width: 7),
                Expanded(child: _tabButton(i)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          AppCard(
            radius: 15,
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec.title,
                  style: const TextStyle(
                    color: Color(0xFF0F1C2E),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  c.nome,
                  style: const TextStyle(
                    color: AppColors.textBody,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$sexo • 0 a 5 anos',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, box) {
                    // Com fonte maior, o gráfico cresce para caber os rótulos.
                    final escala = textScaler.scale(12) / 12;
                    final altura =
                        box.maxWidth / .95 + math.max(0.0, escala - 1) * 80;
                    return Semantics(
                      label: [
                        spec.title,
                        c.nome,
                        if (spec.tooltip != null)
                          'Medida atual: ${spec.tooltip!.join(', ')}'
                        else
                          ?aviso,
                      ].join('. '),
                      child: SizedBox(
                        width: box.maxWidth,
                        height: altura,
                        child: CustomPaint(
                          painter: _GrowthChartPainter(spec, textScaler),
                        ),
                      ),
                    );
                  },
                ),
                if (aviso != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    aviso,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
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
              data: formatarData(ultima.data),
              idade: idadeMeses == null ? '—' : _meses(idadeMeses),
              idadeSub: (idadeMeses != null && idadeMeses >= 24)
                  ? '(${formatarIdade(c.nascimento!, hoje: ultima.data)})'
                  : null,
              peso: formatarPeso(ultima.pesoKg),
              // Z-score e percentil saem do cálculo da OMS (task de back-end).
              situacao: ultima.situacao,
            ),
          const SizedBox(height: 22),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Almarai',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Relatório gerado.'))),
            child: const Text('Gerar relatório'),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }

  Widget _tabButton(int i) {
    final selected = i == _tab;
    // Aparência de 34 dp de altura, com área tocável de 48 dp.
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _tab = i),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Container(
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: selected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  _GrowthChartPainter(this.spec, this.textScaler);
  final _ChartSpec spec;
  final TextScaler textScaler;

  /// Cor das linhas (só desenho).
  static const _curveColor = {
    3: Color(0xFFFC0000),
    2: Color(0xFFFCB903),
    0: Color(0xFF22C55E),
    -2: Color(0xFFFCB903),
    -3: Color(0xFFFC0000),
  };

  /// Cor dos rótulos das linhas: tons escuros com contraste AA sobre branco.
  static const _labelColor = {
    3: AppColors.statusBadText,
    2: AppColors.statusAttentionText,
    0: AppColors.statusNormalText,
    -2: AppColors.statusAttentionText,
    -3: AppColors.statusBadText,
  };

  static const _ponto = Color(0xFF1A73E8);

  // textMuted tem 5,1:1 sobre branco (o textHint anterior tinha 3,7:1).
  static const _labelStyle = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
  );

  TextPainter _tp(String s, TextStyle style) => TextPainter(
    text: TextSpan(
      text: s,
      style: style.copyWith(fontFamily: 'Almarai'),
    ),
    textDirection: ui.TextDirection.ltr,
    textScaler: textScaler,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    final ref = spec.ref;
    final xMin = ref.xMin, xMax = ref.xMax, yMin = ref.yMin;

    // Rótulos medidos antes, para as margens acompanharem o tamanho da fonte.
    final yLabels = <double, TextPainter>{
      for (var y = yMin; y <= ref.yMax + .01; y += ref.yStep)
        y: _tp(y.toStringAsFixed(0), _labelStyle),
    };
    final xLabels = {
      for (final x in ref.xTicks) x: _tp(x.toStringAsFixed(0), _labelStyle),
    };
    final extraStyle = _labelStyle.copyWith(fontSize: 11);
    final extras = <double, TextPainter>{
      for (final x in ref.xTicks)
        if (spec.xTickLabels[x.round()] case final s?) x: _tp(s, extraStyle),
    };
    final zLabels = <int, TextPainter>{
      for (final z in ref.linhas.keys)
        z: _tp(
          z > 0 ? '+$z' : '$z',
          TextStyle(
            color: _labelColor[z],
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
    };
    final titulo = _tp(spec.xLabel, _labelStyle.copyWith(fontSize: 12));

    double maxW(Iterable<TextPainter> l) =>
        l.fold(0, (m, tp) => math.max(m, tp.width));
    double maxH(Iterable<TextPainter> l) =>
        l.fold(0, (m, tp) => math.max(m, tp.height));

    final left = maxW(yLabels.values) + 8;
    final right = maxW(zLabels.values) + 8;
    final top = math.max(6.0, maxH(yLabels.values) / 2);
    final tickH = maxH(xLabels.values);
    final extraH = extras.isEmpty ? 0.0 : maxH(extras.values) + 4;
    final bottom = 4 + tickH + extraH + 8 + titulo.height + 2;

    final plot = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    Offset map(double x, double y) => Offset(
      plot.left + (x - xMin) / (xMax - xMin) * plot.width,
      plot.bottom - (y - yMin) / (ref.yMax - yMin) * plot.height,
    );

    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // Grade horizontal + rótulos Y (pula rótulos que se encostariam).
    var ultimoTopo = double.infinity;
    yLabels.forEach((y, tp) {
      final p = map(xMin, y);
      _dashed(canvas, p, Offset(plot.right, p.dy), grid);
      final dy = p.dy - tp.height / 2;
      if (dy + tp.height <= ultimoTopo) {
        tp.paint(canvas, Offset(plot.left - 6 - tp.width, dy));
        ultimoTopo = dy;
      }
    });

    // Grade vertical + rótulos X.
    var fimTick = -double.infinity, fimExtra = -double.infinity;
    for (final x in ref.xTicks) {
      final p = map(x, yMin);
      _dashed(canvas, Offset(p.dx, plot.top), p, grid);
      final tp = xLabels[x]!;
      fimTick = _rotuloX(canvas, tp, p.dx, plot.bottom + 4, size, fimTick);
      final extra = extras[x];
      if (extra != null) {
        fimExtra = _rotuloX(
          canvas,
          extra,
          p.dx,
          plot.bottom + 4 + tickH + 4,
          size,
          fimExtra,
        );
      }
    }
    titulo.paint(
      canvas,
      Offset(
        plot.center.dx - titulo.width / 2,
        size.height - titulo.height - 2,
      ),
    );

    // Eixos
    final axis = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 1.2;
    canvas.drawLine(plot.bottomLeft, plot.bottomRight, axis);
    canvas.drawLine(plot.topLeft, plot.bottomLeft, axis);

    // Curvas de referência (spline Catmull-Rom).
    final fimDasLinhas = <int, double>{};
    ref.linhas.forEach((z, values) {
      final pts = [
        for (var i = 0; i < ref.xs.length; i++) map(ref.xs[i], values[i]),
      ];
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 0; i < pts.length - 1; i++) {
        final p0 = i == 0 ? pts[i] : pts[i - 1];
        final p1 = pts[i], p2 = pts[i + 1];
        final p3 = i + 2 < pts.length ? pts[i + 2] : p2;
        path.cubicTo(
          p1.dx + (p2.dx - p0.dx) / 6,
          p1.dy + (p2.dy - p0.dy) / 6,
          p2.dx - (p3.dx - p1.dx) / 6,
          p2.dy - (p3.dy - p1.dy) / 6,
          p2.dx,
          p2.dy,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = _curveColor[z]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      fimDasLinhas[z] = pts.last.dy;
    });

    // Rótulos das linhas à direita, de cima para baixo, sem sobreposição.
    final ordem = fimDasLinhas.keys.toList()
      ..sort((a, b) => fimDasLinhas[a]!.compareTo(fimDasLinhas[b]!));
    var proximo = -double.infinity;
    for (final z in ordem) {
      final tp = zLabels[z]!;
      final dy = math.max(fimDasLinhas[z]! - tp.height / 2, proximo);
      tp.paint(canvas, Offset(plot.right + 6, dy));
      proximo = dy + tp.height;
    }

    // Medidas da criança: as antigas menores, ligadas em ordem de data.
    if (spec.pontos.isEmpty) return;
    final pts = [for (final p in spec.pontos) map(p.dx, p.dy)];
    if (pts.length > 1) {
      final linha = Paint()
        ..color = _ponto.withValues(alpha: .6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawPath(Path()..addPolygon(pts, false), linha);
      for (final p in pts.take(pts.length - 1)) {
        canvas.drawCircle(p, 4, Paint()..color = _ponto);
      }
    }
    final pt = pts.last;
    canvas.drawCircle(pt, 11, Paint()..color = _ponto.withValues(alpha: .25));
    canvas.drawCircle(pt, 7, Paint()..color = _ponto);
    canvas.drawCircle(pt, 3, Paint()..color = Colors.white);

    final lines = spec.tooltip;
    if (lines == null) return;
    final tps = [
      for (var i = 0; i < lines.length; i++)
        _tp(
          lines[i],
          i == lines.length - 1
              ? const TextStyle(color: AppColors.textMuted, fontSize: 11)
              : const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
        ),
    ];
    final tipW = maxW(tps) + 24;
    final tipH = tps.fold(0.0, (s, tp) => s + tp.height) + 16;
    double clamp(double v, double lo, double hi) =>
        v.clamp(lo, math.max(lo, hi));
    // Balão acima do ponto; se não couber, vai para baixo dele.
    var tipTop = pt.dy - tipH - 18;
    if (tipTop < plot.top) tipTop = pt.dy + 18;
    final tip = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        clamp(pt.dx - tipW / 2, 0, size.width - tipW),
        clamp(tipTop, 0, size.height - tipH),
        tipW,
        tipH,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(
      tip.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(tip, Paint()..color = Colors.white);
    var y = tip.top + 8;
    for (final tp in tps) {
      tp.paint(canvas, Offset(tip.left + 12, y));
      y += tp.height;
    }
  }

  /// Desenha um rótulo centrado em [cx], dentro do canvas, e devolve onde ele
  /// termina. Pula o rótulo se ele encostar no anterior (fim em [fimAnterior]).
  double _rotuloX(
    Canvas c,
    TextPainter tp,
    double cx,
    double top,
    Size size,
    double fimAnterior,
  ) {
    final double dx = (cx - tp.width / 2).clamp(
      0.0,
      math.max(0.0, size.width - tp.width),
    );
    if (dx < fimAnterior + 4) return fimAnterior;
    tp.paint(c, Offset(dx, top));
    return dx + tp.width;
  }

  void _dashed(Canvas c, Offset a, Offset b, Paint p) {
    const dash = 3.0, gap = 3.0;
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    for (double d = 0; d < total; d += dash + gap) {
      final end = (d + dash) > total ? total : d + dash;
      c.drawLine(a + dir * d, a + dir * end, p);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter old) =>
      old.spec != spec || old.textScaler != textScaler;
}
