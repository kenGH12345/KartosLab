import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_colors.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

/// PhET `FaucetAndWaterNode` — local origin = model position.
///
/// Evidence `FaucetAndWaterNode.ts` + `FaucetAndWater.ts` + scenery-phet `FaucetNode.ts`:
/// - OFFSET_FROM_CENTER_TO_FAUCET_HEAD / WATER_ORIGIN
/// - FaucetNode scale 0.45; UI setting → flow = s==0 ? 0 : 0.25+0.75*s
class FaucetAndWaterNode extends StatelessWidget {
  const FaucetAndWaterNode({
    super.key,
    required this.model,
    required this.opacity,
  });

  final SystemsModel model;
  final double opacity;

  static const double _s = EfacConstants.systemsMvtScaleFactor;

  /// FaucetAndWater.ts OFFSET_FROM_CENTER_TO_FAUCET_HEAD (0.069, 0.083).
  static const Offset offsetToFaucetHead = Offset(0.069, 0.083);

  /// FaucetAndWater.ts OFFSET_FROM_CENTER_TO_WATER_ORIGIN (0.069, 0.105).
  static const Offset offsetToWaterOrigin = Offset(0.069, 0.105);

  static const double maxWaterWidthM = 0.014;

  /// scenery-phet FaucetNode scale in FaucetAndWaterNode.ts.
  static const double faucetScale = 0.45;

  static Offset get _faucetHeadView => Offset(
        offsetToFaucetHead.dx * _s,
        -offsetToFaucetHead.dy * _s,
      );

  static Offset get _waterOriginView => Offset(
        offsetToWaterOrigin.dx * _s,
        -offsetToWaterOrigin.dy * _s,
      );

  static double get _maxWaterWidthPx => maxWaterWidthM * _s;

  /// Map UI setting s∈[0,1] → stored flow proportion (PhET FaucetAndWaterNode.ts).
  static double mapSettingToFlow(double setting) =>
      setting == 0 ? 0 : 0.25 + 0.75 * setting;

  /// Inverse of [mapSettingToFlow] for Slider display.
  static double mapFlowToSetting(double flow) {
    if (flow <= 0) return 0;
    return ((flow - 0.25) / 0.75).clamp(0.0, 1.0);
  }

