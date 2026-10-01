import 'package:flutter/material.dart';

import '../controller/molecule_polarity_controller.dart';
import '../model/mp_preferences.dart';
import '../model/mp_vector2.dart';
import '../model/triatomic_molecule.dart';
import '../mp_constants.dart';
import '../mp_strings.dart';
import '../painters/mp_scene_painters.dart';
import '../widgets/mp_controls.dart';
import '../widgets/mp_reset_all_button.dart';
import '../widgets/mp_simulation_shell.dart';

class ThreeAtomsScreenBody extends StatefulWidget {
  const ThreeAtomsScreenBody({super.key, required this.controller});

  final MoleculePolarityController controller;

  @override
  State<ThreeAtomsScreenBody> createState() => _ThreeAtomsScreenBodyState();
}

class _ThreeAtomsScreenBodyState extends State<ThreeAtomsScreenBody> {
  MoleculePolarityController get c => widget.controller;

  /// null = rotate molecule; 'A' / 'C' = bond angle
  String? _dragTarget;

  @override
  void initState() {
    super.initState();
    c.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    c.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = c.threeAtoms;
    final mol = model.triatomic;
    final vp = model.viewProperties;
    final dir = c.preferences.dipoleDirection;

    return MpSimulationShell(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => _onStart(d.localPosition, mol),
              onPanUpdate: (d) => _onUpdate(d.localPosition, mol),
              onPanEnd: (_) {
                _dragTarget = null;
                c.endThreeAtomsDrag();
              },
              child: CustomPaint(
                painter: _ThreeAtomsScenePainter(
                  molecule: mol,
                  bondDipolesVisible: vp.bondDipolesVisible,
                  molecularDipoleVisible: vp.molecularDipoleVisible,
                  partialChargesVisible: vp.partialChargesVisible,
                  eField: model.eFieldEnabled,
                  dipoleDirection: dir,
                ),
              ),
            ),
          ),
          Positioned(
            top: MpConstants.controlPanelTop,
            right: MpConstants.horizontalMargin,
            child: MpPanel(
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MpSectionTitle(MpStrings.view),
                  MpCheckbox(
                    label: MpStrings.bondDipoles,
                    value: vp.bondDipolesVisible,
                    onChanged: c.setThreeBondDipolesVisible,
                    trailing: const MpDipoleIcon.bond(),
                  ),
                  MpCheckbox(
                    label: MpStrings.molecularDipole,
                    value: vp.molecularDipoleVisible,
                    onChanged: c.setThreeMolecularDipoleVisible,
                    trailing: const MpDipoleIcon.molecular(),
                  ),
                  MpCheckbox(
                    label: MpStrings.partialCharges,
                    value: vp.partialChargesVisible,
                    onChanged: c.setThreePartialChargesVisible,
                  ),
                  const MpHSeparator(),
                  const MpSectionTitle(MpStrings.electricField),
                  MpToggleSwitch(
                    value: model.eFieldEnabled,
                    onChanged: c.setThreeEField,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 40,
            bottom: 40,
            child: Row(
              children: [
                for (final atom in [mol.atomA, mol.atomB, mol.atomC]) ...[
                  MpElectronegativityPanel(
                    atomLabel: atom.label,
                    color: atom.color,
                    value: atom.electronegativity,
                    onChanged: (v) {
                      c.setEnDragging(true);
                      c.setAtomEN(atom, v);
                    },
                    onChangeEnd: (v) {
                      c.setAtomEN(atom, v, snap: true);
                      c.setEnDragging(false);
                    },
                  ),
                  const SizedBox(width: 16),
                ],
              ],
            ),
          ),
          Positioned(
            right: MpConstants.horizontalMargin,
            bottom: MpConstants.verticalMargin,
            child: MpResetAllButton(onPressed: c.resetThreeAtoms),
          ),
        ],
      ),
    );
  }

  void _onStart(Offset local, TriatomicMolecule mol) {
    final p = MpVector2(local.dx, local.dy);
    final hitA = p.distance(mol.atomA.position) < mol.atomA.radius * 1.3;
    final hitC = p.distance(mol.atomC.position) < mol.atomC.radius * 1.3;
    if (hitA) {
      _dragTarget = 'A';
    } else if (hitC) {
      _dragTarget = 'C';
    } else {
      _dragTarget = null; // rotate
    }
    _onUpdate(local, mol);
  }

  void _onUpdate(Offset local, TriatomicMolecule mol) {
    final p = MpVector2(local.dx, local.dy);
    if (_dragTarget == 'A') {
      c.dragBondAngleAB(p);
    } else if (_dragTarget == 'C') {
      c.dragBondAngleBC(p);
    } else {
      c.rotateThreeAtomsTo(p);
    }
  }
}

class _ThreeAtomsScenePainter extends CustomPainter {
  _ThreeAtomsScenePainter({
    required this.molecule,
    required this.bondDipolesVisible,
    required this.molecularDipoleVisible,
    required this.partialChargesVisible,
    required this.eField,
    required this.dipoleDirection,
  });

  final TriatomicMolecule molecule;
  final bool bondDipolesVisible;
  final bool molecularDipoleVisible;
  final bool partialChargesVisible;
  final bool eField;
  final DipoleDirection dipoleDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (eField) {
      PlatesPainter.paint(
        canvas,
        layoutSize: size,
        spacing: MpConstants.platesSpacingThreeAtoms,
      );
    }

    final a = Offset(molecule.atomA.position.x, molecule.atomA.position.y);
    final b = Offset(molecule.atomB.position.x, molecule.atomB.position.y);
    final c = Offset(molecule.atomC.position.x, molecule.atomC.position.y);
    final r = molecule.atomA.radius;

    BondPainter.paint(canvas, a: a, b: b);
    BondPainter.paint(canvas, a: b, b: c);

    for (final atom in molecule.atoms) {
      AtomPainter.paint(
        canvas,
        center: Offset(atom.position.x, atom.position.y),
        radius: atom.radius,
        color: atom.color,
        label: atom.label,
      );
    }

    if (partialChargesVisible) {
      for (final atom in molecule.atoms) {
        PartialChargePainter.paint(
          canvas,
          atomCenter: Offset(atom.position.x, atom.position.y),
          partialCharge: atom.partialCharge,
          atomRadius: r,
        );
      }
    }

    if (bondDipolesVisible) {
      DipolePainter.paintBondDipole(
        canvas,
        bondCenter: Offset(
          (a.dx + b.dx) / 2,
          (a.dy + b.dy) / 2,
        ),
        dipole: molecule.bondAB.dipole(dipoleDirection),
        bondAngle: molecule.bondAB.angle,
      );
      DipolePainter.paintBondDipole(
        canvas,
        bondCenter: Offset(
          (b.dx + c.dx) / 2,
          (b.dy + c.dy) / 2,
        ),
        dipole: molecule.bondBC.dipole(dipoleDirection),
        bondAngle: molecule.bondBC.angle,
      );
    }

    if (molecularDipoleVisible) {
      DipolePainter.paintMolecularDipole(
        canvas,
        moleculeCenter: b,
        dipole: molecule.dipole(dipoleDirection),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ThreeAtomsScenePainter oldDelegate) => true;
}
