import 'package:flutter/material.dart';
import 'package:kratos/balancing_act/ba_assets.dart';
import 'package:kratos/balancing_act/ba_colors.dart';
import 'package:kratos/balancing_act/ba_mvt.dart';
import 'package:kratos/balancing_act/ba_strings.dart';
import 'package:kratos/balancing_act/model/ba_mass.dart';
import 'package:kratos/balancing_act/view/widgets/ba_styled_svg.dart';
import 'package:kratos/balancing_act/view/widgets/ba_text.dart';
import 'package:kratos/hookes_law/view/phet_font.dart';

/// Mass node — original PhET SVG or procedural brick stack; model bottom-center.
class BaMassNode extends StatelessWidget {
  const BaMassNode({
    super.key,
    required this.mass,
    required this.mvt,
    required this.showLabel,
    required this.stageKey,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final BaMass mass;
  final BaModelViewTransform mvt;
  final bool showLabel;
  final GlobalKey stageKey;
  final void Function(Offset stageLocal) onDragStart;
  final void Function(Offset stageLocal) onDragUpdate;
  final VoidCallback onDragEnd;

  String? get _asset {
    switch (mass.type) {
      case BaMassType.fireExtinguisher:
        return BaAssets.fireExtinguisher;
      case BaMassType.smallTrashCan:
      case BaMassType.largeTrashCan:
        return BaAssets.trashCan;
      case BaMassType.boy:
        return BaAssets.usaBoyStanding;
      case BaMassType.girl:
        return BaAssets.usaGirlStanding;
      case BaMassType.man:
        return BaAssets.usaManStanding;
      case BaMassType.woman:
        return BaAssets.usaWomanStanding;
      case BaMassType.mystery:
        final id = mass.mysteryMassId ?? 0;
        return BaAssets.mysteryObject(id);
      case BaMassType.fireHydrant:
        return BaAssets.fireHydrant;
      case BaMassType.television:
        return BaAssets.television;
      case BaMassType.crate:
        return BaAssets.woodCrate;
      case BaMassType.flowerPot:
        return BaAssets.flowerPot;
      case BaMassType.smallBucket:
        return BaAssets.yellowBucket;
      case BaMassType.mediumBucket:
        return BaAssets.blueBucket;
      case BaMassType.largeBucket:
        return BaAssets.metalBucket;
      case BaMassType.pottedPlant:
        return BaAssets.pottedPlant;
      case BaMassType.tire:
        return BaAssets.tire;
      case BaMassType.tinyRock:
        return BaAssets.tinyRock;
      case BaMassType.smallRock:
        return BaAssets.rock4;
      case BaMassType.mediumRock:
        return BaAssets.rock1;
      case BaMassType.bigRock:
        return BaAssets.rock6;
      case BaMassType.cinderBlock:
        return BaAssets.cinderBlock;
      case BaMassType.puppy:
        return BaAssets.puppy;
      case BaMassType.sodaBottle:
        return BaAssets.sodaBottle;
      case BaMassType.barrel:
        return BaAssets.barrel;
      default:
        return null;
    }
  }

  Offset _toStage(Offset global) {
    final box = stageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return global;
    return box.globalToLocal(global);
  }

  Widget _label() {
    if (!showLabel) return const SizedBox.shrink();
    final text = mass.isMystery
        ? BaStrings.unknownMassLabel
        : BaStrings.massLabel(mass.massValue);
    return Text(text, style: PhetFont.of(12), textHeightBehavior: BaText.baseline);
  }

  Widget _body(double heightPx) {
    if (mass.type == BaMassType.brickStack) {
      return _BrickStackVisual(
        numBricks: mass.numBricks,
        heightPx: heightPx,
        widthPx: mvt.modelToViewDeltaX(BaMassCatalog.brickWidth).abs(),
      );
    }
    final asset = _asset;
    if (asset == null) {
      return SizedBox(
        height: heightPx,
        width: heightPx * 0.5,
        child: ColoredBox(color: Colors.grey.shade400),
      );
    }
    return BaSvgPicture.asset(
      asset,
      height: heightPx,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final heightPx =
        mvt.modelToViewDeltaY(mass.height).abs() * mass.animationScale;
    final bottom = mvt.modelToView(mass.position);
    final centerX =
        mvt.modelToViewX(mass.position.x - mass.centerOfMassXOffset);

    return Positioned(
      left: centerX,
      top: bottom.dy,
      child: Transform.rotate(
        angle: -mass.rotationAngle,
        alignment: Alignment.topLeft,
        origin: Offset.zero,
        child: FractionalTranslation(
          translation: const Offset(-0.5, -1.0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) => onDragStart(_toStage(d.globalPosition)),
            onPanUpdate: (d) => onDragUpdate(_toStage(d.globalPosition)),
            onPanEnd: (_) => onDragEnd(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _label(),
                _body(heightPx),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Procedural brick stack — source BrickStackNode fill `rgb(205,38,38)`.
class _BrickStackVisual extends StatelessWidget {
  const _BrickStackVisual({
    required this.numBricks,
    required this.heightPx,
    required this.widthPx,
  });

  final int numBricks;
  final double heightPx;
  final double widthPx;

  @override
  Widget build(BuildContext context) {
    final brickH = heightPx / mathMax(numBricks, 1);
    return SizedBox(
      width: widthPx,
      height: heightPx,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(numBricks, (i) {
          return Container(
            width: widthPx,
            height: brickH,
            decoration: BoxDecoration(
              color: BaColors.brickFill,
              border: Border.all(color: Colors.black, width: 1),
            ),
          );
        }),
      ),
    );
  }
}

int mathMax(int a, int b) => a > b ? a : b;

/// Compact creator thumbnail for Lab carousel (scaled MVT ~150 in source).
class BaBrickCreatorThumb extends StatelessWidget {
  const BaBrickCreatorThumb({super.key, required this.numBricks});

  final int numBricks;

  @override
  Widget build(BuildContext context) {
    const scale = 150.0; // BrickStackCreatorNode SCALING_MVT
    final w = BaMassCatalog.brickWidth * scale;
    final h = BaMassCatalog.brickHeight * numBricks * scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BrickStackVisual(numBricks: numBricks, heightPx: h, widthPx: w),
        const SizedBox(height: 2),
        Text(
          BaStrings.massLabel(numBricks * BaMassCatalog.brickMass),
          style: PhetFont.of(12),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
      ],
    );
  }
}
