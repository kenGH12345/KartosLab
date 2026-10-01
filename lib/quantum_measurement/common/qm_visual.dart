/// Shared PhET visual primitives for Quantum Measurement screens.
library;

import 'package:flutter/material.dart';

import 'package:kratos/quantum_coin_toss/common/quantum_measurement_colors.dart';

import 'qm_typography.dart';

/// QuantumMeasurementConstants.PANEL_OPTIONS
const qmPanelFill = Color(0xFFF0F0F0);
const qmPanelStroke = Color(0x00000000); // transparent in source default
const qmPanelMargin = 10.0;

/// Must stay false on production / Golden paths.
const qmVisualDebugEnabled = false;

class QmPanel extends StatelessWidget {
  const QmPanel({
    super.key,
    required this.child,
    this.minWidth,
    this.padding = const EdgeInsets.all(qmPanelMargin),
  });

  final Widget child;
  final double? minWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth ?? 0),
      padding: padding,
      decoration: BoxDecoration(
        color: qmPanelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFCCCCCC), width: 0.5),
      ),
      child: child,
    );
  }
}

/// ExperimentDividingLine: Line 0→525, stroke black, width 2, dash [6,5].
class QmExperimentDividingLine extends StatelessWidget {
  const QmExperimentDividingLine({super.key, required this.height});

  final double height;

  static const dash = 6.0;
  static const gap = 5.0;
  static const strokeWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(strokeWidth, height),
      painter: const _QmDashedDividerPainter(),
    );
  }
}

class _QmDashedDividerPainter extends CustomPainter {
  const _QmDashedDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = QuantumMeasurementColors.dividerLineStroke
      ..strokeWidth = QmExperimentDividingLine.strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;
    var y = 0.0;
    while (y < size.height) {
      final end = (y + QmExperimentDividingLine.dash).clamp(0.0, size.height);
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, end), paint);
      y += QmExperimentDividingLine.dash + QmExperimentDividingLine.gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Approximate sun TextPushButton (rectangular, rounded, fill from source).
class QmPhetTextButton extends StatelessWidget {
  const QmPhetTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.baseColor,
    this.width,
    this.height = 36,
    this.xMargin = 20,
    this.yMargin = 6,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final Color? baseColor;
  final double? width;
  final double height;
  final double xMargin;
  final double yMargin;

  @override
  Widget build(BuildContext context) {
    final fill = !enabled
        ? const Color(0xFFCCCCCC)
        : (baseColor ?? QuantumMeasurementColors.experimentButton);
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(6),
        elevation: enabled ? 2 : 0,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: xMargin, vertical: yMargin),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: QmTypography.title.copyWith(
                  color: enabled ? Colors.black : Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Aqua-style radio (16×16, PhET cyan ring).
class QmAquaRadio extends StatelessWidget {
  const QmAquaRadio({
    super.key,
    required this.selected,
    required this.label,
    required this.onTap,
    this.labelStyle = QmTypography.control,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;
  final TextStyle labelStyle;

  static const ring = Color(0xFF0094BD);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 2),
            ),
            alignment: Alignment.center,
            child: selected
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: ring,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(label, style: labelStyle),
        ],
      ),
    );
  }
}

class QmCheckbox extends StatelessWidget {
  const QmCheckbox({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  /// QuantumMeasurementConstants.CHECKBOX_BOX_WIDTH
  static const boxWidth = 16.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: boxWidth,
            height: boxWidth,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              color: Colors.white,
            ),
            child: value
                ? CustomPaint(
                    size: const Size(boxWidth, boxWidth),
                    painter: const _CheckPainter(),
                  )
                : null,
          ),
          const SizedBox(width: 5),
          Text(label, style: QmTypography.control),
        ],
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.55)
      ..lineTo(size.width * 0.4, size.height * 0.75)
      ..lineTo(size.width * 0.8, size.height * 0.28);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

SliderThemeData qmSliderTheme(BuildContext context) {
  return SliderTheme.of(context).copyWith(
    trackHeight: 1,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
    activeTrackColor: Colors.black,
    inactiveTrackColor: Colors.black,
    thumbColor: const Color(0xFF0094BD),
  );
}

class QmTimeControlButton extends StatelessWidget {
  const QmTimeControlButton({
    super.key,
    required this.kind,
    required this.onPressed,
  });

  final QmTimeControlKind kind;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8E8E8),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 36,
          height: 32,
          child: CustomPaint(painter: _TimeIconPainter(kind)),
        ),
      ),
    );
  }
}

enum QmTimeControlKind { play, pause, step }

class _TimeIconPainter extends CustomPainter {
  const _TimeIconPainter(this.kind);
  final QmTimeControlKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final c = Offset(size.width / 2, size.height / 2);
    switch (kind) {
      case QmTimeControlKind.play:
        final p = Path()
          ..moveTo(c.dx - 6, c.dy - 8)
          ..lineTo(c.dx - 6, c.dy + 8)
          ..lineTo(c.dx + 8, c.dy)
          ..close();
        canvas.drawPath(p, paint);
      case QmTimeControlKind.pause:
        canvas.drawRect(Rect.fromCenter(center: Offset(c.dx - 4, c.dy), width: 4, height: 14), paint);
        canvas.drawRect(Rect.fromCenter(center: Offset(c.dx + 4, c.dy), width: 4, height: 14), paint);
      case QmTimeControlKind.step:
        final p = Path()
          ..moveTo(c.dx - 8, c.dy - 7)
          ..lineTo(c.dx - 8, c.dy + 7)
          ..lineTo(c.dx + 2, c.dy)
          ..close();
        canvas.drawPath(p, paint);
        canvas.drawRect(Rect.fromLTWH(c.dx + 4, c.dy - 7, 3, 14), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimeIconPainter oldDelegate) => oldDelegate.kind != kind;
}

/// DEBUG-only overlay; never enabled on Golden / production (`qmVisualDebugEnabled`).
class QmVisualDebugOverlay extends StatelessWidget {
  const QmVisualDebugOverlay({super.key, required this.bounds});

  final Iterable<Rect> bounds;

  @override
  Widget build(BuildContext context) {
    if (!qmVisualDebugEnabled) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        painter: _DebugBoundsPainter(bounds.toList()),
        size: Size.infinite,
      ),
    );
  }
}

class _DebugBoundsPainter extends CustomPainter {
  const _DebugBoundsPainter(this.bounds);
  final List<Rect> bounds;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x88FF00FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final r in bounds) {
      canvas.drawRect(r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _DebugBoundsPainter oldDelegate) => true;
}
