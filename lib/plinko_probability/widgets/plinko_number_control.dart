import 'package:flutter/material.dart';

/// PhET `NumberControl` + `createLayoutFunction3` for PegControls.
///
/// All geometry is in ScreenView layout px, then × [layoutScale].
///
/// Layers:
/// 1. Container — title + VBox spacing
/// 2. Track — 170×2 line, major ticks length 18
/// 3. Thumb — 17×34 rounded rect + white center line
/// 4. Arrows — square `ArrowButton` + NumberDisplay box
class PlinkoNumberControl extends StatelessWidget {
  const PlinkoNumberControl({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    this.decimalPlaces = 0,
    this.trackWidthLayout = 170,
    this.titleYSpacing = 5,
    this.layoutScale = 1.0,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final double step;
  final int decimalPlaces;
  final double trackWidthLayout;
  /// Rows uses 3; Binary Probability uses default 5.
  final double titleYSpacing;
  final double layoutScale;
  final ValueChanged<double> onChanged;

  static const thumbWLayout = 17.0;
  static const thumbHLayout = 34.0;
  static const trackHLayout = 2.0;
  static const majorTickLengthLayout = 18.0;
  static const arrowSizeLayout = 28.0;
  static const thumbFill = Color(0xFF159BD6);
  static const trackStroke = Color(0xFF000000);

  double get _s => layoutScale;

  String get _display {
    if (decimalPlaces <= 0) return value.round().toString();
    return value.toStringAsFixed(decimalPlaces);
  }

  void _nudge(int dir) {
    final next = (value + dir * step).clamp(min, max);
    final snapped = decimalPlaces <= 0
        ? next.roundToDouble()
        : ((next / step).round() * step);
    onChanged(snapped.clamp(min, max).toDouble());
  }

  void _setFromFraction(double t) {
    final raw = min + t * (max - min);
    final snapped = decimalPlaces <= 0
        ? raw.roundToDouble()
        : ((raw / step).round() * step);
    onChanged(snapped.clamp(min, max).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final atMin = value <= min + 1e-12;
    final atMax = value >= max - 1e-12;
    final t = max > min ? ((value - min) / (max - min)).clamp(0.0, 1.0) : 0.0;
    final trackW = trackWidthLayout * s;
    final thumbW = thumbWLayout * s;
    final thumbH = thumbHLayout * s;
    final arrow = arrowSizeLayout * s;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18 * s,
            fontFamily: 'Arial',
          ),
        ),
        SizedBox(height: titleYSpacing * s),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ArrowButton(
              size: arrow,
              pointingLeft: true,
              enabled: !atMin,
              onPressed: () => _nudge(-1),
            ),
            SizedBox(width: 5 * s),
            _NumberDisplay(text: _display, scale: s),
            SizedBox(width: 5 * s),
            _ArrowButton(
              size: arrow,
              pointingLeft: false,
              enabled: !atMax,
              onPressed: () => _nudge(1),
            ),
          ],
        ),
        SizedBox(height: titleYSpacing * s),
        SizedBox(
          width: trackW + thumbW,
          child: Column(
            children: [
              _TrackThumb(
                trackWidth: trackW,
                thumbW: thumbW,
                thumbH: thumbH,
                trackH: trackHLayout * s,
                tickLength: majorTickLengthLayout * s,
                fraction: t,
                onFraction: _setFromFraction,
              ),
              SizedBox(height: 1 * s),
              // Labels centered under end ticks (inset by thumbW/2).
              Padding(
                padding: EdgeInsets.symmetric(horizontal: thumbW / 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      decimalPlaces <= 0
                          ? '${min.toInt()}'
                          : min.toStringAsFixed(0),
                      style: TextStyle(fontSize: 16 * s, fontFamily: 'Arial'),
                    ),
                    Text(
                      decimalPlaces <= 0
                          ? '${max.toInt()}'
                          : max.toStringAsFixed(0),
                      style: TextStyle(fontSize: 16 * s, fontFamily: 'Arial'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NumberDisplay extends StatelessWidget {
  const _NumberDisplay({required this.text, required this.scale});

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      constraints: BoxConstraints(minWidth: 48 * s, minHeight: 28 * s),
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 2 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF999999), width: 1),
        borderRadius: BorderRadius.circular(3 * s),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontSize: 18 * s, fontFamily: 'Arial'),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.size,
    required this.pointingLeft,
    required this.enabled,
    required this.onPressed,
  });

  final double size;
  final bool pointingLeft;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: _ArrowButtonPainter(
          pointingLeft: pointingLeft,
          enabled: enabled,
        ),
      ),
    );
  }
}

