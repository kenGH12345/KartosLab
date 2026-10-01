import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/light_ray.dart';
import '../model/sensors.dart';
import '../model/wave_chart.dart';
import '../model/wave_particle.dart';
import '../transform/bl_mvt.dart';

/// Sine ribbon from [waveOffsetAt]. Repaint with [IntroModel.waveFrame] only.
class WaveFrontPainter extends CustomPainter {
  WaveFrontPainter({required this.mvt, required this.rays});

  final BlMvt mvt;
  final List<LightRay> rays;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final ray in rays) {
      final length = ray.getLength();
      if (length <= 0) continue;
      final unit = ray.getUnitVector();
      final path = Path();
      const steps = 48;
      for (var i = 0; i <= steps; i++) {
        final d = length * i / steps;
        final base = ray.tail + unit * d;
        final p = mvt.worldToScreen(base + waveOffsetAt(ray, d));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      final color = Color(ray.colorArgb);
      canvas.drawPath(path, paint..color = color.withValues(alpha: 0.9));
    }
  }

  @override
  bool shouldRepaint(covariant WaveFrontPainter oldDelegate) => true;
}

/// Dots from [waveParticlesFor]. Positions are model state, not a timer.
class WaveParticlePainter extends CustomPainter {
  WaveParticlePainter({required this.mvt, required this.rays});

  final BlMvt mvt;
  final List<LightRay> rays;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < rays.length; i++) {
      final particles = waveParticlesFor(rays[i], incident: i == 0 && rays[i].rayType == 'incident');
      final paint = Paint()..color = Color(rays[i].colorArgb);
      for (final particle in particles) {
        final p = mvt.worldToScreen(particle.position);
        canvas.drawCircle(p, 2.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WaveParticlePainter oldDelegate) => true;
}

/// ChartNode window: x = [time-72e-16, time], y = [-1, 1].
class WaveChartPainter extends CustomPainter {
  WaveChartPainter({
    required this.readTime,
    required this.probe1,
    required this.probe2,
  });

  final double Function() readTime;
  final List<DataPoint> probe1;
  final List<DataPoint> probe2;

  @override
  void paint(Canvas canvas, Size size) {
    final time = readTime();
    final bounds = Offset.zero & size;
    canvas.clipRect(bounds);
    final minT = WaveChartWindow.minTime(time);
    final span = WaveChartWindow.timeWidth;
    final grid = Paint()
      ..color = const Color(0xFFD3D3D3)
      ..strokeWidth = 2;
    final spacing = WaveChartWindow.verticalSpacing();
    final phase = WaveChartWindow.gridPhase(time);
    for (var x = minT - phase + spacing; x <= minT + span + 1e-30; x += spacing) {
      final sx = (x - minT) / span * size.width;
      if (sx < -1 || sx > size.width + 1) continue;
      _dashed(canvas, Offset(sx, 0), Offset(sx, size.height), grid, dashOn: 10, dashOff: 5);
    }
    final midY = size.height / 2;
    _dashed(canvas, Offset(0, midY), Offset(size.width, midY), grid, dashOn: 10, dashOff: 5);
    _series(canvas, size, minT, span, probe1, const Color(0xFF5C5D5F));
    _series(canvas, size, minT, span, probe2, const Color(0xFFCCCED0));
  }

  void _series(Canvas canvas, Size size, double minT, double span, List<DataPoint> series, Color color) {
    final path = Path();
    var started = false;
    for (final p in series) {
      if (p.time < minT || p.time > minT + span) continue;
      final x = (p.time - minT) / span * size.width;
      final yNorm = ((p.magnitude - WaveChartWindow.yMin) /
              (WaveChartWindow.yMax - WaveChartWindow.yMin))
          .clamp(0.0, 1.0);
      final y = size.height - yNorm * size.height;
      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
      }
    }
    if (!started) return;
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint, {double dashOn = 10, double dashOff = 5}) {
    final delta = b - a;
    final len = delta.distance;
    if (len == 0) return;
    final dir = delta / len;
    var d = 0.0;
    while (d < len) {
      final s = a + dir * d;
      final e = a + dir * math.min(d + dashOn, len);
      canvas.drawLine(s, e, paint);
      d += dashOn + dashOff;
    }
  }

  @override
  bool shouldRepaint(covariant WaveChartPainter oldDelegate) => true;
}

