import 'package:flutter/material.dart';

import '../../domain/fluid/buoyancy_pool.dart';
import '../../layout/buoyancy_global_layout_spec.dart';
import '../../rendering/transform/bvec3.dart';
import '../../rendering/transform/buoyancy_three_transform.dart';
import '../buoyancy_scale_host.dart';

/// Source: `BuoyancyScreenView.positionScaleHeightControl` +
/// `PoolScaleHeightControl.ts` layoutFunction origin.
///
/// Track sits **outside** the pool: X = pool.maxX (front) + MARGIN_SMALL;
/// Y origin = pool.minY at scale front (bottom of slider aligns with scale).
class BuoyancyPoolScaleHeightLayout {
  const BuoyancyPoolScaleHeightLayout({
    required this.left,
    required this.top,
    required this.trackHeight,
  });

  final double left;
  final double top;
  final double trackHeight;

  /// Viewport placement for [BuoyancyPoolScaleHeightControl].
  static BuoyancyPoolScaleHeightLayout compute({
    required BuoyancyThreeTransform mvt,
    required BuoyancyPool pool,
    required double layoutScale,
  }) {
    final poolFrontZ = pool.depth / 2;
    final scaleFrontZ = BuoyancyScaleHost.scaleDepth / 2;

    // X: poolBounds.maxX / minY / maxZ + MARGIN_SMALL
    final poolFrontRight = mvt.modelToView(
      BVec3(pool.maxX, pool.minY, poolFrontZ),
    );
    final left = poolFrontRight.dx + buoyancyMarginSmall * layoutScale;

    // Y: poolBounds.maxX / minY / scale.getBounds().maxZ
    final yAnchor = mvt
        .modelToView(BVec3(pool.maxX, pool.minY, scaleFrontZ))
        .dy;

    // Track height: modelToViewDelta(SCALE_X,maxY,maxZ)→(SCALE_X,minY,maxZ)
    final maxY = pool.fluidY + BuoyancyScaleHost.scaleHeight;
    final topPt = mvt.modelToView(
      BVec3(BuoyancyScaleHost.poolScaleX, maxY, poolFrontZ),
    );
    final botPt = mvt.modelToView(
      BVec3(BuoyancyScaleHost.poolScaleX, pool.minY, poolFrontZ),
    );
    final trackHeight = (botPt.dy - topPt.dy).abs().clamp(60.0, 280.0);

    // layoutFunction: vBox.y = -(↑ + margin + slider − thumbW/2)
    // → widget top = yAnchor − (arrow + margin + track − thumbW/2)
    const arrowSize = 14.0;
    const margin = 2.0;
    const thumbW = 15.0;
    final top = yAnchor - (arrowSize + margin + trackHeight - thumbW / 2);

    return BuoyancyPoolScaleHeightLayout(
      left: left,
      top: top,
      trackHeight: trackHeight,
    );
  }
}

/// Source: `PoolScaleHeightControl.ts` + `PrecisionSliderThumb.ts`.
///
/// Vertical NumberControl: ArrowButton↑ · track+thumb · ArrowButton↓.
/// Thumb = PrecisionSliderThumb (mainHeight 12, taper 5, width 15, lineHeight 0).
class BuoyancyPoolScaleHeightControl extends StatefulWidget {
  const BuoyancyPoolScaleHeightControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 140,
  });

  /// Unitless 0..1 (`PoolScale.heightProperty`).
  final double value;
  final ValueChanged<double> onChanged;

  /// Track length in viewport px (model minY→maxY span).
  final double height;

  static const Color thumbFill = Color(0xFF159BD5);
  static const Color thumbHighlight = Color(0xFF45B4E0);
  static const Color arrowColor = Color(0xFF333333);
  static const double trackWidth = 3;
  static const double delta = 0.01; // NUMBER_CONTROL_DELTA (arrow)
  static const double fineDelta = 0.0005; // range/2000

  @override
  State<BuoyancyPoolScaleHeightControl> createState() =>
      _BuoyancyPoolScaleHeightControlState();
}

