import 'hookes_law_numbers.dart';
import 'robotic_arm.dart';
import 'spring.dart';

/// One spring pulled by a robotic arm. `js/common/model/SingleSpringSystem.ts`.
class SingleSpringSystem {
  SingleSpringSystem({
    required RangeWithValue springConstantRange,
    RangeWithValue? appliedForceRange,
    RangeWithValue? displacementRange,
  }) {
    spring = Spring(
      springConstantRange: springConstantRange,
      appliedForceRange: appliedForceRange,
      displacementRange: displacementRange,
    );
    roboticArm = RoboticArm(
      left: spring.right,
      right: spring.right + spring.length,
    );

    spring.rightProperty.link((right) {
      roboticArm.left = right;
    });
    roboticArm.leftProperty.link((left) {
      spring.setDisplacement(left - spring.equilibriumX);
    });

    spring.lockLeftEnd('Left end of spring must remain fixed');
  }

  /// Intro screen spring. Force range is specified, so changing k keeps F.
  factory SingleSpringSystem.intro() {
    return SingleSpringSystem(
      springConstantRange: const RangeWithValue(100, 1000, 200),
      appliedForceRange: const RangeWithValue(-100, 100, 0),
    );
  }

  /// Energy screen spring. Displacement range is specified, so changing k keeps x.
  factory SingleSpringSystem.energy() {
    return SingleSpringSystem(
      springConstantRange: const RangeWithValue(100, 400, 100),
      displacementRange: const RangeWithValue(-1, 1, 0),
    );
  }

  late final Spring spring;
  late final RoboticArm roboticArm;

  void reset() {
    spring.reset();
    roboticArm.reset();
  }
}
