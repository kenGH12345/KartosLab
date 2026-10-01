import 'package:flutter/material.dart';

import '../controller/phase_changes_controller.dart';
import '../layout/phase_changes_scene_layout.dart';
import '../layout/right_panel_layout.dart';
import '../model/lj_potential_calculator.dart';
import '../painters/dial_gauge_painter.dart';
import '../painters/lj_potential_graph_painter.dart';
import '../painters/particle_canvas_painter.dart';
import '../painters/particle_container_painter.dart';
import '../painters/phase_diagram_painter.dart';
import '../painters/pump_hose_painter.dart';
import '../som_constants.dart';
import '../som_strings.dart';
import '../transform/som_coordinate_transform.dart';
import '../widgets/bicycle_pump_button.dart';
import '../widgets/composite_thermometer.dart';
import '../widgets/heater_cooler_control.dart';
import '../widgets/phase_changes_substance_panel.dart';
import '../widgets/pointing_hand_lid_control.dart';
import '../widgets/som_reset_button.dart';
import '../widgets/som_scene_shell.dart';
import '../widgets/som_time_control.dart';

/// Phase Changes screen — PhET `PhaseChangesScreenView` layout via [SomSceneShell].
class PhaseChangesScreen extends StatefulWidget {
  const PhaseChangesScreen({super.key, required this.controller});

  final PhaseChangesController controller;

  @override
  State<PhaseChangesScreen> createState() => _PhaseChangesScreenState();
}

class _PhaseChangesScreenState extends State<PhaseChangesScreen> {
  late final SomCoordinateTransform _mvt;
  late final LjPotentialCalculator _ljCalc;

