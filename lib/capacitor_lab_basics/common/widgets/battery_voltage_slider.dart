import 'package:flutter/material.dart';

import '../../clb_constants.dart';
import '../../clb_strings.dart';
import '../model/battery.dart';
import '../painters/battery_painter.dart';

/// Custom vertical battery voltage slider — `BatteryNode.js` VSlider.
///
/// Track 8 × (0.55 × batteryGraphicScaledHeight); thumb 35×20;
/// fill rgb(255,237,53); highlighted rgb(71,207,255); stroke rgb(191,191,191).
/// Center at batteryCenter + Offset(5, 12).
///
/// Behavior (PhET):
/// - Continuous drag along −1.5…+1.5 V
/// - `constrainValue`: roundSymmetric(v·20)/20 → 0.05 V steps
/// - `endDrag`: |V| < 0.15 → snap to 0
/// - Polarity flip updates battery graphic + tick label colors
class BatteryVoltageSlider extends StatefulWidget {
  const BatteryVoltageSlider({
    super.key,
    required this.battery,
    required this.batteryCenter,
    this.showTickLabels = false,
  });

  final Battery battery;
  final Offset batteryCenter;
  final bool showTickLabels;

  static double trackLength([double scale = ClbConstants.batteryGraphicScale]) =>
      0.55 * BatteryPainter.scaledHeightPositiveUp(scale);

  @override
  State<BatteryVoltageSlider> createState() => _BatteryVoltageSliderState();
}

class _BatteryVoltageSliderState extends State<BatteryVoltageSlider> {
  static const double _trackWidth = 8;
  static const Size _thumbSize = Size(35, 20);
  /// `thumbTouchAreaXDilation` / `YDilation` — BatteryNode.js:52-53
  static const double _touchPad = 11;

  bool _dragging = false;

  void _setFromTrackLocalY(double yInTrack, double trackH) {
    final t = (yInTrack / trackH).clamp(0.0, 1.0);
    final v = ClbConstants.batteryVoltageMax +
        t * (ClbConstants.batteryVoltageMin - ClbConstants.batteryVoltageMax);
    widget.battery.voltage = v;
  }

  void _endDrag() {
    widget.battery.endDragSnap();
    if (_dragging) setState(() => _dragging = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.battery,
      builder: (context, _) {
        final trackH = BatteryVoltageSlider.trackLength();
        final center = widget.batteryCenter + const Offset(5, 12);
        final sliderW = _thumbSize.width + _touchPad * 2;
        final sliderH = trackH + _thumbSize.height + _touchPad * 2;

        final v = widget.battery.voltage;
        final t = (ClbConstants.batteryVoltageMax - v) /
            (ClbConstants.batteryVoltageMax - ClbConstants.batteryVoltageMin);
        final thumbCy = t.clamp(0.0, 1.0) * trackH;
        final trackTop = (sliderH - trackH) / 2;

        return SizedBox(
          width: ClbConstants.canvasWidth,
          height: ClbConstants.canvasHeight,
          child: Stack(
            children: [
              Positioned(
                left: center.dx - sliderW / 2,
                top: center.dy - sliderH / 2,
                width: sliderW,
                height: sliderH,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: (d) {
                    setState(() => _dragging = true);
                    _setFromTrackLocalY(d.localPosition.dy - trackTop, trackH);
                  },
                  onVerticalDragUpdate: (d) {
                    _setFromTrackLocalY(d.localPosition.dy - trackTop, trackH);
                  },
                  onVerticalDragEnd: (_) => _endDrag(),
                  onVerticalDragCancel: _endDrag,
                  onTapDown: (d) {
                    setState(() => _dragging = true);
                    _setFromTrackLocalY(d.localPosition.dy - trackTop, trackH);
                  },
                  onTapUp: (_) => _endDrag(),
                  onTapCancel: _endDrag,
                  child: CustomPaint(
                    size: Size(sliderW, sliderH),
                    painter: _VoltageSliderPainter(
                      trackHeight: trackH,
                      thumbCenterY: thumbCy + trackTop,
                      voltage: v,
                      positiveUp: widget.battery.isPositiveTerminalUp,
                      showTickLabels: widget.showTickLabels,
                      highlighted: _dragging,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VoltageSliderPainter extends CustomPainter {
  _VoltageSliderPainter({
    required this.trackHeight,
    required this.thumbCenterY,
    required this.voltage,
    required this.positiveUp,
    required this.showTickLabels,
    required this.highlighted,
  });

  final double trackHeight;
  final double thumbCenterY;
  final double voltage;
  final bool positiveUp;
  final bool showTickLabels;
  final bool highlighted;

  static const double _trackWidth = 8;
  static const Size _thumbSize = Size(35, 20);
  static const Color _thumbFill = Color.fromRGBO(255, 237, 53, 1);
  static const Color _thumbFillHighlighted = Color.fromRGBO(71, 207, 255, 1);
  static const Color _thumbStroke = Color.fromRGBO(191, 191, 191, 1);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final trackTop = (size.height - trackHeight) / 2;
    final trackRect = Rect.fromCenter(
      center: Offset(cx, trackTop + trackHeight / 2),
      width: _trackWidth,
      height: trackHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, const Radius.circular(2)),
      Paint()..color = const Color.fromRGBO(200, 200, 200, 1),
    );

    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1;
    for (final frac in [0.0, 0.5, 1.0]) {
      final y = trackTop + frac * trackHeight;
      canvas.drawLine(
        Offset(cx + _trackWidth / 2 + 2, y),
        Offset(cx + _trackWidth / 2 + 18, y),
        tickPaint,
      );
    }

    final thumbRect = Rect.fromCenter(
      center: Offset(cx, thumbCenterY),
      width: _thumbSize.width,
      height: _thumbSize.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(thumbRect, const Radius.circular(3)),
      Paint()..color = highlighted ? _thumbFillHighlighted : _thumbFill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(thumbRect, const Radius.circular(3)),
      Paint()
        ..color = _thumbStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(thumbRect.left + 4, thumbRect.center.dy),
      Offset(thumbRect.right - 4, thumbRect.center.dy),
      Paint()
        ..color = Colors.black
        ..strokeWidth = 1,
    );

    if (showTickLabels) {
      final tp = TextPainter(textDirection: TextDirection.ltr);
      void drawLabel(String s, double y, Color fill) {
        tp.text = TextSpan(
          text: s,
          style: TextStyle(fontSize: 12, color: fill),
        );
        tp.layout();
        tp.paint(canvas, Offset(cx - tp.width / 2 - 30, y - tp.height / 2));
      }

      // BatteryNode.js: polarity → max black / min white when positive-up; swapped when negative.
      drawLabel(
        ClbStrings.voltsTickLabel(ClbConstants.batteryVoltageMax),
        trackTop,
        positiveUp ? Colors.black : Colors.white,
      );
      drawLabel(
        ClbStrings.voltsTickLabel(ClbConstants.batteryVoltageDefault),
        trackTop + trackHeight / 2,
        Colors.white,
      );
      drawLabel(
        ClbStrings.voltsTickLabel(ClbConstants.batteryVoltageMin),
        trackTop + trackHeight,
        positiveUp ? Colors.white : Colors.black,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VoltageSliderPainter oldDelegate) =>
      oldDelegate.voltage != voltage ||
      oldDelegate.thumbCenterY != thumbCenterY ||
      oldDelegate.positiveUp != positiveUp ||
      oldDelegate.highlighted != highlighted;
}
