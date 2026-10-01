import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/under_pressure_math.dart';

/// Source: `ControlSlider.js` + sun `AccordionBox`.
///
/// Accordion chrome: fill `#f2fa6a`, stroke gray, cornerRadius 4,
/// expand/collapse button sideLength 12 (left), title font 13.
/// HSlider track 115×6, thumb 12×25 (not Material Slider).
class UpControlSlider extends StatelessWidget {
  const UpControlSlider({
    super.key,
    required this.controller,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.decimals,
    required this.displayString,
    required this.expanded,
    required this.onExpanded,
    required this.onChanged,
    required this.ticks,
    this.disabled = false,
  });

  final UnderPressureController controller;
  final String title;
  final double value;
  final double min;
  final double max;
  final int decimals;
  final String displayString;
  final bool expanded;
  final ValueChanged<bool> onExpanded;
  final ValueChanged<double> onChanged;
  final List<({String title, double value})> ticks;
  final bool disabled;

  static const double _trackW = 115;
  static const double _panelW = 140; // track + 12*xMargin ≈ source minWidth

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _panelW,
      decoration: BoxDecoration(
        color: const Color(0xFFF2FA6A),
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accordion title row — ExpandCollapseButton left
          InkWell(
            onTap: () => onExpanded(!expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 5, 4),
              child: Row(
                children: [
                  _ExpandCollapseButton(expanded: expanded),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 5),
              child: disabled
                  ? const SizedBox(
                      height: 90,
                      child: Center(
                        child: Text(
                          '?',
                          style: TextStyle(fontSize: 60, height: 1),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Value field + arrow buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ArrowButton(
                              right: false,
                              enabled: value > min,
                              onTap: () => onChanged(
                                UnderPressureMath.toFixedNumber(
                                  (value - (decimals == 0 ? 1 : 0.1))
                                      .clamp(min, max),
                                  decimals,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: _trackW * 0.6,
                              height: 18,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                displayString,
                                style: const TextStyle(fontSize: 12, height: 1),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _ArrowButton(
                              right: true,
                              enabled: value < max,
                              onTap: () => onChanged(
                                UnderPressureMath.toFixedNumber(
                                  (value + (decimals == 0 ? 1 : 0.1))
                                      .clamp(min, max),
                                  decimals,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Custom HSlider (not Material)
                        _PhSlider(
                          value: value.clamp(min, max),
                          min: min,
                          max: max,
                          onChanged: onChanged,
                          tickValues: ticks.map((t) => t.value).toList(),
                        ),
                        SizedBox(
                          width: _trackW,
                          height: 28,
                          child: Stack(
                            children: ticks.map((t) {
                              final frac = (t.value - min) / (max - min);
                              return Align(
                                alignment: Alignment(-1 + 2 * frac, 0),
                                child: Text(
                                  t.title,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    height: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }
}

/// Source AccordionBox expandCollapseButtonOptions.sideLength = 12.
class _ExpandCollapseButton extends StatelessWidget {
  const _ExpandCollapseButton({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _PlusMinusPainter(expanded: expanded),
    );
  }
}

class _PlusMinusPainter extends CustomPainter {
  _PlusMinusPainter({required this.expanded});

  final bool expanded;

  @override
  void paint(Canvas canvas, Size size) {
    // sun ExpandCollapseButton: orange square with white + / −
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(2),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFFE74C3C));
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0xFFB03A2E),
    );
    final ink = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(3, cy), Offset(size.width - 3, cy), ink);
    if (!expanded) {
      canvas.drawLine(Offset(cx, 3), Offset(cx, size.height - 3), ink);
    }
  }

  @override
  bool shouldRepaint(covariant _PlusMinusPainter old) =>
      old.expanded != expanded;
}

/// Source sun ArrowButton scale 0.6 — blue chevron pad.
class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.right,
    required this.enabled,
    required this.onTap,
  });

  final bool right;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: CustomPaint(
          size: const Size(18, 18),
          painter: _ArrowPainter(right: right),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.right});

  final bool right;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(3),
    );
    canvas.drawRRect(bg, Paint()..color = const Color(0xFF5DADE2));
    canvas.drawRRect(
      bg,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF2E86C1)
        ..strokeWidth = 1,
    );
    final path = Path();
    if (right) {
      path
        ..moveTo(size.width * 0.35, size.height * 0.25)
        ..lineTo(size.width * 0.7, size.height * 0.5)
        ..lineTo(size.width * 0.35, size.height * 0.75)
        ..close();
    } else {
      path
        ..moveTo(size.width * 0.65, size.height * 0.25)
        ..lineTo(size.width * 0.3, size.height * 0.5)
        ..lineTo(size.width * 0.65, size.height * 0.75)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) => old.right != right;
}

/// Source HSlider: trackSize 115×6, thumbSize 12×25, majorTickLength 15.
class _PhSlider extends StatelessWidget {
  const _PhSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.tickValues,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final List<double> tickValues;

  @override
  Widget build(BuildContext context) {
    const trackW = 115.0;
    const trackH = 6.0;
    const thumbW = 12.0;
    const thumbH = 25.0;
    final frac = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return SizedBox(
      width: trackW + thumbW,
      height: thumbH + 8,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          final local = box.globalToLocal(d.globalPosition);
          final f = ((local.dx - thumbW / 2) / trackW).clamp(0.0, 1.0);
          onChanged(min + f * (max - min));
        },
        onTapDown: (d) {
          final f = ((d.localPosition.dx - thumbW / 2) / trackW).clamp(0.0, 1.0);
          onChanged(min + f * (max - min));
        },
        child: CustomPaint(
          painter: _PhSliderPainter(
            frac: frac,
            tickFracs: tickValues
                .map((t) => ((t - min) / (max - min)).clamp(0.0, 1.0))
                .toList(),
            trackW: trackW,
            trackH: trackH,
            thumbW: thumbW,
            thumbH: thumbH,
          ),
        ),
      ),
    );
  }
}

class _PhSliderPainter extends CustomPainter {
  _PhSliderPainter({
    required this.frac,
    required this.tickFracs,
    required this.trackW,
    required this.trackH,
    required this.thumbW,
    required this.thumbH,
  });

  final double frac;
  final List<double> tickFracs;
  final double trackW;
  final double trackH;
  final double thumbW;
  final double thumbH;

  @override
  void paint(Canvas canvas, Size size) {
    final trackTop = (size.height - trackH) / 2;
    final trackLeft = thumbW / 2;
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(trackLeft, trackTop, trackW, trackH),
      const Radius.circular(3),
    );
    canvas.drawRRect(track, Paint()..color = const Color(0xFFCCCCCC));
    canvas.drawRRect(
      track,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF888888)
        ..strokeWidth = 1,
    );

    // Major ticks
    final tickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    for (final f in tickFracs) {
      final x = trackLeft + f * trackW;
      canvas.drawLine(
        Offset(x, trackTop + trackH),
        Offset(x, trackTop + trackH + 15),
        tickPaint,
      );
    }

    // Thumb 12×25
    final thumbX = trackLeft + frac * trackW - thumbW / 2;
    final thumbY = (size.height - thumbH) / 2;
    final thumb = RRect.fromRectAndRadius(
      Rect.fromLTWH(thumbX, thumbY, thumbW, thumbH),
      const Radius.circular(3),
    );
    final grad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [Color(0xFFF5F5F5), Color(0xFFBDBDBD)],
    ).createShader(Rect.fromLTWH(thumbX, thumbY, thumbW, thumbH));
    canvas.drawRRect(thumb, Paint()..shader = grad);
    canvas.drawRRect(
      thumb,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF666666)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _PhSliderPainter old) =>
      old.frac != frac || old.tickFracs != tickFracs;
}
