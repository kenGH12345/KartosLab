import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/astronomy/keplers_laws/controller/keplers_laws_controller.dart';
import 'package:kratos/astronomy/keplers_laws/keplers_laws_constants.dart';
import 'package:kratos/astronomy/keplers_laws/model/elliptical_orbit_engine.dart';
import 'package:kratos/astronomy/keplers_laws/model/kl_vec.dart';
import 'package:kratos/astronomy/keplers_laws/model/law_mode.dart';
import 'package:kratos/astronomy/keplers_laws/model/orbit_body.dart';
import 'package:kratos/astronomy/keplers_laws/model/orbit_types.dart';
import 'package:kratos/astronomy/keplers_laws/model/period_tracker.dart';
import 'package:kratos/astronomy/keplers_laws/painters/swept_area_painter.dart';

void main() {
  OrbitBody sun() => OrbitBody(
        index: 1,
        mass: KeplersLawsConstants.massOfOurSun,
        position: KlVec.zero,
        velocity: KlVec.zero,
      );

  OrbitBody planet({KlVec? p, KlVec? v}) => OrbitBody(
        index: 2,
        mass: KeplersLawsConstants.planetMass,
        position: p ??
            const KlVec(
              KeplersLawsConstants.defaultPlanetX,
              KeplersLawsConstants.defaultPlanetY,
            ),
        velocity: v ??
            const KlVec(
              KeplersLawsConstants.defaultPlanetVx,
              KeplersLawsConstants.defaultPlanetVy,
            ),
      );

  EllipticalOrbitEngine engineOf(OrbitBody s, OrbitBody p) {
    final e = EllipticalOrbitEngine(sun: s, planet: p);
    e.refreshMu();
    e.update();
    return e;
  }

  test('default bodies produce a stable ellipse', () {
    final e = engineOf(sun(), planet());
    expect(e.allowedOrbit, isTrue);
    expect(e.orbitType, OrbitType.stable);
    expect(e.a, greaterThan(0));
    expect(e.e, greaterThan(0));
    expect(e.e, lessThan(1));
    expect(e.T, greaterThan(0));
    // vis viva a = r μ / (2μ − r v²)
    final r = 2.0;
    final v = 17.2358;
    final mu = e.mu;
    final expectedA = r * mu / (2 * mu - r * v * v);
    expect(e.a, closeTo(expectedA, 1e-6));
  });

  test('thirdLaw uses INITIAL_MU / mu; solar mass is near INITIAL_MU', () {
    final e = engineOf(sun(), planet());
    expect(e.mu, closeTo(KeplersLawsConstants.initialG * 200, 1e-9));
    // [已确认] T = (a³ · INITIAL_MU / μ)^{1/2} — μ = G·M 与 INITIAL_MU 差 ~0.002
    final expected = math
        .pow(
          e.a * e.a * e.a * KeplersLawsConstants.initialMu / e.mu,
          0.5,
        )
        .toDouble();
    expect(e.thirdLaw(e.a), closeTo(expected, 1e-12));
    expect(e.T, closeTo(expected, 1e-9));
  });

  test('calculateR polar ellipse equation', () {
    expect(
      EllipticalOrbitEngine.calculateR(2, 0.5, 0),
      closeTo(2 * (1 - 0.25) / (1 + 0.5), 1e-12),
    );
  });

  test('crash when periapsis inside sun radius', () {
    final s = sun();
    // Very close, low speed → small periapsis
    final p = planet(p: const KlVec(0.05, 0), v: const KlVec(0, 1));
    final e = engineOf(s, p);
    expect(e.orbitType, OrbitType.crash);
    expect(e.allowedOrbit, isFalse);
  });

  test('escape when speed at/above escape · ε', () {
    final s = sun();
    const r = 2.0;
    final p0 = planet(p: const KlVec(r, 0), v: const KlVec(0, 17.2358));
    final e0 = engineOf(s, p0);
    final vesc = e0.escapeSpeed;
    final p = planet(p: const KlVec(r, 0), v: KlVec(0, vesc / 0.99));
    final e = engineOf(s, p);
    expect(e.orbitType, OrbitType.escape);
    expect(e.allowedOrbit, isFalse);
    expect(e.eccentricityDisplay, 1);
  });

  test('always circular sets perpendicular velocity', () {
    final e = engineOf(sun(), planet());
    e.alwaysCircles = true;
    e.update();
    expect(e.eccentricityDisplay, 0);
    final r = e.planet.position;
    final v = e.planet.velocity;
    expect(r.dot(v).abs(), lessThan(1e-4));
  });

  test('run advances mean anomaly and stays bound', () {
    final e = engineOf(sun(), planet());
    final nu0 = e.nu;
    e.run(0.05);
    expect(e.planet.position.magnitude, greaterThan(0));
    expect(e.nu, isNot(nu0));
  });

  test('Controller reset restores default planet', () {
    final c = KeplersLawsController(initialLaw: LawMode.first);
    c.setPlanetPosition(const KlVec(1.2, 0.4));
    c.reset();
    expect(c.planet.position.x, KeplersLawsConstants.defaultPlanetX);
    expect(c.planet.velocity.y, KeplersLawsConstants.defaultPlanetVy);
    expect(c.timeYears, 0);
    expect(c.isPlaying, isFalse);
    expect(c.selectedLaw, LawMode.first);
  });

  test('Controller restart restores last committed state not defaults', () {
    final c = KeplersLawsController(initialLaw: LawMode.first);
    c.beginUserPosition();
    c.setPlanetPosition(const KlVec(1.5, 0));
    c.endUserPosition();
    c.stepOnce(0.01);
    c.restart();
    expect(c.planet.position.x, closeTo(1.5, 1e-6));
    expect(c.timeYears, 0);
    expect(c.isPlaying, isFalse);
  });

  test('play refused on crash orbit', () {
    final c = KeplersLawsController(initialLaw: LawMode.first);
    c.setPlanetPosition(const KlVec(0.05, 0));
    c.setPlanetVelocity(const KlVec(0, 1));
    c.setPlaying(true);
    expect(c.isPlaying, isFalse);
    expect(c.engine.allowedOrbit, isFalse);
  });

  test('correctPowersSelected is T² and a³', () {
    final c = KeplersLawsController(initialLaw: LawMode.third);
    expect(c.correctPowersSelected, isFalse);
    c.setAxisPower(3);
    c.setPeriodPower(2);
    expect(c.correctPowersSelected, isTrue);
  });

  test('star mass snap to Our Sun', () {
    final c = KeplersLawsController(initialLaw: LawMode.third);
    c.setSunMass(200 * 1.04);
    expect(c.sun.mass, KeplersLawsConstants.massOfOurSun);
    c.setSunMass(300);
    expect(c.sun.mass, closeTo(300, 1e-9));
  });

  test('period divisions clamp 2–6', () {
    final c = KeplersLawsController(initialLaw: LawMode.second);
    c.setPeriodDivisions(9);
    expect(c.periodDivisions, 6);
    c.setPeriodDivisions(1);
    expect(c.periodDivisions, 2);
  });

  test('All Laws can switch selected law', () {
    final c = KeplersLawsController(
      initialLaw: LawMode.first,
      isAllLaws: true,
    );
    c.selectLaw(LawMode.second);
    expect(c.selectedLaw, LawMode.second);
    expect(c.isSecondLaw, isTrue);
  });

  test('VELOCITY_TO_VIEW_MULTIPLIER matches SolarSystemCommonConstants', () {
    expect(
      KeplersLawsConstants.velocityToViewMultiplier,
      closeTo(0.049973129676186556, 1e-12),
    );
  });

  test('reset snaps zoom to max without leaving zoomLevel=1', () {
    final c = KeplersLawsController(initialLaw: LawMode.first);
    c.setZoomLevel(1);
    expect(c.targetZoomScale, KeplersLawsConstants.zoomScaleMin);
    c.reset();
    expect(c.zoomLevel, KeplersLawsConstants.zoomLevelDefault);
    expect(c.zoomScale, KeplersLawsConstants.zoomScaleMax);
  });

  test('period tracker fade completes in 3 wall-clock seconds', () {
    final c = KeplersLawsController(initialLaw: LawMode.third);
    c.setPeriodTracking(true);
    expect(c.periodTracker.trackingState, TrackingState.running);
    c.periodTracker.trackingState = TrackingState.fading;
    c.periodTracker.fadingTime = 0;
    c.tick(1.0);
    expect(c.periodTracker.trackingState, TrackingState.fading);
    c.tick(2.5);
    expect(c.periodTracker.trackingState, TrackingState.idle);
  });

  test('alwaysCircular is independent of velocity min clamp', () {
    final c = KeplersLawsController(initialLaw: LawMode.first);
    c.setAlwaysCircular(true);
    expect(c.alwaysCircular, isTrue);
    expect(c.engine.alwaysCircles, isTrue);
    expect(c.engine.eccentricityDisplay, 0);
  });

  test('restart is not reset: zoom stays user value', () {
    final c = KeplersLawsController(initialLaw: LawMode.first);
    c.setZoomLevel(1);
    c.zoomScale = KeplersLawsConstants.zoomScaleMin;
    c.restart();
    expect(c.zoomLevel, 1);
    expect(c.zoomScale, KeplersLawsConstants.zoomScaleMin);
  });

  test('area sweep is always clockwise (kite anticlockwise=false)', () {
    const tau = 2 * math.pi;
    expect(SweptAreaPainter.clockwiseSweep(0, 0.5), closeTo(0.5, 1e-12));
    expect(SweptAreaPainter.clockwiseSweep(0.5, 0.1), closeTo(tau - 0.4, 1e-12));
    expect(SweptAreaPainter.clockwiseSweep(0, 0), closeTo(0, 1e-12));
    expect(
      SweptAreaPainter.clockwiseSweep(0, -0.1),
      closeTo(tau - 0.1, 1e-12),
    );
  });
}
