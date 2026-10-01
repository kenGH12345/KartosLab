import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_reset_all_button.dart';
import '../../constants/hookes_law_constants.dart';
import '../../model/energy_graph_data.dart';
import '../../model/energy_model.dart';
import '../hookes_law_stage.dart';
import 'energy_graph_painter.dart';
import 'energy_scene_painter.dart';
import 'energy_system_view.dart';
import 'energy_view_properties.dart';
import 'energy_visibility_panel.dart';

/// Hooke's Law Energy screen. `EnergyScreenView.ts`.
///
/// One displacement-controlled spring. Leaving this widget does not reset.
/// This screen does not host Intro, Systems, or Home.
class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key, required this.model, this.viewProperties});

  final EnergyModel model;
  final EnergyViewProperties? viewProperties;

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  late final EnergyViewProperties _view;
  late final bool _ownsView;
  int _epoch = 0;
  int _generation = 0;
  double _systemHeight = 320;

  @override
  void initState() {
    super.initState();
    _ownsView = widget.viewProperties == null;
    _view = widget.viewProperties ?? EnergyViewProperties();
    _generation = _view.generation;
    _view.addListener(_onView);
    final spring = widget.model.spring;
    spring.displacementProperty.addListener(_onModel);
    spring.springConstantProperty.addListener(_onModel);
    spring.appliedForceProperty.addListener(_onModel);
  }

  @override
  void dispose() {
    _view.removeListener(_onView);
    final spring = widget.model.spring;
    spring.displacementProperty.removeListener(_onModel);
    spring.springConstantProperty.removeListener(_onModel);
    spring.appliedForceProperty.removeListener(_onModel);
    if (_ownsView) {
      _view.dispose();
    }
    super.dispose();
  }

  void _onModel(double _) {
    if (mounted) {
      setState(() {});
    }
  }

  void _onView() {
    if (_view.generation != _generation) {
      _generation = _view.generation;
      _epoch++;
    }
    setState(() {});
  }

  void _onSystemHeight(double height) {
    if ((height - _systemHeight).abs() < 0.5) {
      return;
    }
    setState(() => _systemHeight = height);
  }

  void _reset() {
    widget.model.reset();
    _view.reset();
  }

  @override
  Widget build(BuildContext context) {
    final spring = widget.model.spring;
    final barAxisY = HookesLawConstants.layoutBoundsHeight -
        HookesLawConstants.energySystemBottomMargin -
        _systemHeight -
        HookesLawConstants.energyBarGapAboveSystem;
    final triangle = EnergyGraphData.forcePlotEnergyTriangle(spring);
    return HookesLawStage(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: EnergyGraphPainter(
                spring: spring,
                properties: _view,
                barAxisY: barAxisY,
              ),
            ),
          ),
          Positioned(
            left: _view.graph == EnergyGraphKind.barGraph
                ? energyPlotOriginX(spring)
                : HookesLawConstants.energyBarWhenPlotLeft,
            top: barAxisY,
            child: const IgnorePointer(
              child: SizedBox(key: Key('energy-bar'), width: 1, height: 1),
            ),
          ),
          if (EnergyGraphData.energyBar(spring).visible)
            const Positioned(
              left: 0,
              top: 0,
              child: IgnorePointer(
                child: SizedBox(key: Key('energy-bar-rect'), width: 1, height: 1),
              ),
            ),
          if (_view.showEnergyPlot)
            Positioned(
              left: energyPlotOriginX(spring),
              top: barAxisY,
              child: const IgnorePointer(
                child: SizedBox(key: Key('energy-plot'), width: 1, height: 1),
              ),
            ),
          if (_view.showForcePlot)
            Positioned(
              left: energyPlotOriginX(spring),
              top: barAxisY - HookesLawConstants.forceYAxisLength / 2,
              child: const IgnorePointer(
                child: SizedBox(key: Key('energy-force-plot'), width: 1, height: 1),
              ),
            ),
          if (_view.showForcePlot && _view.energyOnForcePlotVisible && triangle.visible)
            const Positioned(
              left: 0,
              top: 0,
              child: IgnorePointer(
                child: SizedBox(key: Key('energy-triangle'), width: 1, height: 1),
              ),
            ),
          Positioned(
            left: HookesLawConstants.energySystemLeft,
            bottom: HookesLawConstants.energySystemBottomMargin,
            child: EnergySystemView(
              spring: spring,
              arm: widget.model.system.roboticArm,
              properties: _view,
              epoch: _epoch,
              onLayoutHeight: _onSystemHeight,
            ),
          ),
          Positioned(
            top: HookesLawConstants.introControlsTopMargin,
            right: HookesLawConstants.introControlsRightMargin,
            child: EnergyVisibilityPanel(properties: _view),
          ),
          Positioned(
            right: HookesLawConstants.introResetMargin,
            bottom: HookesLawConstants.introResetMargin,
            child: KratosResetAllButton(
              key: const Key('energy-reset'),
              radius: HookesLawConstants.resetAllButtonRadius,
              onPressed: _reset,
            ),
          ),
        ],
      ),
    );
  }
}
