import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../constants/hookes_law_constants.dart';
import '../../model/hookes_law_numbers.dart';
import '../phet_bevel.dart';
import '../phet_font.dart';
import 'intro_play_painter.dart';

/// PhET `NumberControl` with `springControlLayoutFunction`.
///
/// Title and readout on the first row. Decrement, slider, increment on the
/// second. Slider thumb snaps to [sliderInterval]. Arrow buttons step by
/// [arrowInterval]. Those intervals are not the same.
class IntroNumberControl extends StatelessWidget {
  const IntroNumberControl({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.sliderInterval,
    required this.arrowInterval,
    required this.decimalPlaces,
    required this.units,
    required this.thumbColor,
    required this.majorTicks,
    required this.minorTickSpacing,
    required this.onChanged,
    required this.onInteractionStart,
    required this.onInteractionEnd,
    required this.sliderKey,
    required this.incrementKey,
    required this.decrementKey,
    this.trackWidth = HookesLawConstants.sliderTrackWidth,
    this.framed = true,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final double sliderInterval;
  final double arrowInterval;
  final int decimalPlaces;
  final String units;
  final Color thumbColor;
  final List<IntroTick> majorTicks;
  final double minorTickSpacing;
  final ValueChanged<double> onChanged;
  final VoidCallback onInteractionStart;
  final VoidCallback onInteractionEnd;
  final Key sliderKey;
  final Key incrementKey;
  final Key decrementKey;
  final double trackWidth;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: framed ? HookesLawConstants.springPanelXMargin : 0,
        vertical: framed ? HookesLawConstants.springPanelYMargin : 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: PhetFont.of(HookesLawConstants.controlFontSize)),
              const SizedBox(width: 5),
              Text(
                '${value.toStringAsFixed(decimalPlaces)} $units',
                style: PhetFont.of(HookesLawConstants.controlFontSize),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ArrowButton(
                key: decrementKey,
                direction: -1,
                onPressed: () => onChanged(value - arrowInterval),
                onInteractionStart: onInteractionStart,
                onInteractionEnd: onInteractionEnd,
              ),
              const SizedBox(width: 15),
              _Track(
                key: sliderKey,
                value: value,
                min: min,
                max: max,
                interval: sliderInterval,
                trackWidth: trackWidth,
                thumbColor: thumbColor,
                majorTicks: majorTicks,
                minorTickSpacing: minorTickSpacing,
                onChanged: onChanged,
                onInteractionStart: onInteractionStart,
                onInteractionEnd: onInteractionEnd,
              ),
              const SizedBox(width: 15),
              _ArrowButton(
                key: incrementKey,
                direction: 1,
                onPressed: () => onChanged(value + arrowInterval),
                onInteractionStart: onInteractionStart,
                onInteractionEnd: onInteractionEnd,
              ),
            ],
          ),
        ],
      ),
    );
    if (!framed) {
      return body;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: IntroColors.panelFill,
        border: Border.all(color: IntroColors.panelStroke),
        borderRadius: BorderRadius.circular(4),
      ),
      child: body,
    );
  }
}

class IntroTick {
  const IntroTick(this.value, {this.label});

  final double value;
  final String? label;
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    super.key,
    required this.direction,
    required this.onPressed,
    required this.onInteractionStart,
    required this.onInteractionEnd,
  });

  final int direction;
  final VoidCallback onPressed;
  final VoidCallback onInteractionStart;
  final VoidCallback onInteractionEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onInteractionStart(),
      onTapUp: (_) => onInteractionEnd(),
      onTapCancel: onInteractionEnd,
      onTap: onPressed,
      child: CustomPaint(
        size: const Size(22, 28),
        painter: _TrianglePainter(direction: direction),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter({required this.direction});

  final int direction;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (direction < 0) {
      path
        ..moveTo(size.width - 2, 2)
        ..lineTo(2, size.height / 2)
        ..lineTo(size.width - 2, size.height - 2)
        ..close();
    } else {
      path
        ..moveTo(2, 2)
        ..lineTo(size.width - 2, size.height / 2)
        ..lineTo(2, size.height - 2)
        ..close();
    }
    canvas.save();
    canvas.translate(direction < 0 ? 1.2 : 0, 1.5);
    canvas.drawPath(path, Paint()..color = const Color(0xFF8A8A8A));
    canvas.restore();
    final bounds = path.getBounds();
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          bounds.topCenter,
          bounds.bottomCenter,
          const [Color(0xFFFFFFFF), Color(0xFFE6E6E6), Color(0xFF9A9A9A)],
          const [0, 0.45, 1],
        ),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF000000),
    );
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => false;
}

