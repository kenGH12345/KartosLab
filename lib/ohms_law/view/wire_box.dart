import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/current_units.dart';
import '../model/ohms_law_model.dart';
import '../ohms_law_view_constants.dart';

/// PhET `WireBox` — fixed circuit with batteries, resistor, arrows, readout.
///
/// Resistor scatterer dots match `ResistorNode.js`: positions generated **once**
/// (like Scenery Circles created in the constructor); only visibility tracks R.
class WireBox extends StatefulWidget {
  const WireBox({
    super.key,
    required this.model,
    this.dotRandom,
  });

  final OhmsLawModel model;

  /// Injectable RNG for golden determinism; used only on first mount.
  final math.Random? dotRandom;

  /// Source `ResistorNode` scatterer layout — pure, testable.
  static List<Offset> buildDotCenters(math.Random random) {
    final dots = <Offset>[];
    final n = OhmsLawViewConstants.numberOfDots.floor();
    final rh = OhmsLawViewConstants.resistorHeight;
    final rw = OhmsLawViewConstants.resistorWidth;
    final a = OhmsLawViewConstants.perspectiveFactor * rh / 2;
    final b = rh / 2;
    for (var i = 0; i < n; i++) {
      final centerY =
          (random.nextDouble() - 0.5) * (rh - OhmsLawViewConstants.dotRadius * 2);
      final ellipticalX =
          math.sqrt((1 - (centerY * centerY) / (b * b)) * (a * a));
      final maxW = rw + ellipticalX;
      final centerX = (random.nextDouble() - 0.5) * maxW;
      dots.add(Offset(centerX, centerY));
    }
    return dots;
  }

  /// PhET `ResistorNode` body: rectangle + right elliptical cap (anticlockwise).
  static Path resistorBodyPath({
    required Offset center,
    required double resistorWidth,
    required double resistorHeight,
    required double perspectiveFactor,
  }) {
    final cx = center.dx;
    final cy = center.dy;
    final rw = resistorWidth;
    final rh = resistorHeight;
    final path = Path()
      ..moveTo(cx - rw / 2, cy + rh / 2)
      ..lineTo(cx + rw / 2, cy + rh / 2)
      ..arcTo(
        Rect.fromCenter(
          center: Offset(cx + rw / 2, cy),
          width: perspectiveFactor * rh,
          height: rh,
        ),
        math.pi / 2,
        -math.pi,
        false,
      )
      ..lineTo(cx - rw / 2, cy - rh / 2)
      ..close();
    return path;
  }

  @override
  State<WireBox> createState() => _WireBoxState();
}

class _WireBoxState extends State<WireBox> {
  late final List<Offset> _dotCenters;

  @override
  void initState() {
    super.initState();
    // PhET: Circles created once in ResistorNode constructor — never re-rolled.
    _dotCenters = WireBox.buildDotCenters(
      widget.dotRandom ?? math.Random(0x4F484D53),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = OhmsLawViewConstants.wireWidth;
    final h = OhmsLawViewConstants.wireHeight;
    final pad = OhmsLawViewConstants.arrowOffset + 50;

    return SizedBox(
      width: w + pad * 2,
      height: h + pad * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _WireBoxPainter(
                model: widget.model,
                dotCenters: _dotCenters,
              ),
            ),
          ),
          Positioned(
            left: pad + w / 2 - 160,
            top: pad + h / 2 - 28,
            width: 320,
            child: _CurrentReadout(model: widget.model),
          ),
        ],
      ),
    );
  }
}

class _CurrentReadout extends StatelessWidget {
  const _CurrentReadout({required this.model});

  final OhmsLawModel model;

