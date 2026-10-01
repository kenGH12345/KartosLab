import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_colors.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

/// PhET `SunNode` — local origin = model position.
///
/// Evidence `SunNode.ts` / `SunEnergySource.ts`:
/// - OFFSET_TO_CENTER_OF_SUN (−0.05, 0.12), RADIUS 0.02 m
/// - LightRays (~40) hidden when energyChunksVisible
/// - Clouds Panel at centerX:0, centerY:0 with VSlider 0..1
class SunEnergyNode extends StatelessWidget {
  const SunEnergyNode({
    super.key,
    required this.model,
    required this.opacity,
  });

  final SystemsModel model;
  final double opacity;

  static const double _s = EfacConstants.systemsMvtScaleFactor;

  /// SunEnergySource.ts OFFSET_TO_CENTER_OF_SUN.
  static const Offset offsetToCenterOfSun = Offset(-0.05, 0.12);

  /// SunEnergySource.ts RADIUS.
  static const double radiusM = 0.02;

  static const int rayCount = 36;
  static const double rayLength = 420;

  static Offset get _sunCenterView => Offset(
        offsetToCenterOfSun.dx * _s,
        -offsetToCenterOfSun.dy * _s,
      );

  static double get _sunRadiusPx => radiusM * _s;

  /// Clouds panel approx half-size (title + VSlider).
  static const double panelHalfW = 55;
  static const double panelHalfH = 95;

  static _SunLayout get _layout {
    final c = _sunCenterView;
    final r = _sunRadiusPx;
    final rayExtent = rayLength;
    final cloudIconScale = 0.25;
    final cloudNativeW = 240.0 * cloudIconScale;
    final cloudNativeH = 131.0 * cloudIconScale;
    // Optional decorative cloud near sun (fade with cloudiness).
    final decorCloudLeft = c.dx + r * 0.6;
    final decorCloudTop = c.dy + r * 0.2;

    final minX = math.min(
      c.dx - rayExtent,
      math.min(-panelHalfW, decorCloudLeft),
    );
    final minY = math.min(
      c.dy - rayExtent,
      math.min(-panelHalfH, decorCloudTop),
    );
    final maxX = math.max(
      c.dx + rayExtent,
      math.max(panelHalfW, decorCloudLeft + cloudNativeW),
    );
    final maxY = math.max(
      c.dy + rayExtent,
      math.max(panelHalfH, decorCloudTop + cloudNativeH),
    );

    return _SunLayout(
      sunCenter: c,
      sunRadius: r,
      decorCloudLeft: decorCloudLeft,
      decorCloudTop: decorCloudTop,
      decorCloudW: cloudNativeW,
      decorCloudH: cloudNativeH,
      minX: minX,
      minY: minY,
      maxX: maxX,
      maxY: maxY,
    );
  }

  static Offset topLeftFromModelOrigin() {
    final L = _layout;
    return Offset(L.minX, L.minY);
  }

  @override
  Widget build(BuildContext context) {
    final L = _layout;
    final cloudiness = model.sunCloudinessProportion;

    Widget at(double x, double y, Widget child) => Positioned(
          left: x - L.minX,
          top: y - L.minY,
          child: child,
        );

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: L.maxX - L.minX,
        height: L.maxY - L.minY,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (!model.energyChunksVisible)
              Positioned(
                left: L.sunCenter.dx - rayLength - L.minX,
                top: L.sunCenter.dy - rayLength - L.minY,
                width: rayLength * 2,
                height: rayLength * 2,
                child: CustomPaint(
                  painter: _SunRaysPainter(
                    center: Offset(rayLength, rayLength),
                    sunRadius: L.sunRadius,
                    rayCount: rayCount,
                    rayLength: rayLength,
                  ),
                ),
              ),
            // Decorative cloud fades with cloudiness (optional SunNode cloud look).
            at(
              L.decorCloudLeft,
              L.decorCloudTop,
              Opacity(
                opacity: cloudiness.clamp(0.0, 1.0),
                child: Image.asset(
                  EfacAssets.png('cloud'),
                  width: L.decorCloudW,
                  height: L.decorCloudH,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                ),
              ),
            ),
            at(
              L.sunCenter.dx - L.sunRadius,
              L.sunCenter.dy - L.sunRadius,
              Container(
                width: L.sunRadius * 2,
                height: L.sunRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: const [
                      Colors.white,
                      Colors.white,
                      Color(0xFFFFD700),
                    ],
                    stops: const [0.0, 0.25, 1.0],
                  ),
                  border: Border.all(color: Colors.yellow, width: 1),
                ),
              ),
            ),
            // Clouds control panel — SunNode.ts centerX:0, centerY:0
            Positioned(
              left: -panelHalfW - L.minX,
              top: -panelHalfH - L.minY,
              width: panelHalfW * 2,
              height: panelHalfH * 2,
              child: _CloudsControlPanel(
                value: cloudiness,
                onChanged: model.setCloudiness,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SunLayout {
  const _SunLayout({
    required this.sunCenter,
    required this.sunRadius,
    required this.decorCloudLeft,
    required this.decorCloudTop,
    required this.decorCloudW,
    required this.decorCloudH,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  final Offset sunCenter;
  final double sunRadius;
  final double decorCloudLeft, decorCloudTop, decorCloudW, decorCloudH;
  final double minX, minY, maxX, maxY;
}

class _SunRaysPainter extends CustomPainter {
  _SunRaysPainter({
    required this.center,
    required this.sunRadius,
    required this.rayCount,
    required this.rayLength,
  });

  final Offset center;
  final double sunRadius;
  final int rayCount;
  final double rayLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < rayCount; i++) {
      final a = (2 * math.pi * i) / rayCount;
      final inner = Offset(
        center.dx + math.cos(a) * (sunRadius + 2),
        center.dy + math.sin(a) * (sunRadius + 2),
      );
      final outer = Offset(
        center.dx + math.cos(a) * rayLength,
        center.dy + math.sin(a) * rayLength,
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunRaysPainter old) =>
      old.sunRadius != sunRadius || old.rayCount != rayCount;
}

/// PhET Clouds Panel: title + cloud icon + VSlider None/Lots.
class _CloudsControlPanel extends StatelessWidget {
  const _CloudsControlPanel({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EfacColors.controlPanelBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          EfacConstants.controlPanelCornerRadius,
        ),
        side: const BorderSide(
          color: EfacColors.controlPanelOutline,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  EfacStrings.clouds,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  EfacAssets.png('cloud'),
                  width: 240 * 0.25,
                  height: 131 * 0.25,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    width: 36,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(EfacStrings.lots, style: TextStyle(fontSize: 11)),
                        Text(EfacStrings.none, style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 9,
                          ),
                          activeTrackColor: const Color(0xFF90A4AE),
                          inactiveTrackColor: const Color(0xFFCFD8DC),
                          thumbColor: const Color(0xFF546E7A),
                        ),
                        child: Slider(
                          min: 0,
                          max: 1,
                          // RotatedBox: visual top = Lots = value 1.
                          value: value.clamp(0.0, 1.0),
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
