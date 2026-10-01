import 'package:flutter/material.dart';

import '../../rpal_colors.dart';
import '../../rpal_constants.dart';
import 'sandwich_icon.dart';

/// Vertical stack of substance icons — `StackNode.ts`.
///
/// Eagerly reserves [RpalConstants.quantityMax] slots; visibility follows
/// [quantity]. No animation (source toggles visibility immediately).
class StackNodeWidget extends StatelessWidget {
  const StackNodeWidget({
    super.key,
    required this.quantity,
    required this.icon,
    required this.boxHeight,
    required this.maxIconHeight,
    this.boxYMargin = 8,
  });

  final int quantity;
  final Widget icon;
  final double boxHeight;
  final double maxIconHeight;
  final double boxYMargin;

  @override
  Widget build(BuildContext context) {
    final maxQ = RpalConstants.quantityMax;
    final deltaY = maxQ <= 1
        ? 0.0
        : (boxHeight - (2 * boxYMargin) - maxIconHeight) / (maxQ - 1);
    final startCenterY = boxHeight - boxYMargin - (maxIconHeight / 2);
    final q = quantity.clamp(0, maxQ);

    return SizedBox(
      height: boxHeight,
      width: SandwichIcon.ingredientDisplayWidth *
          SandwichIcon.sandwichScaleDefault,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          for (var i = 0; i < maxQ; i++)
            Positioned(
              left: 0,
              right: 0,
              top: startCenterY - (i * deltaY) - maxIconHeight / 2,
              height: maxIconHeight,
              child: Opacity(
                opacity: i < q ? 1 : 0,
                child: Center(child: icon),
              ),
            ),
        ],
      ),
    );
  }
}

/// Accordion box with substance stacks — `StacksAccordionBox.ts`.
class StacksAccordionBox extends StatelessWidget {
  const StacksAccordionBox({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.stackChildren,
    this.contentSize = const Size(
      RpalConstants.sandwichesBoxWidth,
      RpalConstants.sandwichesBoxHeight,
    ),
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> stackChildren;
  final Size contentSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: contentSize.width,
      decoration: BoxDecoration(
        color: RpalColors.boxFill,
        border: Border.all(color: RpalColors.boxStroke),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TitleBar(title: title, expanded: expanded, onToggle: onToggle),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? SizedBox(
                    width: contentSize.width,
                    height: contentSize.height,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: stackChildren
                          .map((c) => Expanded(child: Center(child: c)))
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({
    required this.title,
    required this.expanded,
    required this.onToggle,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: const BoxDecoration(
        color: RpalColors.statusBarFill,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Arial',
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            left: 4,
            top: 4,
            child: GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFF79722),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: Colors.black26),
                ),
                alignment: Alignment.center,
                child: Text(
                  expanded ? '−' : '+',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
