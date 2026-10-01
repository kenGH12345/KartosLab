import 'package:flutter/material.dart';

import '../../density_constants.dart';
import '../../density_strings.dart';
import '../../model/density_block.dart';
import '../../solver/density_relation.dart';

class DensityNumberLine extends StatelessWidget {
  const DensityNumberLine({
    super.key,
    required this.blockA,
    this.blockB,
  });

  final DensityBlock blockA;
  final DensityBlock? blockB;

  static const double maxDensity = 10000;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: DensityStrings.density,
      child: SizedBox(
        height: 44,
        child: CustomPaint(
          painter: _NumberLinePainter(
            a: DensityRelation.densityOf(blockA),
            b: blockB == null ? null : DensityRelation.densityOf(blockB!),
            tagA: blockA.tag,
            tagB: blockB?.tag,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _NumberLinePainter extends CustomPainter {
  _NumberLinePainter({
    required this.a,
    required this.b,
    required this.tagA,
    required this.tagB,
  });

  final double a;
  final double? b;
  final String tagA;
  final String? tagB;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.55;
    final track = Rect.fromLTWH(8, y - 3, size.width - 16, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(track, const Radius.circular(3)),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    _tick(canvas, track, 0, '0');
    _tick(canvas, track, 1, '10');
    _marker(canvas, track, a, tagA, const Color(0xFFDC2626));
    if (b != null && tagB != null) {
      _marker(canvas, track, b!, tagB!, const Color(0xFF2563EB));
    }
  }

  void _tick(Canvas canvas, Rect track, double t, String label) {
    final x = track.left + track.width * t;
    canvas.drawLine(
      Offset(x, track.bottom),
      Offset(x, track.bottom + 6),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 1,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF475569)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, track.bottom + 8));
  }

  void _marker(Canvas canvas, Rect track, double density, String tag, Color color) {
    final t = (density / DensityNumberLine.maxDensity).clamp(0.0, 1.0);
    final x = track.left + track.width * t;
    final path = Path()
      ..moveTo(x, track.top - 2)
      ..lineTo(x - 6, track.top - 12)
      ..lineTo(x + 6, track.top - 12)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    final kgL = (density / DensityConstants.litersInCubicMeter).toStringAsFixed(2);
    final tp = TextPainter(
      text: TextSpan(
        text: '$tag $kgL ${DensityStrings.kgPerL}',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((x - tp.width / 2).clamp(0, track.right - tp.width), 2));
  }

  @override
  bool shouldRepaint(_NumberLinePainter oldDelegate) =>
      oldDelegate.a != a || oldDelegate.b != b;
}
