import 'dart:math' as math;

import 'package:flutter/material.dart';

/// L0 scenery-phet [MeasuringTapeNode] — PNG housing + gray tape + orange tip.
///
/// Coordinates are **view-space**. Callers own model↔view conversion and label text.
///
/// Asset: original PhET `measuringTape.png` (right-bottom of image = [base]).
class KratosMeasuringTape extends StatelessWidget {
  const KratosMeasuringTape({
    super.key,
    required this.base,
    required this.tip,
    required this.label,
    required this.onBaseDelta,
    required this.onTipDelta,
    this.onBodyDelta,
    this.visible = true,
    this.baseScale = 0.8,
    this.assetPath = defaultAssetPath,
    this.labelStyle,
    this.labelBackground = const Color(0xE6FFFFFF),
  });

  /// Canonical scenery-phet measuring-tape housing (already in pubspec).
  static const String defaultAssetPath =
      'assets/energy_skate_park/scenery_phet/measuringTape.png';

  static const Color crosshairColor = Color(0xFFE05F20);
  static const double crosshairSize = 5;
  static const double tipHaloRadius = 10;
  static const double _pngIntrinsic = 51;

  /// View-space base (housing right-bottom / tape start).
  final Offset base;

  /// View-space tip (tape end).
  final Offset tip;

  /// Distance readout (already formatted, with unit).
  final String label;

  final ValueChanged<Offset> onBaseDelta;
  final ValueChanged<Offset> onTipDelta;
  final ValueChanged<Offset>? onBodyDelta;

  final bool visible;
  final double baseScale;
  final String assetPath;
  final TextStyle? labelStyle;
  final Color labelBackground;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final angle = math.atan2(tip.dy - base.dy, tip.dx - base.dx);
    final img = _pngIntrinsic * baseScale;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _KratosTapeLinePainter(base: base, tip: tip),
          ),
        ),
        Positioned(
          left: (base.dx + tip.dx) / 2 - 40,
          top: (base.dy + tip.dy) / 2 - 16,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: labelBackground,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: labelStyle ??
                    const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
        // Tip halo + crosshair (draggable).
        Positioned(
          left: tip.dx - tipHaloRadius - 12,
          top: tip.dy - tipHaloRadius - 12,
          width: (tipHaloRadius + 12) * 2,
          height: (tipHaloRadius + 12) * 2,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => onTipDelta(d.delta),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: tipHaloRadius * 2,
                  height: tipHaloRadius * 2,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x1A000000),
                  ),
                ),
                Transform.rotate(
                  angle: angle,
                  child: CustomPaint(
                    size: const Size(20, 20),
                    painter: _KratosCrosshairPainter(),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Housing PNG — right-bottom anchored at [base], rotates with tape.
        Positioned(
          left: base.dx - img - 16,
          top: base.dy - img - 16,
          width: img + 32,
          height: img + 32,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => onBaseDelta(d.delta),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Transform.rotate(
                angle: angle,
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  assetPath,
                  width: img,
                  height: img,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => Container(
                    width: img,
                    height: img,
                    color: const Color(0xFFF5E000),
                    alignment: Alignment.center,
                    child: Container(
                      width: img * 0.4,
                      height: img * 0.4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4AA3E0),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Optional body drag (move whole tape).
        if (onBodyDelta != null)
          Positioned(
            left: (base.dx + tip.dx) / 2 - 24,
            top: (base.dy + tip.dy) / 2 - 24,
            width: 48,
            height: 48,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (d) => onBodyDelta!(d.delta),
            ),
          ),
        // Base crosshair at housing tip.
        Positioned(
          left: base.dx - crosshairSize,
          top: base.dy - crosshairSize,
          width: crosshairSize * 2,
          height: crosshairSize * 2,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: angle,
              child: CustomPaint(
                painter: _KratosCrosshairPainter(),
                size: Size(crosshairSize * 2, crosshairSize * 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KratosTapeLinePainter extends CustomPainter {
  _KratosTapeLinePainter({required this.base, required this.tip});

  final Offset base;
  final Offset tip;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      base,
      tip,
      Paint()
        ..color = const Color(0xFF555555)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _KratosTapeLinePainter old) =>
      old.base != base || old.tip != tip;
}

class _KratosCrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = math.min(size.width, size.height) / 2;
    final paint = Paint()
      ..color = KratosMeasuringTape.crosshairColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx - s, c.dy), Offset(c.dx + s, c.dy), paint);
    canvas.drawLine(Offset(c.dx, c.dy - s), Offset(c.dx, c.dy + s), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Toolbox / panel icon — MeasuringTapeNode.createIcon (typical scale 0.55–0.7).
class KratosMeasuringTapeIcon extends StatelessWidget {
  const KratosMeasuringTapeIcon({
    super.key,
    this.scale = 0.55,
    this.assetPath = KratosMeasuringTape.defaultAssetPath,
  });

  final double scale;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final s = 51 * scale;
    return Image.asset(
      assetPath,
      width: s,
      height: s,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
    );
  }
}
