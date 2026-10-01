import 'package:flutter/material.dart';

import '../../model/sandwich_recipe.dart';
import '../../rpal_colors.dart';
import '../../rpal_constants.dart';
import '../../rpal_strings.dart';
import '../sandwiches_controller.dart';
import 'quantities_node.dart';
import 'sandwich_icon.dart';
import 'stacks_accordion_box.dart';

/// Before/After scene for one sandwich recipe — `SandwichesSceneNode.ts`.
class SandwichesScene extends StatelessWidget {
  const SandwichesScene({
    super.key,
    required this.controller,
    required this.recipe,
  });

  final SandwichesController controller;
  final SandwichRecipe recipe;

  static const boxSize = Size(
    RpalConstants.sandwichesBoxWidth,
    RpalConstants.sandwichesBoxHeight,
  );

  Widget _stackIcon(String? iconId) {
    return substanceIconFor(
      iconId: iconId,
      breadCoeff: recipe.bread.coefficient,
      meatCoeff: recipe.meat.coefficient,
      cheeseCoeff: recipe.cheese.coefficient,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Max sandwich icon height for stack layout (coeff 3,3,3).
    const maxIconHeight = 80.0;

    final beforeStacks = [
      for (final reactant in recipe.reactants)
        StackNodeWidget(
          quantity: reactant.quantity,
          icon: _stackIcon(reactant.iconId),
          boxHeight: boxSize.height,
          maxIconHeight: maxIconHeight,
          boxYMargin: 8,
        ),
    ];

    final afterSubstances = [...recipe.products, ...recipe.leftovers];
    final afterStacks = [
      for (final substance in afterSubstances)
        StackNodeWidget(
          quantity: substance.quantity,
          icon: _stackIcon(substance.iconId),
          boxHeight: boxSize.height,
          maxIconHeight: maxIconHeight,
          boxYMargin: 8,
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StacksAccordionBox(
              title: RpalStrings.beforeSandwich,
              expanded: controller.beforeExpanded,
              onToggle: controller.toggleBeforeExpanded,
              stackChildren: beforeStacks,
              contentSize: boxSize,
            ),
            const SizedBox(width: 10),
            CustomPaint(
              size: const Size(40, 28),
              painter: const _BlueArrowPainter(),
            ),
            const SizedBox(width: 10),
            StacksAccordionBox(
              title: RpalStrings.afterSandwich,
              expanded: controller.afterExpanded,
              onToggle: controller.toggleAfterExpanded,
              stackChildren: afterStacks,
              contentSize: boxSize,
            ),
          ],
        ),
        const SizedBox(height: 6),
        QuantitiesNode(
          controller: controller,
          recipe: recipe,
          boxWidth: boxSize.width,
        ),
      ],
    );
  }
}

class _BlueArrowPainter extends CustomPainter {
  const _BlueArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = RpalColors.statusBarFill;
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.12)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.88)
      ..lineTo(size.width * 0.55, size.height * 0.65)
      ..lineTo(0, size.height * 0.65)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
