import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/pool/trapezoid_pool_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_units.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';
import 'package:kratos/under_pressure/view/up_cement_pattern.dart';
import 'package:kratos/under_pressure/view/up_faucet_node.dart';

/// Source: `TrapezoidPoolView` + `TrapezoidPoolBack` + `TrapezoidPoolWaterNode`.
class UpTrapezoidPoolLayer extends StatelessWidget {
  const UpTrapezoidPoolLayer({super.key, required this.controller});

  final UnderPressureController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final pool = m.trapezoid;
    final mvt = controller.mvt;
    final groundY = mvt.modelToView(0, 0).dy;

    final inputMaxH = mvt
        .modelToViewDeltaY(pool.inputFaucet.position.dy - pool.bottomY2)
        .abs();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          painter: _TrapezoidPoolPainter(
            mvt: mvt,
            pool: pool,
            fluidColor: m.fluidColorModel.color,
            showGrid: m.isGridVisible,
            measureUnits: m.measureUnits,
          ),
          child: const SizedBox.expand(),
        ),
        // Grass strips (original texture) — clip between openings
        Positioned(
          left: 0,
          top: groundY - 10,
          width: mvt.modelToView(pool.x1top, 0).dx,
          height: 10,
          child: Image.asset(
            'assets/simulations/under_pressure/images/grassTexture.png',
            fit: BoxFit.fill,
            repeat: ImageRepeat.repeatX,
          ),
        ),
        Positioned(
          left: mvt.modelToView(pool.x2top, 0).dx,
          top: groundY - 10,
          width: mvt.modelToView(pool.x3top - pool.x2top, 0).dx -
              mvt.modelToView(0, 0).dx,
          height: 10,
          child: Image.asset(
            'assets/simulations/under_pressure/images/grassTexture.png',
            fit: BoxFit.fill,
            repeat: ImageRepeat.repeatX,
          ),
        ),
        Positioned(
          left: mvt.modelToView(pool.x4top, 0).dx,
          top: groundY - 10,
          right: 0,
          height: 10,
          child: Image.asset(
            'assets/simulations/under_pressure/images/grassTexture.png',
            fit: BoxFit.fill,
            repeat: ImageRepeat.repeatX,
          ),
        ),
        UpFaucetFluidNode(
          mvt: mvt,
          faucet: pool.inputFaucet,
          pool: pool,
          fluidColor: m.fluidColorModel.color,
          maxHeightPx: inputMaxH,
        ),
        UpFaucetFluidNode(
          mvt: mvt,
          faucet: pool.outputFaucet,
          pool: pool,
          fluidColor: m.fluidColorModel.color,
          maxHeightPx: 1000,
        ),
        UpFaucetNode(
          mvt: mvt,
          faucet: pool.outputFaucet,
          pipeLengthPx: 200,
          onFlowRate: controller.setOutputFlow,
        ),
        UpFaucetNode(
          mvt: mvt,
          faucet: pool.inputFaucet,
          pipeLengthPx: 3000,
          onFlowRate: controller.setInputFlow,
        ),
      ],
    );
  }
}

class _TrapezoidPoolPainter extends CustomPainter {
  _TrapezoidPoolPainter({
    required this.mvt,
    required this.pool,
    required this.fluidColor,
    required this.showGrid,
    required this.measureUnits,
  });

  final UpMvt mvt;
  final TrapezoidPoolModel pool;
  final Color fluidColor;
  final bool showGrid;
  final MeasureUnits measureUnits;

  Offset _v(double x, double y) => mvt.modelToView(x, y);

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = const Color(0xFFF3F0E9);

    // Bottom chamber interior
    final bottomRect = Rect.fromLTRB(
      _v(pool.x1middle, 0).dx - 8,
      _v(0, pool.bottomY1).dy + 1,
      _v(pool.x2middle, 0).dx + 8,
      _v(0, pool.bottomY2).dy,
    );
    canvas.drawRect(bottomRect, fill);

    // Left chamber trapezoid
    final leftPath = Path()
      ..moveTo(_v(pool.x1top, 0).dx, _v(0, 0).dy - 1)
      ..lineTo(_v(pool.x1bottom, -pool.maxHeight).dx, _v(0, -pool.maxHeight).dy)
      ..lineTo(_v(pool.x2bottom, -pool.maxHeight).dx, _v(0, -pool.maxHeight).dy)
      ..lineTo(_v(pool.x2top, 0).dx, _v(0, 0).dy - 1)
      ..close();
    canvas.drawPath(leftPath, fill);

