import 'package:flutter/material.dart';

import '../../model/sandwich_recipe.dart';
import '../../rpal_colors.dart';
import '../sandwiches_controller.dart';
import 'sandwiches_equation_node.dart';

/// Top bar with equation + recipe radios — `ReactionBarNode.ts`.
class ReactionBar extends StatelessWidget {
  const ReactionBar({
    super.key,
    required this.controller,
    required this.layoutWidth,
  });

  final SandwichesController controller;
  final double layoutWidth;

  @override
  Widget build(BuildContext context) {
    final recipe = controller.selected;

    return Container(
      width: layoutWidth,
      color: RpalColors.statusBarFill,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: SandwichesEquationNode(
                controller: controller,
                recipe: recipe,
              ),
            ),
          ),
          _ReactionRadioGroup(
            recipes: controller.recipes,
            selected: recipe,
            onSelected: controller.selectRecipe,
          ),
        ],
      ),
    );
  }
}

class _ReactionRadioGroup extends StatelessWidget {
  const _ReactionRadioGroup({
    required this.recipes,
    required this.selected,
    required this.onSelected,
  });

  final List<SandwichRecipe> recipes;
  final SandwichRecipe selected;
  final ValueChanged<SandwichRecipe> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < recipes.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _AquaRadio(
            label: recipes[i].name ?? '',
            selected: identical(recipes[i], selected),
            onTap: () => onSelected(recipes[i]),
          ),
        ],
      ],
    );
  }
}

class _AquaRadio extends StatelessWidget {
  const _AquaRadio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(16, 16),
            painter: _AquaRadioPainter(selected: selected),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Arial',
            ),
          ),
        ],
      ),
    );
  }
}

class _AquaRadioPainter extends CustomPainter {
  _AquaRadioPainter({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(c, r - 0.5, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      r - 0.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black,
    );
    if (selected) {
      canvas.drawCircle(c, r * 0.55, Paint()..color = const Color(0xFF159BD6));
    }
  }

  @override
  bool shouldRepaint(covariant _AquaRadioPainter oldDelegate) =>
      oldDelegate.selected != selected;
}
