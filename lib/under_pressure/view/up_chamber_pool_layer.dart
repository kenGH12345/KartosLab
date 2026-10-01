import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/pool/chamber_pool_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_units.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';
import 'package:kratos/under_pressure/view/up_cement_pattern.dart';

/// Source: `ChamberPoolView` + `ChamberPoolBack` + `ChamberPoolWaterNode` +
/// `MassNode` + `MassStackNode`.
class UpChamberPoolLayer extends StatelessWidget {
  const UpChamberPoolLayer({super.key, required this.controller});

  final UnderPressureController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final chamber = m.chamber;
    final mvt = controller.mvt;
    final groundY = mvt.modelToView(0, 0).dy;
    final lo = chamber.leftOpening;
    final ro = chamber.rightOpening;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          painter: _ChamberPoolPainter(
            mvt: mvt,
            chamber: chamber,
            fluidColor: m.fluidColorModel.color,
            showGrid: m.isGridVisible,
            measureUnits: m.measureUnits,
          ),
          child: const SizedBox.expand(),
        ),
        // Grass around openings
        Positioned(
          left: 0,
          top: groundY - 10,
          width: mvt.modelToView(lo.x1, 0).dx,
          height: 10,
          child: Image.asset(
            'assets/simulations/under_pressure/images/grassTexture.png',
            fit: BoxFit.fill,
            repeat: ImageRepeat.repeatX,
          ),
        ),
        Positioned(
          left: mvt.modelToView(lo.x2, 0).dx,
          top: groundY - 10,
          width: mvt.modelToViewDeltaX(ro.x1 - lo.x2),
          height: 10,
          child: Image.asset(
            'assets/simulations/under_pressure/images/grassTexture.png',
            fit: BoxFit.fill,
            repeat: ImageRepeat.repeatX,
          ),
        ),
        Positioned(
          left: mvt.modelToView(ro.x2, 0).dx,
          top: groundY - 10,
          right: 0,
          height: 10,
          child: Image.asset(
            'assets/simulations/under_pressure/images/grassTexture.png',
            fit: BoxFit.fill,
            repeat: ImageRepeat.repeatX,
          ),
        ),
        // Drop placement indicator (MassStackNode)
        _MassDropIndicator(controller: controller),
        // Masses
        for (var i = 0; i < chamber.masses.length; i++)
          _MassNode(
            controller: controller,
            index: i,
          ),
      ],
    );
  }
}

class _MassDropIndicator extends StatelessWidget {
  const _MassDropIndicator({required this.controller});

  final UnderPressureController controller;