class _ArrowButtonPainter extends CustomPainter {
  _ArrowButtonPainter({required this.pointingLeft, required this.enabled});

  final bool pointingLeft;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(size.width * 0.1),
    );
    canvas.drawRRect(r, Paint()..color = Colors.white);
    canvas.drawRRect(
      r,
      Paint()
        ..color = enabled ? Colors.black : Colors.black38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final cy = size.height / 2;
    final cx = size.width / 2;
    final halfH = size.height * 0.25;
    final halfW = size.width * 0.22;
    final path = Path();
    if (pointingLeft) {
      path
        ..moveTo(cx + halfW * 0.6, cy - halfH)
        ..lineTo(cx - halfW, cy)
        ..lineTo(cx + halfW * 0.6, cy + halfH)
        ..close();
    } else {
      path
        ..moveTo(cx - halfW * 0.6, cy - halfH)
        ..lineTo(cx + halfW, cy)
        ..lineTo(cx - halfW * 0.6, cy + halfH)
        ..close();
    }
    canvas.drawPath(
      path,
      Paint()..color = enabled ? Colors.black : Colors.black38,
    );
  }

  @override
  bool shouldRepaint(covariant _ArrowButtonPainter oldDelegate) =>
      oldDelegate.pointingLeft != pointingLeft ||
      oldDelegate.enabled != enabled;
}

class _TrackThumb extends StatelessWidget {
  const _TrackThumb({
    required this.trackWidth,
    required this.thumbW,
    required this.thumbH,
    required this.trackH,
    required this.tickLength,
    required this.fraction,
    required this.onFraction,
  });

  final double trackWidth;
  final double thumbW;
  final double thumbH;
  final double trackH;
  final double tickLength;
  final double fraction;
  final ValueChanged<double> onFraction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _emit(d.localPosition.dx),
      onHorizontalDragUpdate: (d) => _emit(d.localPosition.dx),
      child: SizedBox(
        width: trackWidth + thumbW,
        height: thumbH,
        child: CustomPaint(
          painter: _TrackThumbPainter(
            fraction: fraction,
            trackWidth: trackWidth,
            thumbW: thumbW,
            thumbH: thumbH,
            trackH: trackH,
            tickLength: tickLength,
          ),
        ),
      ),
    );
  }

  void _emit(double localX) {
    final inset = thumbW / 2;
    final t = ((localX - inset) / trackWidth).clamp(0.0, 1.0);
    onFraction(t);
  }
}

class _TrackThumbPainter extends CustomPainter {
  _TrackThumbPainter({
    required this.fraction,
    required this.trackWidth,
    required this.thumbW,
    required this.thumbH,
    required this.trackH,
    required this.tickLength,
  });

  final double fraction;
  final double trackWidth;
  final double thumbW;
  final double thumbH;
  final double trackH;
  final double tickLength;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = thumbW / 2;
    final cy = size.height / 2;
    final left = inset;
    final right = inset + trackWidth;

    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, cy), Offset(left, cy + tickLength), tickPaint);
    canvas.drawLine(
      Offset(right, cy),
      Offset(right, cy + tickLength),
      tickPaint,
    );

    canvas.drawLine(
      Offset(left, cy),
      Offset(right, cy),
      Paint()
        ..color = PlinkoNumberControl.trackStroke
        ..strokeWidth = trackH
        ..strokeCap = StrokeCap.butt,
    );

    final cx = left + fraction * trackWidth;
    final thumb = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: thumbW,
        height: thumbH,
      ),
      Radius.circular(3 * (thumbW / PlinkoNumberControl.thumbWLayout)),
    );
    canvas.drawRRect(thumb, Paint()..color = PlinkoNumberControl.thumbFill);
    canvas.drawRRect(
      thumb,
      Paint()
        ..color = const Color(0xFF0D47A1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(cx, cy - thumbH / 2 + 4),
      Offset(cx, cy + thumbH / 2 - 4),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TrackThumbPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.trackWidth != trackWidth ||
      oldDelegate.thumbW != thumbW;
}
