import 'package:flutter/material.dart';

/// PhET `WOASNumberControl` layout: title → [◀] display [▶] → slider.
///
/// Chrome approximates scenery-phet NumberControl (not raw Material Slider).
class WoasNumberControl extends StatelessWidget {
  const WoasNumberControl({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.delta,
    required this.decimalPlaces,
    required this.unitSuffix,
    required this.onChanged,
    this.trackWidth = 135,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final double delta;
  final int decimalPlaces;
  final String unitSuffix;
  final ValueChanged<double> onChanged;
  final double trackWidth;

  void _nudge(int dir) {
    final next = (value + dir * delta).clamp(min, max);
    onChanged(_roundToPlaces(next, decimalPlaces));
  }

  static double _roundToPlaces(double v, int places) {
    final m = _pow10(places);
    return (v * m).round() / m;
  }

  static double _pow10(int n) {
    var r = 1.0;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final display = decimalPlaces == 0
        ? '${value.round()}$unitSuffix'
        : '${value.toStringAsFixed(decimalPlaces)}$unitSuffix';

    return Semantics(
      label: '$title $display',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ArrowChip(
                key: ValueKey('${title}_dec'),
                left: true,
                onTap: () => _nudge(-1),
              ),
              const SizedBox(width: 5),
              Container(
                constraints: const BoxConstraints(minWidth: 72, maxWidth: 83),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black),
                ),
                alignment: Alignment.center,
                child: Text(
                  display,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 5),
              _ArrowChip(
                key: ValueKey('${title}_inc'),
                left: false,
                onTap: () => _nudge(1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _WoasTrack(
            width: trackWidth,
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: (v) =>
                onChanged(_roundToPlaces(v.clamp(min, max), decimalPlaces)),
          ),
        ],
      ),
    );
  }
}

class _WoasTrack extends StatelessWidget {
  const _WoasTrack({
    required this.width,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double width;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  void _fromLocal(double dx) {
    final t = (dx / width).clamp(0.0, 1.0);
    onChanged(min + t * (max - min));
  }

  @override
  Widget build(BuildContext context) {
    final t = max == min ? 0.0 : (value - min) / (max - min);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _fromLocal(d.localPosition.dx),
      onHorizontalDragUpdate: (d) => _fromLocal(d.localPosition.dx),
      child: SizedBox(
        width: width,
        height: 28,
        child: CustomPaint(
          painter: _TrackPainter(t: t),
        ),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final track = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), track);
    final cx = t * size.width;
    canvas.drawCircle(
      Offset(cx, y),
      11,
      Paint()..color = const Color(0xFF6BA3D9),
    );
    canvas.drawCircle(
      Offset(cx, y),
      11,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _TrackPainter oldDelegate) => oldDelegate.t != t;
}

class _ArrowChip extends StatelessWidget {
  const _ArrowChip({
    super.key,
    required this.left,
    required this.onTap,
  });

  final bool left;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: const Size(28, 28),
        painter: _ArrowChipPainter(left: left),
      ),
    );
  }
}

class _ArrowChipPainter extends CustomPainter {
  _ArrowChipPainter({required this.left});
  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(5),
    );
    canvas.drawRRect(r, Paint()..color = const Color(0xFF6BA3D9));
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final path = Path();
    if (left) {
      path.moveTo(size.width * 0.65, size.height * 0.25);
      path.lineTo(size.width * 0.35, size.height * 0.5);
      path.lineTo(size.width * 0.65, size.height * 0.75);
    } else {
      path.moveTo(size.width * 0.35, size.height * 0.25);
      path.lineTo(size.width * 0.65, size.height * 0.5);
      path.lineTo(size.width * 0.35, size.height * 0.75);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ArrowChipPainter oldDelegate) =>
      oldDelegate.left != left;
}
