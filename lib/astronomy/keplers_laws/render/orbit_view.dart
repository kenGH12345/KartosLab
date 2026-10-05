import 'dart:math' as math;
import 'dart:ui';

import '../model/elliptical_orbit_engine.dart';
import '../model/kl_vec.dart';
import 'orbit_render_data.dart';

/// Model point on the current ellipse at true anomaly [nu].
KlVec orbitModelPoint(OrbitRenderData data, double nu) {
  return EllipticalOrbitEngine.staticCreatePolar(data.a, data.e, nu, data.w);
}

Offset orbitViewPoint(OrbitRenderData data, double nu) {
  return data.mvt.toView(orbitModelPoint(data, nu));
}

/// Geometric centre of the ellipse in model space (sun at origin / a focus).
KlVec orbitGeoCenter(OrbitRenderData data) =>
    KlVec(-data.c, 0).rotated(data.w);

Path orbitEllipsePath(OrbitRenderData data, {int samples = 180}) {
  final path = Path();
  for (var i = 0; i <= samples; i++) {
    final nu = 2 * math.pi * i / samples;
    final v = orbitViewPoint(data, nu);
    if (i == 0) {
      path.moveTo(v.dx, v.dy);
    } else {
      path.lineTo(v.dx, v.dy);
    }
  }
  path.close();
  return path;
}

/// Sample an elliptical arc in true anomaly, including endpoints.
void addTrueAnomalyArc(
  Path path,
  OrbitRenderData data,
  double nu0,
  double nu1, {
  required bool retrograde,
  int samples = 48,
}) {
  var span = nu1 - nu0;
  if (retrograde) {
    while (span > 0) {
      span -= 2 * math.pi;
    }
    while (span < -2 * math.pi) {
      span += 2 * math.pi;
    }
  } else {
    while (span < 0) {
      span += 2 * math.pi;
    }
    while (span > 2 * math.pi) {
      span -= 2 * math.pi;
    }
  }
  for (var i = 0; i <= samples; i++) {
    final nu = nu0 + span * i / samples;
    final v = orbitViewPoint(data, nu);
    path.lineTo(v.dx, v.dy);
  }
}
