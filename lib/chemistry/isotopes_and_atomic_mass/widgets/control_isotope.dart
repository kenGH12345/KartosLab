/// ControlIsotope — PhET slider + arrows + readout for Mix slider mode.
library;

import 'package:flutter/material.dart';

import '../controller/mixtures_controller.dart';
import '../model/data/data.dart';
import '../model/get_isotope_color.dart';
import '../model/mixtures_constants.dart';
import '../painters/nucleon_ball_painter.dart';

class ControlIsotopeWidget extends StatelessWidget {
  const ControlIsotopeWidget({
    super.key,
    required this.controller,
    required this.isotope,
  });

  final MixturesController controller;
  final IsotopeData isotope;

  @override
  Widget build(BuildContext context) {
    final count = controller.model.getIsotopeCount(isotope.massNumber);
    final color = getIsotopeColor(
      protonCount: isotope.atomicNumber,
      neutronCount: isotope.neutronCount,
    );
    final name = ElementRepository.instance
            .getByAtomicNumber(isotope.atomicNumber)
            ?.name ??
        isotope.symbol;
    final caption = '$name-${isotope.massNumber}';

    return SizedBox(
      width: kMixMaxSliderWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Numeric readout + ±
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ArrowBtn(
                left: true,
                enabled: count > 0,
                onTap: () => controller.setIsotopeQuantity(
                  isotope.massNumber,
                  count - 1,
                ),
              ),
              Container(
                width: 30,
                height: 16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              _ArrowBtn(
                left: false,
                enabled: count < kSliderCapacity,
                onTap: () => controller.setIsotopeQuantity(
                  isotope.massNumber,
                  count + 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Label: ball + caption
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(
                size: const Size(12, 12),
                painter: _IsoBallPainter(color),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  caption,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _PhetSlider(
            value: count.toDouble(),
            min: 0,
            max: kSliderCapacity.toDouble(),
            onChanged: (v) => controller.setIsotopeQuantity(
              isotope.massNumber,
              v.round().clamp(0, kSliderCapacity),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  const _ArrowBtn({
    required this.left,
    required this.enabled,
    required this.onTap,
  });

  final bool left;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          left ? Icons.chevron_left : Icons.chevron_right,
          size: 18,
          color: enabled ? Colors.black87 : Colors.black26,
        ),
      ),
    );
  }
}

class _IsoBallPainter extends CustomPainter {
  _IsoBallPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    NucleonBallPainter.paint(
      canvas,
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      color,
    );
  }

  @override
  bool shouldRepaint(covariant _IsoBallPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Minimal PhET-like HSlider: track 80×5, thumb 15×30, ticks 0/100.
class _PhetSlider extends StatelessWidget {
  const _PhetSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    const trackW = 80.0;
    const thumbW = 15.0;
    const thumbH = 30.0;
    final t = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          width: trackW + thumbW,
          height: thumbH,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _setFromLocal(d.localPosition.dx, trackW, thumbW),
            onHorizontalDragStart: (d) =>
                _setFromLocal(d.localPosition.dx, trackW, thumbW),
            onHorizontalDragUpdate: (d) =>
                _setFromLocal(d.localPosition.dx, trackW, thumbW),
            child: CustomPaint(
              painter: _SliderPainter(t: t),
              size: const Size(trackW + thumbW, thumbH),
            ),
          ),
        ),
        SizedBox(
          width: trackW + thumbW,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(fontSize: 12)),
              Text('100', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  void _setFromLocal(double localX, double trackW, double thumbW) {
    final x = (localX - thumbW / 2).clamp(0.0, trackW);
    final t = x / trackW;
    onChanged(min + t * (max - min));
  }
}

class _SliderPainter extends CustomPainter {
  _SliderPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const trackW = 80.0;
    const trackH = 5.0;
    const thumbW = 15.0;
    const thumbH = 30.0;
    final trackLeft = (size.width - trackW) / 2;
    final trackTop = (size.height - trackH) / 2;
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(trackLeft, trackTop, trackW, trackH),
      const Radius.circular(2),
    );
    canvas.drawRRect(track, Paint()..color = const Color(0xFF666666));

    // ticks
    canvas.drawLine(
      Offset(trackLeft, trackTop - 8),
      Offset(trackLeft, trackTop + trackH + 8),
      Paint()..color = Colors.black,
    );
    canvas.drawLine(
      Offset(trackLeft + trackW, trackTop - 8),
      Offset(trackLeft + trackW, trackTop + trackH + 8),
      Paint()..color = Colors.black,
    );

    final thumbX = trackLeft + t * trackW - thumbW / 2;
    final thumbY = (size.height - thumbH) / 2;
    final thumb = RRect.fromRectAndRadius(
      Rect.fromLTWH(thumbX, thumbY, thumbW, thumbH),
      const Radius.circular(3),
    );
    canvas.drawRRect(thumb, Paint()..color = const Color(0xFF159CC4));
    canvas.drawRRect(
      thumb,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black54,
    );
  }

  @override
  bool shouldRepaint(covariant _SliderPainter oldDelegate) => oldDelegate.t != t;
}
