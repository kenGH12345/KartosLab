import 'dart:math' as math;

import '../masb_constants.dart';
import 'spring.dart';

/// Port of PhET `Mass.js`.
class MasbMass {
  MasbMass({
    required double massKg,
    required double xPosition,
    required this.gravityGetter,
    this.density = MasbConstants.massDensity,
    this.mysteryLabel = false,
    this.adjustable = false,
    this.colorArgb = MasbConstants.labeledMassArgb,
  })  : massKg = massKg,
        _initialMassKg = massKg,
        positionX = xPosition,
        _initialX = xPosition {
    _recomputeGeometry();
    positionY = height + MasbConstants.shelfHeight;
    _initialY = positionY;
  }

  final double Function() gravityGetter;
  final double density;
  final bool mysteryLabel;
  final bool adjustable;
  final int colorArgb;

  double massKg;
  final double _initialMassKg;

  double positionX;
  double positionY = 0;
  final double _initialX;
  double _initialY = 0;

  late double radius;
  late double cylinderHeight;
  late double height;
  late double zeroReferencePoint;

  double verticalVelocity = 0;
  bool userControlled = false;
  bool onShelf = true;
  bool isAnimating = false;
  bool preserveThermalEnergy = true;

  MasbSpring? spring;

  double? _animStartX;
  double? _animEndX;
  double _animProgress = 0;

  double get centerOfMassY =>
      positionY - cylinderHeight / 2 - MasbConstants.hookHeight;

  double get springForce => spring?.springForce ?? 0;

  double get netForce => springForce - massKg * gravityGetter();

  double get acceleration => netForce / massKg;

  double get kineticEnergy =>
      userControlled ? 0 : 0.5 * massKg * verticalVelocity * verticalVelocity;

  double get gravitationalPotentialEnergy {
    final heightFromZero = positionY - zeroReferencePoint - height;
    return massKg * gravityGetter() * heightFromZero;
  }

  double get elasticPotentialEnergy => spring?.elasticPotentialEnergy ?? 0;

  double get totalEnergy =>
      kineticEnergy + gravitationalPotentialEnergy + elasticPotentialEnergy;

  double initialTotalEnergy = 0;

  double get thermalEnergy => initialTotalEnergy - totalEnergy;

  void _recomputeGeometry() {
    radius = math.pow(
          massKg / (density * MasbConstants.massHeightRatio * math.pi),
          0.5,
        ) *
        MasbConstants.massRadiusScaling;
    cylinderHeight = radius * MasbConstants.massHeightRatio;
    height = cylinderHeight + MasbConstants.hookHeight;
    zeroReferencePoint = -cylinderHeight / 2;
  }

  void setMassKg(double value) {
    assert(value > 0);
    massKg = value;
    _recomputeGeometry();
    spring?.updateEquilibriumFromMass();
  }

  void detach() {
    verticalVelocity = 0;
    spring = null;
  }

  /// PhET `Mass.step` — freefall + cubic shelf return.
  void step(double gravity, double floorY, double dt, double animationDt) {
    final floorPosition = floorY + height;

    if (isAnimating) {
      final startX = _animStartX;
      final endX = _animEndX;
      if (startX == null || endX == null) {
        isAnimating = false;
        onShelf = true;
        return;
      }
      final distance = (endX - startX).abs();
      if (distance > 0) {
        final animationSpeed = math.sqrt(2 / distance);
        _animProgress = math.min(1, _animProgress + animationDt * animationSpeed);
        final t = _animProgress;
        // Easing.CUBIC_IN_OUT
        final ratio = t < 0.5
            ? 4 * t * t * t
            : 1 - math.pow(-2 * t + 2, 3) / 2;
        positionX = startX + (endX - startX) * ratio;
        positionY = floorPosition;
      } else {
        _animProgress = 1;
      }
      if (_animProgress >= 1) {
        onShelf = true;
        isAnimating = false;
        positionX = endX;
        positionY = floorPosition;
      }
      return;
    }

    if (spring == null && !userControlled) {
      final oldY = positionY;
      final newVerticalVelocity = verticalVelocity - gravity * dt;
      final newY = oldY + (verticalVelocity + newVerticalVelocity) * dt / 2;
      if (newY < floorPosition) {
        positionY = floorPosition;
        verticalVelocity = 0;
        _animProgress = 0;
        _animStartX = positionX;
        _animEndX = _initialX;
        if ((_animStartX! - _animEndX!).abs() >= 1e-7) {
          isAnimating = true;
        } else {
          onShelf = true;
        }
      } else {
        verticalVelocity = newVerticalVelocity;
        positionY = newY;
      }
    }
  }

  void reset() {
    massKg = _initialMassKg;
    _recomputeGeometry();
    positionX = _initialX;
    positionY = _initialY;
    onShelf = true;
    userControlled = false;
    spring = null;
    verticalVelocity = 0;
    isAnimating = false;
    _animProgress = 0;
    _animStartX = null;
    _animEndX = null;
    initialTotalEnergy = 0;
  }
}
