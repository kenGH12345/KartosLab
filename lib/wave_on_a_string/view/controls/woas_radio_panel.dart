import 'package:flutter/material.dart';

/// Light-green radio panel (`WOASRadioButtonGroup` in Panel).
class WoasRadioPanel<T> extends StatelessWidget {
  const WoasRadioPanel({
    super.key,
    required this.values,
    required this.labels,
    required this.groupValue,
    required this.onChanged,
    this.semanticLabel,
  });

  final List<T> values;
  final List<String> labels;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    assert(values.length == labels.length);
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFD9FCC5),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.black54, width: 2 / 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < values.length; i++)
              _RadioRow<T>(
                key: ValueKey('radio_${labels[i]}'),
                value: values[i],
                label: labels[i],
                groupValue: groupValue,
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}

class _RadioRow<T> extends StatelessWidget {
  const _RadioRow({
    super.key,
    required this.value,
    required this.label,
    required this.groupValue,
    required this.onChanged,
  });

  final T value;
  final String label;
  final T groupValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(16, 16),
              painter: _RadioPainter(selected: selected),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _RadioPainter extends CustomPainter {
  _RadioPainter({required this.selected});
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      7,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    if (selected) {
      canvas.drawCircle(c, 4, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(covariant _RadioPainter oldDelegate) =>
      oldDelegate.selected != selected;
}
