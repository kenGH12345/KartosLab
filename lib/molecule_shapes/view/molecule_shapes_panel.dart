import 'package:flutter/material.dart';

import 'molecule_shapes_colors.dart';

/// PhET-like titled panel used by Bonding / Lone Pair / Options / Name.
class MoleculeShapesPanel extends StatelessWidget {
  const MoleculeShapesPanel({
    super.key,
    required this.title,
    required this.child,
    this.width = 280,
  });

  final String title;
  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: MoleculeShapesColors.panelFill,
          border: Border.all(color: MoleculeShapesColors.controlPanelBorder, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MoleculeShapesColors.controlPanelTitle,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class MoleculeShapesCheckbox extends StatelessWidget {
  const MoleculeShapesCheckbox({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.labelColor = MoleculeShapesColors.controlPanelText,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: MoleculeShapesColors.checkboxBackground,
              border: Border.all(color: MoleculeShapesColors.checkbox, width: 1.5),
              borderRadius: BorderRadius.circular(3),
            ),
            child: value ? const CustomPaint(painter: _CheckPainter()) : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: labelColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Red X matching `RemovePairGroupButton` (kite cross, not Material close).
class RemovePairGroupButton extends StatelessWidget {
  const RemovePairGroupButton({super.key, required this.onPressed, this.enabled = true});

  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: MoleculeShapesColors.removePairGroup,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(4),
          child: const SizedBox(
            width: 28,
            height: 28,
            child: CustomPaint(painter: _CrossPainter()),
          ),
        ),
      ),
    );
  }
}

class _CrossPainter extends CustomPainter {
  const _CrossPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 7.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(inset, inset), Offset(size.width - inset, size.height - inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(inset, size.height - inset), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MoleculeShapesColors.checkbox
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.55)
      ..lineTo(size.width * 0.4, size.height * 0.75)
      ..lineTo(size.width * 0.8, size.height * 0.3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
