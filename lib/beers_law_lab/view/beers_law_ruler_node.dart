import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/beers_law_model.dart';
import 'beers_law_mvt.dart';

/// PhET `BLLRulerNode` — interactive cm ruler, major tick every 0.5 cm.
///
/// Matches scenery-phet `RulerNode` with `insetsWidth: 0`,
/// `unitsMajorTickIndex: 0` → "cm" sits to the right of the "0" label.
class BeersLawRulerNode extends StatelessWidget {
  const BeersLawRulerNode({
    super.key,
    required this.model,
    this.mvt = const BeersLawMvt(),
  });

  final BeersLawModel model;
  final BeersLawMvt mvt;

  @override
  Widget build(BuildContext context) {
    final pos = mvt.modelToView(model.ruler.position);
    final w = mvt.modelToViewDelta(model.ruler.length);
    final h = mvt.modelToViewDelta(model.ruler.height);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      width: w,
      height: h,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.keyJ) {
            model.jumpRuler();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Semantics(
          label: 'Ruler',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) {
              final cur = model.ruler.position;
              model.setRulerPosition(Offset(
                cur.dx + mvt.viewToModelDelta(d.delta.dx),
                cur.dy + mvt.viewToModelDelta(d.delta.dy),
              ));
            },
            child: CustomPaint(
              size: Size(w, h),
              painter: _RulerPainter(
                lengthCm: model.ruler.length,
                majorTickCm: 0.5,
                minorTicksPerMajor: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({
    required this.lengthCm,
    required this.majorTickCm,
    required this.minorTicksPerMajor,
  });

  final double lengthCm;
  final double majorTickCm;
  final int minorTicksPerMajor;

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(2),
    );
    canvas.drawRRect(body, Paint()..color = const Color(0xFFFFF59D));
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black87
        ..strokeWidth = 1,
    );

    final majorCount = (lengthCm / majorTickCm).floor(); // end exclusive like labels span
    final numberOfMajorTicks = majorCount + 1; // 0 .. floor(L/0.5)
    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    double? zeroLabelRight;
    double? zeroLabelBaseline;

    for (var i = 0; i < numberOfMajorTicks; i++) {
      final x = size.width * (i * majorTickCm / lengthCm);
      final isEnd = i == 0 || i == numberOfMajorTicks - 1;
      // Source RulerNode: with insetsWidth=0, skip end tick marks (labels still drawn).
      if (!isEnd) {
        final tickH = size.height * 0.7;
        canvas.drawLine(Offset(x, 0), Offset(x, tickH), tickPaint);
      }

      // Minor ticks between this major and the next.
      if (i < numberOfMajorTicks - 1) {
        for (var m = 1; m <= minorTicksPerMajor; m++) {
          final t = (i * majorTickCm + majorTickCm * m / (minorTicksPerMajor + 1)) /
              lengthCm;
          final mx = size.width * t;
          final tickH = size.height * 0.4;
          canvas.drawLine(Offset(mx, 0), Offset(mx, tickH), tickPaint);
        }
      }

      // Integer cm labels on even major indices (0, 1, 2, …).
      if (i % 2 == 0) {
        final label = '${i ~/ 2}';
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 11, color: Colors.black),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final labelPos = Offset(x + 2, size.height - tp.height - 2);
        tp.paint(canvas, labelPos);
        if (i == 0) {
          zeroLabelRight = labelPos.dx + tp.width;
          zeroLabelBaseline = labelPos.dy;
        }
      }
    }

    // Units beside the "0" label (unitsMajorTickIndex: 0).
    final cm = TextPainter(
      text: const TextSpan(
        text: 'cm',
        style: TextStyle(fontSize: 11, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final cmX = (zeroLabelRight ?? 2) + 3;
    final cmY = zeroLabelBaseline ?? (size.height - cm.height - 2);
    cm.paint(canvas, Offset(cmX, cmY));
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) =>
      oldDelegate.lengthCm != lengthCm ||
      oldDelegate.majorTickCm != majorTickCm ||
      oldDelegate.minorTicksPerMajor != minorTicksPerMajor;
}
