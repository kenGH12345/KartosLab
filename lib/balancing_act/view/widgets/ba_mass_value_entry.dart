import 'package:flutter/material.dart';
import 'package:kratos/balancing_act/ba_strings.dart';
import 'package:kratos/hookes_law/view/phet_font.dart';

/// Source: `js/game/view/MassValueEntryNode.ts`
///
/// Panel fill `rgb(234,234,174)`; readout 100×24; HSlider thumb 15×30;
/// major ticks every 50, minor every 10; ± ArrowButtons.
class BaMassValueEntry extends StatelessWidget {
  const BaMassValueEntry({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  static const double maxMass = 100;
  static const Color panelFill = Color.fromRGBO(234, 234, 174, 1);
  static const Size thumbSize = Size(15, 30);

  @override
  Widget build(BuildContext context) {
    final v = value.round().clamp(0, maxMass.toInt());
    return Container(
      key: const Key('ba_game_mass_entry'),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      decoration: BoxDecoration(
        color: panelFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black54),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Readout background
          Container(
            width: 100,
            height: 24 * 1.3,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black),
            ),
            child: Text(
              '$v ${BaStrings.kg}',
              style: PhetFont.of(16),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ArrowBtn(
                pointingLeft: true,
                enabled: enabled && v > 0,
                onPressed: () => onChanged((v - 1).toDouble()),
              ),
              const SizedBox(width: 12),
              _BaHSlider(
                value: v.toDouble(),
                enabled: enabled,
                onChanged: (x) => onChanged(x.roundToDouble()),
              ),
              const SizedBox(width: 12),
              _ArrowBtn(
                pointingLeft: false,
                enabled: enabled && v < maxMass,
                onPressed: () => onChanged((v + 1).toDouble()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  const _ArrowBtn({
    required this.pointingLeft,
    required this.enabled,
    required this.onPressed,
  });

  final bool pointingLeft;
  final bool enabled;
  final VoidCallback onPressed;

  /// Source: ARROW_HEIGHT=15; arrowWidth = height * √3 / 2
  static const double arrowHeight = 15;
  static final double arrowWidth = arrowHeight * 0.866;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? const Color(0xFFE8E8E8) : const Color(0xFFCCCCCC),
      borderRadius: BorderRadius.circular(4),
      elevation: enabled ? 1 : 0,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 28,
          height: 28,
          child: CustomPaint(
            painter: _TrianglePainter(
              pointingLeft: pointingLeft,
              color: enabled ? Colors.black87 : Colors.black38,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.pointingLeft, required this.color});
  final bool pointingLeft;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const h = _ArrowBtn.arrowHeight;
    final w = _ArrowBtn.arrowWidth;
    final path = Path();
    if (pointingLeft) {
      path
        ..moveTo(cx + w / 2, cy - h / 2)
        ..lineTo(cx - w / 2, cy)
        ..lineTo(cx + w / 2, cy + h / 2)
        ..close();
    } else {
      path
        ..moveTo(cx - w / 2, cy - h / 2)
        ..lineTo(cx + w / 2, cy)
        ..lineTo(cx - w / 2, cy + h / 2)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.pointingLeft != pointingLeft || oldDelegate.color != color;
}

/// sun HSlider: thumb 15×30, majorTickLength 15, ticks every 10 (major @ 50).
class _BaHSlider extends StatelessWidget {
  const _BaHSlider({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  static const double trackW = 160;
  static const double trackH = 4;
  static const Size thumb = BaMassValueEntry.thumbSize;

  @override
  Widget build(BuildContext context) {
    final t = (value / BaMassValueEntry.maxMass).clamp(0.0, 1.0);
    final height = thumb.height + 28; // room for ticks + labels
    return SizedBox(
      width: trackW + thumb.width,
      height: height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled
            ? (d) => _setFromLocal(d.localPosition.dx)
            : null,
        onHorizontalDragUpdate: enabled
            ? (d) => _setFromLocal(d.localPosition.dx)
            : null,
        child: CustomPaint(
          size: Size(trackW + thumb.width, height),
          painter: _HSliderPainter(t: t, enabled: enabled),
        ),
      ),
    );
  }

  void _setFromLocal(double localX) {
    final x = (localX - thumb.width / 2).clamp(0.0, trackW);
    final v = (x / trackW) * BaMassValueEntry.maxMass;
    onChanged(v.roundToDouble().clamp(0, BaMassValueEntry.maxMass));
  }
}

class _HSliderPainter extends CustomPainter {
  _HSliderPainter({required this.t, required this.enabled});
  final double t;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    const trackW = _BaHSlider.trackW;
    const trackH = _BaHSlider.trackH;
    const thumbW = 15.0;
    const thumbH = 30.0;
    const majorLen = 15.0;
    final trackLeft = thumbW / 2;
    final trackTop = (size.height - trackH) / 2 - 4;
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(trackLeft, trackTop, trackW, trackH),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      track,
      Paint()..color = enabled ? const Color(0xFF666666) : const Color(0xFFAAAAAA),
    );

    // Ticks every 10; major (+label) every 50
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i <= 100; i += 10) {
      final x = trackLeft + (i / 100) * trackW;
      final isMajor = i % 50 == 0;
      final tickH = isMajor ? majorLen : 8.0;
      canvas.drawLine(
        Offset(x, trackTop + trackH),
        Offset(x, trackTop + trackH + tickH),
        Paint()
          ..color = Colors.black87
          ..strokeWidth = 1,
      );
      if (isMajor) {
        tp.text = TextSpan(
          text: '$i',
          style: PhetFont.of(10),
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(x - tp.width / 2, trackTop + trackH + tickH + 2),
        );
      }
    }

    // Thumb — sun HSlider default cyan-ish with left highlight
    final thumbX = trackLeft + t * trackW - thumbW / 2;
    final thumbY = trackTop + trackH / 2 - thumbH / 2;
    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(thumbX, thumbY, thumbW, thumbH),
      const Radius.circular(3),
    );
    final fill = enabled ? const Color(0xFF159BD6) : const Color(0xFF90A4AE);
    canvas.drawRRect(
      thumbRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.55),
            fill,
            fill.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.35, 1.0],
        ).createShader(thumbRect.outerRect),
    );
    canvas.drawRRect(
      thumbRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    // Center line
    canvas.drawLine(
      Offset(thumbX + thumbW / 2, thumbY + 4),
      Offset(thumbX + thumbW / 2, thumbY + thumbH - 4),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _HSliderPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.enabled != enabled;
}
