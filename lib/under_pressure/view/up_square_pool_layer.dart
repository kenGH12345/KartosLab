import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/pool/square_pool_model.dart';
import 'package:kratos/under_pressure/model/under_pressure_units.dart';
import 'package:kratos/under_pressure/transform/up_mvt.dart';
import 'package:kratos/under_pressure/view/up_cement_pattern.dart';
import 'package:kratos/under_pressure/view/up_faucet_node.dart';

/// Square / Mystery pool walls + fluid + grass + grid + faucets.
///
/// Original assets (not substituted):
/// `assets/simulations/under_pressure/images/grassTexture.png`
/// `assets/simulations/under_pressure/images/cementTextureDark.jpg`
class UpSquarePoolLayer extends StatelessWidget {
  const UpSquarePoolLayer({
    super.key,
    required this.controller,
    this.useMysteryPool = false,
  });

  final UnderPressureController controller;

  /// Mystery scene reuses square geometry with [MysteryPoolModel] state.
  final bool useMysteryPool;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final pool = useMysteryPool ? m.mystery : m.square;
    final groundY = controller.mvt.modelToView(0, 0).dy;
    final tl = controller.mvt.modelToView(pool.poolLeftX, pool.poolTopY);
    final br = controller.mvt.modelToView(pool.poolRightX, pool.poolBottomY);
    final inputMaxH = controller.mvt
        .modelToViewDeltaY(pool.poolBottomY - pool.inputFaucet.position.dy)
        .abs();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          painter: _SquarePoolPainter(
            mvt: controller.mvt,
            pool: pool,
            fluidColor: m.fluidColorModel.color,
            showGrid: m.isGridVisible,
            measureUnits: m.measureUnits,
          ),
          child: const SizedBox.expand(),
        ),
        Positioned(
          left: 0,
          top: groundY - 10,
          width: tl.dx,
          height: 10,
          child: Image.asset(
            'assets/simulations/under_pressure/images/grassTexture.png',
            fit: BoxFit.fill,
            repeat: ImageRepeat.repeatX,
          ),
        ),
        Positioned(
          left: br.dx,
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
          mvt: controller.mvt,
          faucet: pool.inputFaucet,
          pool: pool,
          fluidColor: m.fluidColorModel.color,
          maxHeightPx: inputMaxH,
        ),
        UpFaucetFluidNode(
          mvt: controller.mvt,
          faucet: pool.outputFaucet,
          pool: pool,
          fluidColor: m.fluidColorModel.color,
          maxHeightPx: 1000,
        ),
        UpFaucetNode(
          mvt: controller.mvt,
          faucet: pool.outputFaucet,
          pipeLengthPx: 150,
          onFlowRate: controller.setOutputFlow,
        ),
        UpFaucetNode(
          mvt: controller.mvt,
          faucet: pool.inputFaucet,
          pipeLengthPx: 3000,
          onFlowRate: controller.setInputFlow,
        ),
      ],
    );
  }
}

class _SquarePoolPainter extends CustomPainter {
  _SquarePoolPainter({
    required this.mvt,
    required this.pool,
    required this.fluidColor,
    required this.showGrid,
    required this.measureUnits,
  });

  final UpMvt mvt;
  final SquarePoolModel pool;
  final Color fluidColor;
  final bool showGrid;
  final MeasureUnits measureUnits;

  @override
  void paint(Canvas canvas, Size size) {
    final tl = mvt.modelToView(pool.poolLeftX, pool.poolTopY);
    final br = mvt.modelToView(pool.poolRightX, pool.poolBottomY);
    final poolRect = Rect.fromLTRB(tl.dx, tl.dy, br.dx, br.dy);

    canvas.drawRect(poolRect, Paint()..color = const Color(0xFFF3F0E9));

    final fillFrac = pool.volume / pool.maxVolume;
    final fluidH = poolRect.height * fillFrac;
    canvas.drawRect(
      Rect.fromLTRB(
        poolRect.left,
        poolRect.bottom - fluidH,
        poolRect.right,
        poolRect.bottom,
      ),
      Paint()..color = fluidColor,
    );

    final border = Path()
      ..moveTo(poolRect.left - 2, poolRect.top)
      ..lineTo(poolRect.left - 2, poolRect.bottom + 2)
      ..lineTo(poolRect.right + 2, poolRect.bottom + 2)
      ..lineTo(poolRect.right + 2, poolRect.top);
    UpCementPattern.strokePath(canvas, border, lineWidth: 4);


    final groundY = mvt.modelToView(0, 0).dy;
    const grassH = 10.0;
    final grassPaint = Paint()..color = const Color(0xFF5B8C3E);
    canvas.drawRect(
      Rect.fromLTRB(0, groundY - grassH, poolRect.left, groundY),
      grassPaint,
    );
    canvas.drawRect(
      Rect.fromLTRB(poolRect.right, groundY - grassH, size.width, groundY),
      grassPaint,
    );

    if (showGrid) {
      _paintGrid(canvas, poolRect);
    }
  }

  void _paintGrid(Canvas canvas, Rect poolRect) {
    final isEnglish = measureUnits == MeasureUnits.english;
    final stepM = isEnglish ? UnderPressureUnits.feetToMeters(1) : 1.0;
    final light = Paint()
      ..color = const Color.fromRGBO(192, 192, 192, 1)
      ..strokeWidth = 1.5;
    final dark = Paint()
      ..color = const Color.fromRGBO(64, 64, 64, 1)
      ..strokeWidth = 1;

    for (var depth = 0.0; depth <= pool.maxHeight - 0.05; depth += stepM) {
      final y = mvt.modelToView(0, -depth).dy;
      canvas.drawLine(Offset(poolRect.left, y), Offset(poolRect.right, y), light);
      canvas.drawLine(
        Offset(poolRect.left, y + 1),
        Offset(poolRect.right, y + 1),
        dark,
      );
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
      tp.paint(canvas, Offset(poolRect.left - tp.width - 8, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _SquarePoolPainter old) =>
      old.pool.volume != pool.volume ||
      old.fluidColor != fluidColor ||
      old.showGrid != showGrid ||
      old.measureUnits != measureUnits;
}
