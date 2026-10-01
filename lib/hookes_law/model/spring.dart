import '../constants/hookes_law_constants.dart';
import 'hookes_law_numbers.dart';
import 'number_property.dart';

/// One spring. Port of `js/common/model/Spring.ts`.
///
/// Exactly one of [appliedForceRange] or [displacementRange] is specified.
///
/// * Applied-force range (Intro, Systems): changing k keeps F and recomputes x.
/// * Displacement range (Energy): changing k keeps x and recomputes F.
///
/// There is no mass, velocity, or oscillation. After a write, state stays put.
class Spring {
  Spring({
    double left = 0,
    this.equilibriumLength = 1.5,
    required RangeWithValue springConstantRange,
    RangeWithValue? appliedForceRange,
    RangeWithValue? displacementRange,
  }) : springConstantRange = springConstantRange,
       _appliedForceSpecified = appliedForceRange != null {
    if (equilibriumLength <= 0) {
      throw ArgumentError.value(
        equilibriumLength,
        'equilibriumLength',
        'must be > 0',
      );
    }
    if (springConstantRange.min <= 0) {
      throw ArgumentError.value(
        springConstantRange.min,
        'springConstantRange.min',
        'must be positive',
      );
    }
    final hasForce = appliedForceRange != null;
    final hasDisplacement = displacementRange != null;
    if (hasForce == hasDisplacement) {
      throw ArgumentError(
        'specify either appliedForceRange or displacementRange, but not both',
      );
    }

    if (appliedForceRange != null) {
      this.appliedForceRange = appliedForceRange;
      // x = F/k using the minimum k, so the displacement property can hold
      // every force in range. The instantaneous right end is tighter.
      this.displacementRange = RangeWithValue(
        appliedForceRange.min / springConstantRange.min,
        appliedForceRange.max / springConstantRange.min,
        appliedForceRange.defaultValue / springConstantRange.defaultValue,
      );
    } else {
      this.displacementRange = displacementRange!;
      // F = kx using the maximum k.
      this.appliedForceRange = RangeWithValue(
        springConstantRange.max * displacementRange.min,
        springConstantRange.max * displacementRange.max,
        springConstantRange.defaultValue * displacementRange.defaultValue,
      );
    }

    appliedForceProperty = NumberProperty(
      this.appliedForceRange.defaultValue,
      range: this.appliedForceRange,
    );
    springConstantProperty = NumberProperty(
      springConstantRange.defaultValue,
      range: springConstantRange,
    );
    displacementProperty = NumberProperty(
      this.displacementRange.defaultValue,
      range: this.displacementRange,
    );
    leftProperty = NumberProperty(
      left,
      range: const HookesLawRange(double.negativeInfinity, double.infinity),
    );
    rightProperty = NumberProperty(
      equilibriumX + displacementProperty.value,
      range: const HookesLawRange(double.negativeInfinity, double.infinity),
    );

    // F: keep k, recompute x. Registered before the k and x listeners.
    appliedForceProperty.link((appliedForce) {
      displacementProperty.value = appliedForce / springConstantProperty.value;
    });

    // k: branch is fixed by which range was passed in, not by the caller.
    springConstantProperty.link((springConstant) {
      if (_appliedForceSpecified) {
        displacementProperty.value =
            appliedForceProperty.value / springConstant;
      } else {
        appliedForceProperty.value =
            springConstant * displacementProperty.value;
      }
    });

    // x: keep k, recompute F. Clamp, then round to 10 decimals so F↔x stops.
    displacementProperty.link((displacement) {
      final appliedForce = appliedForceRangeOrThrow.constrain(
        springConstantProperty.value * displacement,
      );
      appliedForceProperty.value = HookesLawNumbers.toFixedNumber(
        appliedForce,
        HookesLawConstants.forceFromDisplacementDecimalPlaces,
      );
    });

    // Derived right end. After the F/x listeners, matching Spring.ts.
    displacementProperty.addListener((_) => _updateRight());
    leftProperty.addListener((_) => _updateRight());
  }

  final double equilibriumLength;
  final RangeWithValue springConstantRange;
  final bool _appliedForceSpecified;

  late final RangeWithValue appliedForceRange;
  late final RangeWithValue displacementRange;

  late final NumberProperty appliedForceProperty;
  late final NumberProperty springConstantProperty;
  late final NumberProperty displacementProperty;
  late final NumberProperty leftProperty;
  late final NumberProperty rightProperty;

  RangeWithValue get appliedForceRangeOrThrow => appliedForceRange;

  /// True when this spring was built like Intro/Systems (force range given).
  bool get maintainsAppliedForceWhenSpringConstantChanges =>
      _appliedForceSpecified;

  double get appliedForce => appliedForceProperty.value;

  double get springConstant => springConstantProperty.value;

  double get displacement => displacementProperty.value;

  double get left => leftProperty.value;

  /// Spring force opposes the applied force. `springForceProperty = -F`.
  double get springForce => -appliedForce;

  double get equilibriumX => left + equilibriumLength;

  double get right => rightProperty.value;

  double get length => (right - left).abs();

  /// E = (k * x * x) / 2.
  double get potentialEnergy => (springConstant * displacement * displacement) / 2;

  /// Instantaneous range of the right end.
  ///
  /// Intro/Systems: depends on the current k. Energy: the fixed displacement
  /// window shifted by the equilibrium position.
  HookesLawRange get rightRange {
    if (_appliedForceSpecified) {
      final minDisplacement = appliedForceRange.min / springConstant;
      final maxDisplacement = appliedForceRange.max / springConstant;
      return HookesLawRange(
        equilibriumX + minDisplacement,
        equilibriumX + maxDisplacement,
      );
    }
    return HookesLawRange(
      equilibriumX + displacementRange.min,
      equilibriumX + displacementRange.max,
    );
  }

  void setAppliedForce(double newtons) {
    appliedForceProperty.value = newtons;
  }

  void setSpringConstant(double newtonsPerMeter) {
    springConstantProperty.value = newtonsPerMeter;
  }

  /// Direct displacement write. Clamps to [displacementRange], then the x
  /// listener clamps and rounds F. This is not the robotic-arm drag path:
  /// the 0.01 m snap is applied before [RoboticArm.leftProperty] is set.
  void setDisplacement(double meters) {
    displacementProperty.value = meters;
  }

  /// Source throws if a fixed left end moves. `lazyLink` does not fire for
  /// the current value, and `reset` to the same value does not notify.
  void lockLeftEnd(String message) {
    leftProperty.addListener((value) {
      throw StateError('$message, left=$value');
    });
  }

  void reset() {
    appliedForceProperty.reset();
    springConstantProperty.reset();
    displacementProperty.reset();
    leftProperty.reset();
  }

  void _updateRight() {
    rightProperty.value = equilibriumX + displacementProperty.value;
  }
}
