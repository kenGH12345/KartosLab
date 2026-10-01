import 'package:flutter/material.dart';
import 'package:kratos/balancing_act/ba_colors.dart';

/// Column on/off ABSwitch with procedural icons (ColumnControlIcon).
class BaColumnSwitch extends StatelessWidget {
  const BaColumnSwitch({
    super.key,
    required this.supportsOn,
    required this.onChanged,
  });

  final bool supportsOn;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: BaColors.panelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black54),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Icon(showColumns: true, selected: supportsOn),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onChanged(!supportsOn),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 40,
              height: 20,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: supportsOn
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF9E9E9E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black54),
              ),
              alignment:
                  supportsOn ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _Icon(showColumns: false, selected: !supportsOn),
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({required this.showColumns, required this.selected});

  final bool showColumns;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(60, 60 / 1.6),
      painter: _ColumnIconPainter(showColumns: showColumns, selected: selected),
    );
  }
}

class _ColumnIconPainter extends CustomPainter {
  _ColumnIconPainter({required this.showColumns, required this.selected});

  final bool showColumns;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [BaColors.skyTop, BaColors.skyBottom],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(rrect, bg);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = selected ? Colors.blue : Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 1.5 : 0.5,
    );

    // Mini fulcrum
    final cx = size.width / 2;
    final fy = size.height * 0.85;
    final fw = size.width * 0.35;
    final fh = size.height * 0.5;
    final path = Path()
      ..moveTo(cx - fw / 2, fy)
      ..lineTo(cx - 2, fy - fh)
      ..lineTo(cx + 2, fy - fh)
      ..lineTo(cx + fw / 2, fy)
      ..close();
    canvas.drawPath(path, Paint()..color = BaColors.fulcrumFill);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Mini plank
    final py = fy - fh;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, py),
        width: size.width * 0.85,
        height: 3,
      ),
      Paint()..color = BaColors.plankFill,
    );

    if (showColumns) {
      final colW = size.width * 0.1;
      final colH = size.height * 0.35;
      for (final dx in [-size.width * 0.22, size.width * 0.22]) {
        canvas.drawRect(
          Rect.fromLTWH(cx + dx - colW / 2, py, colW, colH),
          Paint()..color = BaColors.column2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ColumnIconPainter oldDelegate) {
    return oldDelegate.showColumns != showColumns ||
        oldDelegate.selected != selected;
  }
}
