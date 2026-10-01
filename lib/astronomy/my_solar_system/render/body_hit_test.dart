/// Body / velocity-handle hit tests in a single MVT chain.
library;

import 'dart:ui';

import '../model/celestial_body.dart';
import '../my_solar_system_constants.dart';
import 'mss_mvt.dart';
import 'velocity_vector.dart';

/// Visual radius used by [BodiesPainter] (clamped so tiny masses stay hittable).
double bodyViewRadius(double radiusAu, MssMvt mvt) {
  return mvt.toViewDelta(radiusAu).clamp(
        MySolarSystemConstants.bodyViewRadiusMin,
        MySolarSystemConstants.bodyViewRadiusMax,
      );
}

/// Last active body whose disk contains [localView] (topmost / higher index).
int? hitTestBody({
  required Offset localView,
  required List<CelestialBody> bodies,
  required MssMvt mvt,
  double dilation = MySolarSystemConstants.bodyHitDilation,
}) {
  int? hit;
  for (var i = 0; i < bodies.length; i++) {
    final body = bodies[i];
    if (!body.isActive) continue;
    final center = mvt.toView(body.position);
    final r = bodyViewRadius(body.radius, mvt) + dilation;
    final dx = localView.dx - center.dx;
    final dy = localView.dy - center.dy;
    if (dx * dx + dy * dy <= r * r) {
      hit = i;
    }
  }
  return hit;
}

/// Last active body whose velocity grab handle contains [localView].
int? hitTestVelocityHandle({
  required Offset localView,
  required List<CelestialBody> bodies,
  required MssMvt mvt,
  double grabRadius = MySolarSystemConstants.velocityGrabRadius,
}) {
  int? hit;
  for (var i = 0; i < bodies.length; i++) {
    final body = bodies[i];
    if (!body.isActive) continue;
    final tip = mvt.toView(velocityTipModel(body.position, body.velocity));
    final dx = localView.dx - tip.dx;
    final dy = localView.dy - tip.dy;
    if (dx * dx + dy * dy <= grabRadius * grabRadius) {
      hit = i;
    }
  }
  return hit;
}
