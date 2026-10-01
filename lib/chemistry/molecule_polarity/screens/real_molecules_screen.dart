import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controller/molecule_polarity_controller.dart';
import '../model/mp_preferences.dart';
import '../model/mp_vector2.dart';
import '../model/real_molecules/real_molecules_model.dart';
import '../mp_assets.dart';
import '../mp_constants.dart';
import '../mp_strings.dart';
import '../painters/mp_scene_painters.dart';
import '../painters/real_molecule_mesh_painter.dart';
import '../widgets/mp_controls.dart';
import '../widgets/mp_reset_all_button.dart';
import '../widgets/mp_simulation_shell.dart';

class RealMoleculesScreenBody extends StatefulWidget {
  const RealMoleculesScreenBody({
    super.key,
    required this.controller,
    this.preloadedModel,
  });

  final MoleculePolarityController controller;

  /// When non-null (tests / QA), skips async catalog load.
  final RealMoleculesModel? preloadedModel;

  @override
  State<RealMoleculesScreenBody> createState() =>
      _RealMoleculesScreenBodyState();
}

class _RealMoleculesScreenBodyState extends State<RealMoleculesScreenBody> {
  RealMoleculesModel? _model;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedModel != null) {
      _model = widget.preloadedModel;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final catalog = await RealMoleculeCatalog.load();
      setState(() {
        _model = RealMoleculesModel(
          catalog: catalog,
          preferences: widget.controller.preferences,
        );
      });
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(child: Text('Failed to load molecules: $_error'));
    }
    final model = _model;
    if (model == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final vp = model.viewProperties;
    final flip = model.preferences?.dipoleDirection ==
        DipoleDirection.negativeToPositive;

    return MpSimulationShell(
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) {
                setState(() => model.applyDrag(d.delta.dx, d.delta.dy));
              },
              child: CustomPaint(
                painter: _RealMoleculePainter(model: model, flipDipole: flip),
              ),
            ),
          ),
          Positioned(
            top: MpConstants.controlPanelTop,
            right: MpConstants.horizontalMargin,
            child: MpPanel(
              width: 280,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MpSectionTitle(MpStrings.view),
                  MpCheckbox(
                    label: MpStrings.bondDipoles,
                    value: vp.bondDipolesVisible,
                    onChanged: (v) =>
                        setState(() => vp.bondDipolesVisible = v),
                    trailing: const MpDipoleIcon.bond(),
                  ),
                  MpCheckbox(
                    label: MpStrings.molecularDipole,
                    value: vp.molecularDipoleVisible,
                    onChanged: (v) =>
                        setState(() => vp.molecularDipoleVisible = v),
                    trailing: const MpDipoleIcon.molecular(),
                  ),
                  if (model.isAdvanced)
                    MpCheckbox(
                      label: MpStrings.partialCharges,
                      value: vp.partialChargesVisible,
                      onChanged: (v) =>
                          setState(() => vp.partialChargesVisible = v),
                    ),
                  MpCheckbox(
                    label: MpStrings.atomElectronegativities,
                    value: vp.atomElectronegativitiesVisible,
                    onChanged: (v) => setState(
                      () => vp.atomElectronegativitiesVisible = v,
                    ),
                  ),
                  MpCheckbox(
                    label: MpStrings.atomLabels,
                    value: vp.atomLabelsVisible,
                    onChanged: (v) =>
                        setState(() => vp.atomLabelsVisible = v),
                  ),
                  const MpHSeparator(),
                  const MpSectionTitle(MpStrings.surface),
                  MpRadioColumn<SurfaceType>(
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
                    value: vp.surfaceType,
                    onChanged: (v) => setState(() => vp.surfaceType = v),
                  ),
                  const MpHSeparator(),
                  const MpSectionTitle(MpStrings.model),
                  MpRadioColumn<bool>(
                    items: const [false, true],
                    labels: const [MpStrings.basic, MpStrings.advanced],
                    value: model.isAdvanced,
                    onChanged: (v) => setState(() {
                      model.isAdvanced = v;
                      if (!v) vp.partialChargesVisible = false;
                    }),
                  ),
                ],
              ),
            ),
          ),
          // `RealMoleculesScreenView`: moleculeComboBox.centerX + bottom margin
          Positioned(
            left: 0,
            right: 0,
            bottom: MpConstants.verticalMargin,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '${MpStrings.molecule}:',
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Arial',
                    ),
                  ),
                  const SizedBox(width: 10),
                  MpMoleculeComboBox(
                    value: model.molecule,
                    items: model.catalog.molecules,
                    onChanged: (m) => setState(() => model.selectMolecule(m)),
                  ),
                ],
              ),
            ),
          ),
          if (vp.atomElectronegativitiesVisible)
            Positioned(
              left: 40,
              top: 80,
              child: MpPanel(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Electronegativity',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    for (final s in ['H', 'B', 'C', 'N', 'O', 'F', 'Cl'])
                      Text('$s  ${displayElectronegativity(s)}'),
                  ],
                ),
              ),
            ),
          Positioned(
            right: MpConstants.horizontalMargin,
            bottom: MpConstants.verticalMargin,
            child: MpResetAllButton(
              onPressed: () => setState(model.reset),
            ),
          ),
          const Positioned(
            left: -1000,
            child: SizedBox(
              width: 1,
              height: 1,
              child: Image(
                image: AssetImage(MpAssets.realMoleculesScreenIcon),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RealMoleculePainter extends CustomPainter {
  _RealMoleculePainter({required this.model, required this.flipDipole});

  final RealMoleculesModel model;
  final bool flipDipole;

  @override
  void paint(Canvas canvas, Size size) {
    final mol = model.molecule;
    final q = model.quaternion;
    final cx = size.width / 2;
    final cy = size.height / 2 - 20;
    final center = Offset(cx, cy);
    const scale = RealMoleculeMeshPainter.modelScale;

    // Pass 1: surface background (behind ball-stick), matching SurfaceMesh order.
    RealMoleculeMeshPainter.paintBackground(
      canvas: canvas,
      model: model,
      center: center,
    );

    final projected = <Offset>[];
    final depths = <double>[];
    for (final a in mol.atoms) {
      final r = q.rotate(a.x, a.y, a.z);
      projected.add(Offset(cx + r[0] * scale, cy - r[1] * scale));
      depths.add(r[2]);
    }

    final bondOrder = List.generate(mol.bonds.length, (i) => i);
    bondOrder.sort((i, j) {
      final bi = mol.bonds[i];
      final bj = mol.bonds[j];
      final di = (depths[bi.indexA] + depths[bi.indexB]) / 2;
      final dj = (depths[bj.indexA] + depths[bj.indexB]) / 2;
      return di.compareTo(dj);
    });

    for (final i in bondOrder) {
      final bond = mol.bonds[i];
      final p0 = projected[bond.indexA];
      final p1 = projected[bond.indexB];
      BondPainter.paint(canvas, a: p0, b: p1, width: 10);
      if (model.viewProperties.bondDipolesVisible &&
          bond.dipoleMagnitude > 1e-6) {
        final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        final rd = q.rotate(bond.dipoleX, bond.dipoleY, bond.dipoleZ);
        var vx = rd[0];
        var vy = -rd[1];
        if (flipDipole) {
          vx = -vx;
          vy = -vy;
        }
        final len = math.sqrt(vx * vx + vy * vy);
        if (len > 1e-9) {
          final mag = math.min(bond.dipoleMagnitude / 4, 2.0);
          final bondAngle = math.atan2(p1.dy - p0.dy, p1.dx - p0.dx);
          DipolePainter.paintBondDipole(
            canvas,
            bondCenter: mid,
            dipole: MpVector2.polar(mag, math.atan2(vy, vx)),
            bondAngle: bondAngle,
          );
        }
      }
    }

    final atomOrder = List.generate(mol.atoms.length, (i) => i)
      ..sort((a, b) => depths[a].compareTo(depths[b]));

    final showCharges =
        model.isAdvanced && model.viewProperties.partialChargesVisible;

    for (final i in atomOrder) {
      final atom = mol.atoms[i];
      final p = projected[i];
      final radius = atomDisplayRadius(atom.symbol) * scale;
      AtomPainter.paint(
        canvas,
        center: p,
        radius: radius,
        color: atom.color,
        label: model.viewProperties.atomLabelsVisible ? atom.symbol : '',
        lambert: true,
      );
      if (showCharges) {
        PartialChargePainter.paint(
          canvas,
          atomCenter: p,
          partialCharge: atom.displayPartialCharge,
          atomRadius: radius,
        );
      }
    }

    if (model.viewProperties.molecularDipoleVisible) {
      final md = mol.molecularDipole;
      final rd = q.rotate(md[0], md[1], md[2]);
      var vx = rd[0];
      var vy = -rd[1];
      if (flipDipole) {
        vx = -vx;
        vy = -vy;
      }
      final len = math.sqrt(vx * vx + vy * vy + rd[2] * rd[2]);
      if (len > 1e-6) {
        final mag = math.min(len / 2, 2.0);
        DipolePainter.paintMolecularDipole(
          canvas,
          moleculeCenter: Offset(cx, cy),
          dipole: MpVector2.polar(mag, math.atan2(vy, vx)),
        );
      }
    }

    // Pass 2: surface foreground over molecule.
    RealMoleculeMeshPainter.paintForeground(
      canvas: canvas,
      model: model,
      center: center,
    );
  }

  @override
  bool shouldRepaint(covariant _RealMoleculePainter oldDelegate) => true;
}
