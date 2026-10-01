import 'package:flutter/material.dart';

import '../../rpal_assets.dart';

/// Sandwich composition renderer — `SandwichNode.ts`.
class SandwichIcon extends StatelessWidget {
  const SandwichIcon({
    super.key,
    required this.breadCount,
    required this.meatCount,
    required this.cheeseCount,
    this.sandwichScale = sandwichScaleDefault,
  });

  final int breadCount;
  final int meatCount;
  final int cheeseCount;
  final double sandwichScale;

  static const double ySpacing = 4;
  static const double sandwichScaleDefault = 0.65;
  static const double ingredientDisplayWidth = 70;

  static Widget breadIcon({double scale = sandwichScaleDefault}) =>
      _ingredient(RpalAssets.bread, scale);

  static Widget meatIcon({double scale = sandwichScaleDefault}) =>
      _ingredient(RpalAssets.meat, scale);

  static Widget cheeseIcon({double scale = sandwichScaleDefault}) =>
      _ingredient(RpalAssets.cheese, scale);

  static Widget _ingredient(String asset, double scale) {
    return Image.asset(
      asset,
      width: ingredientDisplayWidth * scale,
      filterQuality: FilterQuality.medium,
    );
  }

  /// Bottom → top layer assets, matching SandwichNode stacking order.
  List<String> buildLayerAssets() {
    var bread = breadCount;
    var meat = meatCount;
    var cheese = cheeseCount;
    final layers = <String>[];

    if (bread > 0) {
      layers.add(RpalAssets.bread);
      bread--;
    }

    final moreMeatFirst = meat >= cheese;
    var firstCount = moreMeatFirst ? meat : cheese;
    var secondCount = moreMeatFirst ? cheese : meat;
    final firstAsset = moreMeatFirst ? RpalAssets.meat : RpalAssets.cheese;
    final secondAsset = moreMeatFirst ? RpalAssets.cheese : RpalAssets.meat;

    var imageAdded = true;
    while (imageAdded) {
      imageAdded = false;
      if (firstCount > 0) {
        layers.add(firstAsset);
        firstCount--;
        imageAdded = true;
      }
      if (secondCount > 0) {
        layers.add(secondAsset);
        secondCount--;
        imageAdded = true;
      }
      if (bread > 1) {
        layers.add(RpalAssets.bread);
        bread--;
        imageAdded = true;
      }
    }

    if (bread > 0) {
      layers.add(RpalAssets.bread);
    }
    return layers;
  }

  @override
  Widget build(BuildContext context) {
    if (breadCount <= 0 && meatCount <= 0 && cheeseCount <= 0) {
      return const SizedBox(width: 5, height: 5);
    }

    final layers = buildLayerAssets();
    final width = ingredientDisplayWidth * sandwichScale;
    final layerH = 36.0 * sandwichScale;
    final height =
        layerH + (layers.length > 1 ? (layers.length - 1) * ySpacing * sandwichScale : 0);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < layers.length; i++)
            Positioned(
              bottom: i * ySpacing * sandwichScale,
              child: Image.asset(
                layers[i],
                width: width,
                filterQuality: FilterQuality.medium,
              ),
            ),
        ],
      ),
    );
  }
}

/// Maps [iconId] / recipe coefficients to a substance icon widget.
Widget substanceIconFor({
  required String? iconId,
  required int breadCoeff,
  required int meatCoeff,
  required int cheeseCoeff,
  double scale = SandwichIcon.sandwichScaleDefault,
}) {
  switch (iconId) {
    case 'bread':
      return SandwichIcon.breadIcon(scale: scale);
    case 'meat':
      return SandwichIcon.meatIcon(scale: scale);
    case 'cheese':
      return SandwichIcon.cheeseIcon(scale: scale);
    case 'sandwich:none':
      return const SizedBox(width: 5, height: 5);
    default:
      if (iconId != null && iconId.startsWith('sandwich:')) {
        final parts = iconId.substring('sandwich:'.length).split(',');
        if (parts.length == 3) {
          return SandwichIcon(
            breadCount: int.tryParse(parts[0]) ?? 0,
            meatCount: int.tryParse(parts[1]) ?? 0,
            cheeseCount: int.tryParse(parts[2]) ?? 0,
            sandwichScale: scale,
          );
        }
      }
      return SandwichIcon(
        breadCount: breadCoeff,
        meatCount: meatCoeff,
        cheeseCount: cheeseCoeff,
        sandwichScale: scale,
      );
  }
}
