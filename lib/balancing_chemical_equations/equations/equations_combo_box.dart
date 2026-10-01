import 'package:flutter/material.dart';

import '../model/equation.dart';
import '../views/bce_formula_text.dart';

/// PhET `EquationsComboBox` — sun ComboBox, `listPosition: 'above'`.
class EquationsComboBox extends StatefulWidget {
  const EquationsComboBox({
    super.key,
    required this.equations,
    required this.selected,
    required this.onSelected,
  });

  final List<Equation> equations;
  final Equation selected;
  final ValueChanged<Equation> onSelected;

  @override
  State<EquationsComboBox> createState() => _EquationsComboBoxState();
}

class _EquationsComboBoxState extends State<EquationsComboBox> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _entry;
  bool _open = false;

  @override
  void didUpdateWidget(covariant EquationsComboBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.selected, widget.selected) ||
        oldWidget.equations != widget.equations) {
      _close();
    }
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    if (_open) {
      _open = false;
      if (mounted) setState(() {});
    }
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
    final buttonSize = box.size;
    // Measure list height roughly; list opens ABOVE the button (source).
    const itemH = 32.0;
    final listH = widget.equations.length * itemH + 8;
    final width = buttonSize.width.clamp(180.0, 600.0);

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
            top: origin.dy - listH - 2,
            width: width,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final eq in widget.equations)
                      InkWell(
                        onTap: () {
                          widget.onSelected(eq);
                          _close();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          color: identical(eq, widget.selected)
                              ? const Color(0xFFDDEEFF)
                              : Colors.transparent,
                          child: BceFormulaText(
                            html: eq.getDisplayString(),
                            fontSize: 16,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                  ],
                ),
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
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black87),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: BceFormulaText(
                html: widget.selected.getDisplayString(),
                fontSize: 16,
                textAlign: TextAlign.left,
              ),
            ),
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

class _CaretPainter extends CustomPainter {
  _CaretPainter({required this.up});
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
  bool shouldRepaint(covariant _CaretPainter oldDelegate) =>
      oldDelegate.up != up;
}
