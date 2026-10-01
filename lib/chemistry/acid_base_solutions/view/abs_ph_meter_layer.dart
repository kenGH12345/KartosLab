import 'package:flutter/material.dart';

import '../model/abs_colors.dart';
import '../model/abs_ph_meter.dart';
import '../model/abs_view_properties.dart';

/// pH meter tool — PhET `PHMeterNode.ts`. Origin at probe tip.
class AbsPhMeterLayer extends StatelessWidget {
  const AbsPhMeterLayer({
    super.key,
    required this.meter,
    required this.toolMode,
    required this.onDrag,
    required this.onPressedChanged,
  });

  final AbsPhMeter meter;
  final AbsToolMode toolMode;
  final ValueChanged<Offset> onDrag;
  final ValueChanged<bool> onPressedChanged;

  static const _bgFill = Color.fromRGBO(225, 225, 225, 1);
  static const _bgStroke = Color.fromRGBO(64, 64, 64, 1);

  @override
  Widget build(BuildContext context) {
    if (toolMode != AbsToolMode.pHMeter) return const SizedBox.shrink();

    final tip = meter.position;
    final displayed = meter.displayedPH;
    final text = displayed == null
        ? 'pH: '
        : 'pH: ${displayed.toStringAsFixed(2)}';

    // Probe: shaft 5×40 + tip 14×36 → total height ~75 from tip up.
    const probeHeight = 75.0;
    const boxW = 70.0 + 24.0;
    const boxH = 30.0;

    return Positioned(
      left: tip.dx - boxW * 0.25,
      top: tip.dy - probeHeight - boxH + 1,
      child: GestureDetector(
        onPanStart: (_) => onPressedChanged(true),
        onPanEnd: (_) => onPressedChanged(false),
        onPanCancel: () => onPressedChanged(false),
        onPanUpdate: (d) {
          final next = Offset(tip.dx, tip.dy + d.delta.dy);
          onDrag(next);
        },
        child: SizedBox(
          width: boxW,
          height: probeHeight + boxH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: boxW * 0.25 - 2.5,
                top: boxH - 1,
                child: _Probe(shaftW: 5, shaftH: 40, tipW: 14, tipH: 36),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: boxW,
                  height: boxH,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: _bgFill,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: _bgStroke, width: 1.5),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Probe extends StatelessWidget {
  const _Probe({
    required this.shaftW,
    required this.shaftH,
    required this.tipW,
    required this.tipH,
  });

  final double shaftW;
  final double shaftH;
  final double tipW;
  final double tipH;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(tipW, shaftH + tipH),
      painter: _ProbePainter(
        shaftW: shaftW,
        shaftH: shaftH,
        tipW: tipW,
        tipH: tipH,
      ),
    );
  }
}

class _ProbePainter extends CustomPainter {
  _ProbePainter({
    required this.shaftW,
    required this.shaftH,
    required this.tipW,
    required this.tipH,
  });

  final double shaftW;
  final double shaftH;
  final double tipW;
  final double tipH;

  @override
  void paint(Canvas canvas, Size size) {
    final shaftLeft = (tipW - shaftW) / 2;
    canvas.drawRect(
      Rect.fromLTWH(shaftLeft, 0, shaftW, shaftH + 1),
      Paint()..color = AbsColors.pHProbeShaftFill,
    );
    canvas.drawRect(
      Rect.fromLTWH(shaftLeft, 0, shaftW, shaftH + 1),
      Paint()
        ..color = const Color.fromRGBO(160, 160, 160, 1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    final corner = tipH / 9;
    final tipPath = Path()
      ..moveTo(tipW / 2, shaftH + tipH)
      ..lineTo(0, shaftH + 0.6 * tipH)
      ..lineTo(0, shaftH + corner)
      ..arcToPoint(
        Offset(corner, shaftH),
        radius: Radius.circular(corner),
        clockwise: true,
      )
      ..lineTo(tipW - corner, shaftH)
      ..arcToPoint(
        Offset(tipW, shaftH + corner),
        radius: Radius.circular(corner),
        clockwise: true,
      )
      ..lineTo(tipW, shaftH + 0.6 * tipH)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = AbsColors.pHProbeTipFill);
  }

  @override
  bool shouldRepaint(covariant _ProbePainter oldDelegate) => false;
}

/// Icon for tools radio — `PHMeterNode.createIcon`.
class AbsPhMeterIcon extends StatelessWidget {
  const AbsPhMeterIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(30, 22),
      painter: _MeterIconPainter(),
    );
  }
}

class _MeterIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Mini probe + box
    canvas.drawRect(
      const Rect.fromLTWH(8, 10, 5, 12),
      Paint()..color = AbsColors.pHProbeShaftFill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(10.5, 22)
        ..lineTo(5, 16)
        ..lineTo(16, 16)
        ..close(),
      Paint()..color = AbsColors.pHProbeTipFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 30, 10),
        const Radius.circular(2),
      ),
      Paint()..color = AbsPhMeterLayer._bgFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 30, 10),
        const Radius.circular(2),
      ),
      Paint()
        ..color = AbsPhMeterLayer._bgStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
