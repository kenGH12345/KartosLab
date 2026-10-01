import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../gases_intro_constants.dart';
import '../model/hold_constant.dart';
import '../model/ideal_gas_law_model.dart';
import '../model/particle.dart';

/// Bicycle pump with Path proportions from scenery-phet [BicyclePumpNode].
/// Height 230 (GasPropertiesBicyclePumpNode). Drag handle → [model.pump] (+50).
class BicyclePumpWidget extends StatefulWidget {
  const BicyclePumpWidget({
    super.key,
    required this.model,
    this.height = 230,
    this.width = 120,
  });

  final IdealGasLawModel model;
  final double height;
  final double width;

  @override
  State<BicyclePumpWidget> createState() => _BicyclePumpWidgetState();
}

class _BicyclePumpWidgetState extends State<BicyclePumpWidget> {
  /// 0 = rest (top), 1 = fully depressed.
  double _handleT = 0;
  double _accum = 0;

  IdealGasLawModel get model => widget.model;

  Color get _bodyColor => model.particleType == ParticleKind.heavy
      ? const Color(GasesIntroConstants.heavyParticleColor)
      : const Color(GasesIntroConstants.lightParticleColor);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (d) {
                  final travel = size.height * 0.45;
                  setState(() {
                    _handleT =
                        (_handleT + d.delta.dy / travel).clamp(0.0, 1.0);
                  });
                  _accum += d.delta.dy.abs();
                  if (_accum > travel * 0.4) {
                    _accum = 0;
                    model.pump();
                  }
                },
                onVerticalDragEnd: (_) {
                  setState(() => _handleT = 0);
                  _accum = 0;
                },
                child: CustomPaint(
                  size: size,
                  painter: BicyclePumpPainter(
                    bodyColor: _bodyColor,
                    handleT: _handleT,
                    hoseToLeft: true,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Geometric bicycle pump Path — proportions from BicyclePumpNode.ts.
class BicyclePumpPainter extends CustomPainter {
  BicyclePumpPainter({
    required this.bodyColor,
    required this.handleT,
    this.hoseToLeft = true,
  });

  final Color bodyColor;
  final double handleT;
  final bool hoseToLeft;

  // BicyclePumpNode proportions
  static const double baseW = 0.35;
  static const double baseH = 0.075;
  static const double bodyH = 0.7;
  static const double bodyW = 0.07;
  static const double shaftW = bodyW * 0.25;
  static const double shaftH = bodyH;
  static const double handleH = 0.05;
  static const double coneH = 0.09;
  static const double hoseConnH = 0.04;
  static const double hoseConnW = 0.05;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.62;

    final pumpBodyW = w * bodyW * 2.2; // readable at widget width
    final pumpBodyH = h * bodyH * 0.85;
    final coneHeight = h * coneH;
    final baseWidth = w * baseW;
    final baseHeight = h * baseH;
    final shaftWidth = w * shaftW * 2.2;
    final handleHeight = h * handleH * 1.4;

    final baseTop = h - baseHeight;
    final coneTop = baseTop - coneHeight + 8;
    final bodyBottom = coneTop + 18;
    final bodyTop = bodyBottom - pumpBodyH;

    // Hose (cubic) to the left toward container
    final hoseAttach = Offset(cx - pumpBodyW, bodyBottom - 26);
    final hoseEnd = Offset(4, hoseAttach.dy - 8);
    final hosePath = Path()
      ..moveTo(hoseAttach.dx, hoseAttach.dy)
      ..cubicTo(
        hoseAttach.dx - 40 * 0.75,
        hoseAttach.dy,
        hoseEnd.dx + 20,
        hoseEnd.dy,
        hoseEnd.dx + 8,
        hoseEnd.dy,
      );
    canvas.drawPath(
      hosePath,
      Paint()
        ..color = const Color(0xFFB3B3B3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // Hose connectors
    final connW = w * hoseConnW;
    final connH = h * hoseConnH;
    _hoseConnector(canvas, Rect.fromCenter(center: hoseEnd, width: connW, height: connH));
    _hoseConnector(
      canvas,
      Rect.fromCenter(center: hoseAttach, width: connW, height: connH),
    );

    // Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, baseTop + baseHeight * 0.35),
        width: baseWidth,
        height: baseHeight * 0.7,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      baseRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _shade(const Color(0xFFAAAAAA), 0.05),
            const Color(0xFFAAAAAA),
            _shade(const Color(0xFFAAAAAA), -0.2),
          ],
        ).createShader(baseRect.outerRect),
    );

    // Cone
    final conePath = Path()
      ..moveTo(cx - pumpBodyW * 0.6, coneTop)
      ..lineTo(cx + pumpBodyW * 0.6, coneTop)
      ..lineTo(cx + pumpBodyW, coneTop + coneHeight)
      ..lineTo(cx - pumpBodyW, coneTop + coneHeight)
      ..close();
    canvas.drawPath(
      conePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _shade(const Color(0xFFAAAAAA), -0.4),
            const Color(0xFFAAAAAA),
            _shade(const Color(0xFFAAAAAA), 0.1),
            _shade(const Color(0xFFAAAAAA), -0.5),
          ],
          stops: const [0.0, 0.3, 0.45, 1.0],
        ).createShader(conePath.getBounds()),
    );

