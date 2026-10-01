import 'hookes_law_numbers.dart';
import 'robotic_arm.dart';
import 'spring.dart';

/// Two springs in parallel. `js/systems/model/ParallelSystem.ts`.
///
/// Feq = F1 + F2
/// keq = k1 + k2
/// xeq = x1 = x2
/// Eeq = E1 + E2 (read each spring; there is no stored equivalent-energy field)
class ParallelSystem {
  ParallelSystem() {
    const springConstantRange = RangeWithValue(200, 600, 200);
    const appliedForceRange = RangeWithValue(-100, 100, 0);

    topSpring = Spring(
      left: 0,
      equilibriumLength: 1.5,
      springConstantRange: springConstantRange,
      appliedForceRange: appliedForceRange,
    );
    bottomSpring = Spring(
      left: topSpring.left,
      equilibriumLength: topSpring.equilibriumLength,
      springConstantRange: topSpring.springConstantRange,
      appliedForceRange: topSpring.appliedForceRange,
    );
    equivalentSpring = Spring(
      left: topSpring.left,
      equilibriumLength: topSpring.equilibriumLength,
      springConstantRange: RangeWithValue(
        topSpring.springConstantRange.min + bottomSpring.springConstantRange.min,
        topSpring.springConstantRange.max + bottomSpring.springConstantRange.max,
        topSpring.springConstantRange.defaultValue +
            bottomSpring.springConstantRange.defaultValue,
      ),
      appliedForceRange: topSpring.appliedForceRange,
    );
    roboticArm = RoboticArm(
      left: equivalentSpring.right,
      right: equivalentSpring.right + equivalentSpring.length,
    );

    equivalentSpring.displacementProperty.link((displacement) {
      topSpring.setDisplacement(displacement);
      bottomSpring.setDisplacement(displacement);
    });

    void updateEquivalentSpringConstant() {
      equivalentSpring.setSpringConstant(
        topSpring.springConstant + bottomSpring.springConstant,
      );
    }

    topSpring.springConstantProperty.link((_) => updateEquivalentSpringConstant());
    bottomSpring.springConstantProperty.link(
      (_) => updateEquivalentSpringConstant(),
    );

    roboticArm.leftProperty.link((left) {
      if (_ignoreArmUpdates) {
        return;
      }
      _ignoreArmUpdates = true;
      equivalentSpring.setDisplacement(left - equivalentSpring.equilibriumX);
      _ignoreArmUpdates = false;
    });

    equivalentSpring.rightProperty.link((right) {
      roboticArm.left = right;
    });

    topSpring.lockLeftEnd('Left end of top spring must remain fixed');
    bottomSpring.lockLeftEnd('Left end of bottom spring must remain fixed');
    equivalentSpring.lockLeftEnd(
      'Left end of equivalent spring must remain fixed',
    );
  }

  late final Spring topSpring;
  late final Spring bottomSpring;
  late final Spring equivalentSpring;
  late final RoboticArm roboticArm;
  bool _ignoreArmUpdates = false;

  void reset() {
    topSpring.reset();
    bottomSpring.reset();
    roboticArm.reset();
    equivalentSpring.reset();
  }
}
