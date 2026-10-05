/// Decay / Chart Intro 共用的核子加减箭头列。
///
/// [已确认] `ArrowButton` / `DoubleArrowButton`：白底黑框、三角 Path 14×14。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ban_constants.dart';

class NucleonArrowColumn extends StatelessWidget {
  const NucleonArrowColumn({
    super.key,
    required this.upKey,
    required this.downKey,
    required this.color,
    required this.onUp,
    required this.onDown,
    this.doubled = false,
  });

  final Key upKey;
  final Key downKey;
  final Color color;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final bool doubled;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NucleonArrowButton(
          buttonKey: upKey,
          up: true,
          color: color,
          doubled: doubled,
          onPressed: onUp,
        ),
        const SizedBox(height: BanConstants.nucleonArrowVBoxSpacing),
        NucleonArrowButton(
          buttonKey: downKey,
          up: false,
          color: color,
          doubled: doubled,
          onPressed: onDown,
        ),
      ],
    );
  }
}

class NucleonArrowButton extends StatelessWidget {
  const NucleonArrowButton({
    super.key,
    required this.buttonKey,
    required this.up,
    required this.color,
    required this.onPressed,
    this.doubled = false,
  });

  final Key buttonKey;
  final bool up;
  final Color color;
  final VoidCallback? onPressed;
  final bool doubled;

  @override
  Widget build(BuildContext context) {
    final w = doubled
        ? BanConstants.nucleonDoubleArrowButtonWidth
        : BanConstants.nucleonArrowButtonWidth;
    const h = BanConstants.nucleonArrowButtonHeight;
    final style = IconButton.styleFrom(
      minimumSize: Size(w, h),
      maximumSize: Size(w, h),
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      backgroundColor: Colors.white,
      disabledBackgroundColor: Colors.white,
      side: const BorderSide(color: Colors.black, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
    return SizedBox(
      width: w,
      height: h,
      child: IconButton(
        key: buttonKey,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: w, height: h),
        style: style,
        icon: SizedBox(
          width: doubled
              ? BanConstants.nucleonArrowGlyphSize * 2
              : BanConstants.nucleonArrowGlyphSize,
          height: BanConstants.nucleonArrowGlyphSize,
          child: CustomPaint(
            painter: NucleonArrowPainter(
              up: up,
              doubled: doubled,
              leftFill: doubled
                  ? const Color(BanConstants.protonColorValue)
                  : color,
              rightFill: doubled
                  ? const Color(BanConstants.neutronColorValue)
                  : color,
            ),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class NucleonArrowPainter extends CustomPainter {
  const NucleonArrowPainter({
    required this.up,
    required this.doubled,
    required this.leftFill,
    required this.rightFill,
  });

  final bool up;
  final bool doubled;
  final Color leftFill;
  final Color rightFill;

  @override
  void paint(Canvas canvas, Size size) {
    final g = BanConstants.nucleonArrowGlyphSize;
    final left = !up && doubled ? rightFill : leftFill;
    final right = !up && doubled ? leftFill : rightFill;
    canvas.save();
    if (!up) {
      canvas.translate(size.width, size.height);
      canvas.rotate(math.pi);
    }
    if (doubled) {
      _triangle(canvas, Offset(g / 2, 0), left);
      _triangle(canvas, Offset(g + g / 2, 0), right);
    } else {
      _triangle(canvas, Offset(g / 2, 0), left);
    }
    canvas.restore();
  }

  void _triangle(Canvas canvas, Offset tip, Color fill) {
    final g = BanConstants.nucleonArrowGlyphSize;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + g / 2, tip.dy + g)
      ..lineTo(tip.dx - g / 2, tip.dy + g)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(covariant NucleonArrowPainter old) =>
      old.up != up ||
      old.doubled != doubled ||
      old.leftFill != leftFill ||
      old.rightFill != rightFill;
}
