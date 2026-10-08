import 'package:flutter/material.dart';

import '../../applications/model/buoyancy_applications_model.dart';
import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../layout/buoyancy_global_layout_spec.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';
import '../../rendering/texture/buoyancy_texture_asset.dart';
import '../../rendering/transform/bvec3.dart';
import '../../rendering/transform/buoyancy_three_transform.dart';
import '../../shared/application_mode.dart';
import '../../shared/display_properties.dart';
import '../../shared/widgets/buoyancy_accordion_stub.dart';
import '../../shared/widgets/buoyancy_block_control_panel.dart';
import '../../shared/widgets/buoyancy_fluid_panel.dart';
import '../../shared/widgets/buoyancy_forces_panel.dart';
import '../../shared/widgets/buoyancy_pool_scale_height_control.dart';
import '../../domain/material/buoyancy_material.dart';
import '../composer/applications_composer.dart';
import '../../buoyancy_strings.dart';

/// Applications screen — layout from `BuoyancyApplicationsScreenView.ts`.
class BuoyancyApplicationsScreen extends StatefulWidget {
  const BuoyancyApplicationsScreen({super.key, this.model});
  final BuoyancyApplicationsModel? model;

  @override
  State<BuoyancyApplicationsScreen> createState() =>
      _BuoyancyApplicationsScreenState();
}

class _BuoyancyApplicationsScreenState extends State<BuoyancyApplicationsScreen> {
  late final bool _ownsModel = widget.model == null;
  late final BuoyancyApplicationsModel _model =
      widget.model ?? BuoyancyApplicationsModel();
  final _composer = ApplicationsComposer();
  final _display = BuoyancyDisplayProperties();
  bool _densityExpanded = false;
  bool _submergedExpanded = false;

  static final List<BuoyancyMaterial> _boatBlockMaterials = [
    ...BuoyancyMaterial.simpleMassMaterials,
    BuoyancyMaterial.customSolid(1000),
    BuoyancyMaterial.materialX,
    BuoyancyMaterial.materialY,
  ];

  static final List<BuoyancyMaterial> _bottleInteriorMaterials = [
    BuoyancyMaterial.air,
    BuoyancyMaterial.gasoline,
    BuoyancyMaterial.oil,
    BuoyancyMaterial.water,
    BuoyancyMaterial.seawater,
    BuoyancyMaterial.honey,
    BuoyancyMaterial.mercury,
  ];