/// `WaveSensorNode` body, painted in the already-scaled widget box.
///
/// Source order: outer gradient rectangle, inner blue rectangle, white plot.
/// The waveform is not painted here.
class WaveSensorBodyPainter extends CustomPainter {
  const WaveSensorBodyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 135;
    final sy = size.height / 100;
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(5 * sx),
    );
    final fillShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF5EB4DE), Color(0xFF005B86)],
    ).createShader(Offset.zero & size);
    canvas.drawRRect(outer, Paint()..shader = fillShader);
    final strokeShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF2F9BCE), Color(0xFF00486A)],
    ).createShader(Offset.zero & size);
    canvas.drawRRect(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * sx
        ..shader = strokeShader,
    );

    final inner = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 130 * sx,
      height: 90 * sy,
    );
    canvas.drawRect(inner, Paint()..color = const Color(0xFF0078B0));
    canvas.drawRect(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF0081BE),
    );

    final plot = Rect.fromCenter(
      center: Offset(67.5 * sx, 40 * sy),
      width: 122.3 * sx,
      height: 63 * sy,
    );
    paintShadedRectangle(
      canvas,
      RRect.fromRectAndRadius(plot, Radius.circular(5 * sx)),
      base: const Color(0xFFFFFFFF),
      lightSourceRight: true,
      lightSourceBottom: true,
    );
  }

  @override
  bool shouldRepaint(covariant WaveSensorBodyPainter oldDelegate) => false;
}

/// `ShadedRectangle` luminance. Positive factors move toward white, negative toward black.
/// White base with a positive factor stays white. Negative factors are the visible highlight.
Color graphHighlightLuminance(Color base, double factor) {
  if (factor >= 0) {
    return Color.lerp(base, const Color(0xFFFFFFFF), factor.clamp(0.0, 1.0))!;
  }
  return Color.lerp(base, const Color(0xFF000000), (-factor).clamp(0.0, 1.0))!;
}

/// `ShadedRectangle` with `lightSource: rightBottom`, `cornerRadius` 5,
/// `lightOffset` 0.525, `darkOffset` 0.375, default light/dark factors.
///
/// Not a flat `Colors.white` fill. Top and left are darker than [base].
void paintShadedRectangle(
  Canvas canvas,
  RRect rrect, {
  required Color base,
  required bool lightSourceRight,
  required bool lightSourceBottom,
}) {
  final rect = rrect.outerRect;
  if (rect.width <= 0 || rect.height <= 0) return;
  final corner = rrect.tlRadiusX;
  final lightOffset = 0.525 * corner;
  final darkOffset = 0.375 * corner;
  final lightFromLeft = !lightSourceRight;
  final lightFromTop = !lightSourceBottom;

  final lighter = graphHighlightLuminance(base, 0.6);
  final light = graphHighlightLuminance(base, 0.5);
  final dark = graphHighlightLuminance(base, -0.5);
  final darker = graphHighlightLuminance(base, -0.6);

  final topColor = lightFromTop ? lighter : darker;
  final leftColor = lightFromLeft ? light : dark;
  final rightColor = lightFromLeft ? dark : light;
  final bottomColor = lightFromTop ? darker : lighter;

  final topOffset = lightFromTop ? lightOffset : darkOffset;
  final leftOffset = lightFromLeft ? lightOffset : darkOffset;
  final rightOffset = lightFromLeft ? darkOffset : lightOffset;
  final bottomOffset = lightFromTop ? darkOffset : lightOffset;

  double stop(double offset, double span) {
    if (span <= 0) return 0;
    return (offset / span).clamp(0.0, 1.0);
  }

  canvas.save();
  canvas.clipRRect(rrect);
  canvas.drawRect(rect, Paint()..color = base);

  final leftStop = stop(leftOffset, rect.width);
  final rightStop = (1 - stop(rightOffset, rect.width)).clamp(leftStop, 1.0);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = LinearGradient(
        colors: [leftColor, base, base, rightColor],
        stops: [0, leftStop, rightStop, 1],
      ).createShader(rect),
  );

  final topStop = stop(topOffset, rect.height);
  final bottomStop = (1 - stop(bottomOffset, rect.height)).clamp(topStop, 1.0);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          topColor,
          topColor.withValues(alpha: 0),
          bottomColor.withValues(alpha: 0),
          bottomColor,
        ],
        stops: [0, topStop, bottomStop, 1],
      ).createShader(rect),
  );
  canvas.restore();
}