  @override
  Widget build(BuildContext context) {
    final unit = model.currentUnits == CurrentUnit.amps ? 'A' : 'mA';
    final value = model.getFixedCurrent();
    final style = TextStyle(
      fontFamily: OhmsLawViewConstants.uiFontFamily,
      fontSize: OhmsLawViewConstants.readoutFontSizePanel,
      height: 1.1,
    );
    return Semantics(
      label: 'current equals $value $unit',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: OhmsLawViewConstants.readoutXMargin,
          vertical: OhmsLawViewConstants.readoutYMargin,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: OhmsLawViewConstants.readoutLineWidth,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'current',
                style: style.copyWith(color: OhmsLawViewConstants.redColorblind),
              ),
              SizedBox(width: OhmsLawViewConstants.readoutSpacing),
              Text('=', style: style.copyWith(color: Colors.black)),
              SizedBox(width: OhmsLawViewConstants.readoutSpacing),
              Text(value, style: style.copyWith(color: Colors.black)),
              SizedBox(width: OhmsLawViewConstants.readoutSpacing),
              Text(
                unit,
                style: style.copyWith(color: OhmsLawViewConstants.redColorblind),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WireBoxPainter extends CustomPainter {
  _WireBoxPainter({
    required this.model,
    required this.dotCenters,
  });

  final OhmsLawModel model;

  /// Fixed scatterer positions (PhET constructor Circles).
  final List<Offset> dotCenters;

  @override
  void paint(Canvas canvas, Size size) {
    final pad = OhmsLawViewConstants.arrowOffset + 50;
    final origin = Offset(pad, pad);
    final w = OhmsLawViewConstants.wireWidth;
    final h = OhmsLawViewConstants.wireHeight;

    final frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(origin.dx, origin.dy, w, h),
      const Radius.circular(OhmsLawViewConstants.wireCornerRadius),
    );
    final wirePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = OhmsLawViewConstants.wireThickness;
    canvas.drawRRect(frame, wirePaint);

    _paintBatteries(canvas, origin);
    _paintResistor(canvas, origin);
    _paintArrows(canvas, origin);
  }

  void _paintBatteries(Canvas canvas, Offset origin) {
    final y = origin.dy;
    final left = origin.dx + OhmsLawViewConstants.batteriesOffset;
    final v = model.voltage;

    for (var i = 0; i < OhmsLawViewConstants.maxBatteries; i++) {
      var cellV = math.min(
        OhmsLawViewConstants.aaVoltage,
        v - i * OhmsLawViewConstants.aaVoltage,
      );
      cellV = OhmsLawViewConstants.roundToVoltageInterval(cellV);
      if (cellV <= 0) continue;

      final x = left + i * OhmsLawViewConstants.batteryWidth;
      _paintOneBattery(canvas, Offset(x, y), cellV);
    }
  }

  void _paintOneBattery(Canvas canvas, Offset leftCenter, double cellV) {
    final fullMain = OhmsLawViewConstants.batteryMainBodyWidth;
    final scale = OhmsLawViewConstants.voltageToBatteryScale(cellV);
    final mainW = fullMain * scale;
    final copperW = OhmsLawViewConstants.batteryCopperWidth;
    final nubW = OhmsLawViewConstants.batteryNubWidth;
    final bh = OhmsLawViewConstants.batteryHeight;
    final top = leftCenter.dy - bh / 2;

    final mainRect = Rect.fromLTWH(leftCenter.dx, top, mainW, bh);
    final copperRect = Rect.fromLTWH(leftCenter.dx + mainW, top, copperW, bh);
    final nubH = bh * 0.30;
    final nubRect = Rect.fromLTWH(
      leftCenter.dx + mainW + copperW,
      leftCenter.dy - nubH / 2,
      nubW,
      nubH,
    );

    final mainPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, top),
        Offset(0, top + bh),
        const [Color(0xFF888888), Color(0xFFBDBDBD), Color(0xFF444444)],
        const [0.0, 0.3, 1.0],
      );
    final copperPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, top),
        Offset(0, top + bh),
        const [Color(0xFFCC4E00), Color(0xFFDDDAD6), Color(0xFFCC4E00)],
        const [0.0, 0.3, 1.0],
      );

    canvas.drawRect(mainRect, mainPaint);
    canvas.drawRect(
      mainRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black,
    );
    canvas.drawRect(copperRect, copperPaint);
    canvas.drawRect(
      copperRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black,
    );
    canvas.drawRect(nubRect, Paint()..color = const Color(0xFFDDDDDD));
    canvas.drawRect(
      nubRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black,
    );

    final labelY = cellV >= OhmsLawViewConstants.aaVoltage
        ? leftCenter.dy - 7
        : leftCenter.dy - bh / 2 - 12;
    final value = cellV.toStringAsFixed(1);
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              fontFamily: OhmsLawViewConstants.uiFontFamily,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1,
            ),
          ),
          const TextSpan(
            text: ' V',
            style: TextStyle(
              fontFamily: OhmsLawViewConstants.uiFontFamily,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              height: 1,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(leftCenter.dx + 3, labelY - tp.height / 2));
  }

  void _paintResistor(Canvas canvas, Offset origin) {
    final cx = origin.dx + OhmsLawViewConstants.wireWidth / 2;
    final cy = origin.dy + OhmsLawViewConstants.wireHeight;
    final rw = OhmsLawViewConstants.resistorWidth;
    final rh = OhmsLawViewConstants.resistorHeight;
    final pf = OhmsLawViewConstants.perspectiveFactor;

    final bodyPath = WireBox.resistorBodyPath(
      center: Offset(cx, cy),
      resistorWidth: rw,
      resistorHeight: rh,
      perspectiveFactor: pf,
    );

    final bodyPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(cx, cy - rh / 2),
        Offset(cx, cy + rh / 2),
        const [
          OhmsLawViewConstants.redColorblind,
          Color(0xFFFFFFFF),
          Color(0xFFFCFCFC),
          OhmsLawViewConstants.redColorblind,
        ],
        const [0.0, 0.266, 0.412, 1.0],
      );
    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black
        ..strokeWidth = 1,
    );

    final endRect = Rect.fromCenter(
      center: Offset(cx - rw / 2, cy),
      width: rh * pf,
      height: rh,
    );
    canvas.drawOval(endRect, Paint()..color = const Color(0xFFFFBF9F));
    canvas.drawOval(
      endRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black,
    );

    canvas.drawLine(
      Offset(cx - rw / 2 + 5, cy),
      Offset(cx - rw / 2 - 10, cy),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.butt,
    );

    // PhET: `dot.setVisible( index < numDotsToShow )` — positions stay fixed.
    final numShow = OhmsLawViewConstants.resistanceToNumDots(model.resistance);
    final dotPaint = Paint()..color = Colors.black;
    final showCount = math.min(numShow.floor(), dotCenters.length);
    for (var i = 0; i < showCount; i++) {
      final d = dotCenters[i];
      canvas.drawCircle(
        Offset(cx + d.dx, cy + d.dy),
        OhmsLawViewConstants.dotRadius,
        dotPaint,
      );
    }
  }

  void _paintArrows(Canvas canvas, Offset origin) {
    final w = OhmsLawViewConstants.wireWidth;
    final h = OhmsLawViewConstants.wireHeight;
    final off = OhmsLawViewConstants.arrowOffset;
    final scale = OhmsLawViewConstants.arrowScaleForCurrent(model.current);

    _drawArrow(
      canvas,
      origin + Offset(-off, h + off),
      math.pi / 2,
      scale,
    );
    _drawArrow(
      canvas,
      origin + Offset(w + off, h + off),
      0,
      scale,
    );
  }

  void _drawArrow(Canvas canvas, Offset at, double rotation, double scale) {
    final path = Path()..addPolygon(RightAngleArrowShape.points, true);
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(rotation);
    canvas.scale(scale);
    canvas.drawPath(
      path,
      Paint()..color = OhmsLawViewConstants.redColorblind,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.2
        ..color = Colors.black,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WireBoxPainter oldDelegate) {
    return oldDelegate.model.voltage != model.voltage ||
        oldDelegate.model.resistance != model.resistance ||
        oldDelegate.model.current != model.current ||
        oldDelegate.model.currentUnits != model.currentUnits ||
        !identical(oldDelegate.dotCenters, dotCenters);
  }
}
