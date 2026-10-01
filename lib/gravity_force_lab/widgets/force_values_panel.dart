import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../a11y/gfl_a11y_strings.dart';
import '../gfl_colors.dart';
import '../gfl_strings.dart';
import '../model/force_values_display.dart';
import '../model/gravity_force_lab_model.dart';

/// PhET `GravityForceLabControlPanel` — Force Values radios + Constant Size.
class ForceValuesPanel extends StatelessWidget {
  const ForceValuesPanel({
    super.key,
    required this.model,
    this.focusOrderStart,
  });

  final GravityForceLabModel model;

  /// First radio focus order; subsequent radios +1, checkbox +3.
  final double? focusOrderStart;

  @override
  Widget build(BuildContext context) {
    final base = focusOrderStart ?? 40;
    return Semantics(
      container: true,
      label: GflA11yStrings.forceValues,
      hint: GflA11yStrings.forceValuesHelp,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: GflColors.panelFill,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Text(
                GflStrings.forceValues,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            _AquaRadio(
              label: GflStrings.decimalNotation,
              a11yLabel: GflA11yStrings.decimalNotation,
              selected: model.forceValuesDisplay == ForceValuesDisplay.decimal,
              onTap: () =>
                  model.setForceValuesDisplay(ForceValuesDisplay.decimal),
              focusOrder: base,
            ),
            _AquaRadio(
              label: GflStrings.scientificNotation,
              a11yLabel: GflA11yStrings.scientificNotation,
              selected:
                  model.forceValuesDisplay == ForceValuesDisplay.scientific,
              onTap: () =>
                  model.setForceValuesDisplay(ForceValuesDisplay.scientific),
              focusOrder: base + 1,
            ),
            _AquaRadio(
              label: GflStrings.hidden,
              a11yLabel: GflA11yStrings.hidden,
              selected: model.forceValuesDisplay == ForceValuesDisplay.hidden,
              onTap: () =>
                  model.setForceValuesDisplay(ForceValuesDisplay.hidden),
              focusOrder: base + 2,
              hint: model.forceValuesDisplay == ForceValuesDisplay.hidden
                  ? GflA11yStrings.forceValuesHidden
                  : null,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: GflColors.separator),
            ),
            _PhetCheckbox(
              label: GflStrings.constantSize,
              a11yLabel: GflA11yStrings.constantSize,
              value: model.constantRadius,
              onChanged: model.setConstantRadius,
              focusOrder: base + 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _AquaRadio extends StatelessWidget {
  const _AquaRadio({
    required this.label,
    required this.a11yLabel,
    required this.selected,
    required this.onTap,
    this.focusOrder,
    this.hint,
  });

  final String label;
  final String a11yLabel;
  final bool selected;
  final VoidCallback onTap;
  final double? focusOrder;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    Widget child = Focus(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        selected: selected,
        label: a11yLabel,
        hint: hint,
        button: true,
        onTap: onTap,
        child: Builder(
          builder: (context) {
            return InkWell(
              onTap: () {
                Focus.of(context).requestFocus();
                onTap();
              },
              child: ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      CustomPaint(
                        size: const Size(16, 16),
                        painter: _AquaRadioPainter(selected: selected),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child:
                            Text(label, style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    if (focusOrder != null) {
      child = FocusTraversalOrder(
        order: NumericFocusOrder(focusOrder!),
        child: child,
      );
    }
    return child;
  }
}

class _AquaRadioPainter extends CustomPainter {
  _AquaRadioPainter({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      7,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    if (selected) {
      canvas.drawCircle(c, 4.5, Paint()..color = const Color(0xFF0096FF));
    }
  }

  @override
  bool shouldRepaint(covariant _AquaRadioPainter oldDelegate) =>
      oldDelegate.selected != selected;
}

class _PhetCheckbox extends StatelessWidget {
  const _PhetCheckbox({
    required this.label,
    required this.a11yLabel,
    required this.value,
    required this.onChanged,
    this.focusOrder,
  });

  final String label;
  final String a11yLabel;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double? focusOrder;

  @override
  Widget build(BuildContext context) {
    void toggle() => onChanged(!value);
    Widget child = Focus(
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          toggle();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        checked: value,
        label: a11yLabel,
        hint: GflA11yStrings.constantSizeHelp,
        enabled: true,
        onTap: toggle,
        child: Builder(
          builder: (context) {
            return InkWell(
              onTap: () {
                Focus.of(context).requestFocus();
                toggle();
              },
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    CustomPaint(
                      size: const Size(16, 16),
                      painter: _CheckboxPainter(checked: value),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(label, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    if (focusOrder != null) {
      child = FocusTraversalOrder(
        order: NumericFocusOrder(focusOrder!),
        child: child,
      );
    }
    return child;
  }
}

class _CheckboxPainter extends CustomPainter {
  _CheckboxPainter({required this.checked});

  final bool checked;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      const Radius.circular(2),
    );
    canvas.drawRRect(r, Paint()..color = Colors.white);
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    if (checked) {
      final p = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(3, 8), const Offset(6.5, 12), p);
      canvas.drawLine(const Offset(6.5, 12), const Offset(13, 4), p);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckboxPainter oldDelegate) =>
      oldDelegate.checked != checked;
}
