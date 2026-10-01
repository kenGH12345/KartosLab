import '../constants/hookes_law_constants.dart';
import 'hookes_law_numbers.dart';
import 'robotic_arm.dart';

/// Pointer-drag write from `RoboticArmNode.ts`.
///
/// The 0.01 m snap is not inside [Spring.setDisplacement]. The hand listener
/// constrains to the spring's current right-end range, snaps, then writes
/// `roboticArm.left`. Snap is not re-clamped afterwards (source order).
void applyRoboticArmPointerLeft({
  required RoboticArm arm,
  required HookesLawRange springRightRange,
  required double proposedLeft,
}) {
  final constrained = springRightRange.constrain(proposedLeft);
  final snapped = HookesLawNumbers.roundToInterval(
    constrained,
    HookesLawConstants.roboticArmDisplacementInterval,
  );
  arm.left = snapped;
}