  PhaseChangesController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _mvt = SomCoordinateTransform();
    _ljCalc = LjPotentialCalculator(
      SomConstants.neonRadius * 2,
      SomConstants.minEpsilon,
    );
    _c.addListener(_onChanged);
    _syncLjFromModel();
  }

  void _onChanged() {
    _syncLjFromModel();
    if (mounted) setState(() {});
  }

  void _syncLjFromModel() {
    final m = _c.model;
    _ljCalc.setSigma(m.getSigma());
    _ljCalc.setEpsilon(m.getEpsilon());
  }

  @override
  void dispose() {
    _c.removeListener(_onChanged);
    super.dispose();
  }

  (double tNorm, double pNorm) _diagramCoords() {
    final m = _c.model;
    const tripleOnDiagram = 0.375;
    const criticalOnDiagram = 0.8;
    const tripleModel = SomConstants.triplePointMonatomicModelTemperature;
    const criticalModel = SomConstants.criticalPointMonatomicModelTemperature;

    final tModel = m.temperatureSetPoint;
    double tNorm;
    if (tModel < tripleModel) {
      tNorm = (tModel / tripleModel) * tripleOnDiagram;
    } else if (tModel < criticalModel) {
      final slope =
          (criticalOnDiagram - tripleOnDiagram) / (criticalModel - tripleModel);
      tNorm = tripleOnDiagram + slope * (tModel - tripleModel);
    } else {
      tNorm = criticalOnDiagram +
          (tModel - criticalModel) / criticalModel * (1 - criticalOnDiagram);
    }

    final pNorm = (m.pressure / 200).clamp(0.0, 1.0);
    return (tNorm.clamp(0.0, 1.0), pNorm);
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

    final heaterW = PhaseChangesSceneLayout.heaterWidth();
    final heaterH = PhaseChangesSceneLayout.heaterHeight();
    final heaterLeft = initialBounds.center.dx - heaterW / 2;
    final heaterTop =
        initialBounds.bottom + PhaseChangesSceneLayout.heaterTopGap;
    final heaterCenterY = heaterTop + heaterH / 2;

    final thermoOffsetX = _mvt.modelToViewDeltaX(
      -SomConstants.containerWidth *
          PhaseChangesSceneLayout.thermometerModelXFraction,
    );
    final thermoCenterX = initialBounds.center.dx + thermoOffsetX;

    // PhET DialGaugeNode: right = area.minX + 0.2*width, top = area.top − 75
    // (area.top tracks lid); elbow grows as lid is compressed.
    final gaugeRight = containerBounds.left +
        containerBounds.width * PhaseChangesSceneLayout.gaugeRightFractionOfWidth;
    final gaugeLeft = gaugeRight - PhaseChangesSceneLayout.gaugeWidth;
    final gaugeTop =
        containerBounds.top - PhaseChangesSceneLayout.gaugeTopAboveArea;
    final gaugeElbowHeight = PhaseChangesSceneLayout.gaugeElbowOffset +
        (containerBounds.top - initialBounds.top).abs();
    final gaugeHeight =
        PhaseChangesSceneLayout.gaugeDialBlockHeight + gaugeElbowHeight;

    final hoseAttach = Offset(
      initialBounds.left,
      initialBounds.bottom - PhaseChangesSceneLayout.hoseAttachYAboveBottom,
    );
    final pumpLeft = PhaseChangesSceneLayout.pumpLeft();
    final pumpTop = PhaseChangesSceneLayout.pumpTop();
    // Hose leaves pump near connector (left of body, mid height).
    final hoseStart = Offset(
      pumpLeft + PhaseChangesSceneLayout.pumpWidth * 0.42,
      pumpTop + PhaseChangesSceneLayout.pumpHeight * 0.72,
    );

    final diagram = _diagramCoords();
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
              volumeControlEnabled: true,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: PumpHosePainter(from: hoseStart, to: hoseAttach),
          ),
        ),
        Positioned(
          left: gaugeLeft,
          top: gaugeTop,
          width: PhaseChangesSceneLayout.gaugeWidth,
          height: gaugeHeight,
          child: CustomPaint(
            painter: DialGaugePainter(
              pressureAtm: model.pressure,
              elbowHeight: gaugeElbowHeight,
            ),
          ),
        ),
        Positioned(
          left: thermoCenterX - PhaseChangesSceneLayout.thermometerWidth / 2,
          top: containerBounds.top - PhaseChangesSceneLayout.thermometerTopLift,
          child: CompositeThermometer(
            temperatureKelvin: model.temperatureInKelvin,
            width: PhaseChangesSceneLayout.thermometerWidth,
          ),
        ),
        PointingHandLidControl(
          mvt: _mvt,
          containerHeight: model.containerHeight,
          enabled: model.isPlaying && !model.isExploded,
          onHeightDragged: _c.setTargetContainerHeight,
        ),
        Positioned(
          left: heaterLeft,
          top: heaterTop,
          child: HeaterCoolerControl(
            value: model.heatingCoolingAmount,
            enabled: heaterEnabled,
            scale: PhaseChangesSceneLayout.heaterScale,
            onChanged: _c.setHeatingCoolingAmount,
          ),
        ),
        Positioned(
          left: heaterLeft -
              PhaseChangesSceneLayout.timeControlGapLeftOfHeater -
              PhaseChangesSceneLayout.timeControlIntrinsicWidth,
          top: heaterCenterY - 18,
          child: SomTimeControl(
            isPlaying: model.isPlaying,
            onPlayPause: _c.togglePlaying,
            onStep: _c.stepOnce,
          ),
        ),
        Positioned(
          left: pumpLeft,
          top: pumpTop -
              BicyclePumpButton.handleStroke(PhaseChangesSceneLayout.pumpHeight),
          child: BicyclePumpButton(
            enabled: model.isPumpEnabled,
            onPump: _c.pumpMolecules,
            width: PhaseChangesSceneLayout.pumpWidth,
            height: PhaseChangesSceneLayout.pumpHeight,
            drawHose: false,
          ),
        ),
        if (model.isExploded)
          Positioned(
            left: initialBounds.left - 160,
            top: initialBounds.top,
            child: Material(
              color: const Color(0xFFFFEB3B),
              borderRadius: BorderRadius.circular(6),
              elevation: 2,
              child: InkWell(
                onTap: _c.returnLid,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    SomStrings.returnLid,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        // PhET right stack: Molecules → Interaction Potential → Phase Diagram
        // with INTER_PANEL_SPACING=8; tops derived from prior section bottoms.
        // Constrain height so Phase Diagram is not clipped by layoutBounds.
        Positioned(
          right: RightPanelLayout.panelXInset,
          top: RightPanelLayout.panelTop,
          width: RightPanelLayout.panelWidth,
          height: RightPanelLayout.maxStackHeight(),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: RightPanelLayout.panelWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PhaseChangesSubstancePanel(
                    width: RightPanelLayout.panelWidth,
                    substance: model.substance,
                    onChanged: _c.setSubstance,
                    epsilon: model.adjustableAtomInteractionStrength,
                    onEpsilonChanged: _c.setEpsilon,
                  ),
                  const SizedBox(height: RightPanelLayout.interPanelSpacing),
                  LjPotentialGraphPanel(
                    width: RightPanelLayout.panelWidth,
                    height: RightPanelLayout.narrowGraphHeight,
                    calculator: _ljCalc,
                    markerDistance: model.getSigma() * 1.12,
                    expanded: model.interactionPotentialExpanded,
                    onToggle: _c.toggleInteractionPotential,
                  ),
                  const SizedBox(height: RightPanelLayout.interPanelSpacing),
                  PhaseDiagramPanel(
                    width: RightPanelLayout.panelWidth,
                    contentWidth: RightPanelLayout.phaseDiagramWidth,
                    contentHeight: RightPanelLayout.phaseDiagramHeight,
                    normalizedTemperature: diagram.$1,
                    normalizedPressure: diagram.$2,
                    expanded: model.phaseDiagramExpanded,
                    onToggle: _c.togglePhaseDiagram,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: PhaseChangesSceneLayout.resetSideInset,
          bottom: PhaseChangesSceneLayout.resetBottomInset,
          child: SomResetButton(
            radius: PhaseChangesSceneLayout.resetRadius,
            onPressed: _c.resetAll,
          ),
        ),
      ],
    );
  }
}
