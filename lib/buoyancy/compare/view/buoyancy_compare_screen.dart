import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../layout/buoyancy_global_layout_spec.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';
import '../../rendering/transform/bvec3.dart';
import '../../rendering/transform/buoyancy_three_transform.dart';
import '../../shared/display_properties.dart';
import '../../shared/widgets/buoyancy_accordion_stub.dart';
import '../../shared/widgets/buoyancy_blocks_panel.dart';
import '../../shared/widgets/buoyancy_blocks_value_panel.dart';
import '../../shared/widgets/buoyancy_fluid_panel.dart';
import '../../shared/widgets/buoyancy_forces_panel.dart';
import '../../shared/widgets/buoyancy_pool_scale_height_control.dart';
import '../composer/compare_composer.dart';
import '../model/buoyancy_compare_model.dart';
import '../../buoyancy_strings.dart';

/// Compare screen — layout anchors from `BuoyancyCompareScreenView.ts`.
class BuoyancyCompareScreen extends StatefulWidget {
  const BuoyancyCompareScreen({super.key, this.model});
  final BuoyancyCompareModel? model;

  @override
  State<BuoyancyCompareScreen> createState() => _BuoyancyCompareScreenState();
}

class _BuoyancyCompareScreenState extends State<BuoyancyCompareScreen> {
  late final bool _ownsModel = widget.model == null;
  late final BuoyancyCompareModel _model =
      widget.model ?? BuoyancyCompareModel();
  final _composer = CompareComposer();
  final _display = BuoyancyDisplayProperties(
    supportsDepthLines: true,
    massValuesInitiallyDisplayed: true,
  );
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

  /// Overlay coords are **PlayArea-local** (same space as [frame]), never MediaQuery.
  Widget _overlay(
    Size playSize,
    BuoyancyDesignFrame frame,
    BuoyancyThreeTransform mvt,
  ) {
    final b = frame.contentBounds;
    const m = buoyancyMarginSmall;
    final s = frame.scale;
    // Margin in viewport px (design MARGIN_SMALL × layoutScale).
    final margin = m * s;

    final pool = _model.world.pool;
    final poolTopRight = mvt.modelToView(
      BVec3(pool.maxX, pool.maxY, pool.depth / 2),
    );
    // rightSidePanelsVBox.top = poolTopRight.y + MARGIN
    final rightTop = (poolTopRight.dy + margin).clamp(b.top + margin, playSize.height);

    final fluidLiters =
        ((_model.world.pool.fluidY - _model.world.pool.minY) *
                _model.world.pool.width *
                _model.world.pool.depth *
                1000)
            .clamp(0.0, 9999.0);

    // AlignBox edges inside contentBounds (Joist visibleBounds ≈ contentBounds).
    final left = b.left + margin;
    final right = playSize.width - b.right + margin;
    final top = b.top + margin;
    final bottom = playSize.height - b.bottom + margin;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // blocksPanel — AlignBox right / top
        Positioned(
          right: right,
          top: top,
          child: BuoyancyBlocksPanel(
            value: _model.comparisonMode,
            onChanged: (v) => setState(() => _model.setComparisonMode(v)),
          ),
        ),

        // rightSidePanelsVBox
        Positioned(
          right: right,
          top: rightTop,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: playSize.width * 0.32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                BuoyancyBlocksValuePanel(
                  mode: _model.comparisonMode,
                  massKg: _model.sameMassValue,
                  volumeM3: _model.sameVolumeValue,
                  densityKgPerM3: _model.sameDensityValue,
                  massMin: BuoyancyCompareModel.sameMassMin,
                  massMax: BuoyancyCompareModel.sameMassMax,
                  volumeMin: BuoyancyCompareModel.sameVolumeMin,
                  volumeMax: BuoyancyCompareModel.sameVolumeMax,
                  densityMin: BuoyancyCompareModel.sameDensityMin,
                  densityMax: BuoyancyCompareModel.sameDensityMax,
                  onMass: (v) => setState(() => _model.setSameMass(v)),
                  onVolume: (v) => setState(() => _model.setSameVolume(v)),
                  onDensity: (v) => setState(() => _model.setSameDensity(v)),
                ),
                const SizedBox(height: 5),
                BuoyancyAccordionStub(
                  title: BuoyancyStrings.densityComparison,
                  expanded: _densityExpanded,
                  onToggle: () =>
                      setState(() => _densityExpanded = !_densityExpanded),
                  child: _densityReadout(),
                ),
                const SizedBox(height: 5),
                BuoyancyAccordionStub(
                  title: BuoyancyStrings.percentSubmerged,
                  expanded: _submergedExpanded,
                  onToggle: () =>
                      setState(() => _submergedExpanded = !_submergedExpanded),
                  child: _submergedReadout(),
                ),
              ],
            ),
          ),
        ),

        // displayOptionsPanel — AlignBox left / bottom (compact, must not cover pool)
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

        // fluidPanel — AlignBox center / bottom
        Positioned(
          left: b.left + (b.width - 130) / 2,
          bottom: bottom,
          child: BuoyancyFluidPanel(
            fluid: _model.world.pool.fluidMaterial,
            fluids: BuoyancyFluidPanel.compareFluids,
            onChanged: (mat) => setState(() {
              _model.world.pool.fluidMaterial = mat;
              _model.world.pool.computeFluidY(
                _model.world.masses.where((m) => m.visible).toList(),
              );
            }),
          ),
        ),

        // Fluid level readout on pool mouth (inside pool, not over Forces)
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
            layoutScale: s,
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

        // resetAll — AlignBox right / bottom
        Positioned(
          right: right,
          bottom: bottom,
          child: KratosResetAllButton(
            radius: 20.5,
            onPressed: () => setState(() {
              _display.reset();
              _densityExpanded = false;
              _submergedExpanded = false;
              _model.reset();
            }),
          ),
        ),
      ],
    );
  }

  Widget _densityReadout() {
    final a = _model.blockA;
    final b = _model.blockB;
    final fluid = _model.world.pool.fluidMaterial;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            BuoyancyStrings.blockDensity(
                'A', a.density.toStringAsFixed(0)),
            style: const TextStyle(fontSize: 11, color: Color(0xFF2F59A6))),
        Text(
            BuoyancyStrings.blockDensity(
                'B', b.density.toStringAsFixed(0)),
            style: const TextStyle(fontSize: 11, color: Color(0xFFED3732))),
        Text(
            BuoyancyStrings.fluidDensityValue(
                fluid.density.toStringAsFixed(0)),
            style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _submergedReadout() {
    final a = _model.blockA;
    final b = _model.blockB;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            BuoyancyStrings.submergedPercent(
                'A', a.percentSubmerged.toStringAsFixed(1)),
            style: const TextStyle(fontSize: 11, color: Color(0xFF2F59A6))),
        Text(
            BuoyancyStrings.submergedPercent(
                'B', b.percentSubmerged.toStringAsFixed(1)),
            style: const TextStyle(fontSize: 11, color: Color(0xFFED3732))),
      ],
    );
  }
}
