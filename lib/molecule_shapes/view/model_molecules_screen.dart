import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../common/widgets/kratos_reset_all_button.dart';
import '../model/molecule_shapes_model.dart';
import '../model/pair_group.dart';
import '../molecule_shapes_strings.dart';
import 'bond_thumbnail_painter.dart';
import 'molecule_camera.dart';
import 'molecule_painter.dart';
import 'molecule_shapes_colors.dart';
import 'molecule_shapes_panel.dart';

/// Model Screen — 3D VSEPR playground with bonding / lone-pair controls.
class ModelMoleculesScreen extends StatefulWidget {
  const ModelMoleculesScreen({super.key, this.model});

  final ModelMoleculesModel? model;

  @override
  State<ModelMoleculesScreen> createState() => ModelMoleculesScreenState();
}

class ModelMoleculesScreenState extends State<ModelMoleculesScreen>
    with SingleTickerProviderStateMixin {
  late final ModelMoleculesModel model;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  final MoleculeCamera camera = const MoleculeCamera();

  PairGroup? _dragged;
  bool _rotating = false;
  Offset? _lastPointer;
  Size _viewSize = Size.zero;

  @override
  void initState() {
    super.initState();
    model = widget.model ?? ModelMoleculesModel();
    _ticker = createTicker(_onTick)..start();
  }

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
                  onPointerUp: _onPointerUp,
                  onPointerCancel: _onPointerUp,
                  child: CustomPaint(
                    painter: MoleculePainter(model: model, camera: camera),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: _buildRightControls(),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: _buildNamePanel(),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: KratosResetAllButton(onPressed: () {
                  model.reset();
                  setState(() {});
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRightControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MoleculeShapesPanel(
          title: MoleculeShapesStrings.bonding,
          child: Column(
            children: [
              _bondRow(1),
              const SizedBox(height: 10),
              _bondRow(2),
              const SizedBox(height: 10),
              _bondRow(3),
            ],
          ),
        ),
        const SizedBox(height: 15),
        MoleculeShapesPanel(
          title: MoleculeShapesStrings.lonePair,
          child: _bondRow(0),
        ),
        const SizedBox(height: 15),
        _removeAllButton(),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _bondRow(int order) {
    final canAdd = model.canAddPairGroup(order);
    final canRemove = model.molecule
        .bondsAround(model.molecule.centralAtom!)
        .any((bond) => bond.order == order);
    // BondGroupNode: 120×42 bond preview / 78×55 lone-pair preview + remove X.
    final height = order == 0 ? 55.0 : 42.0;
    return Row(
      children: [
        Expanded(
          child: Opacity(
            opacity: canAdd ? 1 : 0.4,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canAdd
                    ? () {
                        model.addPairGroup(order);
                        setState(() {});
                      }
                    : null,
                child: SizedBox(
                  height: height,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: BondThumbnailPainter(order: order),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        RemovePairGroupButton(
          enabled: canRemove,
          onPressed: () {
            model.removePairGroup(order);
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _removeAllButton() {
    final enabled = model.molecule.radialGroups.isNotEmpty;
    return SizedBox(
      width: 280,
      child: Material(
        color: enabled
            ? MoleculeShapesColors.removeButtonBackground
            : MoleculeShapesColors.removeButtonBackground.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: enabled
              ? () {
                  model.removeAll();
                  setState(() {});
                }
              : null,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              MoleculeShapesStrings.removeAll,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: MoleculeShapesColors.removeButtonText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNamePanel() {
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
    if (_viewSize == Size.zero) {
      return;
    }
    _lastPointer = event.localPosition;
    final hit = _pickRadial(event.localPosition);
    if (hit != null) {
      _dragged = hit;
      hit.userControlled = true;
      _rotating = false;
    } else if (_dragged == null) {
      _rotating = true;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    final last = _lastPointer;
    if (last == null || _viewSize == Size.zero) {
      return;
    }
    final current = event.localPosition;
    if (_dragged != null) {
      final distance = _dragged!.isLonePair
          ? PairGroup.lonePairDistance
          : (model.molecule.parentBond(_dragged!)?.length ??
              PairGroup.bondedPairDistance);
      final hit = camera.hitSphereLocal(
        screen: current,
        size: _viewSize,
        quaternion: model.quaternion,
        radius: distance,
        preferred: _dragged!.position,
      );
      if (hit != null) {
        _dragged!.dragToPosition(hit.withMagnitude(distance));
      }
    } else if (_rotating) {
      final delta = current - last;
      model.rotateByPointer(delta.dx, delta.dy);
    }
    _lastPointer = current;
    setState(() {});
  }

  void _onPointerUp(PointerEvent event) {
    _dragged?.userControlled = false;
    _dragged = null;
    _rotating = false;
    _lastPointer = null;
  }

  PairGroup? _pickRadial(Offset screen) {
    PairGroup? best;
    var bestDepth = double.negativeInfinity;
    final candidates = <PairGroup>[
      ...model.molecule.radialAtoms,
      if (model.showLonePairs) ...model.molecule.radialLonePairs,
    ];
    for (final group in candidates) {
      final world = model.quaternion.rotate(group.position);
      final projected = camera.project(world, _viewSize);
      final scale = camera.scaleAt(world, _viewSize);
      final hitR = (group.isLonePair ? 3.0 : MoleculePainter.atomRadius) * scale * 1.4;
      if ((projected - screen).distance <= hitR) {
        final depth = camera.depth(world);
        // Prefer nearer (smaller depth along camera forward? our depth: larger = farther)
        // Pick the closest to camera = smallest depth value if looking along +forward from cam...
        // camera.depth = (world - cam) · forward, forward points toward origin from cam,
        // so larger depth means farther from camera along view. Prefer smaller depth.
        if (best == null || depth < bestDepth) {
          // wait - if larger = farther, we want smaller depth for nearer
          bestDepth = depth;
          best = group;
        }
      }
    }
    return best;
  }
}
