import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common.dart';

/// Dados de um gráfico de crescimento: eixo X, curvas de Z-score e ponto atual.
class _ChartSpec {
  const _ChartSpec({
    required this.title,
    required this.xLabel,
    required this.xs,
    required this.curves,
    required this.yMin,
    required this.yMax,
    required this.yStep,
    required this.xTicks,
    required this.point,
    required this.tooltip,
    this.xTickLabels = const {},
  });

  final String title, xLabel;
  final List<double> xs;
  final Map<int, List<double>> curves; // z-score -> valores
  final double yMin, yMax, yStep;
  final List<double> xTicks;
  final Map<int, String> xTickLabels;
  final Offset point;
  final List<String> tooltip;
}

// Valores aproximados das curvas OMS (meninas, 0 a 5 anos).
const _meses = <double>[0, 6, 12, 24, 36, 48, 60];
const _tickMeses = <double>[0, 6, 12, 18, 24, 30, 36, 42, 48, 54, 60];
const _labelsMeses = {
  0: 'Nascimento',
  12: '1 ano',
  24: '2 anos',
  36: '3 anos',
  48: '4 anos',
  60: '5 anos',
};

const _pesoIdade = _ChartSpec(
  title: 'Peso para idade (kg)',
  xLabel: 'Idade (meses)',
  xs: _meses,
  curves: {
    3: [4.8, 10.6, 13.1, 17.0, 20.9, 25.2, 29.5],
    2: [4.2, 9.3, 11.5, 14.8, 18.1, 21.5, 24.9],
    0: [3.2, 7.3, 8.9, 11.5, 13.9, 16.1, 18.2],
    -2: [2.4, 5.7, 7.0, 9.0, 10.8, 12.3, 13.7],
    -3: [2.0, 5.1, 6.3, 8.1, 9.6, 10.9, 12.1],
  },
  yMin: 0,
  yMax: 30,
  yStep: 5,
  xTicks: _tickMeses,
  xTickLabels: _labelsMeses,
  point: Offset(24, 9.8),
  tooltip: ['24 meses', '9,8 kg', '15/08/2026'],
);

const _alturaIdade = _ChartSpec(
  title: 'Altura para idade (cm)',
  xLabel: 'Idade (meses)',
  xs: _meses,
  curves: {
    3: [54.7, 71.6, 81.7, 95.2, 105.0, 113.0, 120.0],
    2: [52.9, 69.6, 79.2, 92.0, 101.4, 109.0, 115.7],
    0: [49.1, 65.7, 74.0, 85.7, 95.1, 102.7, 109.4],
    -2: [45.4, 61.8, 68.9, 79.3, 88.0, 95.0, 101.0],
    -3: [43.6, 59.9, 66.3, 76.0, 84.0, 91.0, 97.0],
  },
  yMin: 40,
  yMax: 125,
  yStep: 10,
  xTicks: _tickMeses,
  xTickLabels: _labelsMeses,
  point: Offset(24, 82),
  tooltip: ['24 meses', '82 cm', '15/08/2026'],
);

const _pesoAltura = _ChartSpec(
  title: 'Peso para altura (kg)',
  xLabel: 'Altura (cm)',
  xs: <double>[45, 60, 75, 90, 105, 120],
  curves: {
    3: [3.0, 7.1, 11.0, 15.3, 20.2, 27.0],
    2: [2.7, 6.4, 10.0, 13.9, 18.4, 24.5],
    0: [2.5, 5.5, 8.9, 12.1, 16.0, 21.2],
    -2: [2.0, 4.8, 7.7, 10.6, 14.0, 18.5],
    -3: [1.9, 4.5, 7.2, 10.0, 13.1, 17.3],
  },
  yMin: 0,
  yMax: 30,
  yStep: 5,
  xTicks: <double>[45, 60, 75, 90, 105, 120],
  point: Offset(82, 9.8),
  tooltip: ['82 cm', '9,8 kg', '15/08/2026'],
);

/// TELA 08 — Curva de Crescimento.
class CurvaCrescimentoScreen extends StatefulWidget {
  const CurvaCrescimentoScreen({super.key});

  @override
  State<CurvaCrescimentoScreen> createState() => _CurvaCrescimentoScreenState();
}

class _CurvaCrescimentoScreenState extends State<CurvaCrescimentoScreen> {
  int _tab = 0;
  static const _tabs = ['Peso/Idade', 'Altura/Idade', 'Peso/Altura'];
  static const _specs = [_pesoIdade, _alturaIdade, _pesoAltura];

