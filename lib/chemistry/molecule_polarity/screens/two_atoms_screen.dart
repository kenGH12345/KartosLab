import 'package:flutter/material.dart';

import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

import '../controller/molecule_polarity_controller.dart';
import '../model/bond_character.dart';
import '../model/diatomic_molecule.dart';
import '../model/mp_preferences.dart';
import '../model/mp_vector2.dart';
import '../mp_colors.dart';
import '../mp_constants.dart';
import '../mp_strings.dart';
import '../painters/mp_scene_painters.dart';
import '../widgets/mp_controls.dart';
import '../widgets/mp_simulation_shell.dart';

class TwoAtomsScreenBody extends StatefulWidget {
  const TwoAtomsScreenBody({super.key, required this.controller});

  final MoleculePolarityController controller;

  @override
  State<TwoAtomsScreenBody> createState() => _TwoAtomsScreenBodyState();
}

class _TwoAtomsScreenBodyState extends State<TwoAtomsScreenBody> {
  MoleculePolarityController get c => widget.controller;

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
    // Clock shared — don't dispose here if multi-tab; home owns lifecycle.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = c.twoAtoms;
    final mol = model.diatomic;
    final vp = model.viewProperties;
    final dir = c.preferences.dipoleDirection;

    return MpSimulationShell(
      child: Stack(
        children: [
          // Scene
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) => _rotate(e.localPosition, mol),
              onPointerMove: (e) {
                if (c.twoAtoms.diatomic.isDragging) {
                  _rotate(e.localPosition, mol);
                }
              },
              onPointerUp: (_) => c.endTwoAtomsDrag(),
              onPointerCancel: (_) => c.endTwoAtomsDrag(),
              child: CustomPaint(
                painter: _TwoAtomsScenePainter(
                  molecule: mol,
                  bondDipoleVisible: vp.bondDipoleVisible,
                  partialChargesVisible: vp.partialChargesVisible,
                  surfaceType: vp.surfaceType,
                  eField: model.eFieldEnabled,
                  dipoleDirection: dir,
                  showHintArrows: mol.showHintArrows,
                ),
              ),
            ),
          ),

          // Control panel (right)
          Positioned(
            top: MpConstants.controlPanelTop,
            right: MpConstants.horizontalMargin,
            child: MpPanel(
              width: MpConstants.controlPanelWidth,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MpSectionTitle(MpStrings.view),
                    MpCheckbox(
                      label: MpStrings.bondDipole,
                      value: vp.bondDipoleVisible,
                      onChanged: c.setTwoBondDipoleVisible,
                      trailing: const MpDipoleIcon.bond(),
                    ),
                    MpCheckbox(
                      label: MpStrings.partialCharges,
                      value: vp.partialChargesVisible,
                      onChanged: c.setTwoPartialChargesVisible,
                    ),
                    MpCheckbox(
                      label: MpStrings.bondCharacter,
                      value: vp.bondCharacterVisible,
                      onChanged: c.setTwoBondCharacterVisible,
                    ),
                    const MpHSeparator(),
                    const MpSectionTitle(MpStrings.surface),
                    _SurfaceRadios(
                      value: vp.surfaceType,
                      onChanged: c.setTwoSurfaceType,
                    ),
                    const MpHSeparator(),
                    const MpSectionTitle(MpStrings.electricField),
                    MpToggleSwitch(
                      value: model.eFieldEnabled,
                      onChanged: c.setTwoEField,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // EN panels centered under molecule (`TwoAtomsScreenView` panelsVBox)
          Positioned(
            left: MpConstants.twoAtomsMoleculeX - 210,
            bottom: 25,
            child: Row(
              children: [
                MpElectronegativityPanel(
                  atomLabel: mol.atomA.label,
                  color: mol.atomA.color,
                  value: mol.atomA.electronegativity,
                  onChanged: (v) {
                    c.setEnDragging(true);
                    c.setAtomEN(mol.atomA, v);
                  },
                  onChangeEnd: (v) {
                    c.setAtomEN(mol.atomA, v, snap: true);
                    c.setEnDragging(false);
                  },
                ),
                const SizedBox(width: 10),
                MpElectronegativityPanel(
                  atomLabel: mol.atomB.label,
                  color: mol.atomB.color,
                  value: mol.atomB.electronegativity,
                  onChanged: (v) {
                    c.setEnDragging(true);
                    c.setAtomEN(mol.atomB, v);
                  },
                  onChangeEnd: (v) {
                    c.setAtomEN(mol.atomB, v, snap: true);
                    c.setEnDragging(false);
                  },
                ),
              ],
            ),
          ),

          // Bond character
          if (vp.bondCharacterVisible)
            Positioned(
              left: 280,
              bottom: 160,
              child: _BondCharacterReadout(
                fraction: bondCharacterFraction(mol.bond.dipoleMagnitude),
              ),
            ),

          // Reset
          Positioned(
            right: MpConstants.horizontalMargin,
            bottom: MpConstants.verticalMargin,
            child: KratosResetAllButton(
              onPressed: c.resetTwoAtoms,
              radius: 20.5,
            ),
          ),
        ],
      ),
    );
  }

  void _rotate(Offset local, DiatomicMolecule mol) {
    c.rotateTwoAtomsTo(MpVector2(local.dx, local.dy));
  }
}

