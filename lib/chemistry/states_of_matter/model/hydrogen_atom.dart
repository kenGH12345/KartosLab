import 'atom_type.dart';
import 'scaled_atom.dart';

/// Hydrogen atom with render-order flag — PhET HydrogenAtom.
class HydrogenAtom extends ScaledAtom {
  HydrogenAtom(double x, double y, this.renderBelowOxygen)
      : super(AtomType.hydrogen, x, y);

  /// When true, painter should draw this H behind oxygen.
  final bool renderBelowOxygen;
}
