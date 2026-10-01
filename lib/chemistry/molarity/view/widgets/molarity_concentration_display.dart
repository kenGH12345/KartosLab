import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../model/molarity_constants.dart';
import '../../model/molarity_math.dart';
import '../../model/solution.dart';
import '../molarity_layout.dart';

/// Source `ConcentrationDisplay` — vertical gradient bar + pointer + DualLabels.
class MolarityConcentrationDisplay extends StatelessWidget {
  const MolarityConcentrationDisplay({
    super.key,
    required this.solution,
    required this.valuesVisible,
  });

  final Solution solution;
  final bool valuesVisible;

  @override
  Widget build(BuildContext context) {
    final bar = MolarityLayout.concentrationBarSize;
    return SizedBox(
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '溶液浓度',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Text(
            '(摩尔浓度)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            valuesVisible
                ? MolarityMath.toFixed(
                    MolarityConstants.concentrationDisplayMax,
                    MolarityConstants.rangeDecimalPlaces,
                  )
                : '高',
            style: const TextStyle(fontSize: 20),
          ),
          SizedBox(
            width: bar.width + 120,
            height: bar.height,
            child: CustomPaint(
              painter: _ConcentrationBarPainter(
                solution: solution,
                valuesVisible: valuesVisible,
                barSize: bar,
              ),
            ),
          ),
          Text(
            valuesVisible ? '0' : '零',
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _ConcentrationBarPainter extends CustomPainter {
  _ConcentrationBarPainter({
    required this.solution,
    required this.valuesVisible,
    required this.barSize,
  });

  final Solution solution;
  final bool valuesVisible;
  final Size barSize;

  static const _arrowLength = 55.0;
  static const _arrowHeadH = 0.6 * _arrowLength;
  static const _arrowHeadW = 0.7 * _arrowLength;
  static const _arrowTailW = 0.4 * _arrowLength;

  @override
  void paint(Canvas canvas, Size size) {
    final barLeft = 0.0;
    final barTop = 0.0;
    final barRect = Rect.fromLTWH(barLeft, barTop, barSize.width, barSize.height);

    final solute = solution.solute;
    final cMax = MolarityConstants.concentrationDisplayMax;
    final satScale = (solute.saturatedConcentration / cMax).clamp(0.0, 1.0);
    final satY = barSize.height - barSize.height * satScale;

    // Gradient from C_sat height down to bottom (maxColor → minColor).
    final grad = ui.Gradient.linear(
      Offset(barLeft, satY),
      Offset(barLeft, barSize.height),
      [solute.maxColor, solute.minColor],
    );
    canvas.drawRect(barRect, Paint()..shader = grad);
    canvas.drawRect(
      barRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Gray cover for region above C_sat (when C_sat < display max).
    if (solute.saturatedConcentration < cMax) {
      canvas.drawRect(
        Rect.fromLTWH(barLeft, barTop, barSize.width, satY),
        Paint()..color = const Color(0xFFD3D3D3),
      );
      canvas.drawRect(
        Rect.fromLTWH(barLeft, barTop, barSize.width, satY),
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Pointer position from concentration / display range.
    final c = solution.concentration;
    final y = barSize.height -
        MolarityMath.linear(
          MolarityConstants.concentrationDisplayMin,
          cMax,
          0,
          barSize.height,
          c,
        );

    final arrowColor = solution.solutionColor;
    final path = Path()
      ..moveTo(barSize.width, y)
      ..lineTo(barSize.width + _arrowHeadH, y - _arrowHeadW / 2)
      ..lineTo(barSize.width + _arrowHeadH, y - _arrowTailW / 2)
      ..lineTo(barSize.width + _arrowLength, y - _arrowTailW / 2)
      ..lineTo(barSize.width + _arrowLength, y + _arrowTailW / 2)
      ..lineTo(barSize.width + _arrowHeadH, y + _arrowTailW / 2)
      ..lineTo(barSize.width + _arrowHeadH, y + _arrowHeadW / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = arrowColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    if (valuesVisible) {
      final label =
          '${MolarityMath.toFixed(c, MolarityConstants.concentrationDecimalPlaces)} M';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 20, color: Colors.black),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(barSize.width + _arrowLength + 5, y - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConcentrationBarPainter old) =>
      old.solution.concentration != solution.concentration ||
      old.solution.solute != solution.solute ||
      old.valuesVisible != valuesVisible;
}
