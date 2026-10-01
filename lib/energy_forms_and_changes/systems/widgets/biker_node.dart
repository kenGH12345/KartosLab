import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_colors.dart';
import 'package:kratos/energy_forms_and_changes/efac_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_layout_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

/// PhET `BikerNode` — local origin = model position.
///
/// Intrinsic 500×650 for frame/legs/torso; display size = native × 0.490.
/// Crank HSlider lives in a Panel at (centerX:0, centerY:110) — BikerNode.ts.
class BikerNode extends StatelessWidget {
  const BikerNode({
    super.key,
    required this.model,
    required this.opacity,
    required this.mvtScale,
  });

  final SystemsModel model;
  final double opacity;
  final double mvtScale;

  static const int legFrames = 18;
  static const double nativeW = 500;
  static const double nativeH = 650;

  /// PhET `BikerNode.ts` Panel(crankSlider) centerY.
  static const double crankPanelCenterY = 110;

  /// PhET HSlider trackSize 200×5, thumbSize 20×40.
  static const double crankTrackW = 200;
  static const double crankTrackH = 5;
  static const Size crankThumbSize = Size(20, 40);

  static int mapAngleToImageIndex(double angle) {
    final i = (angle / (2 * math.pi) * legFrames).floor() % legFrames;
    return i < 0 ? i + legFrames : i;
  }