  @override
  Widget build(BuildContext context) {
    final spec = _specs[_tab];
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
                const Text(
                  'Menina • 0 a 5 anos',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                AspectRatio(
                  aspectRatio: .95,
                  child: Semantics(
                    label:
                        '${spec.title}. Medida atual: ${spec.tooltip.join(', ')}',
                    child: CustomPaint(painter: _GrowthChartPainter(spec)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const LastEvaluationCard(
            data: '15/08/2026',
            idade: '24 meses',
            idadeSub: '(2 anos)',
            peso: '9,8 kg',
            zScore: '-1,31',
            percentil: '10º',
            situacao: Situacao.normal,
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
  _GrowthChartPainter(this.spec);
  final _ChartSpec spec;

  static const _curveColor = {
    3: Color(0xFFFC0000),
    2: Color(0xFFFCB903),
    0: Color(0xFF22C55E),
    -2: Color(0xFFFCB903),
    -3: Color(0xFFFC0000),
  };

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0, right = 20.0, top = 6.0, bottom = 52.0;
    final plot = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final xMin = spec.xs.first, xMax = spec.xs.last;
    final yMin = spec.yMin;

    Offset map(double x, double y) => Offset(
      plot.left + (x - xMin) / (xMax - xMin) * plot.width,
      plot.bottom - (y - yMin) / (spec.yMax - yMin) * plot.height,
    );

    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    const labelStyle = TextStyle(color: AppColors.textHint, fontSize: 11);

    // Grade horizontal + rótulos Y
    for (var y = yMin; y <= spec.yMax + .01; y += spec.yStep) {
      final p = map(xMin, y);
      _dashed(canvas, p, Offset(plot.right, p.dy), grid);
      _text(
        canvas,
        y.toStringAsFixed(0),
        Offset(plot.left - 6, p.dy),
        labelStyle,
        align: Alignment.centerRight,
      );
    }
    // Grade vertical + rótulos X
    for (final x in spec.xTicks) {
      final p = map(x, yMin);
      _dashed(canvas, Offset(p.dx, plot.top), p, grid);
      _text(
        canvas,
        x.toStringAsFixed(0),
        Offset(p.dx, plot.bottom + 4),
        labelStyle,
        align: Alignment.topCenter,
      );
      final extra = spec.xTickLabels[x.round()];
      if (extra != null) {
        _text(
          canvas,
          extra,
          Offset(p.dx, plot.bottom + 20),
          labelStyle.copyWith(fontSize: 9),
          align: Alignment.topCenter,
        );
      }
    }
    _text(
      canvas,
      spec.xLabel,
      Offset(plot.center.dx, size.height - 12),
      labelStyle.copyWith(fontSize: 10),
      align: Alignment.topCenter,
    );

    // Eixos
    final axis = Paint()
      ..color = AppColors.textHint
      ..strokeWidth = 1.2;
    canvas.drawLine(plot.bottomLeft, plot.bottomRight, axis);
    canvas.drawLine(plot.topLeft, plot.bottomLeft, axis);

    // Curvas de referência (spline Catmull-Rom)
    spec.curves.forEach((z, values) {
      final pts = [
        for (var i = 0; i < spec.xs.length; i++) map(spec.xs[i], values[i]),
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
      final color = _curveColor[z]!;
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _text(
        canvas,
        '$z',
        pts.last + const Offset(6, 0),
        TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
        align: Alignment.centerLeft,
      );
    });

    // Ponto da criança + tooltip
    final pt = map(spec.point.dx, spec.point.dy);
    canvas.drawCircle(
      pt,
      11,
      Paint()..color = const Color(0xFF1A73E8).withValues(alpha: .25),
    );
    canvas.drawCircle(pt, 7, Paint()..color = const Color(0xFF1A73E8));
    canvas.drawCircle(pt, 3, Paint()..color = Colors.white);

    const tipW = 112.0, tipH = 62.0;
    final tip = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (pt.dx - tipW / 2).clamp(plot.left, plot.right - tipW),
        (pt.dy - tipH - 18).clamp(plot.top, plot.bottom - tipH),
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
    final lines = spec.tooltip;
    for (var i = 0; i < lines.length; i++) {
      final isDate = i == lines.length - 1;
      _text(
        canvas,
        lines[i],
        Offset(tip.left + 12, tip.top + 8 + i * 16),
        TextStyle(
          color: isDate ? AppColors.textMuted : AppColors.textDark,
          fontSize: isDate ? 11 : 13,
          fontWeight: isDate ? FontWeight.w400 : FontWeight.w800,
        ),
        align: Alignment.topLeft,
      );
    }
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

  void _text(
    Canvas c,
    String s,
    Offset at,
    TextStyle style, {
    required Alignment align,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: style.copyWith(fontFamily: 'Almarai'),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final dx = at.dx - tp.width * (align.x + 1) / 2;
    final dy = at.dy - tp.height * (align.y + 1) / 2;
    tp.paint(c, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter old) => old.spec != spec;
}
