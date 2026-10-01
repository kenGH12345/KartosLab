import 'package:flutter/material.dart';

import '../gfl_colors.dart';
import '../gfl_strings.dart';
import '../model/gravity_force_constants.dart';

/// Puller sprite — PhET `ISLCPullerNode` using ISLC `figurePull_1..31.png`.
///
/// Rope / hand layout mirrors `ISLCPullerNode.js`:
/// - rope: `(-ropeLength, 0) → (0, 0)` at mass-edge height
/// - `images[i].bottom = 42`
/// - `images[i].right = -ropeLength + 0.1 * width` so hands overlap the rope
class PullerImageWidget extends StatelessWidget {
  const PullerImageWidget({
    super.key,
    required this.frameIndex,
    required this.massCenter,
    required this.massRadiusView,
    required this.flipHorizontal,
  });

  /// 0..30 → figurePull_1..31.png
  final int frameIndex;
  final Offset massCenter;
  final double massRadiusView;
  final bool flipHorizontal;

  static const int frameCount = 31;
  static const double imageScale = 0.45;
  static const double ropeLength = 40;

  /// Intrinsic size of `figurePull_*.png` (ISLC assets).
  static const double intrinsicWidth = 134;
  static const double intrinsicHeight = 151;

  /// PhET `images[i].bottom = 42` (rope at local y = 0 = mass center Y).
  static const double imageBottomLocal = 42;

  /// PhET: hands stay on the rope as frames widen.
  static const double handOverlapFactor = 0.1;

  static String assetPath(int frameIndex) {
    final n = (frameIndex + 1).clamp(1, frameCount);
    return '${GflStrings.pullerAssetDir}/figurePull_$n.png';
  }

  @override
  Widget build(BuildContext context) {
    final path = assetPath(frameIndex);
    final w = intrinsicWidth * imageScale;
    final h = intrinsicHeight * imageScale;
    final handOverlap = handOverlapFactor * w;

    final edgeX = flipHorizontal
        ? massCenter.dx + massRadiusView
        : massCenter.dx - massRadiusView;
    final ropeFarX =
        flipHorizontal ? edgeX + ropeLength : edgeX - ropeLength;

    // PhET: image.right = -ropeLength + 0.1*width (hands overlap rope).
    final double imageLeft;
    if (flipHorizontal) {
      // Mirrored: hands on the left edge → nudge left edge onto the rope.
      imageLeft = ropeFarX - handOverlap;
    } else {
      final imageRight = ropeFarX + handOverlap;
      imageLeft = imageRight - w;
    }

    // PhET: images[i].bottom = 42 with rope at y = 0 (= massCenter.dy).
    final imageTop = massCenter.dy + imageBottomLocal - h;

    Widget image = Image.asset(
      path,
      width: w,
      height: h,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: w,
        height: h,
        child: const ColoredBox(color: Color(0x33888888)),
      ),
    );

    if (flipHorizontal) {
      image = Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(-1, 1, 1),
        child: image,
      );
    }

    // Shadow ellipse under puller (ISLCPullerNode).
    final shadowLeft = imageLeft + w * 0.15;
    final shadowTop = imageTop + h - 4;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Rope under the sprite so hands visually grip the line.
        CustomPaint(
          size: const Size(
            GravityForceConstants.layoutWidth,
            GravityForceConstants.layoutHeight,
          ),
          painter: _RopePainter(
            from: Offset(edgeX, massCenter.dy),
            to: Offset(ropeFarX, massCenter.dy),
          ),
        ),
        Positioned(
          left: shadowLeft,
          top: shadowTop,
          child: Container(
            width: w * 0.55,
            height: 8,
            decoration: BoxDecoration(
              color: GflColors.shadow.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Positioned(
          left: imageLeft,
          top: imageTop,
          child: image,
        ),
      ],
    );
  }
}

class _RopePainter extends CustomPainter {
  _RopePainter({required this.from, required this.to});

  final Offset from;
  final Offset to;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GflColors.rope
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
  }

  @override
  bool shouldRepaint(covariant _RopePainter oldDelegate) =>
      oldDelegate.from != from || oldDelegate.to != to;
}
