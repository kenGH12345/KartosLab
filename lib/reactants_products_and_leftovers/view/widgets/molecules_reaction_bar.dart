import 'package:flutter/material.dart';

import '../../model/reaction.dart';
import '../../rpal_colors.dart';
import '../molecules_controller.dart';
import 'molecules_equation_node.dart';

/// Top bar for Molecules — `ReactionBarNode` + `MoleculesEquationNode`.
class MoleculesReactionBar extends StatelessWidget {
  const MoleculesReactionBar({
    super.key,
    required this.controller,
    required this.layoutWidth,
  });

  final MoleculesController controller;
  final double layoutWidth;

  @override
  Widget build(BuildContext context) {
    final reaction = controller.selected;

    return Container(
      width: layoutWidth,
      color: RpalColors.statusBarFill,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: MoleculesEquationNode(reaction: reaction),
            ),
          ),
          _RadioGroup(
            reactions: controller.reactions,
            selected: reaction,
            onSelected: controller.selectReaction,
          ),
        ],
      ),
    );
  }
}

class _RadioGroup extends StatelessWidget {
  const _RadioGroup({
    required this.reactions,
    required this.selected,
    required this.onSelected,
  });

  final List<Reaction> reactions;
  final Reaction selected;
  final ValueChanged<Reaction> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < reactions.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _AquaRadio(
            label: reactions[i].name ?? '',
            selected: identical(reactions[i], selected),
            onTap: () => onSelected(reactions[i]),
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
