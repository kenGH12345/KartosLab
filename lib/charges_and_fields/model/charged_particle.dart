import 'model_element.dart';
import 'vec2.dart';

/// Point charge: charge is +1 or -1 (nano Coulomb units).
class ChargedParticle extends CafModelElement {
  ChargedParticle({
    required this.charge,
    required CafVec2 initialPosition,
  })  : assert(charge == 1 || charge == -1),
        super(initialPosition);

  /// +1 = positive 1 nC, -1 = negative 1 nC.
  final int charge;

  bool get isPositive => charge > 0;
}
