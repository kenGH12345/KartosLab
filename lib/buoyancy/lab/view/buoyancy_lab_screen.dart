import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../lab/model/buoyancy_lab_model.dart';
import '../../layout/buoyancy_global_layout_spec.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';
import '../../rendering/transform/buoyancy_three_transform.dart';
import '../../shared/display_properties.dart';
import '../../shared/widgets/buoyancy_accordion_stub.dart';
import '../../shared/widgets/buoyancy_block_control_panel.dart';
import '../../shared/widgets/buoyancy_fluid_displaced_panel.dart';
import '../../shared/widgets/buoyancy_fluid_panel.dart';
import '../../shared/widgets/buoyancy_forces_panel.dart';
import '../../shared/widgets/buoyancy_gravity_panel.dart';
import '../../shared/widgets/buoyancy_pool_scale_height_control.dart';
import '../composer/lab_composer.dart';
import '../../buoyancy_strings.dart';

/// Lab screen — layout anchors from `BuoyancyLabScreenView.ts`.
class BuoyancyLabScreen extends StatefulWidget {
  const BuoyancyLabScreen({super.key, this.model});
  final BuoyancyLabModel? model;

  @override
  State<BuoyancyLabScreen> createState() => _BuoyancyLabScreenState();
}

class _BuoyancyLabScreenState extends State<BuoyancyLabScreen> {
  late final bool _ownsModel = widget.model == null;
  late final BuoyancyLabModel _model = widget.model ?? BuoyancyLabModel();
  final _composer = LabComposer();
  final _display = BuoyancyDisplayProperties(
    supportsDepthLines: true,
    forcesInitiallyDisplayed: true,
    massValuesInitiallyDisplayed: false,
  );
  bool _displacedExpanded = true;
  bool _densityExpanded = false;
  bool _submergedExpanded = false;

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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // leftSideContent — fluid displaced + Forces
        Positioned(
          left: left,
          bottom: bottom,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 176,
              maxHeight: playSize.height * 0.5,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BuoyancyFluidDisplacedPanel(
                    displacedLiters: () => _model.fluidDisplacedVolumeLiters,
                    fluid: () => _model.world.pool.fluidMaterial,
                    gravity: () => _model.world.gravity,
                    expanded: _displacedExpanded,
                    onToggle: () => setState(
                        () => _displacedExpanded = !_displacedExpanded),
                  ),
                  const SizedBox(height: 5),
                  BuoyancyForcesPanel(
                    display: _display,
                    onChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
        ),

        // bottomNode — Fluid + Gravity (center bottom)
        Positioned(
          left: b.left + (b.width - 260) / 2,
          bottom: bottom,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BuoyancyFluidPanel(
                fluid: _model.world.pool.fluidMaterial,
                onChanged: (mat) =>
                    setState(() => _model.setFluidMaterial(mat)),
              ),
              const SizedBox(width: 10),
              BuoyancyGravityPanel(
                value: _model.world.gravity,
                presets: BuoyancyLabModel.gravityPresets,
                onChanged: (g) =>
                    setState(() => _model.setSelectedGravityPreset(g)),
              ),
            ],
          ),
        ),

        // rightSideVBox
        Positioned(
          right: right,
          top: top,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: playSize.width * 0.34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                BuoyancyBlockControlPanel(
                  mass: _model.block,
                  materials: BuoyancyLabModel.availableMassMaterials,
                  onMaterial: (mat) =>
                      setState(() => _model.setBlockMaterial(mat)),
                  onMass: (kg) => setState(() => _model.setBlockMass(kg)),
                  onVolume: (vol) => setState(() => _model.setBlockVolume(vol)),
                ),
                const SizedBox(height: 5),
                BuoyancyAccordionStub(
                  title: BuoyancyStrings.objectDensity,
                  expanded: _densityExpanded,
                  onToggle: () =>
                      setState(() => _densityExpanded = !_densityExpanded),
                  child: Text(
                    '${_model.block.density.toStringAsFixed(0)} kg/m³',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(height: 5),
                BuoyancyAccordionStub(
                  title: BuoyancyStrings.percentSubmerged,
                  expanded: _submergedExpanded,
                  onToggle: () => setState(
                      () => _submergedExpanded = !_submergedExpanded),
                  child: Text(
                    'Block: ${_model.block.percentSubmerged.toStringAsFixed(1)} %',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),

        // PoolScaleHeightControl — outside pool (maxX + MARGIN_SMALL)
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

        Positioned(
          right: right,
          bottom: bottom,
          child: KratosResetAllButton(
            radius: 20.5,
            onPressed: () => setState(() {
              _display.reset();
              _displacedExpanded = true;
              _densityExpanded = false;
              _submergedExpanded = false;
              _model.reset();
            }),
          ),
        ),
      ],
    );
  }
}