    // Shaft + handle (move with handleT)
    final restHandleBottom = bodyTop - 18;
    final maxTravel = pumpBodyH * 0.55;
    final handleBottom = restHandleBottom + handleT * maxTravel;
    final handleTop = handleBottom - handleHeight;
    final shaftTop = handleBottom;
    final shaftBottom = math.min(bodyBottom - 8, shaftTop + h * shaftH * 0.5);

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, (shaftTop + shaftBottom) / 2),
        width: shaftWidth,
        height: (shaftBottom - shaftTop).abs(),
      ),
      Paint()
        ..color = const Color(0xFFCACACA)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, (shaftTop + shaftBottom) / 2),
        width: shaftWidth,
        height: (shaftBottom - shaftTop).abs(),
      ),
      Paint()
        ..color = _shade(const Color(0xFFCACACA), -0.38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Handle with grip bumps
    _paintHandle(canvas, Offset(cx, (handleTop + handleBottom) / 2), handleHeight);

    // Body (over shaft)
    final bodyRect = Rect.fromCenter(
      center: Offset(cx, (bodyTop + bodyBottom) / 2),
      width: pumpBodyW,
      height: pumpBodyH,
    );
    canvas.drawRect(
      bodyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _shade(bodyColor, 0.2),
            bodyColor,
            _shade(bodyColor, -0.2),
          ],
          stops: const [0.0, 0.4, 0.7],
        ).createShader(bodyRect),
    );

    // Body top opening (ellipse hint)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bodyTop),
        width: pumpBodyW * 1.05,
        height: 6,
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, bodyTop),
        width: pumpBodyW * 1.05,
        height: 6,
      ),
      Paint()
        ..color = _shade(Colors.white, -0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintHandle(Canvas canvas, Offset center, double height) {
    final halfW = 28.0;
    final path = Path()
      ..moveTo(center.dx - 8, center.dy + height / 2)
      ..lineTo(center.dx + 8, center.dy + height / 2)
      ..quadraticBezierTo(
        center.dx + 18,
        center.dy + height / 2,
        center.dx + halfW,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + 18,
        center.dy - height / 2,
        center.dx + 8,
        center.dy - height / 2,
      )
      ..lineTo(center.dx - 8, center.dy - height / 2)
      ..quadraticBezierTo(
        center.dx - 18,
        center.dy - height / 2,
        center.dx - halfW,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - 18,
        center.dy + height / 2,
        center.dx - 8,
        center.dy + height / 2,
      )
      ..close();

    // Grip bumps left/right
    for (final sign in [-1.0, 1.0]) {
      for (var i = 0; i < 4; i++) {
        final y = center.dy - height * 0.28 + i * (height * 0.18);
        path.addOval(
          Rect.fromCenter(
            center: Offset(center.dx + sign * (halfW + 4), y),
            width: 10,
            height: 8,
          ),
        );
      }
    }

    canvas.drawPath(path, Paint()..color = const Color(0xFFADAFB1));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF6B6D70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _hoseConnector(Canvas canvas, Rect r) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(2)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _shade(const Color(0xFFAAAAAA), -0.2),
            const Color(0xFFAAAAAA),
            _shade(const Color(0xFFAAAAAA), 0.1),
            _shade(const Color(0xFFAAAAAA), -0.4),
          ],
          stops: const [0.0, 0.3, 0.4, 1.0],
        ).createShader(r),
    );
  }

  static Color _shade(Color c, double luminanceFactor) {
    final hsl = HSLColor.fromColor(c);
    final l = (hsl.lightness * (1 + luminanceFactor)).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  @override
  bool shouldRepaint(covariant BicyclePumpPainter oldDelegate) =>
      oldDelegate.handleT != handleT || oldDelegate.bodyColor != bodyColor;
}

/// Heater/Cooler — stove bowl + flame/ice Image.asset + vertical slider.
/// Port of HeaterCoolerBack (PNG) + HeaterCoolerFront (bucket + VSlider).
/// Factor ∈ [-1,1]; release → 0.
///
/// V5: sizes follow parent [Positioned] (anchors × layoutScale). Slider track
/// gets an explicit length so RotatedBox never yields a zero-width Material
/// Slider (clamp assertion / hit-test collapse).
class HeaterCoolerWidget extends StatelessWidget {
  const HeaterCoolerWidget({super.key, required this.model});

