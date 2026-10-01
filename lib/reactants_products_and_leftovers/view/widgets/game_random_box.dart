import 'dart:math';

import 'package:flutter/material.dart';

import '../../model/substance.dart';
import '../../rpal_colors.dart';
import '../../rpal_constants.dart';
import 'substance_icon.dart';

/// Molecules at random positions — `RandomBox.ts` (approximate layout).
class RandomBox extends StatelessWidget {
  const RandomBox({
    super.key,
    required this.substances,
    this.width = RpalConstants.gameBoxWidth,
    this.height = RpalConstants.gameBoxHeight,
    this.visible = true,
    this.seed = 0,
  });

  final List<Substance> substances;
  final double width;
  final double height;
  final bool visible;
  final int seed;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return SizedBox(width: width, height: height);
    }
    final icons = <Widget>[];
    final rng = Random(seed);
    // Keep molecule/chip fully inside the box (FormulaText chips ~48–56 wide).
    const inset = 28.0;
    final usableW = max(1.0, width - inset * 2);
    final usableH = max(1.0, height - inset * 2);
    var index = 0;
    for (final s in substances) {
      for (var q = 0; q < s.quantity; q++) {
        final left = inset + rng.nextDouble() * usableW - 20;
        final top = inset + rng.nextDouble() * usableH - 12;
        icons.add(
          Positioned(
            left: left.clamp(8.0, width - 56),
            top: top.clamp(8.0, height - 40),
            child: SubstanceIcon(substance: s, scale: 0.85),
          ),
        );
        index++;
        if (index > RpalConstants.quantityMax * substances.length) {
          break;
        }
      }
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: RpalColors.boxFill,
        border: Border.all(color: RpalColors.boxStroke, width: 2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(clipBehavior: Clip.hardEdge, children: icons),
      ),
    );
  }
}
