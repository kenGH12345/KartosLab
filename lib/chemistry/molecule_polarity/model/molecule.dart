import '../mp_constants.dart';
import 'atom.dart';
import 'bond.dart';
import 'mp_preferences.dart';
import 'mp_vector2.dart';
import 'normalize_angle.dart';

/// Abstract 2D molecule base.
/// Source: `js/common/model/Molecule.ts`
abstract class MpMolecule {
  MpMolecule({
    required this.atoms,
    required this.bonds,
    required this.position,
    double angle = 0,
  }) : _angle = angle {
    updateGeometry();
    updatePartialCharges();
  }

  final List<MpAtom> atoms;
  final List<MpBond> bonds;
  final MpVector2 position;

  double _angle;
  double get angle => _angle;

  /// Hint arrows (Two Atoms): hidden on any post-init [angle] change.
  /// Source: `DiatomicMoleculeNode` → `angleProperty.lazyLink(hideArrows)`.
  /// EN changes do **not** hide arrows.
  bool showHintArrows = true;
  bool _suppressHintHide = false;

  set angle(double value) {
    final next = normalizeAngle(value, MpConstants.angleMin);
    if (!_suppressHintHide && next != _angle) {
      showHintArrows = false;
    }
    _angle = next;
    updateGeometry();
  }

  bool isDragging = false;
  bool isRotatingDueToEField = false;

  /// Sum of bond dipoles.
  MpVector2 dipole([
    DipoleDirection direction = DipoleDirection.positiveToNegative,
  ]) {
    var sum = MpVector2.zero;
    for (final bond in bonds) {
      sum = sum + bond.dipole(direction);
    }
    if (sum.y.abs() < 1e-10) {
      sum = MpVector2(sum.x, 0);
    }
    return sum;
  }

  double dipoleMagnitude([
    DipoleDirection direction = DipoleDirection.positiveToNegative,
  ]) =>
      dipole(direction).magnitude;

  /// Electronegativity difference metric (subclass-specific).
  double get deltaEN;

  void updateGeometry();
  void updatePartialCharges();

  void setElectronegativity(MpAtom atom, double value) {
    assert(atoms.contains(atom));
    atom.electronegativity = value.clamp(
      MpConstants.electronegativityMin,
      MpConstants.electronegativityMax,
    );
    updatePartialCharges();
  }

  /// Snap EN to tick spacing (0.2) on slider release.
  void snapElectronegativity(MpAtom atom) {
    final spacing = MpConstants.electronegativityTickSpacing;
    final snapped =
        (atom.electronegativity / spacing).round() * spacing;
    setElectronegativity(atom, snapped);
  }

  void reset() {
    showHintArrows = true;
    _suppressHintHide = true;
    angle = 0;
    _suppressHintHide = false;
    for (final atom in atoms) {
      atom.reset();
    }
    updateGeometry();
    updatePartialCharges();
  }
}
