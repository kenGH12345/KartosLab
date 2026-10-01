import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../layout/buoyancy_global_layout_spec.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';
import '../../rendering/transform/bvec3.dart';
import '../../rendering/transform/buoyancy_three_transform.dart';
import '../../shared/display_properties.dart';
import '../../shared/two_block_mode.dart';
import '../../shared/widgets/buoyancy_ab_controls_panel.dart';
import '../../shared/widgets/buoyancy_accordion_stub.dart';
import '../../shared/widgets/buoyancy_blocks_mode_radio.dart';
import '../../shared/widgets/buoyancy_fluid_panel.dart';
import '../../shared/widgets/buoyancy_forces_panel.dart';
import '../../shared/widgets/buoyancy_pool_scale_height_control.dart';
import '../composer/explore_composer.dart';
import '../model/buoyancy_explore_model.dart';

/// Explore screen — layout anchors from `BuoyancyExploreScreenView.ts`.
class BuoyancyExploreScreen extends StatefulWidget {
  const BuoyancyExploreScreen({super.key, this.model});
  final BuoyancyExploreModel? model;

  @override
  State<BuoyancyExploreScreen> createState() => _BuoyancyExploreScreenState();
}

class _BuoyancyExploreScreenState extends State<BuoyancyExploreScreen> {
  late final bool _ownsModel = widget.model == null;
  late final BuoyancyExploreModel _model =
      widget.model ?? BuoyancyExploreModel();
  final _composer = ExploreComposer();
  final _display = BuoyancyDisplayProperties(supportsDepthLines: true);
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

  /// Overlay coords are PlayArea-local (same space as [frame]).
  Widget _overlay(
    Size playSize,
    BuoyancyDesignFrame frame,
    BuoyancyThreeTransform mvt,
  ) {
    final b = frame.contentBounds;
    const m = buoyancyMarginSmall;
    final s = frame.scale;
    final margin = m * s;

    final pool = _model.world.pool;
    final left = b.left + margin;
    final right = playSize.width - b.right + margin;
    final top = b.top + margin;
    final bottom = playSize.height - b.bottom + margin;

    final fluidLiters =
        ((_model.world.pool.fluidY - _model.world.pool.minY) *
                _model.world.pool.width *
                _model.world.pool.depth *
                1000)
            .clamp(0.0, 9999.0);

    final massesForReadout = _model.mode == TwoBlockMode.twoBlocks
        ? [_model.blockA, _model.blockB]
        : [_model.blockA];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // rightSideVBox — AlignBox right / top
        Positioned(
          right: right,
          top: top,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: playSize.width * 0.34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                BuoyancyAbControlsPanel(
                  blockA: _model.blockA,
                  blockB: _model.blockB,
                  showB: _model.blockB.visible,
                  materials: BuoyancyExploreModel.availableMaterials,
                  onMaterial: (id, mat) =>
                      setState(() => _model.setBlockMaterial(id, mat)),
                  onMass: (id, kg) =>
                      setState(() => _model.setBlockMass(id, kg)),
                  onVolume: (id, vol) =>
                      setState(() => _model.setBlockVolume(id, vol)),
                ),
                const SizedBox(height: 5),
                BuoyancyAccordionStub(
                  title: 'Object Density',
                  expanded: _densityExpanded,
                  onToggle: () =>
                      setState(() => _densityExpanded = !_densityExpanded),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final mass in massesForReadout)
                        Text(
                          'Block ${mass.id.endsWith('A') ? 'A' : 'B'}: '
                          '${mass.density.toStringAsFixed(0)} kg/m³',
                          style: TextStyle(
                            fontSize: 11,
                            color: mass.id.endsWith('A')
                                ? const Color(0xFF2F59A6)
                                : const Color(0xFFED3732),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                BuoyancyAccordionStub(
                  title: '% Submerged',
                  expanded: _submergedExpanded,
                  onToggle: () => setState(
                      () => _submergedExpanded = !_submergedExpanded),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final mass in massesForReadout)
                        Text(
                          'Block ${mass.id.endsWith('A') ? 'A' : 'B'}: '
                          '${mass.percentSubmerged.toStringAsFixed(1)} %',
                          style: TextStyle(
                            fontSize: 11,
                            color: mass.id.endsWith('A')
                                ? const Color(0xFF2F59A6)
                                : const Color(0xFFED3732),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // displayOptionsPanel — AlignBox left / bottom
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

        // fluidDensityPanel — AlignBox center / bottom
        Positioned(
          left: b.left + (b.width - 130) / 2,
          bottom: bottom,
          child: BuoyancyFluidPanel(
            fluid: _model.world.pool.fluidMaterial,
            onChanged: (mat) => setState(() => _model.setFluidMaterial(mat)),
          ),
        ),

        // Fluid level readout
        Builder(builder: (_) {
          final tip = mvt.modelToView(
            BVec3(pool.minX + 0.02, pool.fluidY, pool.depth / 2),
          );
          return Positioned(
            left: tip.dx + 6,
            top: tip.dy - 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow, color: Colors.red, size: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${fluidLiters.toStringAsFixed(2)} L',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        }),

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

        // blocksModeRadio + resetAll — right / bottom
        Positioned(
          right: right,
          bottom: bottom,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BuoyancyBlocksModeRadio(
                value: _model.mode,
                onChanged: (v) => setState(() => _model.setMode(v)),
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
