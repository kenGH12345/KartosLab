/// Elliptical orbit engine — faithful port of
/// `js/common/model/EllipticalOrbitEngine.ts`.
///
/// Units and variable names match the TypeScript source (a, e, nu, w, M, W).
library;

import 'dart:math' as math;

import '../keplers_laws_constants.dart';
import 'kl_vec.dart';
import 'orbit_body.dart';
import 'orbit_types.dart';
import 'orbital_area.dart';

class _Ellipse {
  const _Ellipse({
    required this.a,
    required this.b,
    required this.c,
    required this.e,
    required this.w,
    required this.m,
    required this.W,
    required this.nu,
  });

  final double a;
  final double b;
  final double c;
  final double e;
  final double w;
  final double m;
  final double W;
  final double nu;
}

class EllipticalOrbitEngine {
  EllipticalOrbitEngine({required this.sun, required this.planet}) {
    for (var i = 0; i < KeplersLawsConstants.periodDivisionsMax; i++) {
      orbitalAreas.add(OrbitalArea(i));
    }
  }

  final OrbitBody sun;
  final OrbitBody planet;

  double mu = KeplersLawsConstants.initialMu;
  bool isRunning = false;
  bool internalPropertyMutation = false;
  bool alwaysCircles = false;
  bool retrograde = false;
  bool areasErased = false;
  int periodDivisions = KeplersLawsConstants.periodDivisionsDefault;

  double a = 1;
  double b = 0;
  double c = 0;
  double e = 0;
  double w = 0;
  double M = 0;
  double W = 0;
  double T = 1;
  double nu = 0;
  double L = 0;
  double d1 = 0;
  double d2 = 0;

  bool allowedOrbit = false;
  OrbitType orbitType = OrbitType.stable;
  bool isCircular = true;
  double eccentricityDisplay = 0;
  double escapeSpeed = 0;
  double escapeRadius = 0;
  double totalArea = 1;
  double segmentArea = 1;
  int activeAreaIndex = 0;

  final List<OrbitalArea> orbitalAreas = [];

  static const double _twoPi = 2 * math.pi;
  static const double _epsilon = KeplersLawsConstants.escapeEpsilon;

  void run(double dt) {
    isRunning = true;
    internalPropertyMutation = true;

    M += dt * W;
    nu = getTrueAnomaly(M);

    var newPosition = createPolar(nu, w);
    var newVelocity = calculateOrbitalVelocity(nu, w);
    final newAngularMomentum = newPosition.cross(newVelocity);
    if (newAngularMomentum != 0) {
      newVelocity = newVelocity.times(L / newAngularMomentum);
    }

    planet.position = newPosition;
    planet.velocity = newVelocity;

    updateBodyDistances();
    updateForces(newPosition);
    calculateOrbitalDivisions();

    areasErased = false;
    isRunning = false;
    internalPropertyMutation = false;
  }

  void update() {
    refreshMu();
    resetOrbitalAreas();
    enforceValidPosition();

    final r = planet.position;
    updateForces(r);

    escapeSpeed = math.sqrt(2 * mu / r.magnitude) * _epsilon;
    final vMagForEscape = planet.velocity.magnitude;
    if (vMagForEscape > 0) {
      escapeRadius =
          2 * mu / (vMagForEscape * vMagForEscape) * _epsilon * _epsilon;
    }

    enforceValidVelocity();
    var escaped = false;
    if (alwaysCircles) {
      enforceCircularOrbit(r);
    } else {
      final currentSpeed = planet.velocity.magnitude;
      if (currentSpeed >= escapeSpeed) {
        enforceEscapeSpeed();
      }
      escaped = currentSpeed >= (escapeSpeed * _epsilon);
      if (escaped) {
        allowedOrbit = false;
        orbitType = OrbitType.escape;
        eccentricityDisplay = 1;
      }
    }

    final v = planet.velocity;
    L = r.cross(v);

    final ellipse = _calculateEllipse(r, v);
    a = ellipse.a;
    b = ellipse.b;
    c = ellipse.c;
    e = ellipse.e;
    w = ellipse.w;
    M = ellipse.m;
    W = ellipse.W;
    nu = ellipse.nu;

    T = thirdLaw(a);
    updateBodyDistances();
    totalArea = math.pi * a * b;
    segmentArea = totalArea / periodDivisions;

    if (_collidedWithSun(a, e)) {
      allowedOrbit = false;
      orbitType = OrbitType.crash;
    } else if (!escaped) {
      allowedOrbit = true;
      orbitType = OrbitType.stable;
      calculateOrbitalDivisions();
    }

    if (e != eccentricityDisplay && orbitType != OrbitType.escape) {
      if (alwaysCircles || e < 0.01) {
        eccentricityDisplay = 0;
      } else {
        eccentricityDisplay = e;
      }
      isCircular = eccentricityDisplay == 0;
    }
  }

