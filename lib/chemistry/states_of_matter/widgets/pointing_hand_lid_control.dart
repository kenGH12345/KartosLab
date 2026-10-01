import 'package:flutter/material.dart';

import '../layout/phase_changes_scene_layout.dart';
import '../model/phase_changes_model.dart';
import '../som_assets.dart';
import '../som_constants.dart';
import '../transform/som_coordinate_transform.dart';

/// Pointing-hand lid control — PhET `PointingHandNode` (WIDTH=150, fingertip on lid).
///
/// Full `pointingHand.png` is painted (overflows above layoutBounds), matching
/// ORIGINAL. Green hint arrows appear on hover / drag.
class PointingHandLidControl extends StatefulWidget {
  const PointingHandLidControl({
    super.key,
    required this.mvt,
    required this.containerHeight,
    required this.enabled,
    required this.onHeightDragged,
  });

  final SomCoordinateTransform mvt;
  final double containerHeight;
  final bool enabled;
  final ValueChanged<double> onHeightDragged;

  /// PhET `PointingHandNode.WIDTH`.
  static const double handWidth = PhaseChangesSceneLayout.pointingHandWidth;

  /// Intrinsic pointingHand mipmap level-0: 222×1065.
  static const double _intrinsicW = 222;
  static const double _intrinsicH = 1065;

  static double get handHeight => handWidth * (_intrinsicH / _intrinsicW);

  @override
  State<PointingHandLidControl> createState() => _PointingHandLidControlState();
}

class _PointingHandLidControlState extends State<PointingHandLidControl> {
  bool _mouseOver = false;
  bool _dragging = false;

  bool get _showHint => widget.enabled && (_mouseOver || _dragging);

  @override
  Widget build(BuildContext context) {
    final lidTop = widget.mvt.modelToViewY(widget.containerHeight);
    final areaCenterX =
        widget.mvt.modelToViewX(SomConstants.containerWidth / 2);
    final centerX =
        areaCenterX + PhaseChangesSceneLayout.pointingHandCenterXOffset;

    final handH = PointingHandLidControl.handHeight;
    final handW = PointingHandLidControl.handWidth;

    // PhET: fingertip ≈ image bottom; hint hangs ~5px below; node.bottom =
    // fingertipY + fingertipToBottomDistanceY → image.bottom ≈ lidTop.
    const hintOverhang = 55.0;
    final top = lidTop - handH;

    final atMax = widget.containerHeight >=
        SomConstants.containerInitialHeight - 1e-6;
    final atMin = widget.containerHeight <=
        PhaseChangesModel.minAllowableContainerHeight + 1e-6;

    return Positioned(
      left: centerX - handW / 2,
      top: top,
      width: handW + 40,
      height: handH + hintOverhang,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.35,
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.resizeUpDown
              : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _mouseOver = true),
          onExit: (_) => setState(() => _mouseOver = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragStart: widget.enabled
                ? (_) => setState(() => _dragging = true)
                : null,
            onVerticalDragUpdate: widget.enabled
                ? (details) {
                    // PhET: height += viewToModelDeltaY(endY − startY).
                    // View-down → model height decreases → lid / finger go down.
                    widget.onHeightDragged(
                      widget.containerHeight +
                          widget.mvt.viewToModelDeltaY(details.delta.dy),
                    );
                  }
                : null,
            onVerticalDragEnd: widget.enabled
                ? (_) => setState(() => _dragging = false)
                : null,
            onVerticalDragCancel: widget.enabled
                ? () => setState(() => _dragging = false)
                : null,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  width: handW,
                  height: handH,
                  child: Image.asset(
                    SomAssets.pointingHand,
                    width: handW,
                    height: handH,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                    gaplessPlayback: true,
                  ),
                ),
                if (_showHint)
                  Positioned(
                    // PhET hintNode: top = image.bottom - 50, left = image.right - 20
                    left: handW - 20,
                    top: handH - 50,
                    child: _HintArrows(
                      showUp: !atMax,
                      showDown: !atMin,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// PhET `ArrowNode` pair, fill `#33FF00`.
class _HintArrows extends StatelessWidget {
  const _HintArrows({required this.showUp, required this.showDown});

  final bool showUp;
  final bool showDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showUp)
          CustomPaint(
            size: const Size(14, 28),
            painter: _ArrowPainter(up: true),
          ),
        if (showUp && showDown) const SizedBox(height: 5),
        if (showDown)
          CustomPaint(
            size: const Size(14, 28),
            painter: _ArrowPainter(up: false),
          ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.up});

  final bool up;

  static const Color _fill = Color(0xFF33FF00);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _fill;
    final cx = size.width / 2;
    const headH = 10.0;
    const headW = 10.0;
    const tailW = 6.0;

    final path = Path();
    if (up) {
      path.moveTo(cx, 0);
      path.lineTo(cx + headW / 2, headH);
      path.lineTo(cx + tailW / 2, headH);
      path.lineTo(cx + tailW / 2, size.height);
      path.lineTo(cx - tailW / 2, size.height);
      path.lineTo(cx - tailW / 2, headH);
      path.lineTo(cx - headW / 2, headH);
      path.close();
    } else {
      path.moveTo(cx, size.height);
      path.lineTo(cx + headW / 2, size.height - headH);
      path.lineTo(cx + tailW / 2, size.height - headH);
      path.lineTo(cx + tailW / 2, 0);
      path.lineTo(cx - tailW / 2, 0);
      path.lineTo(cx - tailW / 2, size.height - headH);
      path.lineTo(cx - headW / 2, size.height - headH);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.up != up;
}
