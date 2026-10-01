import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../common/widgets/kratos_reset_all_button.dart';
import '../model/molecule_shapes_model.dart';
import '../model/real_molecule.dart';
import '../model/real_molecule_shape.dart';
import '../model/vec3.dart';
import '../molecule_shapes_strings.dart';
import 'element_colors.dart';
import 'molecule_camera.dart';
import 'molecule_painter.dart';
import 'molecule_shapes_colors.dart';
import 'molecule_shapes_panel.dart';

/// Real Molecules Screen — view / compare only (no bonding edits).
class RealMoleculesScreen extends StatefulWidget {
  const RealMoleculesScreen({super.key, this.model});

  final RealMoleculesModel? model;

  @override
  State<RealMoleculesScreen> createState() => RealMoleculesScreenState();
}

class RealMoleculesScreenState extends State<RealMoleculesScreen>
    with SingleTickerProviderStateMixin {
  late final RealMoleculesModel model;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final MoleculeCamera camera = const MoleculeCamera();

  bool _rotating = false;
  Offset? _lastPointer;
  Size _viewSize = Size.zero;

  /// Snapshot of radial positions before any rotation — rotation never mutates these.
  late List<Vec3> _coordinateFingerprint;

  @override
  void initState() {
    super.initState();
    model = widget.model ?? RealMoleculesModel();
    _coordinateFingerprint = _fingerprint();
    _ticker = createTicker(_onTick)..start();
  }

  List<Vec3> _fingerprint() =>
      model.molecule.radialAtoms.map((atom) => atom.position).toList();

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 1 / 60
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt > 0) {
      model.step(dt);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MoleculeShapesColors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _viewSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
            children: [
              Positioned.fill(
                child: Listener(
                  onPointerDown: _onPointerDown,
                  onPointerMove: _onPointerMove,
                  onPointerUp: (_) => _endPointer(),
                  onPointerCancel: (_) => _endPointer(),
                  child: CustomPaint(
                    painter: MoleculePainter(model: model, camera: camera),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Positioned(
                top: 20,
                left: 0,
                right: 200,
                child: Align(
                  alignment: const Alignment(-0.15, 0),
                  child: _realModelRadios(),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _rightControls(),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: _namePanel(),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: KratosResetAllButton(
                  onPressed: () {
                    model.reset();
                    _coordinateFingerprint = _fingerprint();
                    setState(() {});
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _realModelRadios() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _radio(true, MoleculeShapesStrings.realView),
        const SizedBox(width: 30),
        _radio(false, MoleculeShapesStrings.modelView),
      ],
    );
  }

  Widget _radio(bool realValue, String label) {
    final selected = model.showRealView == realValue;
    return InkWell(
      onTap: () {
        model.setShowRealView(realValue);
        _coordinateFingerprint = _fingerprint();
        setState(() {});
      },
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MoleculeShapesColors.controlPanelText, width: 2),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: MoleculeShapesColors.controlPanelText,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: MoleculeShapesColors.controlPanelText,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rightControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MoleculeShapesPanel(
          title: MoleculeShapesStrings.molecule,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<RealMoleculeShape>(
              value: model.shape,
              dropdownColor: const Color(0xFF333333),
              isExpanded: true,
              items: [
                for (final shape in tab2Molecules)
                  DropdownMenuItem(
                    value: shape,
                    child: Text(
                      toSubscriptFormula(shape.displayName),
                      style: const TextStyle(
                        color: MoleculeShapesColors.controlPanelText,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
              onChanged: (shape) {
                if (shape == null) {
                  return;
                }
                model.selectMolecule(shape);
                _coordinateFingerprint = _fingerprint();
                setState(() {});
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        MoleculeShapesPanel(
          title: MoleculeShapesStrings.options,
          child: Column(
            children: [
              MoleculeShapesCheckbox(
                value: model.showLonePairs,
                label: MoleculeShapesStrings.showLonePairs,
                onChanged: (v) => setState(() => model.showLonePairs = v),
              ),
              const SizedBox(height: 8),
              MoleculeShapesCheckbox(
                value: model.showBondAngles,
                label: MoleculeShapesStrings.showBondAngles,
                onChanged: (v) => setState(() => model.showBondAngles = v),
              ),
              const SizedBox(height: 8),
              MoleculeShapesCheckbox(
                value: model.preferences.showOuterLonePairs,
                label: MoleculeShapesStrings.showOuterLonePairs,
                onChanged: (v) =>
                    setState(() => model.preferences.showOuterLonePairs = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _namePanel() {
    return MoleculeShapesPanel(
      title: MoleculeShapesStrings.geometryName,
      width: 320,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                MoleculeShapesCheckbox(
                  value: model.showElectronGeometry,
                  label: MoleculeShapesStrings.electronGeometry,
                  labelColor: MoleculeShapesColors.electronGeometryName,
                  onChanged: (v) => setState(() => model.showElectronGeometry = v),
                ),
                const SizedBox(height: 6),
                Text(
                  model.showElectronGeometry ? model.electronGeometryLabel : '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MoleculeShapesColors.electronGeometryName,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                MoleculeShapesCheckbox(
                  value: model.showMoleculeGeometry,
                  label: MoleculeShapesStrings.moleculeGeometry,
                  labelColor: MoleculeShapesColors.moleculeGeometryName,
                  onChanged: (v) => setState(() => model.showMoleculeGeometry = v),
                ),
                const SizedBox(height: 6),
                Text(
                  model.showMoleculeGeometry ? model.moleculeGeometryLabel : '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MoleculeShapesColors.moleculeGeometryName,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    _lastPointer = event.localPosition;
    _rotating = true;
  }

  void _onPointerMove(PointerMoveEvent event) {
    final last = _lastPointer;
    if (!_rotating || last == null || _viewSize == Size.zero) {
      return;
    }
    final current = event.localPosition;
    final delta = current - last;
    model.rotateByPointer(delta.dx, delta.dy);
    _lastPointer = current;
    setState(() {});
  }

  void _endPointer() {
    _rotating = false;
    _lastPointer = null;
  }

  /// Exposed for tests: local coordinates must survive rotation.
  bool coordinatesUnchangedByRotation() {
    final now = _fingerprint();
    if (now.length != _coordinateFingerprint.length) {
      return false;
    }
    for (var i = 0; i < now.length; i++) {
      if (!now[i].almostEquals(_coordinateFingerprint[i])) {
        return false;
      }
    }
    return true;
  }
}
