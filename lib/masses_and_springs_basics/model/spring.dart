import 'dart:math' as math;

import '../masb_constants.dart';
import '../math/complex.dart';
import 'mass.dart';
import 'period_trace.dart';

/// Port of PhET `Spring.js` — analytical damped harmonic oscillator.
class MasbSpring {
  MasbSpring({
    required this.positionX,
    required this.positionY,
    required double initialNaturalRestingLength,
    required double Function() dampingGetter,
    required double Function() gravityGetter,
  })  : naturalRestingLength = initialNaturalRestingLength,
        _initialNaturalRestingLength = initialNaturalRestingLength,
        _dampingGetter = dampingGetter,
        _gravityGetter = gravityGetter,
        gravity = gravityGetter(),
        dampingCoefficient = dampingGetter(),
        springConstant = MasbConstants.springConstantDefault {
    updateThickness(naturalRestingLength, springConstant);
  }

  final double positionX;
  final double positionY;
  final double _initialNaturalRestingLength;
  final double Function() _dampingGetter;
  final double Function() _gravityGetter;

  double gravity;
  double displacement = 0;
  double springConstant;
  double dampingCoefficient;
  double naturalRestingLength;
  double thickness = 3;
  final double _initialThickness = 3;

  MasbMass? massAttached;
  bool animating = false;
  bool buttonEnabled = false;
  bool periodTraceVisible = false;
  PeriodTrace? periodTrace;

  double equilibriumYPosition = 0;
  double massEquilibriumYPosition = 0;
  double? massEquilibriumDisplacement;

  double forcesOrientation = 1;
  double _prevVelocity = 0;
  double? _prevMassEqDisp;

  double get springForce => -springConstant * displacement;

  double get elasticPotentialEnergy =>
      0.5 * springConstant * displacement * displacement;

  double get length => naturalRestingLength - displacement;

  double get bottom => positionY - length;

  void syncFromSystem() {
    gravity = _gravityGetter();
    dampingCoefficient = _dampingGetter();
  }

  void updateThickness(double length, double k) {
    thickness = _initialThickness *
        k /
        MasbConstants.springConstantDefault *
        length /
        _initialNaturalRestingLength;
  }

  void updateEquilibriumFromMass() {
    final mass = massAttached;
    if (mass == null) return;
    final springExtension =
        (mass.massKg * gravity) / springConstant;
    equilibriumYPosition =
        positionY - naturalRestingLength - springExtension;
    final nextMassEq = positionY -
        naturalRestingLength -
        springExtension -
        mass.height / 2;
    if ((nextMassEq - massEquilibriumYPosition).abs() > 1e-9) {
      periodTrace?.onFaded();
    }
    massEquilibriumYPosition = nextMassEq;
  }

  void updateDisplacement(double yPosition, {required bool factorNaturalLength}) {
    final mass = massAttached;
    if (factorNaturalLength && mass != null) {
      displacement = mass.positionY -
          (yPosition - naturalRestingLength) -
          MasbConstants.hookCenter;
    } else {
      displacement = -(positionY - naturalRestingLength) +
          yPosition -
          MasbConstants.hookCenter;
    }
  }

  void setMass(MasbMass mass) {
    if (massAttached != null) {
      massAttached!.detach();
    }
    massAttached = mass;
    mass.spring = this;
    mass.onShelf = false;
    mass.positionX = positionX;
    updateDisplacement(positionY, factorNaturalLength: true);
    mass.verticalVelocity = 0;
    updateEquilibriumFromMass();
  }

  void removeMass() {
    massAttached?.detach();
    displacement = 0;
    massAttached = null;
    buttonEnabled = false;
  }

  void stopSpring() {
    final mass = massAttached;
    if (mass == null) return;
    mass.initialTotalEnergy = mass.totalEnergy;
    final springExtension = (mass.massKg * gravity) / springConstant;
    displacement = -springExtension;
    mass.positionX = positionX;
    mass.positionY = equilibriumYPosition + MasbConstants.hookCenter;
    mass.verticalVelocity = 0;
    buttonEnabled = false;
  }

