import 'hookes_law_numbers.dart';
import 'robotic_arm.dart';
import 'spring.dart';

/// Two springs in series. `js/systems/model/SeriesSystem.ts`.
///
/// Feq = F1 = F2
/// keq = 1 / (1/k1 + 1/k2)
/// xeq = x1 + x2
/// Eeq = E1 + E2 (read each spring; there is no stored equivalent-energy field)
class SeriesSystem {
  SeriesSystem() {
    const springConstantRange = RangeWithValue(200, 600, 200);
    const appliedForceRange = RangeWithValue(-100, 100, 0);

    leftSpring = Spring(
      left: 0,
      equilibriumLength: 0.75,
      springConstantRange: springConstantRange,
      appliedForceRange: appliedForceRange,
    );
    rightSpring = Spring(
      left: leftSpring.right,
      equilibriumLength: leftSpring.equilibriumLength,
      springConstantRange: leftSpring.springConstantRange,
      appliedForceRange: leftSpring.appliedForceRange,
    );
    equivalentSpring = Spring(
      left: leftSpring.left,
      equilibriumLength:
          leftSpring.equilibriumLength + rightSpring.equilibriumLength,
      springConstantRange: RangeWithValue(
        _equivalentK(leftSpring.springConstantRange.min, rightSpring.springConstantRange.min),
        _equivalentK(leftSpring.springConstantRange.max, rightSpring.springConstantRange.max),
        _equivalentK(
          leftSpring.springConstantRange.defaultValue,
          rightSpring.springConstantRange.defaultValue,
        ),
      ),
      appliedForceRange: leftSpring.appliedForceRange,
    );
    roboticArm = RoboticArm(
      left: equivalentSpring.right,
      right: equivalentSpring.right + equivalentSpring.length,
    );

    equivalentSpring.appliedForceProperty.link((appliedForce) {
      leftSpring.setAppliedForce(appliedForce);
      rightSpring.setAppliedForce(appliedForce);
    });

    void updateEquivalentSpringConstant() {
      equivalentSpring.setSpringConstant(
        _equivalentK(leftSpring.springConstant, rightSpring.springConstant),
      );
    }

    leftSpring.springConstantProperty.link((_) => updateEquivalentSpringConstant());
    rightSpring.springConstantProperty.link((_) => updateEquivalentSpringConstant());

    roboticArm.leftProperty.link((left) {
      if (_ignoreArmUpdates) {
        return;
      }
      _ignoreArmUpdates = true;
      equivalentSpring.setDisplacement(left - equivalentSpring.equilibriumX);
      _ignoreArmUpdates = false;
    });

    leftSpring.rightProperty.link((right) {
      rightSpring.leftProperty.value = right;
    });
    equivalentSpring.rightProperty.link((right) {
      roboticArm.left = right;
    });

    leftSpring.lockLeftEnd('Left end of left spring must remain fixed');
    equivalentSpring.lockLeftEnd(
      'Left end of equivalent spring must remain fixed',
    );
  }

  static double _equivalentK(double k1, double k2) {
    return 1 / ((1 / k1) + (1 / k2));
  }

  late final Spring leftSpring;
  late final Spring rightSpring;
  late final Spring equivalentSpring;
  late final RoboticArm roboticArm;
  bool _ignoreArmUpdates = false;

  void reset() {
    leftSpring.reset();
    rightSpring.reset();
    roboticArm.reset();
    equivalentSpring.reset();
  }
}