    // Right chamber trapezoid
    final rightPath = Path()
      ..moveTo(_v(pool.x3top, 0).dx, _v(0, 0).dy - 1)
      ..lineTo(_v(pool.x3bottom, -pool.maxHeight).dx, _v(0, -pool.maxHeight).dy)
      ..lineTo(_v(pool.x4bottom, -pool.maxHeight).dx, _v(0, -pool.maxHeight).dy)
      ..lineTo(_v(pool.x4top, 0).dx, _v(0, 0).dy - 1)
      ..close();
    canvas.drawPath(rightPath, fill);

    _paintWater(canvas);

    // Cement border stroke (original Pattern texture)
    const cw = 2.0;
    final border = Path()
      ..moveTo(_v(pool.x1top, 0).dx - cw, _v(0, 0).dy)
      ..lineTo(
        _v(pool.x1bottom, -pool.maxHeight).dx - cw,
        _v(0, -pool.maxHeight).dy + cw,
      )
      ..lineTo(
        _v(pool.x4bottom, -pool.maxHeight).dx + cw,
        _v(0, -pool.maxHeight).dy + cw,
      )
      ..lineTo(_v(pool.x4top, 0).dx + cw, _v(0, 0).dy)
      ..moveTo(_v(pool.x2top, 0).dx + cw, _v(0, 0).dy)
      ..lineTo(_v(pool.x1middle, pool.ymiddle).dx + cw, _v(0, pool.ymiddle).dy - 1)
      ..lineTo(_v(pool.x2middle, pool.ymiddle).dx - cw, _v(0, pool.ymiddle).dy - 1)
      ..lineTo(_v(pool.x3top, 0).dx - cw, _v(0, 0).dy);
    UpCementPattern.strokePath(canvas, border, lineWidth: 4);


    if (showGrid) _paintGrid(canvas);
  }

  /// Source `TrapezoidPoolWaterNode` polygon.
  void _paintWater(Canvas canvas) {
    final viewHeight = pool.maxHeight * pool.volume / pool.maxVolume;
    final yMax = mvt.modelToView(0, -pool.maxHeight).dy;
    final topY = yMax + mvt.modelToViewDeltaY(viewHeight);
    final h = viewHeight < (pool.bottomY1 - pool.bottomY2)
        ? viewHeight
        : (pool.bottomY1 - pool.bottomY2);
    final x1 = mvt.modelToView(pool.x1bottom, 0).dx;
    final x4 = mvt.modelToView(pool.x4bottom, 0).dx;

    final water = Path()
      ..moveTo(
        mvt.modelToView(pool.leftChamber.leftBorder.evaluate(viewHeight), 0).dx,
        topY,
      )
      ..lineTo(x1, yMax)
      ..lineTo(x4, yMax)
      ..lineTo(
        mvt.modelToView(pool.rightChamber.rightBorder.evaluate(viewHeight), 0).dx,
        topY,
      )
      ..lineTo(
        mvt.modelToView(pool.rightChamber.leftBorder.evaluate(viewHeight), 0).dx,
        topY,
      )
      ..lineTo(
        mvt.modelToView(pool.rightChamber.leftBorder.evaluate(h), 0).dx,
        yMax + mvt.modelToViewDeltaY(h),
      )
      ..lineTo(
        mvt.modelToView(pool.leftChamber.rightBorder.evaluate(h), 0).dx,
        yMax + mvt.modelToViewDeltaY(h),
      )
      ..lineTo(
        mvt.modelToView(pool.leftChamber.rightBorder.evaluate(viewHeight), 0).dx,
        topY,
      )
      ..close();
    canvas.drawPath(water, Paint()..color = fluidColor);
  }

  void _paintGrid(Canvas canvas) {
    final isEnglish = measureUnits == MeasureUnits.english;
    final stepM = isEnglish ? UnderPressureUnits.feetToMeters(1) : 1.0;
    final light = Paint()
      ..color = const Color.fromRGBO(192, 192, 192, 1)
      ..strokeWidth = 1.5;
    final dark = Paint()
      ..color = const Color.fromRGBO(64, 64, 64, 1)
      ..strokeWidth = 1;

    final poolLeft = mvt.modelToView(pool.x1bottom, 0).dx;
    final poolRight = mvt.modelToView(pool.x4bottom, 0).dx;
    final labelX = mvt
        .modelToView(
          (pool.leftChamber.centerTop +
                  pool.leftChamber.widthTop / 2 +
                  pool.rightChamber.centerTop -
                  pool.rightChamber.widthTop / 2) /
              2,
          0,
        )
        .dx;

    for (var depth = 0.0; depth <= pool.maxHeight - 0.05; depth += stepM) {
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
  bool shouldRepaint(covariant _TrapezoidPoolPainter old) =>
      old.pool.volume != pool.volume ||
      old.fluidColor != fluidColor ||
      old.showGrid != showGrid ||
      old.measureUnits != measureUnits;
}
