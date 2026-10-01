import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/my_solar_system/config/mss_scenario.dart';
import 'package:kratos/astronomy/my_solar_system/config/simulation_config.dart';
import 'package:kratos/astronomy/my_solar_system/controller/my_solar_system_controller.dart';
import 'package:kratos/astronomy/my_solar_system/model/celestial_body.dart';
import 'package:kratos/astronomy/my_solar_system/model/center_of_mass.dart';
import 'package:kratos/astronomy/my_solar_system/model/mss_vec.dart';
import 'package:kratos/astronomy/my_solar_system/my_solar_system_constants.dart';
import 'package:kratos/astronomy/my_solar_system/render/mss_format.dart';
import 'package:kratos/astronomy/my_solar_system/render/mss_mvt.dart';
import 'package:kratos/astronomy/my_solar_system/solver/numerical_engine.dart';

void main() {
  test('Center of Mass matches Σ(m r)/M', () {
    final bodies = [
      CelestialBody(
        index: 1,
        mass: 3,
        position: MssVec(0, 0),
        velocity: MssVec(1, 0),
        color: const Color(0xFFFFFF00),
      ),
      CelestialBody(
        index: 2,
        mass: 1,
        position: MssVec(4, 0),
        velocity: MssVec(0, 8),
        color: const Color(0xFFFF00FF),
      ),
    ];
    final com = CenterOfMassState.fromBodies(bodies);
    expect(com.position.x, closeTo(1, 1e-12));
    expect(com.position.y, closeTo(0, 1e-12));
    expect(com.velocity.x, closeTo(0.75, 1e-12));
    expect(com.velocity.y, closeTo(2, 1e-12));
  });

  test('Follow CoM thresholds [MSS-SOURCE]', () {
    final c = MySolarSystemController(isLab: false);
    c.bodies[0].position.setXY(0, 0);
    c.bodies[0].velocity.setXY(0, 0);
    // |r_com| = 25*20/275 ≈ 1.82 ≥ 1 → not following
    c.bodies[1].position.setXY(20, 0);
    c.bodies[1].velocity.setXY(0, 0);
    expect(c.isFollowingCenterOfMass, isFalse);
    expect(c.showFollowCenterOfMassButton, isTrue);
    c.followAndCenterCenterOfMass();
    expect(c.centerOfMass.position.magnitude, lessThan(1e-9));
    expect(c.isFollowingCenterOfMass, isTrue);
  });

  test('Gravity force direction and magnitude; scale uses force', () {
    final a = CelestialBody(
      index: 1,
      mass: 1,
      position: MssVec(0, 0),
      velocity: MssVec.zero(),
      color: const Color(0xFFFFFF00),
    );
    final b = CelestialBody(
      index: 2,
      mass: 2,
      position: MssVec(2, 0),
      velocity: MssVec.zero(),
      color: const Color(0xFFFF00FF),
    );
    final engine = NumericalEngine([a, b]);
    engine.updateForces();
    expect(a.gravityForce.x, greaterThan(0));
    expect(a.gravityForce.y, closeTo(0, 1e-12));
    final expectedMag = MySolarSystemConstants.G * 1 * 2 / 4;
    expect(a.gravityForce.magnitude, closeTo(expectedMag, 1e-12));
    final scale0 = MySolarSystemConstants.gravityArrowScale(0);
    final scaleBallet = MySolarSystemConstants.gravityArrowScale(-1.1);
    expect(scaleBallet, lessThan(scale0));
    expect(
      scale0,
      closeTo(MySolarSystemConstants.velocityToViewMultiplier * 1e-3, 1e-12),
    );
  });

  test('Zoom mapping linear 1→25 … 6→125; default 4→85', () {
    expect(MySolarSystemConstants.zoomScaleForLevel(1), 25);
    expect(MySolarSystemConstants.zoomScaleForLevel(6), 125);
    expect(MySolarSystemConstants.zoomScaleForLevel(4), 85);
    expect(SimulationConfig.instance.zoomScaleForLevel(4), 85);
  });

  test('Grid lines are world-spaced via MVT', () {
    const mvt = MssMvt(center: Offset(400, 300), scale: 85);
    final spacingView = mvt.toViewDelta(MySolarSystemConstants.gridSpacing);
    expect(spacingView, 85);
    final next = mvt.toView(MssVec(1, 0));
    expect(next.dx - mvt.center.dx, closeTo(spacingView, 1e-9));
  });

  test('Measuring tape distance |p2-p1|', () {
    final c = MySolarSystemController(isLab: false);
    expect(c.tapeDistance, closeTo(1, 1e-12));
    c.setTapeTip(MssVec(3, 5));
    expect(
      c.tapeDistance,
      closeTo(MssVec(0, 1).distance(MssVec(3, 5)), 1e-12),
    );
  });

  test('Mass clamp/step [TEMPORARY step 0.1]', () {
    expect(MySolarSystemConstants.clampMassUi(0.05), 0.1);
    expect(MySolarSystemConstants.clampMassUi(12.34), closeTo(12.3, 1e-9));
    expect(MySolarSystemConstants.clampMassUi(500), 300);
  });

  test('Position formatting uses 2 decimal places', () {
    expect(MssFormat.positionAu(2), '2.00');
    expect(MssFormat.velocityKms(-2.3446), '-2.34');
    expect(MssFormat.mass(25), '25.00');
  });

  test('Mass change does NOT pause; Lab → Custom', () {
    final c = MySolarSystemController(isLab: true);
    c.play();
    expect(c.isPlaying, isTrue);
    expect(c.currentScenarioId, 'sun_planet');
    c.setBodyMass(1, 30);
    expect(c.isPlaying, isTrue);
    expect(c.currentScenarioId, 'custom');
    expect(c.bodies[1].mass, closeTo(30, 1e-9));
  });

  test('Position / velocity edit pauses', () {
    final c = MySolarSystemController(isLab: true);
    c.play();
    c.setBodyPositionComponent(1, x: 1.5);
    expect(c.isPlaying, isFalse);
    c.play();
    c.setBodyVelocityComponent(1, vy: 20);
    expect(c.isPlaying, isFalse);
  });

  test('Four Star Ballet JSON applies gravityForceScalePower -1.1', () {
    final file = File('assets/scenarios/my-solar-system/four_star_ballet.json');
    final scenario = MssScenario.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    );
    expect(scenario.gravityForceScalePower, -1.1);
    final c = MySolarSystemController(isLab: true);
    c.loadScenario(scenario);
    expect(
      c.gravityForceScalePower,
      MySolarSystemConstants.fourStarBalletGravityScalePower,
    );
  });

  test('maxPathPoints is centralized TEMPORARY constant', () {
    expect(MySolarSystemConstants.maxPathPoints, 800);
    expect(SimulationConfig.instance.maxPathPoints, 800);
  });
}
