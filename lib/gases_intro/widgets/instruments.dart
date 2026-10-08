import 'package:flutter/material.dart';

import '../gases_intro_constants.dart';
import '../model/hold_constant.dart';
import '../model/ideal_gas_law_model.dart';
import '../model/particle.dart';
import 'package:kratos/gases_intro/gases_intro_strings.dart';

/// Bicycle pump with Path proportions from scenery-phet [BicyclePumpNode].
/// Shared by Gases Intro and Gas Properties.
class BicyclePumpWidget extends StatefulWidget {
  const BicyclePumpWidget({
    super.key,
    required this.listenable,
    required this.bodyColorOf,
    required this.onPump,
    this.height = 230,
    this.width = 120,
  });

  BicyclePumpWidget.forIntro({
    super.key,
    required IdealGasLawModel model,
    this.height = 230,
    this.width = 120,
  })  : listenable = model,
        bodyColorOf = (() => model.particleType == ParticleKind.heavy
            ? const Color(GasesIntroConstants.heavyParticleColor)
            : const Color(GasesIntroConstants.lightParticleColor)),
        onPump = model.pump;

  final Listenable listenable;
  final Color Function() bodyColorOf;
  final VoidCallback onPump;
  final double height;
  final double width;

  @override
  State<BicyclePumpWidget> createState() => _BicyclePumpWidgetState();
}

