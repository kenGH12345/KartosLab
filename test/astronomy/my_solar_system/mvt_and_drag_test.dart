import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/my_solar_system/controller/my_solar_system_controller.dart';
import 'package:kratos/astronomy/my_solar_system/model/celestial_body.dart';
import 'package:kratos/astronomy/my_solar_system/model/mss_vec.dart';
import 'package:kratos/astronomy/my_solar_system/my_solar_system_constants.dart';
import 'package:kratos/astronomy/my_solar_system/render/body_hit_test.dart';
import 'package:kratos/astronomy/my_solar_system/render/constrain_drag_point.dart';
import 'package:kratos/astronomy/my_solar_system/render/mss_mvt.dart';
import 'package:kratos/astronomy/my_solar_system/render/velocity_vector.dart';

void main() {
  const mvt = MssMvt(center: Offset(400, 300), scale: 85);

  test('toView / toModel round-trip (Y-up)', () {
    final sample = MssVec(2, 1.5);
    final view = mvt.toView(sample);
    final back = mvt.toModel(view);
    expect(back.x, closeTo(sample.x, 1e-9));
    expect(back.y, closeTo(sample.y, 1e-9));
    expect(view.dx, closeTo(400 + 2 * 85, 1e-9));
    expect(view.dy, closeTo(300 - 1.5 * 85, 1e-9));
  });

  test('toViewDelta / toModelDelta inverse', () {
    expect(mvt.toModelDelta(mvt.toViewDelta(0.15)), closeTo(0.15, 1e-12));
  });

  test('constrainDragPoint keeps point inside canvas model rect', () {
    final inside = constrainDragPoint(
      modelPoint: MssVec(0, 0),
      canvasSize: const Size(800, 600),
      mvt: mvt,
    );
    expect(inside.x, closeTo(0, 1e-9));
    expect(inside.y, closeTo(0, 1e-9));

    final far = constrainDragPoint(
      modelPoint: MssVec(100, 100),
      canvasSize: const Size(800, 600),
      mvt: mvt,
    );
    final maxModel = mvt.toModel(const Offset(800, 0));
    expect(far.x, lessThanOrEqualTo(maxModel.x + 1e-9));
    expect(far.y, lessThanOrEqualTo(maxModel.y + 1e-9));
  });

  test('body hit test uses visual radius + dilation', () {
    final sun = CelestialBody(
      index: 1,
      mass: 250,
      position: MssVec(0, 0),
      velocity: MssVec.zero(),
      color: const Color(0xFFFFFF00),
    );
    final planet = CelestialBody(
      index: 2,
      mass: 25,
      position: MssVec(2, 0),
      velocity: MssVec(0, 23.4457),
      color: const Color(0xFFFF00FF),
    );
    final bodies = [sun, planet];
    final sunView = mvt.toView(sun.position);
    expect(
      hitTestBody(localView: sunView, bodies: bodies, mvt: mvt),
      0,
    );
    expect(
      hitTestBody(
        localView: const Offset(0, 0),
        bodies: bodies,
        mvt: mvt,
      ),
      isNull,
    );
    final planetView = mvt.toView(planet.position);
    expect(
      hitTestBody(localView: planetView, bodies: bodies, mvt: mvt),
      1,
    );
  });

  test('velocity tip conversion is invertible and scales with zoom via MVT', () {
    final pos = MssVec(2, 0);
    final vel = MssVec(0, 23.4457);
    final tip = velocityTipModel(pos, vel);
    final back = velocityFromTip(pos, tip);
    expect(back.x, closeTo(vel.x, 1e-9));
    expect(back.y, closeTo(vel.y, 1e-9));

    final viewLenDefault = (mvt.toView(tip) - mvt.toView(pos)).distance;
    const zoomed = MssMvt(center: Offset(400, 300), scale: 125);
    final viewLenZoomed = (zoomed.toView(tip) - zoomed.toView(pos)).distance;
    expect(viewLenZoomed / viewLenDefault, closeTo(125 / 85, 1e-9));
    expect(
      MySolarSystemConstants.velocityToViewMultiplier,
      closeTo(50 * 0.01 / MySolarSystemConstants.velocityMultiplier, 1e-12),
    );
  });

  test('constrainVelocityMagnitude enforces Kepler二次 min', () {
    final tiny = constrainVelocityMagnitude(MssVec(0.01, 0));
    expect(tiny.magnitude, closeTo(MySolarSystemConstants.velocityMinMagnitude, 1e-9));
  });

  test('drag position/velocity pauses and pointer-up does not resume', () {
    final c = MySolarSystemController(isLab: false);
    c.play();
    expect(c.isPlaying, isTrue);
    c.beginBodyPositionDrag(1);
    expect(c.isPlaying, isFalse);
    c.endBodyDrag();
    expect(c.isPlaying, isFalse);

    c.play();
    c.beginBodyVelocityDrag(1);
    expect(c.isPlaying, isFalse);
    c.endBodyDrag();
    expect(c.isPlaying, isFalse);
  });

  test('velocity drag writes Body.velocity', () {
    final c = MySolarSystemController(isLab: false);
    final pos = c.bodies[1].position;
    final tip = velocityTipModel(pos, MssVec(0, 10));
    final viewTip = mvt.toView(tip);
    c.updateBodyVelocityFromViewTip(1, viewTip, mvt: mvt);
    expect(c.bodies[1].velocity.x, closeTo(0, 1e-6));
    expect(c.bodies[1].velocity.y, closeTo(10, 1e-6));
  });
}
