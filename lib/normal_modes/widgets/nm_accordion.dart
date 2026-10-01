import 'package:flutter/material.dart';

import '../normal_modes_colors.dart';
import '../normal_modes_constants.dart';

/// Sun AccordionBox: hide content with [Visibility], do not dispose children.
class NmAccordion extends StatelessWidget {
  const NmAccordion({
    super.key,
    required this.title,
    required this.expanded,
    required this.onExpandedChanged,
    required this.child,
    this.showTitleWhenExpanded = true,
    this.titleAlign = Alignment.centerLeft,
    this.expandButtonSize = 22,
  });

  final String title;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;
  final Widget child;
  final bool showTitleWhenExpanded;
  final Alignment titleAlign;
  final double expandButtonSize;

  @override
  Widget build(BuildContext context) {
    final showTitle = !expanded || showTitleWhenExpanded;
    return Container(
      decoration: BoxDecoration(
        color: NormalModesColors.panelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: NormalModesColors.panelStroke),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bounded = constraints.maxHeight.isFinite &&
              constraints.maxHeight < double.infinity;
          final header = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _PlusMinus(
                  expanded: expanded,
                  size: expandButtonSize,
                  onTap: () => onExpandedChanged(!expanded),
                ),
                if (showTitle) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: titleAlign,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: NormalModesConstants.controlFontSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
          final body = Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: child,
          );
          return Column(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              if (bounded)
                Expanded(
                  child: Visibility(
                    visible: expanded,
                    maintainState: true,
                    maintainAnimation: true,
                    maintainSize: false,
                    child: SingleChildScrollView(child: body),
                  ),
                )
              else
                Visibility(
                  visible: expanded,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: false,
                  child: body,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PlusMinus extends StatelessWidget {
  const _PlusMinus({
    required this.expanded,
    required this.size,
    required this.onTap,
  });

  final bool expanded;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(size, size),
        painter: _PlusMinusPainter(expanded: expanded),
      ),
    );
  }
}

class _PlusMinusPainter extends CustomPainter {
  _PlusMinusPainter({required this.expanded});
  final bool expanded;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(3),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFF58BE6E));
    canvas.drawRRect(
      r,
      Paint()
        ..color = const Color(0xFF3E8C4F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(4, c.dy), Offset(size.width - 4, c.dy), p);
    if (!expanded) {
      canvas.drawLine(Offset(c.dx, 4), Offset(c.dx, size.height - 4), p);
    }
  }

  @override
  bool shouldRepaint(covariant _PlusMinusPainter oldDelegate) =>
      oldDelegate.expanded != expanded;
}