class _BicyclePumpWidgetState extends State<BicyclePumpWidget> {
  /// 0 = rest (top), 1 = fully depressed.
  double _handleT = 0;
  double _accum = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.listenable,
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
                  final travel = size.height * 0.28;
                  final next =
                      (_handleT + d.delta.dy / travel).clamp(0.0, 1.0);
                  setState(() => _handleT = next);
                  if (d.delta.dy > 0) {
                    _accum += d.delta.dy;
                    if (_accum > travel * 0.45) {
                      _accum = 0;
                      widget.onPump();
                    }
                  }
                },
                onVerticalDragEnd: (_) {
                  setState(() => _handleT = 0);
                  _accum = 0;
                },
                child: CustomPaint(
                  size: size,
                  painter: BicyclePumpPainter(
                    bodyColor: widget.bodyColorOf(),
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

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.68;
    final cylW = (w * 0.20).clamp(18.0, 28.0);
    final shaftW = 5.0;
    final handleH = 12.0;
    final handleHalfW = 18.0;

    final baseH = h * 0.08;
    final baseTop = h - baseH;
    final bodyBottom = baseTop - h * 0.04;
    // Cylinder starts below the fully-pulled T-handle + visible shaft.
    final pulledTop = 4.0;
    final bodyTop = pulledTop + handleH + h * 0.16;
    final bodyRect = Rect.fromLTRB(
      cx - cylW / 2,
      bodyTop,
      cx + cylW / 2,
      bodyBottom,
    );

    // T-handle stays above the rim — never sinks into the barrel.
    final pressedTop = bodyTop - 5 - handleH;
    final handleTop = pulledTop + handleT * (pressedTop - pulledTop);
    final handleCy = handleTop + handleH / 2;
    final pistonY = bodyTop + 10 + handleT * (bodyRect.height * 0.55);

    // Hose to container (left).
    final hoseAttach = Offset(bodyRect.left, bodyTop + bodyRect.height * 0.58);
    final hoseEnd = Offset(2, hoseAttach.dy - 2);
    canvas.drawPath(
      Path()
        ..moveTo(hoseAttach.dx, hoseAttach.dy)
        ..cubicTo(
          hoseAttach.dx - w * 0.18,
          hoseAttach.dy,
          hoseEnd.dx + w * 0.22,
          hoseEnd.dy + 6,
          hoseEnd.dx + 5,
          hoseEnd.dy,
        ),
      Paint()
        ..color = const Color(0xFFB0B0B0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    _hoseConnector(
      canvas,
      Rect.fromCenter(center: hoseEnd, width: 12, height: 8),
    );
    _hoseConnector(
      canvas,
      Rect.fromCenter(center: hoseAttach, width: 10, height: 8),
    );

    // Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, baseTop + baseH * 0.38),
        width: cylW * 2.0,
        height: baseH * 0.65,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(baseRect, Paint()..color = const Color(0xFFA3A3A3));

    final cone = Path()
      ..moveTo(cx - cylW * 0.36, bodyBottom - 4)
      ..lineTo(cx + cylW * 0.36, bodyBottom - 4)
      ..lineTo(cx + cylW * 0.68, baseTop)
      ..lineTo(cx - cylW * 0.68, baseTop)
      ..close();
    canvas.drawPath(cone, Paint()..color = const Color(0xFFB8B8B8));

    // Shaft above the rim (pulled out of the barrel).
    final shaftPaint = Paint()..color = const Color(0xFFD8D8D8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cx - shaftW / 2, handleTop + handleH, cx + shaftW / 2, bodyTop + 1),
        const Radius.circular(1),
      ),
      shaftPaint,
    );

    // T-handle (always outside).
    _paintHandle(canvas, Offset(cx, handleCy), handleH, handleHalfW);

    // Barrel
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _shade(bodyColor, 0.28),
            bodyColor,
            _shade(bodyColor, -0.28),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(bodyRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)),
      Paint()
        ..color = _shade(bodyColor, -0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );

    final tickPaint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..strokeWidth = 1;
    for (var i = 1; i <= 7; i++) {
      final y = bodyRect.top + 10 + (bodyRect.height - 20) * (i / 8);
      canvas.drawLine(
        Offset(cx + 3, y),
        Offset(cx + cylW / 2 - 2, y),
        tickPaint,
      );
    }

    // Interior: shaft + piston clipped to the barrel (enters through the opening).
    canvas.save();
    canvas.clipRect(bodyRect.deflate(1));
    canvas.drawRect(
      Rect.fromLTRB(cx - shaftW / 2 + 0.5, bodyTop, cx + shaftW / 2 - 0.5, pistonY),
      Paint()..color = const Color(0xFFC5C5C5),
    );
    final piston = Rect.fromCenter(
      center: Offset(cx, pistonY),
      width: cylW - 4,
      height: 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(piston, const Radius.circular(1)),
      Paint()..color = const Color(0xFFE8E8E8),
    );
    canvas.restore();

    // Rim opening — shaft comes out of this hole only.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, bodyTop), width: cylW * 1.02, height: 6),
      Paint()..color = const Color(0xFFE8E8E8),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, bodyTop), width: cylW * 1.02, height: 6),
      Paint()
        ..color = _shade(bodyColor, -0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _paintHandle(
    Canvas canvas,
    Offset center,
    double height,
    double halfW,
  ) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: halfW * 2, height: height),
          const Radius.circular(3),
        ),
      );
    canvas.drawPath(path, Paint()..color = const Color(0xFFC8C8C8));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF6B6D70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    final ridge = Paint()
      ..color = const Color(0xFF7A7A7A)
      ..strokeWidth = 1;
    for (final dx in [-10.0, 0.0, 10.0]) {
      canvas.drawLine(
        Offset(center.dx + dx, center.dy - height * 0.28),
        Offset(center.dx + dx, center.dy + height * 0.28),
        ridge,
      );
    }
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
  const HeaterCoolerWidget({
    super.key,
    required this.listenable,
    required this.factorOf,
    required this.enabledOf,
    required this.hideOf,
    required this.onChanged,
    required this.onReleased,
  });

  HeaterCoolerWidget.forIntro({
    super.key,
    required IdealGasLawModel model,
  })  : listenable = model,
        factorOf = (() => model.heatCoolFactor),
        enabledOf = (() => model.isPlaying && model.numberOfParticles > 0),
        hideOf = (() =>
            model.holdConstant == HoldConstant.temperature ||
            model.holdConstant == HoldConstant.pressureT),
        onChanged = model.setHeatCool,
        onReleased = (() => model.setHeatCool(0));

  final Listenable listenable;
  final double Function() factorOf;
  final bool Function() enabledOf;
  final bool Function() hideOf;
  final ValueChanged<double> onChanged;
  final VoidCallback onReleased;

  /// Logical design size (scale=1); matches IdealScreenAnchors heaterW/H.
  static const double designWidth = 168;
  static const double designHeight = 150;
  static const double stoveWidthLogical = 120;

  @override
  Widget build(BuildContext context) {
        return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        if (hideOf()) {
          return const SizedBox.expand();
        }
        final enabled = enabledOf();
        final factor = factorOf();

        return Material(
          type: MaterialType.transparency,
          child: LayoutBuilder(
          builder: (context, constraints) {
            final s = constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? (constraints.maxHeight / designHeight).clamp(0.55, 1.0)
                : 1.0;
            final stoveW = stoveWidthLogical * s;
            final stoveH = 140 * s;
            const labelStyle = TextStyle(color: Colors.white54, fontSize: 10);

            return Opacity(
              opacity: enabled ? 1 : 0.45,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      if (factor > 0)
                        Positioned(
                          top: -factor * 40 * s,
                          left: 18 * s,
                          right: 18 * s,
                          child: Image.asset(
                            'assets/gases_intro/flame.png',
                            height: 64 * s,
                            fit: BoxFit.contain,
                          ),
                        ),
                      if (factor < 0)
                        Positioned(
                          top: factor.abs() * -28 * s,
                          left: 24 * s,
                          right: 24 * s,
                          child: Image.asset(
                            'assets/gases_intro/iceCubeStack.png',
                            height: 50 * s,
                            fit: BoxFit.contain,
                          ),
                        ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: CustomPaint(
                          size: Size(stoveW, stoveH * 0.78),
                          painter: const _StovePainter(
                            baseColor: Color(0xFFB8B8B8),
                          ),
                        ),
                      ),
                      Positioned(
                        left: stoveW * 0.32,
                        right: stoveW * 0.32,
                        top: stoveH * 0.28,
                        bottom: stoveH * 0.12,
                        child: IgnorePointer(
                          ignoring: !enabled,
                          child: Column(
                            children: [
                              Text(GasesIntroStrings.heat, style: labelStyle),
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
                                        height: 28 * s,
                                        child: SliderTheme(
                                          data: SliderTheme.of(context)
                                              .copyWith(
                                            trackHeight:
                                                (10 * s).clamp(6.0, 10.0),
                                            trackShape:
                                                const _HeatCoolGradientTrack(),
                                            thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius:
                                                  (8 * s).clamp(6.0, 8.0),
                                            ),
                                            overlayShape:
                                                RoundSliderOverlayShape(
                                              overlayRadius:
                                                  (12 * s).clamp(8.0, 12.0),
                                            ),
                                            thumbColor:
                                                const Color(0xFF71EDFF),
                                          ),
                                          child: Slider(
                                            value: factor.clamp(-1.0, 1.0),
                                            min: -1,
                                            max: 1,
                                            onChanged: enabled
                                                ? onChanged
                                                : null,
                                            onChangeEnd: enabled
                                                ? (_) => onReleased()
                                                : null,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Text(GasesIntroStrings.cool, style: labelStyle),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        );
      },
    );
  }
}

/// Horizontal slider is rotated 270° (quarterTurns: 3): left=bottom, right=top.
/// Paint cool `#0A00F0` at min (bottom) → heat `#EF000F` at max (top).
class _HeatCoolGradientTrack extends SliderTrackShape {
  const _HeatCoolGradientTrack();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final height = sliderTheme.trackHeight ?? 8;
    final top = offset.dy + (parentBox.size.height - height) / 2;
    return Rect.fromLTWH(offset.dx, top, parentBox.size.width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
    context.canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF0A00F0),
            Color(0xFFEF000F),
          ],
        ).createShader(rect),
    );
  }
}

/// Stove bowl / body geometry from HeaterCoolerBack + HeaterCoolerFront.
class _StovePainter extends CustomPainter {
  const _StovePainter({required this.baseColor});
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
