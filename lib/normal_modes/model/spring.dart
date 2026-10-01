import 'mass.dart';

/// `js/common/model/Spring.js` — visible follows left mass only.
class Spring {
  Spring(this.leftMass, this.rightMass);

  final Mass leftMass;
  final Mass rightMass;

  bool get leftVisible => leftMass.visible;
}
