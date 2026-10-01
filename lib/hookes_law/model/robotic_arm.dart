import 'hookes_law_numbers.dart';
import 'number_property.dart';

/// Movable left end, fixed right end. `js/common/model/RoboticArm.ts`.
class RoboticArm {
  RoboticArm({
    double left = 0,
    required this.right,
  }) : leftProperty = NumberProperty(
          left,
          range: HookesLawRange(double.negativeInfinity, right),
        ) {
    // Source `isValidValue: value => value < this.right`.
    // [HookesLawRange.constrain] would clamp to `right`, which is illegal.
    // Reject that endpoint explicitly.
    if (left >= right) {
      throw ArgumentError('robotic arm left must be < right');
    }
  }

  final double right;
  final NumberProperty leftProperty;

  double get left => leftProperty.value;

  set left(double value) {
    if (value >= right) {
      throw ArgumentError('robotic arm left must be < right, left=$value');
    }
    leftProperty.value = value;
  }

  void reset() {
    leftProperty.reset();
  }
}
