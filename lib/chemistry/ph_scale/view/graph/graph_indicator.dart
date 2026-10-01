import 'package:flutter/material.dart';

import '../../model/ph_scale_colors.dart';
import '../ph_scale_fonts.dart';
import '../scientific_notation.dart';
import '../widgets/molecule_icon.dart';

enum GraphIndicatorSide { left, right }

enum GraphIndicatorSpecies { h3o, oh, h2o }

/// Callout pointing at a vertical scale — PhET `GraphIndicatorNode`.
///
/// Source: background 160×80, node scale 0.75, formula/value PhetFont(28).
/// Flutter bumps formula + molecule slightly for readability (user request).
class GraphIndicator extends StatelessWidget {
  const GraphIndicator({
    super.key,
    required this.species,
    required this.value,
    required this.side,
    required this.anchorY,
    this.interactive = false,
    this.onVerticalDrag,
  });

  final GraphIndicatorSpecies species;
  final double? value;
  final GraphIndicatorSide side;
  final double anchorY;
  final bool interactive;
  final GestureDragUpdateCallback? onVerticalDrag;

  /// PhET: 160×80 @ 0.75. Slightly taller so large formula + molecule fit.
  static const double scale = 0.85;
  static const double bgW = 168 * scale;
  static const double bgH = 96 * scale;

  /// Drag-arrow column width when [interactive].
  static const double dragArrowW = 18;

  static double layoutWidth({required bool interactive}) =>
      bgW + (interactive ? dragArrowW : 0);

  @override
  Widget build(BuildContext context) {
    final bg = switch (species) {
      GraphIndicatorSpecies.h3o => PhScaleColors.acidic,
      GraphIndicatorSpecies.oh => PhScaleColors.basic,
      GraphIndicatorSpecies.h2o => PhScaleColors.h2oBackground,
    };
    final formula = switch (species) {
      GraphIndicatorSpecies.h3o => 'H₃O⁺',
      GraphIndicatorSpecies.oh => 'OH⁻',
      GraphIndicatorSpecies.h2o => 'H₂O',
    };
    final icon = switch (species) {
      GraphIndicatorSpecies.h3o => MoleculeKind.h3o,
      GraphIndicatorSpecies.oh => MoleculeKind.oh,
      GraphIndicatorSpecies.h2o => MoleculeKind.h2o,
    };

    final display = value == null
        ? '—'
        : species == GraphIndicatorSpecies.h2o
            ? ScientificNotation.from(
                value!,
                mantissaDecimalPlaces: 0,
                fixedExponent: 0,
              ).mantissa
            : ScientificNotation.from(
                value!,
                mantissaDecimalPlaces: 1,
              ).display;

    final pointerOnRight = side == GraphIndicatorSide.left;

    // Source PhetFont(28)×0.75≈21; formula/molecule emphasized per UX request.
    final valueStyle = PhScaleFonts.style(
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
    final formulaStyle = PhScaleFonts.style(
      fontSize: 22,
      fontWeight: FontWeight.w700,
    );

    Widget callout = SizedBox(
      width: bgW,
      height: bgH,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(bgW, bgH),
            painter: _CalloutPainter(
              fill: bg,
              pointerOnRight: pointerOnRight,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: pointerOnRight ? 10 : 18,
              right: pointerOnRight ? 18 : 10,
              top: 5,
              bottom: 4,
            ),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade500, width: 1),
                    ),
                    child: Text(display, style: valueStyle),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(formula, style: formulaStyle),
                      const SizedBox(width: 8),
                      MoleculeIcon(kind: icon, scale: 0.62),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Widget body = SizedBox(
      width: layoutWidth(interactive: interactive),
      height: bgH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (interactive)
            Positioned(
              left: pointerOnRight ? null : 0,
              right: pointerOnRight ? 0 : null,
              top: 0,
              bottom: 0,
              child: const CustomPaint(
                size: Size(14, 40),
                painter: _DragArrowPainter(),
              ),
            ),
          Positioned(
            left: pointerOnRight ? 0 : (interactive ? dragArrowW : 0),
            child: callout,
          ),
        ],
      ),
    );

    if (interactive && onVerticalDrag != null) {
      body = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: onVerticalDrag,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: body,
        ),
      );
    }

    return body;
  }
}

class _CalloutPainter extends CustomPainter {
  _CalloutPainter({required this.fill, required this.pointerOnRight});

  final Color fill;
  final bool pointerOnRight;

  @override
  void paint(Canvas canvas, Size size) {
    const ptrW = 0.15;
    final pw = size.width * ptrW;
    final bodyLeft = pointerOnRight ? 0.0 : pw * 0.35;
    final bodyW = size.width - pw * 0.35;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bodyLeft, 0, bodyW, size.height),
        const Radius.circular(8),
      ),
      Paint()..color = fill,
    );

    final tip = Path();
    if (pointerOnRight) {
      tip
        ..moveTo(size.width - 14, size.height / 2 - 12)
        ..lineTo(size.width, size.height / 2)
        ..lineTo(size.width - 14, size.height / 2 + 12)
        ..close();
    } else {
      tip
        ..moveTo(14, size.height / 2 - 12)
        ..lineTo(0, size.height / 2)
        ..lineTo(14, size.height / 2 + 12)
        ..close();
    }
    canvas.drawPath(tip, Paint()..color = fill);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          pointerOnRight ? 0 : 10,
          0,
          size.width - 10,
          size.height,
        ),
        const Radius.circular(8),
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _CalloutPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.pointerOnRight != pointerOnRight;
}

class _DragArrowPainter extends CustomPainter {
  const _DragArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color.fromARGB(255, 0, 200, 0)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final cx = size.width / 2;
    canvas.drawLine(Offset(cx, 4), Offset(cx, size.height - 4), p);
    canvas.drawLine(Offset(cx, 4), Offset(cx - 4, 10), p);
    canvas.drawLine(Offset(cx, 4), Offset(cx + 4, 10), p);
    canvas.drawLine(
      Offset(cx, size.height - 4),
      Offset(cx - 4, size.height - 10),
      p,
    );
    canvas.drawLine(
      Offset(cx, size.height - 4),
      Offset(cx + 4, size.height - 10),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
