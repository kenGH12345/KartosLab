import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../layout/buoyancy_global_layout_spec.dart';
import '../../physics/constants.dart';
import '../../rendering/runtime/buoyancy_play_area.dart';
import '../../rendering/transform/bvec3.dart';
import '../../rendering/transform/buoyancy_three_transform.dart';
import '../../shared/display_properties.dart';
import '../../shared/widgets/buoyancy_accordion_stub.dart';
import '../../shared/widgets/buoyancy_blocks_mode_radio.dart';
import '../../shared/widgets/buoyancy_fluid_panel.dart';
import '../../shared/widgets/buoyancy_forces_panel.dart';
import '../../shared/widgets/buoyancy_pool_scale_height_control.dart';
import '../../shared/widgets/buoyancy_shapes_controls_panel.dart';
import '../../shapes/model/buoyancy_shapes_model.dart';
import '../composer/shapes_composer.dart';

/// Shapes screen — layout anchors from `BuoyancyShapesScreenView.ts`.
class BuoyancyShapesScreen extends StatefulWidget {
  const BuoyancyShapesScreen({super.key, this.model});
  final BuoyancyShapesModel? model;

  @override
  State<BuoyancyShapesScreen> createState() => _BuoyancyShapesScreenState();
}

class _BuoyancyShapesScreenState extends State<BuoyancyShapesScreen> {
  late final bool _ownsModel = widget.model == null;
  late final BuoyancyShapesModel _model =
      widget.model ?? BuoyancyShapesModel();
  final _composer = ShapesComposer();
  final _display = BuoyancyDisplayProperties();
  final _densityKey = GlobalKey();
  final _submergedKey = GlobalKey();
  bool _densityExpanded = false;
  bool _submergedExpanded = false;

  @override
  void dispose() {
    if (_ownsModel) {
      _model.dispose();
    }
    super.dispose();
  }

  void _toggleDensity() {
    setState(() => _densityExpanded = !_densityExpanded);
    if (_densityExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _densityKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 200),
            alignment: 1.0,
          );
        }
      });
    }
  }

  void _toggleSubmerged() {
    setState(() => _submergedExpanded = !_submergedExpanded);
    if (_submergedExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _submergedKey.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 200),
            alignment: 1.0,
          );
        }
      });
    }
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

    final slots = [
      _model.objectA,
      if (_model.objectB.mass.visible) _model.objectB,
    ];

    final poolBL = mvt.modelToView(
      BVec3(pool.minX, pool.minY, pool.depth / 2),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // rightSideVBox — fill to above mode/reset so accordions aren't clipped
        Positioned(
          right: right,
          top: top,
          bottom: bottom + 56,
          child: SizedBox(
            width: (playSize.width * 0.36).clamp(200.0, 280.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BuoyancyShapesControlsPanel(
                    model: _model,
                    onMaterial: (mat) =>
                        setState(() => _model.setMaterial(mat)),
                    onShape: (which, s) =>
                        setState(() => _model.setObjectShape(which, s)),
                    onRatios: (which, w, h) =>
                        setState(() => _model.setObjectRatios(which, w, h)),
                  ),
                  const SizedBox(height: 5),
                  BuoyancyAccordionStub(
                    key: _densityKey,
                    title: 'Object Density',
                    expanded: _densityExpanded,
                    onToggle: () => _toggleDensity(),
                    child: Text(
                      // DensityAccordionBox: kg/m³ → kg/L, 2 decimals
                      '${(_model.material.density / BuoyancyPhysicsConstants.litersInCubicMeter).toStringAsFixed(2)} kg/L',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 5),
                  BuoyancyAccordionStub(
                    key: _submergedKey,
                    title: '% Submerged',
                    expanded: _submergedExpanded,
                    onToggle: () => _toggleSubmerged(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final s in slots)
                          Text(
                            // shapeTagPattern: "A" / "B" + percent
                            '${s.idPrefix.endsWith('A') ? 'A' : 'B'}: '
                            '${s.mass.percentSubmerged.toStringAsFixed(1)} %',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: s.idPrefix.endsWith('A')
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
        ),

        // displayOptions — left bottom
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

        // fluidDensity — center bottom
        Positioned(
          left: b.left + (b.width - 130) / 2,
          bottom: bottom,
          child: BuoyancyFluidPanel(
            fluid: _model.world.pool.fluidMaterial,
            fluids: BuoyancyFluidPanel.shapesFluids,
            onChanged: (mat) => setState(() => _model.setFluidMaterial(mat)),
          ),
        ),

        // Info button — pool bottom-left (`ShapesInfoDialog`)
        Positioned(
          left: poolBL.dx,
          top: poolBL.dy + 10,
          child: Material(
            color: const Color(0xFF1177AA),
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Shapes'),
                    content: const Text(
                      // density-buoyancy-common-strings_en.json · shapesInfoDialog
                      'This simulation is limited to vertical forces, without '
                      'considering torque. Object rotations and other more '
                      'complex movements are not considered in the model.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const SizedBox(
                width: 28,
                height: 28,
                child: Center(
                  child: Text(
                    'i',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
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

        // Mode radio + Reset
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
