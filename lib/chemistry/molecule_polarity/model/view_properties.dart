import 'mp_preferences.dart';

/// Source: `js/twoatoms/view/TwoAtomsViewProperties.ts`
class TwoAtomsViewProperties {
  bool bondDipoleVisible = true;
  bool partialChargesVisible = false;
  bool bondCharacterVisible = false;
  SurfaceType surfaceType = SurfaceType.none;

  void reset() {
    bondDipoleVisible = true;
    partialChargesVisible = false;
    bondCharacterVisible = false;
    surfaceType = SurfaceType.none;
  }
}

/// Source: `js/threeatoms/view/ThreeAtomsViewProperties.ts`
class ThreeAtomsViewProperties {
  bool bondDipolesVisible = false;
  bool molecularDipoleVisible = true;
  bool partialChargesVisible = false;

  void reset() {
    bondDipolesVisible = false;
    molecularDipoleVisible = true;
    partialChargesVisible = false;
  }
}

/// Source: `js/realmolecules/view/RealMoleculesViewProperties.ts`
class RealMoleculesViewProperties {
  bool bondDipolesVisible = false;
  bool molecularDipoleVisible = false;
  bool partialChargesVisible = false;
  bool atomElectronegativitiesVisible = false;
  bool atomLabelsVisible = true;
  SurfaceType surfaceType = SurfaceType.none;

  void reset() {
    bondDipolesVisible = false;
    molecularDipoleVisible = false;
    partialChargesVisible = false;
    atomElectronegativitiesVisible = false;
    atomLabelsVisible = true;
    surfaceType = SurfaceType.none;
  }
}
