import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../keplers_laws_colors.dart';
import '../keplers_motion.dart';
import '../model/elliptical_orbit_engine.dart';
import '../model/law_mode.dart';

/// PhET `KeplersLawsScreenIcon` ellipse (a=20, b=17).
const double _a = 20;
const double _b = 17;
final double _c = math.sqrt(_a * _a - _b * _b);

/// [已确认] LawsRadioButtonGroup.ts — First/Second/ThirdLawScreenIcon.createFullNode × 1.5
/// selectedStroke `#60a9dd` 4px, deselected 2px
class KeplersLawsRadioRow extends StatelessWidget {
  const KeplersLawsRadioRow({super.key, required this.selected, required this.onSelect});

  final LawMode selected;
  final ValueChanged<LawMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final mode in LawMode.values) ...[
          if (mode != LawMode.first) const SizedBox(width: 6),
          _LawThumb(
            mode: mode,
            selected: selected == mode,
            onTap: () => onSelect(mode),
          ),
        ],
      ],
    );
  }
}

class _LawThumb extends StatelessWidget {
  const _LawThumb({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final LawMode mode;
  final bool selected;
  final VoidCallback onTap;

  static const Color _stroke = Color(0xFF60A9DD);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: KeplersMotion.duration,
      curve: KeplersMotion.curve,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _stroke, width: selected ? 4 : 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CustomPaint(
              size: const Size(72, 52),
              painter: _LawIconPainter(mode: mode),
            ),
          ),
        ),
      ),
    );
  }
}

class _LawIconPainter extends CustomPainter {
  _LawIconPainter({required this.mode});

  final LawMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(1.5, 1.5);

    switch (mode) {
      case LawMode.first:
        _ellipse(canvas);
        _sun(canvas);
        _firstLaw(canvas);
      case LawMode.second:
        _secondAreas(canvas);
        _ellipse(canvas);
        _sun(canvas);
        _secondPlanet(canvas);
      case LawMode.third:
        _ellipse(canvas);
        _sun(canvas);
        _thirdLaw(canvas);
    }
    canvas.restore();
  }

  void _ellipse(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: _a * 2, height: _b * 2),
      Paint()
        ..color = KeplersLawsColors.orbit
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _sun(Canvas canvas) {
    _sphere(canvas, Offset(-_c, 0), 4, KeplersLawsColors.sun);
  }

  void _firstLaw(Canvas canvas) {
    _xMark(canvas, Offset(-_c, 0));
    _xMark(canvas, Offset(_c, 0));
    _sphere(canvas, Offset(_a, 0), 1.5, KeplersLawsColors.planet);
  }

  void _secondAreas(Canvas canvas) {
    const angles = [2.807, 1.877, 0.0, -1.877, 3.475];
    for (var i = 1; i < angles.length; i++) {
      var start = angles[i];
      var end = i + 1 == angles.length ? angles[0] : angles[i + 1];
      start = math.pi - start;
      end = math.pi - end;
      final opacity = (angles.length - i + 1) / (angles.length + 1);
      var sweep = end - start;
      sweep %= 2 * math.pi;
      if (sweep < 0) sweep += 2 * math.pi;
      final path = Path()
        ..moveTo(-_c, 0)
        ..arcTo(
          Rect.fromCenter(center: Offset.zero, width: _a * 2, height: _b * 2),
          start,
          sweep,
          false,
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = KeplersLawsColors.planet.withValues(alpha: opacity),
      );
    }
  }

  void _secondPlanet(Canvas canvas) {
    const angles = [2.807, 1.877, 0.0, -1.877, 3.475];
    final e = _c / _a;
    final p = EllipticalOrbitEngine.staticCreatePolar(
      _a,
      e,
      angles[angles.length - 2] * 0.98,
    );
    _sphere(
      canvas,
      Offset(p.x + _c, -p.y),
      1.5,
      KeplersLawsColors.planet,
    );
  }

  void _thirdLaw(Canvas canvas) {
    canvas.drawLine(
      Offset.zero,
      Offset(_a, 0),
      Paint()
        ..color = KeplersLawsColors.semiMajorAxis
        ..strokeWidth = 1,
    );
    canvas.save();
    canvas.translate(5, -15);
    canvas.scale(0.5, 0.5);
    const tw = 50.0;
    const th = 20.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, tw, th),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFFFE75E),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, tw, th),
        const Radius.circular(5),
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    const sw = 40.0;
    const sh = 15.0;
    const sx = (tw - sw) / 2;
    const sy = (th - sh) / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(sx, sy, sw, sh),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(sx, sy, sw, sh),
        const Radius.circular(3),
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '0:00',
        style: TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((tw - tp.width) / 2, (th - tp.height) / 2));
    canvas.restore();
    _sphere(canvas, Offset(_a, 0), 1.5, KeplersLawsColors.planet);
  }

  void _sphere(Canvas canvas, Offset c, double r, Color color) {
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Color.lerp(color, Colors.white, 0.45)!,
            color,
            Color.lerp(color, Colors.black, 0.35)!,
          ],
        ).createShader(rect),
    );
  }

  void _xMark(Canvas canvas, Offset c) {
    final p = Paint()
      ..color = KeplersLawsColors.foci
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    const s = 2.6;
    canvas.drawLine(c + const Offset(-s, -s), c + const Offset(s, s), p);
    canvas.drawLine(c + const Offset(-s, s), c + const Offset(s, -s), p);
  }

  @override
  bool shouldRepaint(covariant _LawIconPainter old) => old.mode != mode;
}
