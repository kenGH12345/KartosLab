import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/chemistry/molecule_polarity/model/atom.dart';
import 'package:kratos/chemistry/molecule_polarity/model/drag_math.dart';
import 'package:kratos/chemistry/molecule_polarity/model/mp_preferences.dart';
import 'package:kratos/chemistry/molecule_polarity/model/mp_vector2.dart';
import 'package:kratos/chemistry/molecule_polarity/model/three_atoms_model.dart';
import 'package:kratos/chemistry/molecule_polarity/model/two_atoms_model.dart';

/// Shared preferences + Two/Three Atoms controllers.
class MoleculePolarityController extends ChangeNotifier {
  MoleculePolarityController._({
    required this.preferences,
    required this.twoAtoms,
    required this.threeAtoms,
  });

  factory MoleculePolarityController.shared() {
    final prefs = MpPreferences();
    return MoleculePolarityController._(
      preferences: prefs,
      twoAtoms: TwoAtomsModel(preferences: prefs),
      threeAtoms: ThreeAtomsModel(preferences: prefs),
    );
  }

  final MpPreferences preferences;
  final TwoAtomsModel twoAtoms;
  final ThreeAtomsModel threeAtoms;

  SimulationClock? _clock;

  void attachClock(TickerProvider vsync) {
    disposeClock();
    _clock = SimulationClock(fps: 60)..attach(vsync);
    _clock!.onTick = (dt, _) {
      twoAtoms.step(dt);
      threeAtoms.step(dt);
      if (twoAtoms.eFieldEnabled || threeAtoms.eFieldEnabled) {
        notifyListeners();
      }
    };
    _clock!.play();
  }

  void disposeClock() {
    _clock?.dispose();
    _clock = null;
  }

  @override
  void dispose() {
    disposeClock();
    super.dispose();
  }

  void setDipoleDirection(DipoleDirection d) {
    preferences.dipoleDirection = d;
    notifyListeners();
  }

  void setSurfaceColor(SurfaceColor c) {
    preferences.surfaceColor = c;
    notifyListeners();
  }

  void setAtomEN(MpAtom atom, double value, {bool snap = false}) {
    if (twoAtoms.diatomic.atoms.contains(atom)) {
      twoAtoms.diatomic.setElectronegativity(atom, value);
      if (snap) twoAtoms.diatomic.snapElectronegativity(atom);
    } else {
      threeAtoms.triatomic.setElectronegativity(atom, value);
      if (snap) threeAtoms.triatomic.snapElectronegativity(atom);
    }
    notifyListeners();
  }

  void setEnDragging(bool dragging) {
    twoAtoms.diatomic.isDragging = dragging;
    threeAtoms.triatomic.isDragging = dragging;
    if (!dragging) {
      for (final a in twoAtoms.diatomic.atoms) {
        twoAtoms.diatomic.snapElectronegativity(a);
      }
      for (final a in threeAtoms.triatomic.atoms) {
        threeAtoms.triatomic.snapElectronegativity(a);
      }
    }
    notifyListeners();
  }

  void rotateTwoAtomsTo(MpVector2 pointer) {
    final m = twoAtoms.diatomic;
    m.isDragging = true;
    m.angle = angleFromPointer(center: m.position, pointer: pointer);
    notifyListeners();
  }

  void endTwoAtomsDrag() {
    twoAtoms.diatomic.isDragging = false;
    notifyListeners();
  }

  void setTwoBondDipoleVisible(bool v) {
    twoAtoms.viewProperties.bondDipoleVisible = v;
    notifyListeners();
  }

  void setTwoPartialChargesVisible(bool v) {
    twoAtoms.viewProperties.partialChargesVisible = v;
    notifyListeners();
  }

  void setTwoBondCharacterVisible(bool v) {
    twoAtoms.viewProperties.bondCharacterVisible = v;
    notifyListeners();
  }

  void setTwoSurfaceType(SurfaceType t) {
    twoAtoms.viewProperties.surfaceType = t;
    notifyListeners();
  }

  void setTwoEField(bool v) {
    twoAtoms.eFieldEnabled = v;
    notifyListeners();
  }

  void resetTwoAtoms() {
    twoAtoms.reset();
    notifyListeners();
  }

  void rotateThreeAtomsTo(MpVector2 pointer) {
    final m = threeAtoms.triatomic;
    m.isDragging = true;
    m.angle = angleFromPointer(center: m.position, pointer: pointer);
    notifyListeners();
  }

  void dragBondAngleAB(MpVector2 pointer) {
    final m = threeAtoms.triatomic;
    m.isDragging = true;
    m.bondAngleAB = bondAngleFromPointer(
      center: m.position,
      pointer: pointer,
      moleculeAngle: m.angle,
    );
    notifyListeners();
  }

  void dragBondAngleBC(MpVector2 pointer) {
    final m = threeAtoms.triatomic;
    m.isDragging = true;
    m.bondAngleBC = bondAngleFromPointer(
      center: m.position,
      pointer: pointer,
      moleculeAngle: m.angle,
    );
    notifyListeners();
  }

  void endThreeAtomsDrag() {
    threeAtoms.triatomic.isDragging = false;
    notifyListeners();
  }

  void setThreeBondDipolesVisible(bool v) {
    threeAtoms.viewProperties.bondDipolesVisible = v;
    notifyListeners();
  }

  void setThreeMolecularDipoleVisible(bool v) {
    threeAtoms.viewProperties.molecularDipoleVisible = v;
    notifyListeners();
  }

  void setThreePartialChargesVisible(bool v) {
    threeAtoms.viewProperties.partialChargesVisible = v;
    notifyListeners();
  }

  void setThreeEField(bool v) {
    threeAtoms.eFieldEnabled = v;
    notifyListeners();
  }

  void resetThreeAtoms() {
    threeAtoms.reset();
    notifyListeners();
  }
}
