import 'package:flutter/material.dart';

import '../constants/baa_constants.dart';

/// PhET sun AccordionBox styling used by Build an Atom panels.
///
/// ExpandCollapseButton chrome matches PhET: red (−) when expanded, green (+)
/// when collapsed.
class BaaAccordionBox extends StatelessWidget {
  const BaaAccordionBox({
    super.key,
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.minWidth = 220,
    this.maxHeight,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  final double minWidth;

  /// When set, scale down to fit a fixed vertical seat (image-3 blank slots).
  final double? maxHeight;

  static const _expandedButton = Color(0xFFE74C3C);
  static const _collapsedButton = Color(0xFF27AE60);

  @override
  Widget build(BuildContext context) {
    final bg = const Color(BAAConstants.displayPanelBackgroundValue);
    final panel = DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: expanded ? _expandedButton : _collapsedButton,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: Colors.black87),
                    ),
                    child: Text(
                      expanded ? '−' : '+',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: child,
            ),
        ],
      ),
    );

    final maxH = maxHeight;
    if (maxH == null) {
      return SizedBox(width: minWidth, child: panel);
    }

    // FittedBox needs a bounded child width (it passes infinite constraints).
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: minWidth, maxHeight: maxH),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: SizedBox(width: minWidth, child: panel),
      ),
    );
  }
}