  void updateBodyDistances() {
    final polar = createPolar(nu);
    d1 = polar.magnitude;
    d2 = 2 * a - d1;
  }

  void updateForces(KlVec position) {
    final mag = position.magnitude;
    final gravityForce = position.times(
      -mu * planet.mass / (mag * mag * mag),
    );
    planet.gravityForce = gravityForce;
    planet.acceleration = gravityForce.times(1 / planet.mass);
    sun.gravityForce = gravityForce.times(-1);
  }

  /// Kepler's Third Law. When mu == INITIAL_MU, T = a^(3/2).
  double thirdLaw(double axis) {
    return math.pow(
      axis * axis * axis * KeplersLawsConstants.initialMu / mu,
      1 / 2,
    ).toDouble();
  }

  void enforceCircularOrbit(KlVec position) {
    internalPropertyMutation = true;
    final direction = retrograde ? -1.0 : 1.0;
    planet.velocity = position.perpendicular.normalized().times(
          direction * 1.0001 * math.sqrt(mu / position.magnitude),
        );
    internalPropertyMutation = false;
  }

  void enforceEscapeSpeed() {
    internalPropertyMutation = true;
    planet.velocity = planet.velocity.normalized().times(escapeSpeed);
    internalPropertyMutation = false;
  }

  void enforceValidVelocity() {
    if (planet.velocity.magnitude == 0) return;
    if (math.sin(planet.velocity.angleBetween(planet.position)).abs() <= 1e-6) {
      planet.velocity = planet.velocity.rotated(0.01);
    }
  }

  void enforceValidPosition() {
    if (planet.position.magnitude == 0) {
      planet.position = const KlVec(0.01, 0);
    }
  }

  bool _collidedWithSun(double axis, double ecc) {
    return axis * (1 - ecc) < OrbitBody.massToRadius(sun.mass);
  }

  KlVec createPolar(double trueAnomaly, [double argPeriapsis = 0]) {
    return staticCreatePolar(a, e, trueAnomaly, argPeriapsis);
  }

  static KlVec staticCreatePolar(
    double a,
    double e,
    double nu, [
    double w = 0,
  ]) {
    return KlVec.polar(calculateR(a, e, nu), nu + w);
  }

  KlVec calculateOrbitalVelocity(double trueAnomaly, [double argPeriapsis = 0]) {
    final denom = T * math.sqrt(1 - e * e);
    final vTheta = 2 * math.pi * a * (1 + e * math.cos(trueAnomaly)) / denom;
    final vR = -2 * math.pi * a * e * math.sin(trueAnomaly) / denom;
    final pos = createPolar(trueAnomaly, argPeriapsis);
    return pos.perpendicular.normalized().times(vTheta) +
        pos.normalized().times(vR);
  }

  void calculateOrbitalDivisions() {
    var previousNu = 0.0;
    var bodyAngle = -nu;
    segmentArea = totalArea / periodDivisions;
    final angularSection = _twoPi / periodDivisions;

    for (var i = 0; i < orbitalAreas.length; i++) {
      final orbitalArea = orbitalAreas[i];
      if (i < periodDivisions && allowedOrbit) {
        final mean = (i + 1) * _twoPi / periodDivisions;
        final divisionNu = getTrueAnomaly(mean);

        var startAngle = previousNu;
        var endAngle = moduloBetweenDown(divisionNu, startAngle, startAngle + _twoPi);
        bodyAngle = moduloBetweenDown(bodyAngle, startAngle, startAngle + _twoPi);

        orbitalArea.startAngle = startAngle;
        orbitalArea.endAngle = endAngle;

        void setDefault() {
          orbitalArea.sweptArea = segmentArea;
          orbitalArea.inside = false;
        }

        if (startAngle <= bodyAngle && bodyAngle < endAngle) {
          if (isRunning) {
            orbitalArea.inside = true;
            orbitalArea.alreadyEntered = true;
            activeAreaIndex = orbitalArea.index;
            if (retrograde) {
              startAngle = bodyAngle;
            } else {
              endAngle = bodyAngle;
            }
            orbitalArea.sweptArea = _calculateSweptArea(startAngle, endAngle);
            orbitalArea.completion =
                _meanAnomalyDiff(startAngle, endAngle) / angularSection;
          } else {
            setDefault();
          }
        } else {
          setDefault();
        }

        if (!orbitalArea.alreadyEntered) {
          orbitalArea.completion = 0;
          orbitalArea.sweptArea = 0;
        }
        orbitalArea.dotPosition = createPolar(divisionNu);
        orbitalArea.startPosition = createPolar(startAngle);
        orbitalArea.endPosition = createPolar(endAngle);
        orbitalArea.active = true;
        previousNu = divisionNu;
      } else {
        orbitalArea.completion = 0;
        orbitalArea.active = false;
        orbitalArea.inside = false;
      }
    }
  }

