import 'package:flutter/material.dart';

import '../../model/sandwich_recipe.dart';
import '../../rpal_constants.dart';
import '../../rpal_strings.dart';
import '../sandwiches_controller.dart';
import 'rpal_number_spinner.dart';
import 'sandwich_icon.dart';

/// Equation bar content — `SandwichesEquationNode.ts`.
class SandwichesEquationNode extends StatelessWidget {
  const SandwichesEquationNode({
    super.key,
    required this.controller,
    required this.recipe,
  });

  final SandwichesController controller;
  final SandwichRecipe recipe;

  static const _coeffStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontFamily: 'Arial',
  );

  @override
  Widget build(BuildContext context) {
    final reactants = recipe.reactants;
    final children = <Widget>[];

    for (var i = 0; i < reactants.length; i++) {
      final reactant = reactants[i];
      if (recipe.coefficientsMutable) {
        children.add(
          RpalNumberSpinner(
            value: reactant.coefficient,
            min: RpalConstants.sandwichCoefficientMin,
            max: RpalConstants.sandwichCoefficientMax,
            onChanged: (v) => controller.setCoefficient(reactant, v),
            fontSize: 22,
          ),
        );
      } else {
        children.add(Text('${reactant.coefficient}', style: _coeffStyle));
      }
      children.add(const SizedBox(width: 8));
      children.add(
        substanceIconFor(
          iconId: reactant.iconId,
          breadCoeff: recipe.bread.coefficient,
          meatCoeff: recipe.meat.coefficient,
          cheeseCoeff: recipe.cheese.coefficient,
        ),
      );
      if (i < reactants.length - 1) {
        children.add(const SizedBox(width: 15));
        children.add(
          const Text('+', style: TextStyle(color: Colors.white, fontSize: 24)),
        );
        children.add(const SizedBox(width: 15));
      }
    }

    children.add(const SizedBox(width: 15));
    children.add(
      CustomPaint(
        size: const Size(36, 16),
        painter: const _WhiteArrowPainter(),
      ),
    );
    children.add(const SizedBox(width: 15));

    if (recipe.isReaction()) {
      children.add(
        SandwichIcon(
          breadCount: recipe.bread.coefficient,
          meatCount: recipe.meat.coefficient,
          cheeseCount: recipe.cheese.coefficient,
        ),
      );
    } else {
      children.add(
        const Text(
          RpalStrings.noReaction,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Arial',
            height: 1.15,
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class _WhiteArrowPainter extends CustomPainter {
  const _WhiteArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.15)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.85)
      ..lineTo(size.width * 0.55, size.height * 0.65)
      ..lineTo(0, size.height * 0.65)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
