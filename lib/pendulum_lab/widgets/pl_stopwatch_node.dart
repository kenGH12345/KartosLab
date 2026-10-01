import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// scenery-phet `ShadedRectangle` — light from leftTop, cornerRadius 10.
class PlShadedRectangle extends StatelessWidget {
  const PlShadedRectangle({
    super.key,
    required this.child,
    this.baseColor = const Color.fromRGBO(80, 130, 230, 1),
    this.cornerRadius = 10,
    this.padding = const EdgeInsets.all(8),
    this.shades,
  });

  final Widget child;
  final Color baseColor;
  final double cornerRadius;
  final EdgeInsets padding;

  /// Explicit (light, lighter, dark, darker) edge colors. When null they are
  /// derived from [baseColor] via an HSL approximation of scenery's
  /// PaintColorProperty luminanceFactor.
  final ({Color light, Color lighter, Color dark, Color darker})? shades;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShadedRectanglePainter(
        baseColor: baseColor,
        cornerRadius: cornerRadius,
        shades: shades,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _ShadedRectanglePainter extends CustomPainter {
  _ShadedRectanglePainter({
    required this.baseColor,
    required this.cornerRadius,
    this.shades,
  });

  final Color baseColor;
  final double cornerRadius;
  final ({Color light, Color lighter, Color dark, Color darker})? shades;

  Color _lum(Color c, double factor) {
    // Approximate PaintColorProperty luminanceFactor.
    final hsl = HSLColor.fromColor(c);
    final l = (hsl.lightness + factor * 0.35).clamp(0.0, 1.0);
    return hsl.withLightness(l).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(cornerRadius),
    );
    final lighter = shades?.lighter ?? _lum(baseColor, 0.6);
    final light = shades?.light ?? _lum(baseColor, 0.5);
    final dark = shades?.dark ?? _lum(baseColor, -0.5);
    final darker = shades?.darker ?? _lum(baseColor, -0.6);

    final lightOffset = 0.525 * cornerRadius;
    final darkOffset = 0.375 * cornerRadius;

    canvas.drawRRect(
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, 0),
          [light, baseColor, baseColor, dark],
          [
            0,
            (lightOffset / size.width).clamp(0.0, 1.0),
            (1 - darkOffset / size.width).clamp(0.0, 1.0),
            1,
          ],
        ),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          [
            lighter,
            lighter.withValues(alpha: 0),
            darker.withValues(alpha: 0),
            darker,
          ],
          [
            0,
            (lightOffset / size.height).clamp(0.0, 1.0),
            (1 - darkOffset / size.height).clamp(0.0, 1.0),
            1,
          ],
          // Blend over horizontal base.
        )
        ..blendMode = BlendMode.srcOver,
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = dark.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _ShadedRectanglePainter oldDelegate) =>
      oldDelegate.baseColor != baseColor ||
      oldDelegate.cornerRadius != cornerRadius ||
      oldDelegate.shades != shades;
}

/// Edge shades measured from the published build's StopwatchNode (scenery
/// repo is not in the local source tree, so PaintColorProperty's exact
/// luminanceFactor curve was calibrated against ORIGINAL captures).
const plStopwatchShades = (
  light: Color.fromRGBO(150, 178, 236, 1),
  lighter: Color.fromRGBO(163, 189, 242, 1),
  dark: Color.fromRGBO(64, 104, 183, 1),
  darker: Color.fromRGBO(51, 83, 147, 1),
);

/// scenery-phet StopwatchNode — NumberDisplay + Reset + Play/Pause.
class PlStopwatchNode extends StatelessWidget {
  const PlStopwatchNode({
    super.key,
    required this.timeSeconds,
    required this.isRunning,
    required this.onToggleRunning,
    required this.onReset,
  });

  final double timeSeconds;
  final bool isRunning;
  final VoidCallback onToggleRunning;
  final VoidCallback onReset;

  static const Color backgroundBase = Color.fromRGBO(80, 130, 230, 1);
  static const Color buttonBase = Color(0xFFDFE0E1);
  static const String fontFamily = 'Trebuchet MS';

  @override
  Widget build(BuildContext context) {
    final minutes = (timeSeconds / 60).floor();
    final wholeSeconds = (timeSeconds - minutes * 60).floor();
    final centi =
        ((timeSeconds - minutes * 60 - wholeSeconds) * 100).round().clamp(0, 99);
    final canReset = timeSeconds > 0;

    return PlShadedRectangle(
      baseColor: backgroundBase,
      shades: plStopwatchShades,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // NumberDisplay: xMargin 4 / yMargin 2 / cornerRadius 4 /
            // backgroundFill white / backgroundStroke lightGray / align right.
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFD3D3D3), width: 1),
            ),
            child: RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: fontFamily,
                  color: Colors.black,
                  height: 1.0,
                ),
                children: [
                  TextSpan(
                    text:
                        '${minutes.toString().padLeft(2, '0')}:${wholeSeconds.toString().padLeft(2, '0')}.',
                    style: const TextStyle(fontSize: 20),
                  ),
                  TextSpan(
                    text: centi.toString().padLeft(2, '0'),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          // StopwatchNode: VBox spacing 6; HBox(reset, playPause) spacing 6;
          // iconHeight 10, iconFill black on buttonBaseColor #DFE0E1.
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RectIconButton(
                enabled: canReset,
                onTap: onReset,
                child: CustomPaint(
                  size: const Size(12, 10),
                  painter: _UTurnPainter(),
                ),
              ),
              const SizedBox(width: 6),
              _RectIconButton(
                enabled: true,
                onTap: onToggleRunning,
                child: CustomPaint(
                  // play: width = 0.8 x height; pause: 0.75 x play width
                  size: Size(isRunning ? 6 : 8, 10),
                  painter: isRunning ? _PausePainter() : _PlayPainter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RectIconButton extends StatelessWidget {
  const _RectIconButton({
    required this.enabled,
    required this.onTap,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          // sun RectangularPushButton: content + xMargin 8*2 / yMargin 5*2,
          // plus button bevel — published build measures ~23 design px tall.
          width: 28,
          height: 23,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: PlStopwatchNode.buttonBase,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFF999999)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.2, size.height * 0.9)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PausePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.1, size.width * 0.25, size.height * 0.8),
      p,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.1, size.width * 0.25, size.height * 0.8),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UTurnPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final r = size.height * 0.35;
    final path = Path()
      ..moveTo(size.width * 0.85, size.height * 0.75)
      ..lineTo(size.width * 0.85, size.height * 0.45)
      ..arcToPoint(
        Offset(size.width * 0.15, size.height * 0.45),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(size.width * 0.15, size.height * 0.75);
    canvas.drawPath(path, paint);
    final tip = Offset(size.width * 0.15, size.height * 0.75);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx - 3, tip.dy - 4)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(tip.dx + 3, tip.dy - 4),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
