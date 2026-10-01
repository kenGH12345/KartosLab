import 'nm_vec.dart';

/// `js/common/model/Mass.js`
class Mass {
  Mass({
    required this.equilibriumPosition,
    required this.visible,
  });

  NmVec equilibriumPosition;
  bool visible;
  NmVec displacement = NmVec.zero;
  NmVec velocity = NmVec.zero;
  NmVec acceleration = NmVec.zero;
  NmVec previousAcceleration = NmVec.zero;

  NmVec get position => equilibriumPosition + displacement;

  void zeroPosition() {
    displacement = NmVec.zero;
    velocity = NmVec.zero;
    acceleration = NmVec.zero;
    previousAcceleration = NmVec.zero;
  }
}
