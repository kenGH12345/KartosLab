import '../ba_shared_constants.dart';
import 'ba_mass.dart';
import 'ba_vector2.dart';

/// Source: `js/common/model/MassForceVector.ts` — display force only.
class MassForceVector {
  MassForceVector(this.mass) {
    update();
  }

  final BaMass mass;
  late BaVector2 origin;
  late BaVector2 vector;

  void update() {
    origin = BaVector2(mass.position.x, mass.position.y);
    vector = BaVector2(
      0,
      mass.massValue * BaGeometry.accelerationDueToGravity,
    );
  }

  bool get isObfuscated => mass.isMystery;
}
