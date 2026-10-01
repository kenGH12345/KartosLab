import 'package:flutter/material.dart';

import '../../model/sandwich_recipe.dart';
import '../../model/substance.dart';
import '../../rpal_colors.dart';
import '../../rpal_constants.dart';
import '../../rpal_strings.dart';
import '../sandwiches_controller.dart';
import 'rpal_number_spinner.dart';
import 'sandwich_icon.dart';

/// Quantities below Before/After boxes — `QuantitiesNode.ts` (Sandwiches mode).
class QuantitiesNode extends StatelessWidget {
  const QuantitiesNode({
    super.key,
    required this.controller,
    required this.recipe,
    required this.boxWidth,
  });

  final SandwichesController controller;
  final SandwichRecipe recipe;
  final double boxWidth;

  static List<double> createXOffsets(int numberOfSubstances, double boxWidth) {
    assert(numberOfSubstances > 0);
    final xMargin = numberOfSubstances > 2 ? 0.0 : 0.15 * boxWidth;
    final deltaX = (boxWidth - (2 * xMargin)) / numberOfSubstances;
    final offsets = <double>[];
    var xOffset = xMargin + (deltaX / 2);
    for (var i = 0; i < numberOfSubstances; i++) {
      offsets.add(xOffset);
      xOffset += deltaX;
    }
    return offsets;
  }

  Widget _iconFor(Substance substance) {
    return substanceIconFor(
      iconId: substance.iconId,
      breadCoeff: recipe.bread.coefficient,
      meatCoeff: recipe.meat.coefficient,
      cheeseCoeff: recipe.cheese.coefficient,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reactants = recipe.reactants;
    final products = recipe.products;
    final leftovers = recipe.leftovers;
    final beforeOffsets = createXOffsets(reactants.length, boxWidth);
    final afterOffsets =
        createXOffsets(products.length + leftovers.length, boxWidth);

    // Layout: two panels side by side matching Before/After boxes + arrow gap.
    // Approximate arrow width ~40 + spacing 10*2 from HBox.
    const arrowGap = 60.0;
    final afterBoxX = boxWidth + arrowGap;

    return SizedBox(
      width: afterBoxX + boxWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                for (var i = 0; i < reactants.length; i++)
                  Positioned(
                    left: beforeOffsets[i] - 40,
                    width: 80,
                    child: _ReactantColumn(
                      substance: reactants[i],
                      icon: _iconFor(reactants[i]),
                      onChanged: (v) =>
                          controller.setReactantQuantity(reactants[i], v),
                    ),
                  ),
                for (var i = 0; i < products.length; i++)
                  Positioned(
                    left: afterBoxX + afterOffsets[i] - 40,
                    width: 80,
                    child: _StaticColumn(
                      quantity: products[i].quantity,
                      icon: _iconFor(products[i]),
                    ),
                  ),
                for (var i = 0; i < leftovers.length; i++)
                  Positioned(
                    left: afterBoxX +
                        afterOffsets[i + products.length] -
                        40,
                    width: 80,
                    child: _StaticColumn(
                      quantity: leftovers[i].quantity,
                      icon: _iconFor(leftovers[i]),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 28,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  width: boxWidth,
                  child: _BracketLabel(
                    label: RpalStrings.reactants,
                    width: boxWidth * 0.7,
                  ),
                ),
                Positioned(
                  left: afterBoxX,
                  width: boxWidth *
                      products.length /
                      (products.length + leftovers.length),
                  child: _BracketLabel(
                    label: RpalStrings.products,
                    width: 80,
                  ),
                ),
                Positioned(
                  left: afterBoxX +
                      boxWidth *
                          products.length /
                          (products.length + leftovers.length),
                  width: boxWidth *
                      leftovers.length /
                      (products.length + leftovers.length),
                  child: _BracketLabel(
                    label: RpalStrings.leftovers,
                    width: boxWidth * 0.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReactantColumn extends StatelessWidget {
  const _ReactantColumn({
    required this.substance,
    required this.icon,
    required this.onChanged,
  });

  final Substance substance;
  final Widget icon;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RpalNumberSpinner(
          value: substance.quantity,
          min: RpalConstants.quantityMin,
          max: RpalConstants.quantityMax,
          onChanged: onChanged,
        ),
        const SizedBox(height: 4),
        icon,
      ],
    );
  }
}

class _StaticColumn extends StatelessWidget {
  const _StaticColumn({required this.quantity, required this.icon});

  final int quantity;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$quantity',
          style: const TextStyle(
            fontSize: 28,
            fontFamily: 'Arial',
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        icon,
      ],
    );
  }
}

class _BracketLabel extends StatelessWidget {
  const _BracketLabel({required this.label, required this.width});

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(width.clamp(40, 200), 10),
          painter: const _BracketPainter(),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Arial',
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _BracketPainter extends CustomPainter {
  const _BracketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RpalColors.bracketStroke
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, 8)
      ..lineTo(0, 2)
      ..lineTo(size.width, 2)
      ..lineTo(size.width, 8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
