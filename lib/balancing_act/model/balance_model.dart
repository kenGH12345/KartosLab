import '../ba_shared_constants.dart';
import 'ba_enums.dart';
import 'ba_mass.dart';
import 'ba_vector2.dart';
import 'plank.dart';

/// Source: `js/common/model/BalanceModel.ts`
class BalanceModel {
  BalanceModel() {
    plank = Plank(
      position: const BaVector2(0, BaGeometry.plankHeight),
      pivotPoint: const BaVector2(0, BaGeometry.fulcrumHeight),
      columnStateGetter: () => columnState,
      userControlledMassesGetter: () => userControlledMasses,
    );
    // Default DOUBLE_COLUMNS forces level.
    plank.onColumnStateChanged(columnState);
  }

  late final Plank plank;
  ColumnState columnState = ColumnState.doubleColumns;
  final List<BaMass> massList = [];
  final List<BaMass> userControlledMasses = [];

  /// Fixed pivot — not draggable.
  BaVector2 get pivotPoint => plank.pivotPoint;

  void setColumnState(ColumnState state) {
    if (columnState == state) return;
    columnState = state;
    plank.onColumnStateChanged(state);
  }

  /// ABSwitch semantics: A = DOUBLE_COLUMNS, B = NO_COLUMNS.
  void setSupportsEnabled(bool enabled) {
    setColumnState(
      enabled ? ColumnState.doubleColumns : ColumnState.noColumns,
    );
  }

  bool get supportsEnabled => columnState == ColumnState.doubleColumns;

  void step(double dt) {
    plank.step(dt);
    for (final mass in massList) {
      mass.step(dt);
    }
  }

  void addMass(BaMass mass) {
    massList.add(mass);
  }

  void removeMass(BaMass mass) {
    massList.remove(mass);
    if (mass.onPlank) {
      plank.removeMassFromSurface(mass);
    }
    userControlledMasses.remove(mass);
  }

  /// Pointer-down semantics: begin user control; lift off plank if needed.
  void beginDrag(BaMass mass) {
    mass.userControlled = true;
    if (!userControlledMasses.contains(mass)) {
      userControlledMasses.add(mass);
    }
    if (mass.onPlank) {
      plank.removeMassFromSurface(mass);
    }
  }

  /// Continuous drag — position in model meters (not snapped).
  void dragMassTo(BaMass mass, BaVector2 position) {
    if (!mass.userControlled) return;
    mass.position = position;
  }

  /// Pointer-up — attempts snap to plank; subclasses handle miss.
  bool endDrag(BaMass mass) {
    mass.userControlled = false;
    userControlledMasses.remove(mass);
    return plank.addMassToSurface(mass);
  }

  void reset() {
    plank.removeAllMasses();
    columnState = ColumnState.doubleColumns;
    plank.onColumnStateChanged(columnState);
  }
}