  final IdealGasLawModel model;

  /// Logical design size (scale=1); matches IdealScreenAnchors heaterW/H.
  static const double designWidth = 168;
  static const double designHeight = 150;
  static const double stoveWidthLogical = 120;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final hide = model.holdConstant == HoldConstant.temperature ||
            model.holdConstant == HoldConstant.pressureT;
        if (hide) {
          return const SizedBox.expand();
        }
        final enabled = model.isPlaying && model.numberOfParticles > 0;
        final factor = model.heatCoolFactor;

        return LayoutBuilder(
          builder: (context, constraints) {
            final s = constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? (constraints.maxHeight / designHeight).clamp(0.55, 1.0)
                : 1.0;
            final stoveW = stoveWidthLogical * s;
            final stoveH = 140 * s;
            final sliderColW = 40 * s;
            // Labels stay 10px — do not shrink fonts to dodge overflow.
            const labelStyle = TextStyle(color: Colors.white54, fontSize: 10);

            return Opacity(
              opacity: enabled ? 1 : 0.45,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: stoveW,
                    height: stoveH,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        if (factor > 0)
                          Positioned(
                            top: -factor * 55 * s,
                            left: 10 * s,
                            right: 10 * s,
                            child: Image.asset(
                              'assets/gases_intro/flame.png',
                              height: 70 * s,
                              fit: BoxFit.contain,
                            ),
                          ),
                        if (factor < 0)
                          Positioned(
                            top: factor.abs() * -40 * s,
                            left: 16 * s,
                            right: 16 * s,
                            child: Image.asset(
                              'assets/gases_intro/iceCubeStack.png',
                              height: 55 * s,
                              fit: BoxFit.contain,
                            ),
                          ),
                        CustomPaint(
                          size: Size(stoveW, 100 * s),
                          painter: _StovePainter(
                            baseColor: const Color(0xFF9FB6CD),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: sliderColW,
                    height: 110 * s,
                    child: Column(
                      children: [
                        const Text('Heat', style: labelStyle),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final trackLen = c.maxHeight;
                              if (trackLen < 32) {
                                return const SizedBox.shrink();
                              }
                              return RotatedBox(
                                quarterTurns: 3,
                                child: SizedBox(
                                  width: trackLen,
                                  height: sliderColW,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: (10 * s).clamp(6.0, 10.0),
                                      thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius:
                                            (9 * s).clamp(6.0, 9.0),
                                      ),
                                      overlayShape: RoundSliderOverlayShape(
                                        overlayRadius:
                                            (16 * s).clamp(10.0, 16.0),
                                      ),
                                      activeTrackColor:
                                          const Color(0xFFEF000F),
                                      inactiveTrackColor:
                                          const Color(0xFF0A00F0),
                                      thumbColor: const Color(0xFF71EDFF),
                                    ),
                                    child: Slider(
                                      value: factor.clamp(-1.0, 1.0),
                                      min: -1,
                                      max: 1,
                                      onChanged: enabled
                                          ? (v) => model.setHeatCool(v)
                                          : null,
                                      onChangeEnd: enabled
                                          ? (_) => model.setHeatCool(0)
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Text('Cool', style: labelStyle),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Stove bowl / body geometry from HeaterCoolerBack + HeaterCoolerFront.
class _StovePainter extends CustomPainter {
  _StovePainter({required this.baseColor});
  final Color baseColor;

  static const double openingScale = 0.1;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final openingH = w * openingScale;
    final bodyH = w * 0.75;
    final bottomW = w * 0.80;

    // Interior ellipse (bowl opening)
    final interior = Rect.fromCenter(
      center: Offset(w / 2, openingH / 4),
      width: w,
      height: openingH,
    );
    canvas.drawOval(
      interior,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.lerp(baseColor, Colors.black, 0.5)!,
            Color.lerp(baseColor, Colors.white, 0.5)!,
          ],
        ).createShader(interior),
    );
    canvas.drawOval(
      interior,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Stove body (front trapezoid with elliptical top/bottom)
    final bodyPath = Path()
      ..moveTo(0, openingH / 2)
      ..lineTo((w - bottomW) / 2, bodyH + openingH / 2)
      ..arcToPoint(
        Offset((w + bottomW) / 2, bodyH + openingH / 2),
        radius: Radius.elliptical(bottomW / 2, openingH),
        clockwise: false,
      )
      ..lineTo(w, openingH / 2)
      ..arcToPoint(
        Offset(0, openingH / 2),
        radius: Radius.elliptical(w / 2, openingH / 2),
        clockwise: false,
      )
      ..close();

    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.lerp(baseColor, Colors.white, 0.5)!,
            Color.lerp(baseColor, Colors.black, 0.5)!,
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, bodyH + openingH)),
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _StovePainter oldDelegate) =>
      oldDelegate.baseColor != baseColor;
}