  double _meanAnomalyDiff(double startAngle, double endAngle) {
    return moduloBetweenDown(
      getMeanAnomaly(endAngle, e) - getMeanAnomaly(startAngle, e),
      0,
      _twoPi,
    );
  }

  double _calculateSweptArea(double startAngle, double endAngle) {
    final raw = (0.5 * a * b * _meanAnomalyDiff(startAngle, endAngle)).abs();
    return raw.clamp(0, segmentArea);
  }

  /// vis viva
  double calculateA(KlVec r, KlVec v) {
    final rMag = r.magnitude;
    final vMag = v.magnitude;
    return rMag * mu / (2 * mu - rMag * vMag * vMag);
  }

  double calculateE(KlVec r, KlVec v, double axis) {
    final rMag = r.magnitude;
    final vMag = v.magnitude;
    return math.pow(
      (1 -
              math.pow(
                rMag * vMag * math.sin(v.angle - r.angle),
                2,
              ) /
                  (axis * mu))
          .abs(),
      0.5,
    ).toDouble();
  }

  List<double> calculateAngles(KlVec r, KlVec v, double axis, double ecc) {
    final rMag = r.magnitude;
    final rAngle = r.angle;
    final vAngle = v.angle;

    var trueAnomaly = rAngle;
    if (ecc > 0) {
      trueAnomaly = math.acos(
        ((1 / ecc) * (axis * (1 - ecc * ecc) / rMag - 1)).clamp(-1.0, 1.0),
      );
      if (math.cos(rAngle - vAngle) > 0) {
        trueAnomaly *= -1;
      }
    }

    var angVel = -500 / thirdLaw(axis);
    retrograde = r.cross(v) > 0;
    if (retrograde) {
      trueAnomaly *= -1;
      angVel *= -1;
    }

    final meanAnomaly = getMeanAnomaly(trueAnomaly, ecc);
    final argPeriapsis = rAngle - trueAnomaly;
    return [argPeriapsis, meanAnomaly, angVel, trueAnomaly];
  }

  _Ellipse _calculateEllipse(KlVec r, KlVec v) {
    final axis = calculateA(r, v);
    final ecc = calculateE(r, v, axis);
    final minor = axis * math.sqrt(1 - ecc * ecc);
    final focal = axis * ecc;
    final angles = calculateAngles(r, v, axis, ecc);
    return _Ellipse(
      a: axis,
      b: minor,
      c: focal,
      e: ecc,
      w: angles[0],
      m: angles[1],
      W: angles[2],
      nu: angles[3],
    );
  }

  static double calculateR(double a, double e, double nu) {
    return a * (1 - e * e) / (1 + e * math.cos(nu));
  }

  double getTrueAnomaly(double meanAnomaly) {
    var E = meanAnomaly;
    const eps = KeplersLawsConstants.keplerNrEpsilon;
    var delta = 1.0;
    var guard = 0;
    while (delta.abs() > eps && guard < 100) {
      final g = E - e * math.sin(E) - meanAnomaly;
      final gPrime = 1 - e * math.cos(E);
      delta = g / gPrime;
      E = E - delta;
      guard++;
    }
    final trueAnomaly = math.atan2(
      math.sqrt(1 - e * e) * math.sin(E),
      math.cos(E) - e,
    );
    return moduloBetweenDown(trueAnomaly, 0, _twoPi);
  }

  double getMeanAnomaly(double trueAnomaly, double ecc) {
    var E = -math.acos(
      ((ecc + math.cos(trueAnomaly)) / (1 + ecc * math.cos(trueAnomaly)))
          .clamp(-1.0, 1.0),
    );
    if (math.sin(E) * math.sin(trueAnomaly) < 0) {
      E *= -1;
    }
    return E - ecc * math.sin(E);
  }

  void resetOrbitalAreas({bool eraseAreas = false}) {
    for (final area in orbitalAreas) {
      area.reset(eraseAreas: eraseAreas);
    }
    calculateOrbitalDivisions();
    areasErased = true;
  }

  void refreshMu() {
    mu = KeplersLawsConstants.initialG * sun.mass;
  }

  void reset() {
    resetOrbitalAreas();
    a = 1;
    e = 0;
    w = 0;
    M = 0;
    W = 0;
    T = 1;
    nu = 0;
    update();
  }
}
