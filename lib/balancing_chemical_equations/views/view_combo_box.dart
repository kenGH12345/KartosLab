import 'package:flutter/material.dart';

import '../model/view_mode.dart';

/// PhET `ViewComboBox` — sun ComboBox chrome (not Material DropdownButton).
class ViewComboBox extends StatefulWidget {
  const ViewComboBox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ViewMode value;
  final ValueChanged<ViewMode> onChanged;

  @override
  State<ViewComboBox> createState() => _ViewComboBoxState();
}

class _ViewComboBoxState extends State<ViewComboBox> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _entry;
  bool _open = false;

  @override
  void didUpdateWidget(covariant ViewComboBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _close();
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (_open && mounted) setState(() => _open = false);
    _open = false;
  }

  void _toggle() {
    if (_entry != null) {
      _close();
      return;
    }
    final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.maybeOf(context);
    if (box == null || overlay == null) return;
    final origin = box.localToGlobal(Offset.zero);
    final w = box.size.width.clamp(80.0, 200.0);

    _entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          Positioned(
            left: origin.dx,
            top: origin.dy + box.size.height + 2,
            width: w,
            child: Material(
              elevation: 6,
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final mode in ViewMode.values)
                    InkWell(
                      onTap: () {
                        widget.onChanged(mode);
                        _close();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        color: mode == widget.value
                            ? const Color(0xFFDDEEFF)
                            : Colors.transparent,
                        child: _ViewModeItem(mode: mode),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
    setState(() => _open = true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _buttonKey,
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black54),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ViewModeItem(mode: widget.value),
            const SizedBox(width: 8),
            CustomPaint(
              size: const Size(12, 8),
              painter: _CaretPainter(up: _open),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModeItem extends StatelessWidget {
  const _ViewModeItem({required this.mode});
  final ViewMode mode;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case ViewMode.particles:
        return const SizedBox(
          width: 40,
          height: 24,
          child: CustomPaint(painter: _ParticlesIconPainter()),
        );
      case ViewMode.balanceScales:
        return const SizedBox(
          width: 48,
          height: 28,
          child: CustomPaint(painter: _ScalesIconPainter()),
        );
      case ViewMode.barCharts:
        return const SizedBox(
          width: 40,
          height: 24,
          child: CustomPaint(painter: _BarsIconPainter()),
        );
      case ViewMode.none:
        return const Text(
          'None',
          style: TextStyle(fontFamily: 'Arial', fontSize: 18),
        );
    }
  }
}

class _ParticlesIconPainter extends CustomPainter {
  const _ParticlesIconPainter();
  @override
  void paint(Canvas canvas, Size size) {
    void sphere(Offset c, double d, int gray) {
      canvas.drawCircle(
        c,
        d / 2,
        Paint()..color = Color.fromARGB(255, gray, gray, gray),
      );
      canvas.drawCircle(
        c,
        d / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = Colors.black,
      );
    }

    sphere(Offset(size.width * 0.5, size.height * 0.45), 16, 100);
    sphere(Offset(size.width * 0.28, size.height * 0.7), 10, 180);
    sphere(Offset(size.width * 0.72, size.height * 0.7), 10, 180);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScalesIconPainter extends CustomPainter {
  const _ScalesIconPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFB4B4B4);
    canvas.drawCircle(Offset(8, 6), 5, paint);
    canvas.drawCircle(Offset(16, 6), 5, paint);
    canvas.drawCircle(Offset(size.width - 16, 6), 5, paint);
    canvas.drawCircle(Offset(size.width - 8, 6), 5, paint);
    canvas.drawRect(
      Rect.fromLTWH(4, 12, size.width - 8, 3),
      Paint()..color = Colors.black,
    );
    final fulcrum = Path()
      ..moveTo(size.width / 2, 15)
      ..lineTo(size.width / 2 - 10, size.height)
      ..lineTo(size.width / 2 + 10, size.height)
      ..close();
    canvas.drawPath(fulcrum, Paint()..color = const Color(0xFF888888));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarsIconPainter extends CustomPainter {
  const _BarsIconPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final heights = [10.0, 15.0, 20.0];
    final grays = [109, 217, 163];
    for (var i = 0; i < 3; i++) {
      final h = heights[i];
      final rect = Rect.fromLTWH(i * 14.0, size.height - h, 10, h);
      canvas.drawRect(
        rect,
        Paint()..color = Color.fromARGB(255, grays[i], grays[i], grays[i]),
      );
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5
          ..color = Colors.black,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CaretPainter extends CustomPainter {
  const _CaretPainter({required this.up});
  final bool up;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (up) {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width / 2, 0)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _CaretPainter oldDelegate) => oldDelegate.up != up;
}
