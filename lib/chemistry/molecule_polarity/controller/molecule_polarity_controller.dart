import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:kratos/common/simulation_clock.dart';
import 'package:kratos/chemistry/molecule_polarity/model/atom.dart';
import 'package:kratos/chemistry/molecule_polarity/model/drag_math.dart';
import 'package:kratos/chemistry/molecule_polarity/model/mp_preferences.dart';
import 'package:kratos/chemistry/molecule_polarity/model/mp_vector2.dart';
import 'package:kratos/chemistry/molecule_polarity/model/three_atoms_model.dart';
import 'package:kratos/chemistry/molecule_polarity/model/two_atoms_model.dart';
import 'package:kratos/chemistry/molecule_polarity/mp_constants.dart';

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
  double? _twoAngleTarget;
  double? _threeAngleTarget;
  double? _threeBondABTarget;
  double? _threeBondBCTarget;

  void attachClock(TickerProvider vsync) {
    disposeClock();
    _clock = SimulationClock(fps: 60)..attach(vsync);
    _clock!.onTick = (dt, _) {
      twoAtoms.step(dt);
      threeAtoms.step(dt);
      final dragging =
          twoAtoms.diatomic.isDragging || threeAtoms.triatomic.isDragging;
      if (dragging) {
        _smoothDrag(dt);
      }
      if (dragging ||
          twoAtoms.eFieldEnabled ||
          threeAtoms.eFieldEnabled) {
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

  double _follow(double from, double to, double dt) {
    final t = 1 - math.exp(-MpConstants.angleDragLambda * dt);
    return lerpAngle(from, to, t);
  }

  void _smoothDrag(double dt) {
    if (_twoAngleTarget != null) {
      twoAtoms.diatomic.angle =
          _follow(twoAtoms.diatomic.angle, _twoAngleTarget!, dt);
    }
    final tri = threeAtoms.triatomic;
    if (_threeAngleTarget != null) {
      tri.angle = _follow(tri.angle, _threeAngleTarget!, dt);
    }
    if (_threeBondABTarget != null) {
      tri.bondAngleAB = _follow(tri.bondAngleAB, _threeBondABTarget!, dt);
    }
    if (_threeBondBCTarget != null) {
      tri.bondAngleBC = _follow(tri.bondAngleBC, _threeBondBCTarget!, dt);
    }
  }

  void rotateTwoAtomsTo(MpVector2 pointer) {
    final m = twoAtoms.diatomic;
    m.isDragging = true;
    _twoAngleTarget = angleFromPointer(
      center: m.position,
      pointer: pointer,
      snap: false,
    );
    m.angle = _follow(m.angle, _twoAngleTarget!, 1 / 60);
    notifyListeners();
  }

  void endTwoAtomsDrag() {
    final m = twoAtoms.diatomic;
    m.angle = snapAngleDegrees(m.angle);
    m.isDragging = false;
    _twoAngleTarget = null;
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
    _twoAngleTarget = null;
    twoAtoms.reset();
    notifyListeners();
  }

  void rotateThreeAtomsTo(MpVector2 pointer) {
    final m = threeAtoms.triatomic;
    m.isDragging = true;
    _threeBondABTarget = null;
    _threeBondBCTarget = null;
    _threeAngleTarget = angleFromPointer(
      center: m.position,
      pointer: pointer,
      snap: false,
    );
    m.angle = _follow(m.angle, _threeAngleTarget!, 1 / 60);
    notifyListeners();
  }

  void dragBondAngleAB(MpVector2 pointer) {
    final m = threeAtoms.triatomic;
    m.isDragging = true;
    _threeAngleTarget = null;
    _threeBondBCTarget = null;
    _threeBondABTarget = bondAngleFromPointer(
      center: m.position,
      pointer: pointer,
      moleculeAngle: m.angle,
      snap: false,
    );
    m.bondAngleAB = _follow(m.bondAngleAB, _threeBondABTarget!, 1 / 60);
    notifyListeners();
  }

  void dragBondAngleBC(MpVector2 pointer) {
    final m = threeAtoms.triatomic;
    m.isDragging = true;
    _threeAngleTarget = null;
    _threeBondABTarget = null;
    _threeBondBCTarget = bondAngleFromPointer(
      center: m.position,
      pointer: pointer,
      moleculeAngle: m.angle,
      snap: false,
    );
    m.bondAngleBC = _follow(m.bondAngleBC, _threeBondBCTarget!, 1 / 60);
    notifyListeners();
  }

  void endThreeAtomsDrag() {
    final m = threeAtoms.triatomic;
    m.angle = snapAngleDegrees(m.angle);
    m.bondAngleAB = snapAngleDegrees(m.bondAngleAB);
    m.bondAngleBC = snapAngleDegrees(m.bondAngleBC);
    m.isDragging = false;
    _threeAngleTarget = null;
    _threeBondABTarget = null;
    _threeBondBCTarget = null;
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
    _threeAngleTarget = null;
    _threeBondABTarget = null;
    _threeBondBCTarget = null;
    threeAtoms.reset();
    notifyListeners();
  }
}
