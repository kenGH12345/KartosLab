import 'package:flutter/material.dart';

import '../../model/reaction.dart';
import '../../model/substance.dart';
import '../../rpal_colors.dart';
import '../../rpal_constants.dart';
import '../../rpal_strings.dart';
import '../molecules_controller.dart';
import 'molecule_icon.dart';
import 'molecules_quantities_node.dart';
import 'stacks_accordion_box.dart';

/// Before/After scene for one reaction — `MoleculesSceneNode.ts`.
class MoleculesScene extends StatelessWidget {
  const MoleculesScene({
    super.key,
    required this.controller,
    required this.reaction,
  });

  final MoleculesController controller;
  final Reaction reaction;

  static const boxSize = Size(
    RpalConstants.moleculesBoxWidth,
    RpalConstants.moleculesBoxHeight,
  );

  Widget _icon(Substance s) {
    final id = RpalMoleculeIdX.fromIconId(s.iconId);
    if (id == null) {
      return const SizedBox(width: 30, height: 25);
    }
    return MoleculeIcon(id: id);
  }

  @override
  Widget build(BuildContext context) {
    // minIconSize 30×25; use a bit more for stack spacing with shaded spheres.
    const maxIconHeight = 36.0;

    final beforeStacks = [
      for (final reactant in reaction.reactants)
        StackNodeWidget(
          quantity: reactant.quantity,
          icon: _icon(reactant),
          boxHeight: boxSize.height,
          maxIconHeight: maxIconHeight,
          boxYMargin: 6,
        ),
    ];

    final afterStacks = [
      for (final substance in [...reaction.products, ...reaction.leftovers])
        StackNodeWidget(
          quantity: substance.quantity,
          icon: _icon(substance),
          boxHeight: boxSize.height,
          maxIconHeight: maxIconHeight,
          boxYMargin: 6,
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StacksAccordionBox(
              title: RpalStrings.beforeReaction,
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
              title: RpalStrings.afterReaction,
              expanded: controller.afterExpanded,
              onToggle: controller.toggleAfterExpanded,
              stackChildren: afterStacks,
              contentSize: boxSize,
            ),
          ],
        ),
        const SizedBox(height: 6),
        MoleculesQuantitiesNode(
          controller: controller,
          reaction: reaction,
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
    final path = Path()
      ..moveTo(0, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.35)
      ..lineTo(size.width * 0.55, size.height * 0.12)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.88)
      ..lineTo(size.width * 0.55, size.height * 0.65)
      ..lineTo(0, size.height * 0.65)
      ..close();
    canvas.drawPath(path, Paint()..color = RpalColors.statusBarFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