  /// PhET `Spring.step` — under/over/critically damped closed-form update.
  void step(double dt) {
    syncFromSystem();
    final mass = massAttached;
    if (mass == null || mass.userControlled) return;

    mass.preserveThermalEnergy = false;

    final k = springConstant;
    final m = mass.massKg;
    final c = dampingCoefficient;
    final v = mass.verticalVelocity;
    final x = displacement;
    final g = gravity;

    final discriminant = c * c - 4 * k * m;

    if (discriminant != 0) {
      final km = k * m;
      final gm = g * m;
      final tDm = dt / m;
      final kx = k * x;
      final c2 = c * c;
      final kR2 = math.sqrt(k);
      final k3R2 = k * kR2;
      final twok3R2mv = Complex.fromReal(2 * k3R2 * m * v);
      final alpha = Complex.fromReal(4 * km - c2).sqrt();
      final alphaI = alpha.times(Complex.i);
      final alphaPrime = Complex.fromReal(c2 - 4 * km).sqrt();
      final alphatD2m = Complex.fromReal(tDm / 2).multiply(alpha);
      final beta =
          Complex.fromReal(tDm).multiply(alphaI).exponentiate();
      final eta = Complex.fromReal(c)
          .add(alphaI)
          .multiply(Complex.fromReal(tDm / 2))
          .exponentiate()
          .multiply(Complex.fromReal(2));

      var coef = Complex.one.dividedBy(
        Complex.fromReal(k3R2).multiply(alphaPrime).multiply(eta),
      );
      var a = beta.minus(Complex.one).times(
            Complex.fromReal(c * kR2 * (gm + kx)),
          );
      var b = Complex.fromReal(gm * kR2).times(alphaI).times(
            beta.minus(eta).plus(Complex.one),
          );
      final cTerm = twok3R2mv.times(beta);
      final d = Complex.fromReal(k3R2 * x).times(alphaI);
      final e = d.times(beta);
      var newDisplacement =
          coef.times(a.plus(b).plus(cTerm).plus(d).plus(e).minus(twok3R2mv)).real;

      coef = Complex.fromReal(-(math.exp((-c * dt) / (2 * m)) / (2 * k3R2 * m)))
          .divide(alphaPrime)
          .multiply(Complex.i);
      a = alphatD2m.sinOf().times(
            Complex.fromReal(kR2 * (gm + kx))
                .times(alpha.squared().plus(Complex.fromReal(c2)))
                .plus(twok3R2mv.times(Complex.fromReal(c))),
          );
      // Mutable cos() after immutable sinOf — matches PhET order.
      b = alphatD2m
          .cos()
          .times(twok3R2mv)
          .times(alpha)
          .times(Complex.fromReal(-1));
      final newVelocity = a.plus(b).times(coef).real;

      if (discriminant > 0) {
        newDisplacement =
            displacement > 0 ? newDisplacement.abs() : -newDisplacement.abs();
      }

      if ((displacement - newDisplacement).abs() < 1e-6 &&
          mass.verticalVelocity.abs() < 1e-6) {
        displacement = -m * g / k;
        mass.verticalVelocity = 0;
      } else {
        displacement = newDisplacement;
        mass.verticalVelocity = newVelocity;
      }

      assert(!displacement.isNaN, 'displacement must be a number');
      assert(!mass.verticalVelocity.isNaN, 'velocity must be a number');
    } else {
      // Critically damped
      final omega = math.sqrt(k / m);
      final phi = math.exp(dt * omega);
      displacement = (g * (-m * phi + dt * math.sqrt(k * m) + m) +
              k * (dt * (x * omega + v) + x)) /
          (phi * k);
      mass.verticalVelocity = (g *
                  m *
                  (math.sqrt(k * m) - omega * (m + dt * math.sqrt(k * m))) -
              k * (m * v * (omega * dt - 1) + k * dt * x)) /
          (phi * k * m);
    }

    mass.positionX = positionX;
    mass.positionY = bottom + MasbConstants.hookCenter;
    buttonEnabled = mass.verticalVelocity != 0;
    mass.preserveThermalEnergy = true;

    // PhET Mass.verticalVelocityProperty.lazyLink → peakEmitter
    final oldV = _prevVelocity;
    final newV = mass.verticalVelocity;
    if (oldV.sign != newV.sign && oldV != 0) {
      periodTrace?.onPeak(1);
    }
    _prevVelocity = newV;

    if (massAttached != null) {
      final comY = mass.centerOfMassY;
      final oldDisp = _prevMassEqDisp;
      massEquilibriumDisplacement = comY - massEquilibriumYPosition;
      final newDisp = massEquilibriumDisplacement!;
      if (oldDisp != null && (oldDisp >= 0) != (newDisp >= 0)) {
        periodTrace?.onCross(velocityAbs: newV.abs());
      }
      _prevMassEqDisp = newDisp;
    }
  }

  void reset() {
    buttonEnabled = false;
    gravity = _gravityGetter();
    displacement = 0;
    dampingCoefficient = _dampingGetter();
    naturalRestingLength = _initialNaturalRestingLength;
    massAttached = null;
    springConstant = MasbConstants.springConstantDefault;
    animating = false;
    massEquilibriumDisplacement = null;
    periodTraceVisible = false;
    periodTrace?.reset();
    _prevVelocity = 0;
    _prevMassEqDisp = null;
    updateThickness(naturalRestingLength, springConstant);
  }
}
