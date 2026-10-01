import 'package:flutter/material.dart';

import '../controller/states_of_matter_controller.dart';
import '../layout/states_scene_layout.dart';
import '../model/phase_state.dart';
import '../painters/particle_canvas_painter.dart';
import '../painters/particle_container_painter.dart';
import '../som_constants.dart';
import '../transform/som_coordinate_transform.dart';
import '../widgets/composite_thermometer.dart';
import '../widgets/heater_cooler_control.dart';
import '../widgets/som_reset_button.dart';
import '../widgets/som_scene_shell.dart';
import '../widgets/som_time_control.dart';
import '../widgets/states_phase_control.dart';
import '../widgets/substance_selector_panel.dart';

/// States screen — PhET `StatesScreenView` layout (834×504 via [SomSceneShell]).
class StatesScreen extends StatefulWidget {
  const StatesScreen({
    super.key,
    required this.controller,
  });

  final StatesOfMatterController controller;

  @override
  State<StatesScreen> createState() => _StatesScreenState();
}

class _StatesScreenState extends State<StatesScreen> {
  late final SomCoordinateTransform _mvt;
  PhaseState? _selectedPhase;

  StatesOfMatterController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _mvt = SomCoordinateTransform();
    _c.addListener(_onControllerChanged);
    _selectedPhase = PhaseState.solid;
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _c.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SomSceneShell(child: _buildLayout());
  }

  Widget _buildLayout() {
    final model = _c.model;
    final containerBounds = _mvt.particleContainerViewBounds(
      containerHeight: model.containerHeight,
    );
    final initialBounds = _mvt.particleContainerViewBounds();

    final heaterW = StatesSceneLayout.heaterWidth();
    final heaterH = StatesSceneLayout.heaterHeight();
    final heaterLeft = initialBounds.center.dx - heaterW / 2;
    final heaterTop = initialBounds.bottom + StatesSceneLayout.heaterTopGap;
    final heaterCenterY = heaterTop + heaterH / 2;

    final thermoOffsetX = _mvt.modelToViewDeltaX(
      -SomConstants.containerWidth * StatesSceneLayout.thermometerModelXFraction,
    );
    final thermoCenterX = initialBounds.center.dx + thermoOffsetX;
    final thermoW = StatesSceneLayout.thermometerWidth;

    final heaterEnabled = model.isPlaying && !model.isExploded;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: ParticleCanvasPainter(
              atoms: List.of(model.scaledAtoms),
              mvt: _mvt,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: ParticleContainerPainter(
              mvt: _mvt,
              containerHeight: model.containerHeight,
              isExploded: model.isExploded,
            ),
          ),
        ),
        Positioned(
          left: thermoCenterX - thermoW / 2,
          top: containerBounds.top - StatesSceneLayout.thermometerTopLift,
          child: CompositeThermometer(
            temperatureKelvin: model.temperatureInKelvin,
            width: thermoW,
          ),
        ),
        Positioned(
          left: heaterLeft,
          top: heaterTop,
          child: HeaterCoolerControl(
            value: model.heatingCoolingAmount,
            enabled: heaterEnabled,
            scale: StatesSceneLayout.heaterScale,
            onChanged: _c.setHeatingCoolingAmount,
          ),
        ),
        Positioned(
          left: heaterLeft -
              StatesSceneLayout.timeControlGapLeftOfHeater -
              StatesSceneLayout.timeControlIntrinsicWidth,
          top: heaterCenterY - 18,
          child: SomTimeControl(
            isPlaying: model.isPlaying,
            onPlayPause: _c.togglePlaying,
            onStep: _c.stepOnce,
          ),
        ),
        // PhET: phase.top = molecules.bottom + CONTROL_PANEL_Y_INSET
        Positioned(
          right: StatesSceneLayout.controlPanelXInset,
          top: StatesSceneLayout.controlPanelYInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              SubstanceSelectorPanel(
                width: StatesSceneLayout.controlPanelWidth,
                substance: model.substance,
                onChanged: (s) {
                  _selectedPhase = PhaseState.solid;
                  _c.setSubstance(s);
                },
              ),
              const SizedBox(height: StatesSceneLayout.controlPanelYInset),
              StatesPhaseControl(
                width: StatesSceneLayout.controlPanelWidth,
                selectedPhase: _selectedPhase,
                onPhaseSelected: (phase) {
                  setState(() => _selectedPhase = phase);
                  _c.setPhase(phase);
                },
              ),
            ],
          ),
        ),
        Positioned(
          right: StatesSceneLayout.resetSideInset,
          bottom: StatesSceneLayout.resetBottomInset,
          child: SomResetButton(
            radius: StatesSceneLayout.resetRadius,
            onPressed: () {
              setState(() => _selectedPhase = PhaseState.solid);
              _c.resetAll();
            },
          ),
        ),
      ],
    );
  }
}