class _ThumbPainter extends CustomPainter {
  const _ThumbPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    paintBeveledRRect(
      canvas,
      Offset.zero & size,
      face: color,
      radius: 2,
    );
  }

  @override
  bool shouldRepaint(_ThumbPainter oldDelegate) => oldDelegate.color != color;
}

class _Track extends StatefulWidget {
  const _Track({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.interval,
    required this.trackWidth,
    required this.thumbColor,
    required this.majorTicks,
    required this.minorTickSpacing,
    required this.onChanged,
    required this.onInteractionStart,
    required this.onInteractionEnd,
  });

  final double value;
  final double min;
  final double max;
  final double interval;
  final double trackWidth;
  final Color thumbColor;
  final List<IntroTick> majorTicks;
  final double minorTickSpacing;
  final ValueChanged<double> onChanged;
  final VoidCallback onInteractionStart;
  final VoidCallback onInteractionEnd;

  @override
  State<_Track> createState() => _TrackState();
}

class _TrackState extends State<_Track> {
  double _valueAt(double dx) {
    final t = (dx / widget.trackWidth).clamp(0.0, 1.0);
    final raw = widget.min + t * (widget.max - widget.min);
    return HookesLawNumbers.roundToInterval(raw, widget.interval);
  }

  @override
  Widget build(BuildContext context) {
    final fraction =
        ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
    final thumbLeft = fraction * widget.trackWidth -
        HookesLawConstants.sliderThumbWidth / 2;
    return GestureDetector(
      onPanStart: (details) {
        widget.onInteractionStart();
        widget.onChanged(_valueAt(details.localPosition.dx));
      },
      onPanUpdate: (details) {
        widget.onChanged(_valueAt(details.localPosition.dx));
      },
      onPanEnd: (_) => widget.onInteractionEnd(),
      onPanCancel: widget.onInteractionEnd,
      child: SizedBox(
        width: widget.trackWidth,
        height: 78,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 16,
              child: Container(
                width: widget.trackWidth,
                height: HookesLawConstants.sliderTrackHeight,
                color: IntroColors.track,
              ),
            ),
            ..._minorTicks(),
            ..._majorTicks(),
            Positioned(
              left: thumbLeft,
              top: 16 - (HookesLawConstants.sliderThumbHeight - 3) / 2,
              child: IgnorePointer(
                child: CustomPaint(
                  size: Size(HookesLawConstants.sliderThumbWidth, HookesLawConstants.sliderThumbHeight),
                  painter: _ThumbPainter(color: widget.thumbColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _majorTicks() {
    return [
      for (final tick in widget.majorTicks)
        Positioned(
          left: _tickLeft(tick.value),
          top: 18,
          child: Column(
            children: [
              Container(
                width: 1,
                height: HookesLawConstants.sliderMajorTickLength,
                color: const Color(0xFF000000),
              ),
              if (tick.label != null)
                Text(
                  tick.label!,
                  style: PhetFont.of(HookesLawConstants.majorTickFontSize),
                ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _minorTicks() {
    final ticks = <Widget>[];
    var value = widget.min;
    while (value <= widget.max + 1e-9) {
      final labeled = widget.majorTicks.any((tick) => (tick.value - value).abs() < 1e-6);
      if (!labeled) {
        ticks.add(
          Positioned(
            left: _tickLeft(value),
            top: 18,
            child: Container(
              width: 1,
              height: 8,
              color: const Color(0xFF000000),
            ),
          ),
        );
      }
      value += widget.minorTickSpacing;
    }
    return ticks;
  }

  double _tickLeft(double value) {
    final t = (value - widget.min) / (widget.max - widget.min);
    return t * widget.trackWidth;
  }
}