class _BuoyancyPoolScaleHeightControlState
    extends State<BuoyancyPoolScaleHeightControl> {
  bool _thumbHot = false;
  double? _dragStartValue;
  double? _dragStartY;

  static const double _thumbW = 18;
  static const double _thumbH = 20; // taper 5 + main 12 + stroke pad
  static const double _arrowSize = 14;
  static const double _margin = 2;

  void _nudge(double d) {
    widget.onChanged((widget.value + d).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final trackH = widget.height;
    // Total column: arrow + margin + track + margin + arrow
    final totalH = _arrowSize + _margin + trackH + _margin + _arrowSize;
    // value 1 = top of pool (high), 0 = bottom — PhET linear map
    final t = 1.0 - widget.value.clamp(0.0, 1.0);
    final thumbCenterY = _arrowSize + _margin + t * trackH;

    return SizedBox(
      width: 36,
      height: totalH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ↑ ArrowButton (rotated −90° in source → points up)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TriangleArrowButton(
              pointingUp: true,
              onPressed: () => _nudge(BuoyancyPoolScaleHeightControl.delta),
            ),
          ),

          // Track (3 px)
          Positioned(
            top: _arrowSize + _margin,
            left: (36 - BuoyancyPoolScaleHeightControl.trackWidth) / 2,
            child: Container(
              width: BuoyancyPoolScaleHeightControl.trackWidth,
              height: trackH,
              decoration: BoxDecoration(
                color: const Color(0xFF888888),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),

          // Drag hit area (includes leftward scale area like thumbInteractionArea)
          Positioned(
            top: _arrowSize + _margin,
            left: -8,
            width: 44,
            height: trackH,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) {
                _dragStartValue = widget.value;
                _dragStartY = d.localPosition.dy;
                setState(() => _thumbHot = true);
              },
              onPanUpdate: (d) {
                final startV = _dragStartValue;
                final startY = _dragStartY;
                if (startV == null || startY == null || trackH <= 0) return;
                // Screen +y down → height decreases
                final dh = (d.localPosition.dy - startY) / trackH;
                widget.onChanged((startV - dh).clamp(0.0, 1.0));
              },
              onPanEnd: (_) {
                _dragStartValue = null;
                _dragStartY = null;
                setState(() => _thumbHot = false);
              },
              onPanCancel: () {
                _dragStartValue = null;
                _dragStartY = null;
                setState(() => _thumbHot = false);
              },
            ),
          ),

          // PrecisionSliderThumb — tip points up (source local +y along track)
          Positioned(
            top: thumbCenterY - _thumbH / 2,
            left: (36 - _thumbW) / 2,
            child: IgnorePointer(
              child: CustomPaint(
                size: const Size(_thumbW, _thumbH),
                painter: _PrecisionSliderThumbPainter(
                  fill: _thumbHot
                      ? BuoyancyPoolScaleHeightControl.thumbHighlight
                      : BuoyancyPoolScaleHeightControl.thumbFill,
                ),
              ),
            ),
          ),

          // ↓ ArrowButton
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _TriangleArrowButton(
              pointingUp: false,
              onPressed: () => _nudge(-BuoyancyPoolScaleHeightControl.delta),
            ),
          ),
        ],
      ),
    );
  }
}

/// Source ArrowButton rotated ±90° — filled triangle, no Material chrome.
class _TriangleArrowButton extends StatelessWidget {
  const _TriangleArrowButton({
    required this.pointingUp,
    required this.onPressed,
  });

  final bool pointingUp;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        height: 14,
        child: Center(
          child: CustomPaint(
            size: const Size(12, 10),
            painter: _TrianglePainter(pointingUp: pointingUp),
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.pointingUp});
  final bool pointingUp;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointingUp) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close();
    }
    canvas.drawPath(
      path,
      Paint()..color = BuoyancyPoolScaleHeightControl.arrowColor,
    );
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.pointingUp != pointingUp;
}

/// PrecisionSliderThumb geometry: tip + taper + body, tip pointing up.
class _PrecisionSliderThumbPainter extends CustomPainter {
  _PrecisionSliderThumbPainter({required this.fill});

  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    // PoolScaleHeightControl: thumbWidth=15, taperHeight=5, mainHeight=12, lineHeight=0
    const tw = 15.0;
    const taper = 5.0;
    const main = 12.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(tw / 2, taper)
      ..lineTo(tw / 2, taper + main)
      ..lineTo(-tw / 2, taper + main)
      ..lineTo(-tw / 2, taper)
      ..close();

    canvas.save();
    canvas.translate(size.width / 2, 1);

    canvas.drawPath(
      path.shift(const Offset(1.2, 1.2)),
      Paint()..color = const Color(0x55000000),
    );
    // Soft round body (original reads as circular) under the polygonal tip.
    final bodyCenter = Offset(0, taper + main * 0.45);
    canvas.drawCircle(
      bodyCenter.translate(1, 1),
      tw * 0.42,
      Paint()..color = const Color(0x44000000),
    );
    canvas.drawCircle(bodyCenter, tw * 0.42, Paint()..color = fill);
    canvas.drawCircle(
      bodyCenter,
      tw * 0.42,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Bottom nub
    canvas.drawCircle(
      Offset(0, taper + main - 1),
      2.2,
      Paint()..color = fill,
    );
    canvas.drawCircle(
      Offset(0, taper + main - 1),
      2.2,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
    // White tip
    final tip = Path()
      ..moveTo(0, -0.5)
      ..lineTo(3.2, taper * 0.85)
      ..lineTo(-3.2, taper * 0.85)
      ..close();
    canvas.drawPath(tip, Paint()..color = const Color(0xEEFFFFFF));
    canvas.drawPath(
      tip,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PrecisionSliderThumbPainter oldDelegate) =>
      oldDelegate.fill != fill;
}