  @override
  void dispose() {
    if (_ownsModel) {
      _model.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final playSize = Size(c.maxWidth, c.maxHeight);
        final frame = _composer.global.designFrame(playSize);
        final mvt = _composer.transform(frame);
        return BuoyancyPlayArea(
          model: _model,
          frame: frame,
          transform: mvt,
          sceneBuilder: () => _composer.compose(_model, display: _display),
          overlay: _overlay(playSize, frame, mvt),
        );
      },
    );
  }

  Widget _overlay(
    Size playSize,
    BuoyancyDesignFrame frame,
    BuoyancyThreeTransform mvt,
  ) {
    final b = frame.contentBounds;
    const m = buoyancyMarginSmall;
    final margin = m * frame.scale;
    final pool = _model.world.pool;
    final left = b.left + margin;
    final right = playSize.width - b.right + margin;
    final top = b.top + margin;
    final bottom = playSize.height - b.bottom + margin;
    final bottleMode = _model.applicationMode == ApplicationMode.bottle;

    final resetBoatPos = mvt.modelToView(
      BVec3(pool.maxX, pool.minY, pool.depth / 2),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // rightSideVBox
        Positioned(
          right: right,
          top: top,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: playSize.width * 0.34,
              maxHeight: playSize.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (bottleMode)
                    _BottlePanel(
                      interior: _model.bottleInteriorMaterial,
                      volume: _model.bottleInteriorVolume,
                      materials: _bottleInteriorMaterials,
                      onInterior: (mat) => setState(
                          () => _model.setBottleInteriorMaterial(mat)),
                      onVolume: (v) => setState(
                          () => _model.setBottleInteriorVolume(v)),
                    )
                  else
                    BuoyancyBlockControlPanel(
                      tag: BuoyancyStrings.brick,
                      tagColor: const Color(0xFFED3732),
                      mass: _model.block,
                      materials: _boatBlockMaterials,
                      onMaterial: (mat) =>
                          setState(() => _model.setBlockMaterial(mat)),
                      onMass: (kg) =>
                          setState(() => _model.setBlockMass(kg)),
                      onVolume: (vol) =>
                          setState(() => _model.setBlockVolume(vol)),
                    ),
                  const SizedBox(height: 5),
                  BuoyancyAccordionStub(
                    title: BuoyancyStrings.objectDensity,
                    expanded: _densityExpanded,
                    onToggle: () =>
                        setState(() => _densityExpanded = !_densityExpanded),
                    child: bottleMode
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inside: ${_model.bottleInteriorMaterial.density.toStringAsFixed(0)} kg/m³',
                                style: const TextStyle(fontSize: 11),
                              ),
                              Text(
                                'Bottle: ${_model.bottle.density.toStringAsFixed(0)} kg/m³',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Brick: ${_model.block.density.toStringAsFixed(0)} kg/m³',
                                style: const TextStyle(fontSize: 11),
                              ),
                              Text(
                                'Boat: ${_model.boat.density.toStringAsFixed(0)} kg/m³',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 5),
                  BuoyancyAccordionStub(
                    title: BuoyancyStrings.percentSubmerged,
                    expanded: _submergedExpanded,
                    onToggle: () => setState(
                        () => _submergedExpanded = !_submergedExpanded),
                    child: Text(
                      bottleMode
                          ? 'Bottle: ${_model.bottle.percentSubmerged.toStringAsFixed(1)} %'
                          : 'Boat: ${_model.boat.percentSubmerged.toStringAsFixed(1)} %',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Forces — left bottom
        Positioned(
          left: left,
          bottom: bottom,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 168,
              maxHeight: playSize.height * 0.42,
            ),
            child: SingleChildScrollView(
              child: BuoyancyForcesPanel(
                display: _display,
                onChanged: () => setState(() {}),
              ),
            ),
          ),
        ),

        // Fluid — center bottom
        Positioned(
          left: b.left + (b.width - 130) / 2,
          bottom: bottom,
          child: BuoyancyFluidPanel(
            fluid: _model.world.pool.fluidMaterial,
            fluids: BuoyancyFluidPanel.applicationsFluids,
            onChanged: (mat) => setState(() => _model.setFluidMaterial(mat)),
          ),
        ),

        // resetBoatButton — boat mode only (`resetArrow_png`, scale 0.3)
        if (!bottleMode)
          Positioned(
            left: resetBoatPos.dx - 40,
            top: resetBoatPos.dy + 5,
            child: Material(
              color: const Color(0xFFDCDCDC),
              borderRadius: BorderRadius.circular(4),
              elevation: 2,
              child: InkWell(
                onTap: () =>
                    setState(() => _model.resetBoatAndBlockPosition()),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Image.asset(
                    BuoyancyTextureAsset.resetArrow,
                    width: 22,
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

        // PoolScaleHeightControl — bottle mode only; outside pool
        if (bottleMode)
          Builder(builder: (_) {
            final layout = BuoyancyPoolScaleHeightLayout.compute(
              mvt: mvt,
              pool: pool,
              layoutScale: frame.scale,
            );
            return Positioned(
              left: layout.left,
              top: layout.top,
              child: BuoyancyPoolScaleHeightControl(
                value: _model.poolScaleHeight.clamp(0.0, 1.0),
                height: layout.trackHeight,
                onChanged: (t) => setState(() => _model.setPoolScaleHeight(t)),
              ),
            );
          }),

        // applicationModeRadio + ResetAll
        Positioned(
          right: right,
          bottom: bottom,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Material(
                color: const Color(0xFFEEEEEE),
                elevation: 2,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ModeIconButton(
                        selected: bottleMode,
                        onTap: () => setState(() => _model
                            .setApplicationMode(ApplicationMode.bottle)),
                        child: Image.asset(
                          BuoyancyTextureAsset.bottleIcon,
                          width: 40,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _ModeIconButton(
                        selected: !bottleMode,
                        onTap: () => setState(() =>
                            _model.setApplicationMode(ApplicationMode.boat)),
                        child: Image.asset(
                          BuoyancyTextureAsset.boatIcon,
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              KratosResetAllButton(
                radius: 20.5,
                onPressed: () => setState(() {
                  _display.reset();
                  _densityExpanded = false;
                  _submergedExpanded = false;
                  _model.reset();
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeIconButton extends StatelessWidget {
  const _ModeIconButton({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFB3E5FC) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? const Color(0xFF0288D1) : const Color(0xFF9E9E9E),
            width: selected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _BottlePanel extends StatelessWidget {
  const _BottlePanel({
    required this.interior,
    required this.volume,
    required this.materials,
    required this.onInterior,
    required this.onVolume,
  });

  final BuoyancyMaterial interior;
  final double volume;
  final List<BuoyancyMaterial> materials;
  final ValueChanged<BuoyancyMaterial> onInterior;
  final ValueChanged<double> onVolume;

  @override
  Widget build(BuildContext context) {
    final selected = materials.firstWhere(
      (m) => m.id == interior.id,
      orElse: () => materials.first,
    );
    final liters = (volume * 1000).clamp(0.0, 10.0);
    return BuoyancyPanel(
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(BuoyancyStrings.shapeKindLabel('bottle'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            const Text('内部材料', style: TextStyle(fontSize: 11)),
            DropdownButton<BuoyancyMaterial>(
              isExpanded: true,
              isDense: true,
              value: selected,
              items: [
                for (final m in materials)
                  DropdownMenuItem(
                    value: m,
                    child: Text(m.id[0].toUpperCase() + m.id.substring(1)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) onInterior(v);
              },
            ),
            Text(BuoyancyStrings.volumeWithUnit(liters.toStringAsFixed(2)),
                style: const TextStyle(fontSize: 11)),
            Slider(
              value: liters.toDouble(),
              min: 0,
              max: 10,
              onChanged: (l) => onVolume(l / 1000),
            ),
          ],
        ),
      ),
    );
  }
}