  @override
  Widget build(BuildContext context) {
    final chamber = controller.model.chamber;
    final mvt = controller.mvt;
    final dragging = chamber.masses.where((m) => m.isDragging).toList();
    if (dragging.isEmpty) return const SizedBox.shrink();

    final mass = dragging.first;
    final lo = chamber.leftOpening;
    final left = mvt.modelToView(lo.x1, 0).dx;
    final width = mvt.modelToViewDeltaX(lo.x2 - lo.x1);
    final waterY = mvt
        .modelToView(
          0,
          lo.y2 + chamber.leftWaterHeight - chamber.leftDisplacement,
        )
        .dy;
    final stackH = chamber.stack.fold<double>(0, (a, b) => a + b.height);
    final hPx = mvt.modelToViewDeltaY(mass.height).abs();
    final top =
        waterY - mvt.modelToViewDeltaY(stackH).abs() - hPx;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: hPx,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFFFDCF0),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dash = 10.0;
    const gap = 5.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset((x + dash).clamp(0, size.width), 0), paint);
      canvas.drawLine(
        Offset(x, size.height),
        Offset((x + dash).clamp(0, size.width), size.height),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Source `MassNode` — body centered on model position; drag bounds = layout.
class _MassNode extends StatelessWidget {
  const _MassNode({required this.controller, required this.index});

  final UnderPressureController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final mass = controller.model.chamber.masses[index];
    final mvt = controller.mvt;
    final w = mvt.modelToViewDeltaX(mass.width);
    final h = mvt.modelToViewDeltaY(mass.height).abs();
    final c = mvt.modelToViewOffset(mass.position);

    return Positioned(
      left: c.dx - w / 2,
      top: c.dy - h / 2,
      width: w,
      height: h,
      child: GestureDetector(
        onPanStart: (_) => controller.beginMassDrag(index),
        onPanUpdate: (d) {
          final m = controller.model.chamber.masses[index];
          final current = mvt.modelToViewOffset(m.position);
          final nextView = Offset(current.dx + d.delta.dx, current.dy + d.delta.dy);
          // Source dragBounds = layoutBounds
          final clamped = Offset(
            nextView.dx.clamp(w / 2, UpMvt.layoutWidth - w / 2),
            nextView.dy.clamp(h / 2, UpMvt.layoutHeight - h / 2),
          );
          controller.updateMassCenter(index, mvt.viewToModelOffset(clamped));
        },
        onPanEnd: (_) => controller.endMassDrag(index),
        child: CustomPaint(
          painter: _MassPainter(label: '${mass.mass.toInt()} kg'),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _MassPainter extends CustomPainter {
  _MassPainter({required this.label});

  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [
        Color(0xFF8C8D8D),
        Color(0xFFC0C1C2),
        Color(0xFFF0F1F1),
        Color(0xFFF8F8F7),
      ],
      stops: const [0, 0.3, 0.5, 0.6],
    ).createShader(rect);
    canvas.drawRect(rect, Paint()..shader = shader);
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF918E8E),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: size.width - 5);
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MassPainter old) => old.label != label;
}

class _ChamberPoolPainter extends CustomPainter {
  _ChamberPoolPainter({
    required this.mvt,
    required this.chamber,
    required this.fluidColor,
    required this.showGrid,
    required this.measureUnits,
  });

  final UpMvt mvt;
  final ChamberPoolModel chamber;
  final Color fluidColor;
  final bool showGrid;
  final MeasureUnits measureUnits;

  @override
  void paint(Canvas canvas, Size size) {
    final d = chamber.poolDimensions;
    final lo = d['leftOpening']!;
    final lc = d['leftChamber']!;
    final rc = d['rightChamber']!;
    final ro = d['rightOpening']!;
    final hp = d['horizontalPassage']!;

    double vx(double x) => mvt.modelToView(x, 0).dx;
    double vy(double y) => mvt.modelToView(0, y).dy;

    final leftOpeningX1 = vx(lo.x1);
    final leftOpeningX2 = vx(lo.x2);
    final leftChamberX1 = vx(lc.x1);
    final leftChamberX2 = vx(lc.x2);
    final rightChamberX1 = vx(rc.x1);
    final rightChamberX2 = vx(rc.x2);
    final rightOpeningX1 = vx(ro.x1);
    final rightOpeningX2 = vx(ro.x2);
    final leftOpeningY1 = vy(lo.y1);
    final leftOpeningY2 = vy(lo.y2);
    final leftChamberY2 = vy(lc.y2);
    final passageY1 = vy(hp.y1);
    final passageY2 = vy(hp.y2);

    // Interior fill
    final interior = Path()
      ..moveTo(leftOpeningX1, leftOpeningY1 - 1)
      ..lineTo(leftOpeningX1, leftOpeningY2)
      ..lineTo(leftChamberX1, leftOpeningY2)
      ..lineTo(leftChamberX1, leftChamberY2)
      ..lineTo(leftChamberX2, leftChamberY2)
      ..lineTo(leftChamberX2, passageY2)
      ..lineTo(rightChamberX1, passageY2)
      ..lineTo(rightChamberX1, leftChamberY2)
      ..lineTo(rightChamberX2, leftChamberY2)
      ..lineTo(rightChamberX2, leftOpeningY2)
      ..lineTo(rightOpeningX2, leftOpeningY2)
      ..lineTo(rightOpeningX2, leftOpeningY1 - 1)
      ..lineTo(rightOpeningX1, leftOpeningY1 - 1)
      ..lineTo(rightOpeningX1, leftOpeningY2)
      ..lineTo(rightChamberX1, leftOpeningY2)
      ..lineTo(rightChamberX1, passageY1)
      ..lineTo(leftChamberX2, passageY1)
      ..lineTo(leftChamberX2, leftOpeningY2)
      ..lineTo(leftOpeningX2, leftOpeningY2)
      ..lineTo(leftOpeningX2, leftOpeningY1 - 1)
      ..close();
    canvas.drawPath(interior, Paint()..color = const Color(0xFFF3F0E9));

    // Water (ChamberPoolWaterNode)
    final leftY = mvt
        .modelToView(
          0,
          lo.y2 + chamber.leftWaterHeight - chamber.leftDisplacement,
        )
        .dy;
    final rightY = mvt
        .modelToView(
          0,
          ro.y2 +
              chamber.leftWaterHeight +
              chamber.leftDisplacement / chamber.lengthRatio,
        )
        .dy;

    final water = Path()
      ..moveTo(leftOpeningX1, leftY)
      ..lineTo(leftOpeningX1, leftOpeningY2)
      ..lineTo(leftChamberX1, leftOpeningY2)
      ..lineTo(leftChamberX1, leftChamberY2)
      ..lineTo(leftChamberX2, leftChamberY2)
      ..lineTo(leftChamberX2, passageY2)
      ..lineTo(rightChamberX1, passageY2)
      ..lineTo(rightChamberX1, leftChamberY2)
      ..lineTo(rightChamberX2, leftChamberY2)
      ..lineTo(rightChamberX2, leftOpeningY2)
      ..lineTo(rightOpeningX2, leftOpeningY2)
      ..lineTo(rightOpeningX2, rightY)
      ..lineTo(rightOpeningX1, rightY)
      ..lineTo(rightOpeningX1, leftOpeningY2)
      ..lineTo(rightChamberX1, leftOpeningY2)
      ..lineTo(rightChamberX1, passageY1)
      ..lineTo(leftChamberX2, passageY1)
      ..lineTo(leftChamberX2, leftOpeningY2)
      ..lineTo(leftOpeningX2, leftOpeningY2)
      ..lineTo(leftOpeningX2, leftY)
      ..close();
    canvas.drawPath(water, Paint()..color = fluidColor);

    // Cement border
    const cementWidth = 2.0;
    final cement = Path()
      ..moveTo(leftOpeningX1 - cementWidth, leftOpeningY1)
      ..lineTo(leftOpeningX1 - cementWidth, leftOpeningY2 - cementWidth)
      ..lineTo(leftChamberX1 - cementWidth, leftOpeningY2 - cementWidth)
      ..lineTo(leftChamberX1 - cementWidth, leftChamberY2 + cementWidth)
      ..lineTo(leftChamberX2 + cementWidth, leftChamberY2 + cementWidth)
      ..lineTo(leftChamberX2 + cementWidth, passageY2 + cementWidth)
      ..lineTo(rightChamberX1 - cementWidth, passageY2 + cementWidth)
      ..lineTo(rightChamberX1 - cementWidth, leftChamberY2 + cementWidth)
      ..lineTo(rightChamberX2 + cementWidth, leftChamberY2 + cementWidth)
      ..lineTo(rightChamberX2 + cementWidth, leftOpeningY2 + cementWidth)
      ..lineTo(rightOpeningX2 + cementWidth, leftOpeningY2 + cementWidth)
      ..lineTo(rightOpeningX2 + cementWidth, leftOpeningY1)
      ..moveTo(leftOpeningX2 + cementWidth, leftOpeningY1)
      ..lineTo(leftOpeningX2 + cementWidth, leftOpeningY2 - cementWidth)
      ..lineTo(leftChamberX2 + cementWidth, leftOpeningY2 - cementWidth)
      ..lineTo(leftChamberX2 + cementWidth, passageY1 - cementWidth)
      ..lineTo(rightChamberX1 - cementWidth, passageY1 - cementWidth)
      ..lineTo(rightChamberX1 - cementWidth, leftOpeningY2 + cementWidth)
      ..lineTo(rightOpeningX1 - cementWidth, leftOpeningY2 + cementWidth)
      ..lineTo(rightOpeningX1 - cementWidth, leftOpeningY1);
    UpCementPattern.strokePath(canvas, cement, lineWidth: 4);


    if (showGrid) {
      _paintGrid(canvas, lo, ro, lc);
    }
  }

  void _paintGrid(
    Canvas canvas,
    ChamberRegion lo,
    ChamberRegion ro,
    ChamberRegion lc,
  ) {
    final isEnglish = measureUnits == MeasureUnits.english;
    final stepM = isEnglish ? UnderPressureUnits.feetToMeters(1) : 1.0;
    final light = Paint()
      ..color = const Color.fromRGBO(192, 192, 192, 1)
      ..strokeWidth = 1.5;
    final dark = Paint()
      ..color = const Color.fromRGBO(64, 64, 64, 1)
      ..strokeWidth = 1;
    final poolLeft = mvt.modelToView(lc.x1, 0).dx;
    final poolRight = mvt.modelToView(ro.x2, 0).dx;
    final labelX =
        mvt.modelToView((lc.x2 + ro.x1) / 2, 0).dx;
    final maxH = -lc.y2;

    for (var depth = 0.0; depth <= maxH - 0.05; depth += stepM) {
      final y = mvt.modelToView(0, -depth).dy;
      canvas.drawLine(Offset(poolLeft, y), Offset(poolRight, y), light);
      canvas.drawLine(Offset(poolLeft, y + 1), Offset(poolRight, y + 1), dark);
    }
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final maxLabel = isEnglish ? 10 : 3;
    for (var i = 0; i <= maxLabel; i++) {
      final depthM =
          isEnglish ? UnderPressureUnits.feetToMeters(i.toDouble()) : i.toDouble();
      final y = mvt.modelToView(0, -depthM).dy;
      tp.text = TextSpan(
        text: isEnglish ? '$i ft' : '$i m',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(labelX - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _ChamberPoolPainter old) =>
      old.chamber.leftDisplacement != chamber.leftDisplacement ||
      old.fluidColor != fluidColor ||
      old.showGrid != showGrid ||
      old.measureUnits != measureUnits;
}
