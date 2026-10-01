/// [已确认] `js/common/model/OrbitalArea.ts`
library;

import 'kl_vec.dart';

class OrbitalArea {
  OrbitalArea(this.index);

  final int index;

  KlVec dotPosition = KlVec.zero;
  KlVec startPosition = KlVec.zero;
  KlVec endPosition = KlVec.zero;
  double startAngle = 0;
  double endAngle = 0;
  double completion = 0;
  double sweptArea = 0;
  bool inside = false;
  bool alreadyEntered = true;
  bool active = false;

  /// [已确认] reset(eraseAreas=false): alreadyEntered = !eraseAreas
  void reset({bool eraseAreas = false}) {
    dotPosition = KlVec.zero;
    startPosition = KlVec.zero;
    endPosition = KlVec.zero;
    startAngle = 0;
    endAngle = 0;
    completion = 0;
    sweptArea = 0;
    alreadyEntered = !eraseAreas;
    active = false;
    inside = false;
  }
}
