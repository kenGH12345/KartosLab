/// Chart Intro 衰变方程。对标 `DecayEquationNode`，不可点，不是五键面板。
library;

import 'package:flutter/material.dart';

import '../chart_intro_visuals.dart';
import '../render/decay_equation_render.dart';

class DecayEquationView extends StatelessWidget {
  const DecayEquationView({super.key, required this.render});

  final DecayEquationRender render;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: KeyedSubtree(
        key: const ValueKey('chart_intro_decay_equation'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  ChartIntroVisuals.mostLikelyDecayType,
                  style: TextStyle(fontSize: ChartIntroVisuals.legendFontSize),
                ),
                if (render.percentText != null) ...[
                  const SizedBox(width: ChartIntroVisuals.decayEquationVBoxSpacing),
                  Text(
                    render.percentText!,
                    key: const ValueKey('chart_intro_decay_percent'),
                    style: const TextStyle(
                      fontSize: ChartIntroVisuals.legendFontSize,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: ChartIntroVisuals.decayEquationVBoxSpacing),
            SizedBox(
              height: ChartIntroVisuals.decayEquationMinHeight,
              child: _equationBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _equationBody() {
    switch (render.kind) {
      case DecayEquationKind.hidden:
        return const SizedBox.shrink();
      case DecayEquationKind.stable:
        return const Text(
          ChartIntroVisuals.stableLabel,
          key: ValueKey('chart_intro_decay_stable'),
          style: TextStyle(fontSize: ChartIntroVisuals.decayEquationStableFontSize),
        );
      case DecayEquationKind.unknown:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (render.parent != null)
              DecayEquationSymbol(nuclide: render.parent!),
            const SizedBox(width: ChartIntroVisuals.decayEquationHBoxSpacing),
            const _DecayArrow(),
            const SizedBox(width: ChartIntroVisuals.decayEquationHBoxSpacing),
            const Text(
              ChartIntroVisuals.unknownLabel,
              key: ValueKey('chart_intro_decay_unknown'),
              style: TextStyle(
                fontSize: ChartIntroVisuals.decayEquationStableFontSize,
              ),
            ),
          ],
        );
      case DecayEquationKind.decay:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecayEquationSymbol(nuclide: render.parent!),
            const SizedBox(width: ChartIntroVisuals.decayEquationHBoxSpacing),
            const _DecayArrow(),
            const SizedBox(width: ChartIntroVisuals.decayEquationHBoxSpacing),
            DecayEquationSymbol(nuclide: render.daughter!),
            const SizedBox(width: ChartIntroVisuals.decayEquationHBoxSpacing),
            const _DecayPlus(),
            const SizedBox(width: ChartIntroVisuals.decayEquationHBoxSpacing),
            DecayEquationSymbol(nuclide: render.emitted!),
          ],
        );
    }
  }
}

/// 对标 `DecaySymbolNode`：无边框盒；A 上 Z 下 + 符号。scale 0.15。
class DecayEquationSymbol extends StatelessWidget {
  const DecayEquationSymbol({super.key, required this.nuclide});

  final DecayEquationNuclide nuclide;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${nuclide.massNumber}',
              style: const TextStyle(
                fontSize: ChartIntroVisuals.decayEquationNumberFontSize,
                height: 1,
              ),
            ),
            const SizedBox(height: ChartIntroVisuals.decayEquationNumberVSpacing),
            Text(
              '${nuclide.protonNumber}',
              style: const TextStyle(
                fontSize: ChartIntroVisuals.decayEquationNumberFontSize,
                height: 1,
                color: ChartIntroVisuals.decayEquationProtonNumber,
              ),
            ),
          ],
        ),
        const SizedBox(width: ChartIntroVisuals.decayEquationSymbolHSpacing),
        Text(
          nuclide.symbol,
          style: const TextStyle(
            fontSize: ChartIntroVisuals.decayEquationSymbolFontSize,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _DecayArrow extends StatelessWidget {
  const _DecayArrow();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(
        ChartIntroVisuals.decayEquationArrowLength,
        ChartIntroVisuals.decayEquationArrowHeadWidth,
      ),
      painter: _DecayArrowPainter(),
    );
  }
}

class _DecayArrowPainter extends CustomPainter {
  const _DecayArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    const head = ChartIntroVisuals.decayEquationArrowHeadHeight;
    const halfHead = ChartIntroVisuals.decayEquationArrowHeadWidth / 2;
    final path = Path()
      ..moveTo(0, y - ChartIntroVisuals.decayEquationArrowTailWidth / 2)
      ..lineTo(size.width - head, y - ChartIntroVisuals.decayEquationArrowTailWidth / 2)
      ..lineTo(size.width - head, y - halfHead)
      ..lineTo(size.width, y)
      ..lineTo(size.width - head, y + halfHead)
      ..lineTo(size.width - head, y + ChartIntroVisuals.decayEquationArrowTailWidth / 2)
      ..lineTo(0, y + ChartIntroVisuals.decayEquationArrowTailWidth / 2)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = ChartIntroVisuals.decayEquationArrowFill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ChartIntroVisuals.decayEquationArrowStrokeWidth
        ..color = ChartIntroVisuals.decayEquationArrowStroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DecayPlus extends StatelessWidget {
  const _DecayPlus();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(
        ChartIntroVisuals.decayEquationPlusWidth,
        ChartIntroVisuals.decayEquationPlusWidth,
      ),
      painter: _DecayPlusPainter(),
    );
  }
}

class _DecayPlusPainter extends CustomPainter {
  const _DecayPlusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ChartIntroVisuals.decayEquationPlus;
    final t = ChartIntroVisuals.decayEquationPlusThickness;
    final w = ChartIntroVisuals.decayEquationPlusWidth;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: w, height: t),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: t, height: w),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
