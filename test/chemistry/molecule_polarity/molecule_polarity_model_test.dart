import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/molecule_polarity/model/bond_character.dart';
import 'package:kratos/chemistry/molecule_polarity/model/diatomic_molecule.dart';
import 'package:kratos/chemistry/molecule_polarity/model/drag_math.dart';
import 'package:kratos/chemistry/molecule_polarity/model/mp_preferences.dart';
import 'package:kratos/chemistry/molecule_polarity/model/mp_vector2.dart';
import 'package:kratos/chemistry/molecule_polarity/model/normalize_angle.dart';
import 'package:kratos/chemistry/molecule_polarity/model/three_atoms_model.dart';
import 'package:kratos/chemistry/molecule_polarity/model/triatomic_molecule.dart';
import 'package:kratos/chemistry/molecule_polarity/model/two_atoms_model.dart';
import 'package:kratos/chemistry/molecule_polarity/mp_constants.dart';
import 'package:kratos/chemistry/molecule_polarity/painters/mp_scene_painters.dart';

void main() {
  group('normalizeAngle', () {
    test('wraps into [min, min+2π)', () {
      expect(normalizeAngle(0), 0);
      expect(normalizeAngle(2 * math.pi), closeTo(0, 1e-12));
      expect(normalizeAngle(-0.1, -math.pi), closeTo(-0.1, 1e-12));
      expect(
        normalizeAngle(math.pi + 0.1, -math.pi),
        closeTo(-math.pi + 0.1, 1e-12),
      );
    });
  });

  group('DiatomicMolecule', () {
    test('defaults EN A=2 B=3 and bond length', () {
      final m = DiatomicMolecule();
      expect(m.atomA.electronegativity, 2);
      expect(m.atomB.electronegativity, 3);
      expect(m.bond.length, closeTo(MpConstants.bondLength, 1e-9));
      expect(m.deltaEN, 1);
      expect(m.atomA.partialCharge, 1);
      expect(m.atomB.partialCharge, -1);
    });

    test('dipole magnitude equals |deltaEN|', () {
      final m = DiatomicMolecule();
      expect(m.bond.dipoleMagnitude, 1);
      m.setElectronegativity(m.atomA, 4);
      m.setElectronegativity(m.atomB, 2);
      expect(m.deltaEN, -2);
      expect(m.bond.dipoleMagnitude, 2);
      expect(m.atomA.partialCharge, -2);
      expect(m.atomB.partialCharge, 2);
    });

    test('IUPAC dipole direction rotates 180°', () {
      final m = DiatomicMolecule();
      final a = m.bond.dipole(DipoleDirection.positiveToNegative);
      final b = m.bond.dipole(DipoleDirection.negativeToPositive);
      expect(b.x, closeTo(-a.x, 1e-9));
      expect(b.y, closeTo(-a.y, 1e-9));
    });

    test('rotation updates atom positions clockwise', () {
      final m = DiatomicMolecule(angle: 0);
      final b0 = m.atomB.position;
      m.angle = math.pi / 2;
      // angle π/2 with +y down → B moves toward +y
      expect(m.atomB.position.x, closeTo(m.position.x, 1e-9));
      expect(
        m.atomB.position.y,
        closeTo(m.position.y + MpConstants.bondLength / 2, 1e-9),
      );
      expect(m.atomB.position, isNot(b0));
    });

    test('hint arrows hide on angle change, not EN; reset restores', () {
      final m = DiatomicMolecule();
      expect(m.showHintArrows, true);
      m.setElectronegativity(m.atomA, 3.2);
      expect(m.showHintArrows, true); // EN must not hide
      m.angle = 0.5;
      expect(m.showHintArrows, false);
      m.reset();
      expect(m.showHintArrows, true);
      expect(m.angle, 0);
    });
  });

  group('TriatomicMolecule', () {
    test('default bond angles and partial charges', () {
      final m = TriatomicMolecule();
      expect(m.bondAngleAB, closeTo(5 * math.pi / 6, 1e-12));
      expect(m.bondAngleBC, closeTo(math.pi / 6, 1e-12));
      expect(m.atomB.position, m.position);
      // EN A=2 B=3 C=2 → deltaAB=-1 deltaCB=-1
      expect(m.atomA.partialCharge, 1);
      expect(m.atomC.partialCharge, 1);
      expect(m.atomB.partialCharge, -2);
    });

    test('deltaEN is molecular dipole magnitude', () {
      final m = TriatomicMolecule();
      expect(m.deltaEN, closeTo(m.dipoleMagnitude(), 1e-12));
    });
  });

  group('TwoAtomsModel / E-field', () {
    test('step aligns toward field when enabled', () {
      final model = TwoAtomsModel();
      model.diatomic.angle = math.pi / 2;
      model.eFieldEnabled = true;
      for (var i = 0; i < 200; i++) {
        model.step(1 / 60);
      }
      expect(model.diatomic.angle.abs(), lessThan(0.2));
    });

    test('dragging blocks E-field rotation', () {
      final model = TwoAtomsModel();
      model.diatomic.angle = math.pi / 2;
      model.eFieldEnabled = true;
      model.diatomic.isDragging = true;
      final before = model.diatomic.angle;
      model.step(1 / 60);
      expect(model.diatomic.angle, before);
    });

    test('reset clears e-field and view props', () {
      final model = TwoAtomsModel();
      model.eFieldEnabled = true;
      model.viewProperties.partialChargesVisible = true;
      model.viewProperties.surfaceType = SurfaceType.electronDensity;
      model.reset();
      expect(model.eFieldEnabled, false);
      expect(model.viewProperties.partialChargesVisible, false);
      expect(model.viewProperties.surfaceType, SurfaceType.none);
      expect(model.viewProperties.bondDipoleVisible, true);
    });
  });

  group('ThreeAtomsModel', () {
    test('view defaults', () {
      final model = ThreeAtomsModel();
      expect(model.viewProperties.bondDipolesVisible, false);
      expect(model.viewProperties.molecularDipoleVisible, true);
    });
  });

  group('helpers', () {
    test('bondCharacterFraction', () {
      expect(bondCharacterFraction(0), 0);
      expect(bondCharacterFraction(2), 1);
      expect(bondCharacterFraction(1), 0.5);
    });

    test('angleFromPointer snaps to 5°', () {
      final a = angleFromPointer(
        center: MpVector2.zero,
        pointer: const MpVector2(1, 0.01),
      );
      expect(a % (5 * math.pi / 180), closeTo(0, 1e-9));
    });

    test('lerpAngle damps toward target without wrapping jump', () {
      final next = lerpAngle(0, math.pi / 2, 0.32);
      expect(next, greaterThan(0));
      expect(next, lessThan(math.pi / 2));
    });
  });

  group('PlatesPainter layout', () {
    test('right plate stays left of the View panel', () {
      const panelLeft = MpConstants.layoutWidth -
          MpConstants.horizontalMargin -
          MpConstants.controlPanelWidth;
      final twoRight = PlatesPainter.rightEdge(
        moleculeX: MpConstants.twoAtomsMoleculeX,
        spacing: MpConstants.platesSpacingTwoAtoms,
      );
      final threeRight = PlatesPainter.rightEdge(
        moleculeX: MpConstants.threeAtomsMoleculeX,
        spacing: MpConstants.platesSpacingThreeAtoms,
      );
      expect(twoRight, lessThan(panelLeft));
      expect(threeRight, lessThan(panelLeft));
    });
  });
}