  static _FaucetLayout get _layout {
    final head = _faucetHeadView;
    final water = _waterOriginView;
    final sc = faucetScale;

    // Native FaucetNode layout (origin = spout bottom-center), then × scale.
    const spoutW = 118.0, spoutH = 64.0;
    const bodyW = 154.0, bodyH = 84.0;
    const vertNativeW = 85.0;
    const trackW = 106.0, trackH = 46.0;
    const knobW = 73.0, knobH = 120.0;
    const horizNativeH = 84.0;
    const verticalPipeLength = 40.0;
    const vertOverlap = 1.0;
    const horizOverlap = 1.0;
    const trackYOffset = 15.0;
    // FaucetAndWaterNode: horizontalPipeLength 1400 (long look).
    const horizontalPipeLength = 400.0;

    final spoutDispW = spoutW * sc;
    final spoutDispH = spoutH * sc;
    final spoutLeft = head.dx - spoutDispW / 2;
    final spoutTop = head.dy - spoutDispH;
    final spoutBottom = head.dy;

    final vertH = (verticalPipeLength + 2 * vertOverlap) * sc;
    final vertW = vertNativeW * sc;
    final vertLeft = head.dx - vertW / 2;
    final vertBottom = spoutTop + vertOverlap * sc;
    final vertTop = vertBottom - vertH;

    final bodyDispW = bodyW * sc;
    final bodyDispH = bodyH * sc;
    final bodyRight = vertLeft + vertW;
    final bodyLeft = bodyRight - bodyDispW;
    final bodyBottom = vertTop + vertOverlap * sc;
    final bodyTop = bodyBottom - bodyDispH;

    final horizTargetW =
        (horizontalPipeLength - 112 + horizOverlap) * sc;
    final horizH = horizNativeH * sc;
    final horizRight = bodyLeft + horizOverlap * sc;
    final horizLeft = horizRight - horizTargetW;
    final horizTop = bodyTop;

    final trackDispW = trackW * sc;
    final trackDispH = trackH * sc;
    final trackLeft = bodyLeft;
    final trackBottom = bodyTop + trackYOffset * sc;
    final trackTop = trackBottom - trackDispH;

    final knobDispW = knobW * sc * 0.55;
    final knobDispH = knobH * sc * 0.55;
    final sliderTrackW = 120.0;
    final sliderLeft = trackLeft + 4;
    final sliderTop = trackTop - 8;

    final waterMaxW = _maxWaterWidthPx;
    final waterH = 280.0;
    final waterLeft = water.dx - waterMaxW / 2;
    final waterTop = water.dy;

    final minX = math.min(horizLeft, math.min(waterLeft, sliderLeft));
    final minY = math.min(trackTop - 4, math.min(bodyTop, waterTop));
    final maxX = math.max(
      bodyRight,
      math.max(waterLeft + waterMaxW, sliderLeft + sliderTrackW + 20),
    );
    final maxY = math.max(spoutBottom, waterTop + waterH);

    return _FaucetLayout(
      head: head,
      water: water,
      spoutLeft: spoutLeft,
      spoutTop: spoutTop,
      spoutW: spoutDispW,
      spoutH: spoutDispH,
      vertLeft: vertLeft,
      vertTop: vertTop,
      vertW: vertW,
      vertH: vertH,
      bodyLeft: bodyLeft,
      bodyTop: bodyTop,
      bodyW: bodyDispW,
      bodyH: bodyDispH,
      horizLeft: horizLeft,
      horizTop: horizTop,
      horizW: horizTargetW,
      horizH: horizH,
      trackLeft: trackLeft,
      trackTop: trackTop,
      trackW: trackDispW,
      trackH: trackDispH,
      knobW: knobDispW,
      knobH: knobDispH,
      sliderLeft: sliderLeft,
      sliderTop: sliderTop,
      sliderTrackW: sliderTrackW,
      waterLeft: waterLeft,
      waterTop: waterTop,
      waterMaxW: waterMaxW,
      waterH: waterH,
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
    final flow = model.faucetFlowProportion;
    final setting = mapFlowToSetting(flow);

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
            if (flow > 0)
              at(
                L.waterLeft,
                L.waterTop,
                CustomPaint(
                  size: Size(L.waterMaxW, L.waterH),
                  painter: _FallingWaterPainter(
                    flow: flow,
                    maxWidth: L.waterMaxW,
                  ),
                ),
              ),
            at(
              L.horizLeft,
              L.horizTop,
              Image.asset(
                EfacAssets.png('faucetHorizontalPipe'),
                width: L.horizW,
                height: L.horizH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            at(
              L.vertLeft,
              L.vertTop,
              Image.asset(
                EfacAssets.png('faucetVerticalPipe'),
                width: L.vertW,
                height: L.vertH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            at(
              L.spoutLeft,
              L.spoutTop,
              Image.asset(
                EfacAssets.faucetSpout,
                width: L.spoutW,
                height: L.spoutH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            at(
              L.bodyLeft,
              L.bodyTop,
              Image.asset(
                EfacAssets.faucetBody,
                width: L.bodyW,
                height: L.bodyH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            at(
              L.trackLeft,
              L.trackTop,
              Image.asset(
                EfacAssets.png('faucetTrack'),
                width: L.trackW,
                height: L.trackH,
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            // Clear HSlider for flow (PhET shooter mapped to setting 0..1).
            Positioned(
              left: L.sliderLeft - L.minX,
              top: L.sliderTop - L.minY,
              width: L.sliderTrackW + 24,
              child: Material(
                color: EfacColors.controlPanelBackground.withValues(alpha: 0.92),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Image.asset(
                        EfacAssets.png('faucetKnob'),
                        width: L.knobW * 0.35,
                        height: L.knobH * 0.35,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 5,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
                            activeTrackColor: const Color(0xFF5A9BD5),
                            inactiveTrackColor: const Color(0xFFB8D4EA),
                            thumbColor: const Color(0xFF3D7AB5),
                          ),
                          child: Slider(
                            min: 0,
                            max: 1,
                            value: setting,
                            onChanged: (s) =>
                                model.setFaucetFlow(mapSettingToFlow(s)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaucetLayout {
  const _FaucetLayout({
    required this.head,
    required this.water,
    required this.spoutLeft,
    required this.spoutTop,
    required this.spoutW,
    required this.spoutH,
    required this.vertLeft,
    required this.vertTop,
    required this.vertW,
    required this.vertH,
    required this.bodyLeft,
    required this.bodyTop,
    required this.bodyW,
    required this.bodyH,
    required this.horizLeft,
    required this.horizTop,
    required this.horizW,
    required this.horizH,
    required this.trackLeft,
    required this.trackTop,
    required this.trackW,
    required this.trackH,
    required this.knobW,
    required this.knobH,
    required this.sliderLeft,
    required this.sliderTop,
    required this.sliderTrackW,
    required this.waterLeft,
    required this.waterTop,
    required this.waterMaxW,
    required this.waterH,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  final Offset head, water;
  final double spoutLeft, spoutTop, spoutW, spoutH;
  final double vertLeft, vertTop, vertW, vertH;
  final double bodyLeft, bodyTop, bodyW, bodyH;
  final double horizLeft, horizTop, horizW, horizH;
  final double trackLeft, trackTop, trackW, trackH;
  final double knobW, knobH;
  final double sliderLeft, sliderTop, sliderTrackW;
  final double waterLeft, waterTop, waterMaxW, waterH;
  final double minX, minY, maxX, maxY;
}

/// Simple blue water column; width ∝ flow (FaucetAndWater.MAX_WATER_WIDTH).
class _FallingWaterPainter extends CustomPainter {
  _FallingWaterPainter({required this.flow, required this.maxWidth});

  final double flow;
  final double maxWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final w = (maxWidth * flow).clamp(2.0, maxWidth);
    final left = (size.width - w) / 2;
    final rect = Rect.fromLTWH(left, 0, w, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF4FC3F7).withValues(alpha: 0.35),
          const Color(0xFF29B6F6).withValues(alpha: 0.75),
          const Color(0xFF4FC3F7).withValues(alpha: 0.35),
        ],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FallingWaterPainter old) =>
      old.flow != flow || old.maxWidth != maxWidth;
}