  @override
  Widget build(BuildContext context) {
    final scale = EfacLayoutConstants.bikerImageScale;
    final right = EfacLayoutConstants.bicycleSystemRightOffset;
    final top = EfacLayoutConstants.bicycleSystemTopOffset;
    final displayW = nativeW * scale;
    final displayH = nativeH * scale;
    final frameLeft = right - displayW;
    final frameTop = top;

    final gearCenter = Offset(
      EfacLayoutConstants.centerOfGearOffset.dx * mvtScale,
      -EfacLayoutConstants.centerOfGearOffset.dy * mvtScale,
    );
    final wheelCenter = Offset(
      EfacLayoutConstants.centerOfBackWheelOffset.dx * mvtScale,
      -EfacLayoutConstants.centerOfBackWheelOffset.dy * mvtScale,
    );

    final legI = mapAngleToImageIndex(model.bikerCrankAngle);
    final backLeg = EfacAssets.png(
      'cyclistLegBack${(legI + 1).toString().padLeft(2, '0')}',
    );
    final frontLeg = EfacAssets.png(
      'cyclistLegFront${(legI + 1).toString().padLeft(2, '0')}',
    );
    final torso = _torsoAsset(model.bikerEnergyChunksRemaining);

    final spokesW = 128 * scale;
    final spokesH = 130 * scale;
    final gearW = 66 * scale;
    final gearH = 67 * scale;

    // Panel ≈ track + thumb + padding; Feed Me sits above torso.
    const panelHalfH = 36.0;
    const panelHalfW = 120.0;
    final panelTop = crankPanelCenterY - panelHalfH;
    final panelBottom = crankPanelCenterY + panelHalfH;
    const feedMeTopPad = 50.0;

    final minX = math.min(
      frameLeft,
      math.min(gearCenter.dx - gearW / 2, -panelHalfW),
    );
    final minY = math.min(frameTop - feedMeTopPad, panelTop);
    final maxX = math.max(right + 10, panelHalfW);
    final maxY = math.max(frameTop + displayH, panelBottom);

    Widget at(double x, double y, Widget child) => Positioned(
          left: x - minX,
          top: y - minY,
          child: child,
        );

    Widget bikeLayer(String asset) => Image.asset(
          asset,
          width: displayW,
          height: displayH,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.medium,
          gaplessPlayback: true,
        );

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: maxX - minX,
        height: maxY - minY,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            at(frameLeft, frameTop, bikeLayer(backLeg)),
            at(
              wheelCenter.dx - spokesW / 2,
              wheelCenter.dy - spokesH / 2,
              Transform.rotate(
                angle: -model.bikerRearWheelAngle,
                child: Image.asset(
                  EfacAssets.png('bicycleSpokes'),
                  width: spokesW,
                  height: spokesH,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                ),
              ),
            ),
            at(frameLeft, frameTop, bikeLayer(EfacAssets.png('bicycleFrame'))),
            at(
              gearCenter.dx - gearW / 2,
              gearCenter.dy - gearH / 2,
              Transform.rotate(
                angle: -model.bikerCrankAngle,
                child: Image.asset(
                  EfacAssets.png('bicycleGear'),
                  width: gearW,
                  height: gearH,
                  fit: BoxFit.fill,
                  gaplessPlayback: true,
                ),
              ),
            ),
            at(frameLeft, frameTop, bikeLayer(torso)),
            at(frameLeft, frameTop, bikeLayer(frontLeg)),
            // Feed Me above head — BikerNode.ts centerY: torso.centerTop.y - 15
            if (model.bikerEnergyChunksRemaining == 0)
              Positioned(
                left: frameLeft + displayW / 2 - 55 - minX,
                top: frameTop - 45 - minY,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00DC00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: const Size(100, 30),
                  ),
                  onPressed: model.feedBiker,
                  child: const Text(
                    EfacStrings.feedMe,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            // Panel AFTER bike images so it is visible and pickable (PhET order
            // places it below the sprite in Y; Flutter must also paint on top).
            Positioned(
              left: -panelHalfW - minX,
              top: panelTop - minY,
              width: panelHalfW * 2,
              child: _CrankControlPanel(
                value: model.bikerTargetCrankAngularVelocity,
                onChanged: model.setBikerSpeed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _torsoAsset(int remaining) {
    // BikerNode.ts: >0.67 / >0.33 / >0 / else
    const max = 21;
    final ratio = remaining / max;
    if (ratio > 0.67) return EfacAssets.png('cyclistTorso');
    if (ratio > 0.33) return EfacAssets.png('cyclistTorsoTired1');
    if (ratio > 0) return EfacAssets.png('cyclistTorsoTired2');
    return EfacAssets.png('cyclistTorsoTired3');
  }

  static Offset topLeftFromModelOrigin(double mvtScale) {
    final scale = EfacLayoutConstants.bikerImageScale;
    final displayW = nativeW * scale;
    final frameLeft =
        EfacLayoutConstants.bicycleSystemRightOffset - displayW;
    final frameTop = EfacLayoutConstants.bicycleSystemTopOffset;
    const panelHalfW = 120.0;
    const panelTop = crankPanelCenterY - 36.0;
    const feedMeTopPad = 50.0;
    return Offset(
      math.min(frameLeft, -panelHalfW),
      math.min(frameTop - feedMeTopPad, panelTop),
    );
  }
}

/// PhET Panel + HSlider under the bicycle (BikerNode.ts:274-295).
class _CrankControlPanel extends StatelessWidget {
  const _CrankControlPanel({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  static const double _maxOmega = 3 * math.pi;

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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: SizedBox(
          width: BikerNode.crankTrackW,
          height: BikerNode.crankThumbSize.height,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: BikerNode.crankTrackH,
              thumbShape: _BikerCrankThumbShape(
                size: BikerNode.crankThumbSize,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: const Color(0xFF5A9BD5),
              inactiveTrackColor: const Color(0xFFB8D4EA),
              thumbColor: const Color(0xFF3D7AB5),
            ),
            child: Slider(
              min: 0,
              max: _maxOmega,
              value: value.clamp(0.0, _maxOmega),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

/// Vertical capsule thumb — PhET thumbSize (20, 40) on HSlider.
class _BikerCrankThumbShape extends SliderComponentShape {
  const _BikerCrankThumbShape({required this.size});

  final Size size;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => size;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawRRect(
      rrect,
      Paint()..color = sliderTheme.thumbColor ?? const Color(0xFF3D7AB5),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}
