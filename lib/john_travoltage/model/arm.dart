import 'appendage.dart';
import 'john_travoltage_constants.dart';
import 'jt_vec2.dart';

/// Arm appendage — PhET `Arm.js`.
class Arm extends Appendage {
  Arm()
      : fingerVector =
            JohnTravoltageConstants.armFingerSample -
                JohnTravoltageConstants.armPivot,
        super(
          position: JohnTravoltageConstants.armPivot,
          initialAngle: JohnTravoltageConstants.armInitialAngle,
          angleMin: JohnTravoltageConstants.armAngleMin,
          angleMax: JohnTravoltageConstants.armAngleMax,
        );

  /// Vector from pivot to finger tip at angle 0.
  final JtVec2 fingerVector;

  /// Finger tip in ScreenView coords: `fingerVector.rotated(angle) + pivot`.
  JtVec2 getFingerPosition() =>
      fingerVector.rotated(angle).plus(position);
}