class _SurfaceRadios extends StatelessWidget {
  const _SurfaceRadios({required this.value, required this.onChanged});

  final SurfaceType value;
  final ValueChanged<SurfaceType> onChanged;

  @override
  Widget build(BuildContext context) {
    return MpRadioColumn<SurfaceType>(
      items: const [
        SurfaceType.none,
        SurfaceType.electrostaticPotential,
        SurfaceType.electronDensity,
      ],
      labels: const [
        MpStrings.none,
        MpStrings.electrostaticPotential,
        MpStrings.electronDensity,
      ],
      value: value,
      onChanged: onChanged,
    );
  }
}

class _BondCharacterReadout extends StatelessWidget {
  const _BondCharacterReadout({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return MpPanel(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            MpStrings.bondCharacter,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: CustomPaint(
              painter: _BondCharacterBarPainter(fraction: fraction),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(MpStrings.covalent, style: TextStyle(fontSize: 12)),
              Text(MpStrings.ionic, style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BondCharacterBarPainter extends CustomPainter {
  _BondCharacterBarPainter({required this.fraction});

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height / 2 - 3, size.width, 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(track, Paint()..color = const Color(0xFFCCCCCC));
    final x = fraction.clamp(0.0, 1.0) * size.width;
    canvas.drawCircle(
      Offset(x, size.height / 2),
      8,
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _BondCharacterBarPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}

class _TwoAtomsScenePainter extends CustomPainter {
  _TwoAtomsScenePainter({
    required this.molecule,
    required this.bondDipoleVisible,
    required this.partialChargesVisible,
    required this.surfaceType,
    required this.eField,
    required this.dipoleDirection,
    required this.showHintArrows,
  });

  final DiatomicMolecule molecule;
  final bool bondDipoleVisible;
  final bool partialChargesVisible;
  final SurfaceType surfaceType;
  final bool eField;
  final DipoleDirection dipoleDirection;
  final bool showHintArrows;

  @override
  void paint(Canvas canvas, Size size) {
    if (eField) {
      PlatesPainter.paint(
        canvas,
        moleculeCenter: Offset(molecule.position.x, molecule.position.y),
        spacing: MpConstants.platesSpacingTwoAtoms,
      );
    }

    final a = Offset(molecule.atomA.position.x, molecule.atomA.position.y);
    final b = Offset(molecule.atomB.position.x, molecule.atomB.position.y);
    final r = molecule.atomA.radius;

    if (surfaceType != SurfaceType.none) {
      final colors = surfaceType == SurfaceType.electronDensity
          ? [MpColors.surfaceBwBlack, MpColors.surfaceBwWhite]
          : [
              MpColors.surfaceRwbRed,
              MpColors.surfaceRwbWhite,
              MpColors.surfaceRwbBlue,
            ];
      Surface2dPainter.paint(
        canvas,
        a: a,
        b: b,
        radius: r * 1.15,
        gradientColors: colors,
        deltaEN: molecule.deltaEN,
      );
    }

    BondPainter.paint(canvas, a: a, b: b);
    AtomPainter.paint(
      canvas,
      center: a,
      radius: r,
      color: molecule.atomA.color,
      label: molecule.atomA.label,
    );
    AtomPainter.paint(
      canvas,
      center: b,
      radius: r,
      color: molecule.atomB.color,
      label: molecule.atomB.label,
    );

    // Layer order: hints → partial charges → bond dipole (`DiatomicMoleculeNode`)
    if (showHintArrows) {
      final molC = Offset(molecule.position.x, molecule.position.y);
      TranslateHintArrowsPainter.paint(
        canvas,
        atomCenter: a,
        moleculeCenter: molC,
        atomRadius: r,
        color: molecule.atomA.color,
      );
      TranslateHintArrowsPainter.paint(
        canvas,
        atomCenter: b,
        moleculeCenter: molC,
        atomRadius: r,
        color: molecule.atomB.color,
      );
    }

    if (partialChargesVisible) {
      PartialChargePainter.paint(
        canvas,
        atomCenter: a,
        partialCharge: molecule.atomA.partialCharge,
        atomRadius: r,
      );
      PartialChargePainter.paint(
        canvas,
        atomCenter: b,
        partialCharge: molecule.atomB.partialCharge,
        atomRadius: r,
      );
    }

    if (bondDipoleVisible) {
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      final dipole = molecule.bond.dipole(dipoleDirection);
      DipolePainter.paintBondDipole(
        canvas,
        bondCenter: mid,
        dipole: dipole,
        bondAngle: molecule.bond.angle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TwoAtomsScenePainter oldDelegate) => true;
}
