import 'package:flutter/material.dart';
import 'package:kratos/energy_forms_and_changes/efac_assets.dart';
import 'package:kratos/energy_forms_and_changes/efac_layout_constants.dart';
import 'package:kratos/energy_forms_and_changes/efac_strings.dart';
import 'package:kratos/energy_forms_and_changes/systems/model/systems_model.dart';

/// PhET `GeneratorNode` — local origin = model position.
///
/// Intrinsic sizes measured from assets:
/// generator 212×330, spokes 167×167, hub 173×173, wireBottomLeft 133×277,
/// connector 46×72.
class GeneratorNode extends StatelessWidget {
  const GeneratorNode({
    super.key,
    required this.model,
    required this.opacity,
    this.directCoupling = true,
  });

  final SystemsModel model;
  final double opacity;
  final bool directCoupling;

  static const double genW = 212;
  static const double genH = 330;
  static const double spokesSize = 167;
  static const double wireNativeW = 133;
  static const double wireNativeH = 277;

  @override
  Widget build(BuildContext context) {
    const left = EfacLayoutConstants.generatorImageLeft;
    const top = EfacLayoutConstants.generatorImageTop;
    final genCenter = Offset(left + genW / 2, top + genH / 2);
    final wheelCenter = Offset(
      genCenter.dx,
      genCenter.dy + EfacLayoutConstants.spokesAndPaddlesCenterYOffset,
    );

    final wireScale = EfacLayoutConstants.wireImageScale;
    final wireW = wireNativeW * wireScale;
    final wireH = wireNativeH * wireScale;
    final wireRight = left + genW - 29;
    final wireLeft = wireRight - wireW;
    final wireTop = genCenter.dy - 30;

    final connectorLeft = left + genW - 2;
    final connectorCenterY = genCenter.dy + 90;

    // Hub maxWidth = modelToViewDeltaX(2*R) with systems MVT 2200
    final hubMaxW =
        (EfacLayoutConstants.generatorWheelRadius * 2 * 2200).clamp(24.0, 80.0);

    final wheelAsset = directCoupling
        ? EfacAssets.png('generatorWheelSpokes')
        : EfacAssets.png('generatorWheelPaddlesShort');
    final wheelNative = directCoupling ? spokesSize : 295.0;

    final minX = [left, wireLeft, connectorLeft].reduce((a, b) => a < b ? a : b);
    final minY = [
      top,
      wheelCenter.dy - wheelNative / 2,
      wireTop,
    ].reduce((a, b) => a < b ? a : b);
    final maxX = left + genW + 46;
    final maxY = top + genH;

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
              wireLeft,
              wireTop,
              Image.asset(
                EfacAssets.png('wireBottomLeft'),
                width: wireW,
                height: wireH,
                gaplessPlayback: true,
              ),
            ),
            at(
              left,
              top,
              Image.asset(
                EfacAssets.png('generator'),
                width: genW,
                height: genH,
                gaplessPlayback: true,
              ),
            ),
            at(
              genCenter.dx - 80,
              top + genH - 28,
              SizedBox(
                width: 160,
                child: Text(
                  EfacStrings.generator,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            at(
              connectorLeft,
              connectorCenterY - 36,
              Image.asset(
                EfacAssets.png('connector'),
                width: 46,
                height: 72,
                gaplessPlayback: true,
              ),
            ),
            at(
              wheelCenter.dx - wheelNative / 2,
              wheelCenter.dy - wheelNative / 2,
              Transform.rotate(
                angle: -model.generatorWheelAngle,
                child: SizedBox(
                  width: wheelNative,
                  height: wheelNative,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        wheelAsset,
                        width: wheelNative,
                        height: wheelNative,
                        gaplessPlayback: true,
                      ),
                      Image.asset(
                        EfacAssets.png('generatorWheelHub'),
                        width: hubMaxW,
                        height: hubMaxW,
                        gaplessPlayback: true,
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

  static Offset topLeftFromModelOrigin() {
    const left = EfacLayoutConstants.generatorImageLeft;
    const top = EfacLayoutConstants.generatorImageTop;
    final wireW = wireNativeW * EfacLayoutConstants.wireImageScale;
    final wireLeft = left + genW - 29 - wireW;
    final minX = left < wireLeft ? left : wireLeft;
    return Offset(minX, top);
  }
}
