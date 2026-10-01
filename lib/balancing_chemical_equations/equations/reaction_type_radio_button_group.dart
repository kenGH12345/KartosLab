import 'package:flutter/material.dart';

import '../model/view_mode.dart';

/// PhET `ReactionTypeRadioButtonGroup` — HorizontalAquaRadioButtonGroup.
class ReactionTypeRadioButtonGroup extends StatelessWidget {
  const ReactionTypeRadioButtonGroup({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ReactionType value;
  final ValueChanged<ReactionType> onChanged;

  static const _items = <(ReactionType, String, double)>[
    (ReactionType.synthesis, 'Synthesis', 70),
    (ReactionType.decomposition, 'Decomposition', 106),
    (ReactionType.combustion, 'Combustion', 86),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          _AquaRadio(
            selected: value == _items[i].$1,
            label: _items[i].$2,
            maxLabelWidth: _items[i].$3,
            onTap: () => onChanged(_items[i].$1),
          ),
        ],
      ],
    );
  }
}

class _AquaRadio extends StatelessWidget {
  const _AquaRadio({
    required this.selected,
    required this.label,
    required this.maxLabelWidth,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final double maxLabelWidth;
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
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxLabelWidth),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// sun AquaRadioButton — white disc, blue center when selected (radius 8).
class _AquaRadioPainter extends CustomPainter {
  _AquaRadioPainter({required this.selected});
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF333333),
    );
    if (selected) {
      canvas.drawCircle(
        c,
        r * 0.45,
        Paint()..color = const Color(0xFF2E6BB2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AquaRadioPainter oldDelegate) =>
      oldDelegate.selected != selected;
}
