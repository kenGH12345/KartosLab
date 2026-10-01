import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_layout_constants.dart';

/// PhET `LightBulbNode` — wires + base + bulb images; local origin = model position.
///
/// Evidence: `systems/view/LightBulbNode.ts`
class LightBulbNode extends StatelessWidget {
  const LightBulbNode({
    super.key,
    required this.fluorescent,
    required this.lit,
    required this.litProportion,
    required this.opacity,
    this.energyChunksVisible = false,
  });

  final bool fluorescent;
  final bool lit;
  final double litProportion;
  final double opacity;
  final bool energyChunksVisible;

  static const double fluorescentBulbTopOffset = 28;
  static const double incandescentBulbTopOffset = 31;

  static const double wireStraightLeft = -110.5;
  static const double wireStraightTop = 78;

  @override
  Widget build(BuildContext context) {
    final ws = EfacLayoutConstants.wireImageScale;
    final wireStraightW =
        EfacLayoutConstants.wireStraightNative.width * ws;
    final wireStraightH =
        EfacLayoutConstants.wireStraightNative.height * ws;

    // wireBottomRight (full, not Short): left = wireStraight.right - 4
    const wireBrNative = Size(133, 277);
    final wireBrW = wireBrNative.width * ws;
    final wireBrH = wireBrNative.height * ws;
    final wireBrLeft = wireStraightLeft + wireStraightW - 4;
    final wireBrBottom = wireStraightTop + wireStraightH + 2.3;
    final wireBrTop = wireBrBottom - wireBrH;

    final baseW = EfacLayoutConstants.elementBaseWidth;
    final baseRight = wireBrLeft + wireBrW + 22;
    final baseLeft = baseRight - baseW;
    final baseBackTop = wireBrTop - 2.5;
    final baseFrontTop = wireBrTop - 3;
    // elementBase intrinsic 152×92 → height from maxWidth
    final baseH = baseW * (92 / 152);

    final bulbTopOffset =
        fluorescent ? fluorescentBulbTopOffset : incandescentBulbTopOffset;
    final bulbBottom = baseFrontTop + bulbTopOffset;
    // Native sizes for layout bounds
    final bulbW = fluorescent ? 175.0 : 180.0;
    final bulbH = fluorescent ? 176.0 : 247.0;
    final bulbLeft = baseLeft + baseW / 2 - bulbW / 2;
    final bulbTop = bulbBottom - bulbH;

    final glassOpacity = energyChunksVisible
        ? (fluorescent ? 0.7 : 1.0) * litProportion.clamp(0.0, 1.0)
        : litProportion.clamp(0.0, 1.0);
    final offOpacity = energyChunksVisible && fluorescent ? 0.7 : 1.0;

    final minX = [wireStraightLeft, baseLeft, bulbLeft]
        .reduce((a, b) => a < b ? a : b);
    final minY = [bulbTop, wireStraightTop, baseBackTop]
        .reduce((a, b) => a < b ? a : b);
    final maxX = baseRight;
    final maxY = wireBrBottom;

    Widget at(double x, double y, Widget child) => Positioned(
          left: x - minX,
          top: y - minY,
          child: child,
        );

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: maxX - minX,
        height: maxY - minY,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            at(
              wireStraightLeft,
              wireStraightTop,
              Image.asset(
                EfacAssets.png('wireStraight'),
                width: wireStraightW,
                height: wireStraightH,
                gaplessPlayback: true,
              ),
            ),
            at(
              wireBrLeft,
              wireBrTop,
              Image.asset(
                EfacAssets.png('wireBottomRight'),
                width: wireBrW,
                height: wireBrH,
                gaplessPlayback: true,
              ),
            ),
            at(
              baseLeft,
              baseBackTop,
              Image.asset(
                EfacAssets.png('elementBaseBack'),
                width: baseW,
                height: baseH,
                gaplessPlayback: true,
              ),
            ),
            at(
              baseLeft,
              baseFrontTop,
              Image.asset(
                EfacAssets.png('elementBaseFront'),
                width: baseW,
                height: baseH,
                gaplessPlayback: true,
              ),
            ),
            if (fluorescent) ...[
              at(
                bulbLeft,
                bulbTop,
                Opacity(
                  opacity: offOpacity,
                  child: Image.asset(
                    EfacAssets.png('fluorescentBack'),
                    width: bulbW,
                    height: bulbH,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              at(
                bulbLeft,
                bulbTop,
                Opacity(
                  opacity: glassOpacity,
                  child: Image.asset(
                    EfacAssets.png('fluorescentOnBack'),
                    width: bulbW,
                    height: bulbH,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              at(
                bulbLeft,
                bulbTop,
                Opacity(
                  opacity: offOpacity,
                  child: Image.asset(
                    EfacAssets.png('fluorescentFront'),
                    width: bulbW,
                    height: bulbH,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              at(
                bulbLeft,
                bulbTop,
                Opacity(
                  opacity: glassOpacity,
                  child: Image.asset(
                    EfacAssets.png('fluorescentOnFront'),
                    width: bulbW,
                    height: bulbH,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ] else ...[
              at(
                bulbLeft,
                bulbTop,
                Image.asset(
                  EfacAssets.png('incandescent'),
                  width: bulbW,
                  height: bulbH,
                  gaplessPlayback: true,
                ),
              ),
              at(
                bulbLeft,
                bulbTop,
                Opacity(
                  opacity: litProportion.clamp(0.0, 1.0),
                  child: Image.asset(
                    EfacAssets.png('incandescentOn'),
                    width: bulbW,
                    height: bulbH,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Stack top-left so local (0,0) = model origin.
  static Offset topLeftFromModelOrigin({required bool fluorescent}) {
    final ws = EfacLayoutConstants.wireImageScale;
    final wireStraightW =
        EfacLayoutConstants.wireStraightNative.width * ws;
    const wireBrNative = Size(133, 277);
    final wireBrW = wireBrNative.width * ws;
    final wireBrH = wireBrNative.height * ws;
    final wireBrLeft = wireStraightLeft + wireStraightW - 4;
    final wireBrBottom = wireStraightTop +
        EfacLayoutConstants.wireStraightNative.height * ws +
        2.3;
    final wireBrTop = wireBrBottom - wireBrH;
    final baseW = EfacLayoutConstants.elementBaseWidth;
    final baseRight = wireBrLeft + wireBrW + 22;
    final baseLeft = baseRight - baseW;
    final baseFrontTop = wireBrTop - 3;
    final bulbTopOffset =
        fluorescent ? fluorescentBulbTopOffset : incandescentBulbTopOffset;
    final bulbH = fluorescent ? 176.0 : 247.0;
    final bulbW = fluorescent ? 175.0 : 180.0;
    final bulbLeft = baseLeft + baseW / 2 - bulbW / 2;
    final bulbTop = baseFrontTop + bulbTopOffset - bulbH;

    final minX = [wireStraightLeft, baseLeft, bulbLeft]
        .reduce((a, b) => a < b ? a : b);
    final minY = [bulbTop, wireStraightTop, wireBrTop - 2.5]
        .reduce((a, b) => a < b ? a : b);
    return Offset(minX, minY);
  }
}

/// Backward-compatible thin wrapper used by older call sites.
@Deprecated('Use LightBulbNode')
class BulbNode extends StatelessWidget {
  const BulbNode({
    super.key,
    required this.fluorescent,
    required this.lit,
    required this.opacity,
  });

  final bool fluorescent;
  final bool lit;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return LightBulbNode(
      fluorescent: fluorescent,
      lit: lit,
      litProportion: lit ? 1.0 : 0.0,
      opacity: opacity,
    );
  }
}
