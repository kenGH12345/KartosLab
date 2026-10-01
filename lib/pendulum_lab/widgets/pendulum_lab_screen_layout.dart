import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kratos/pendulum_lab/controller/pendulum_lab_controller.dart';
import 'package:kratos/pendulum_lab/model/energy_model.dart';
import 'package:kratos/pendulum_lab/model/lab_model.dart';
import 'package:kratos/pendulum_lab/model/pendulum.dart';
import 'package:kratos/pendulum_lab/model/pendulum_drag_logic.dart';
import 'package:kratos/pendulum_lab/model/pendulum_lab_model.dart';
import 'package:kratos/pendulum_lab/painters/pendulum_scene_painters.dart';
import 'package:kratos/pendulum_lab/pl_constants.dart';
import 'package:kratos/pendulum_lab/widgets/control_panels.dart';
import 'package:kratos/pendulum_lab/widgets/movable_tools.dart';
import 'package:kratos/pendulum_lab/widgets/playback_controls.dart';
import 'package:kratos/pendulum_lab/widgets/pl_reset_all_button.dart';

/// Full Intro / Energy / Lab layout in PhET layoutBounds coordinates.
class PendulumLabScreenLayout extends StatefulWidget {
  const PendulumLabScreenLayout({
    super.key,
    required this.controller,
    this.hasGravityTweakers = false,
    this.showEnergyGraph = false,
    this.showArrowPanel = false,
  });

  final PendulumLabController controller;
  final bool hasGravityTweakers;
  final bool showEnergyGraph;
  final bool showArrowPanel;

  @override
  State<PendulumLabScreenLayout> createState() =>
      _PendulumLabScreenLayoutState();
}

class _PendulumLabScreenLayoutState extends State<PendulumLabScreenLayout> {
  Pendulum? _dragging;
  double _angleOffset = 0;
  bool _toolsReady = false;

  PendulumLabModel get model => widget.controller.model;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initTools());
  }

  void _initTools() {
    if (!mounted) return;
    ensureToolPositions(
      ruler: model.ruler,
      stopwatch: model.stopwatch,
      periodTimer: model.periodTimer,
      energyGraphPresent: widget.showEnergyGraph,
      arrowsPresent: widget.showArrowPanel,
    );
    setState(() => _toolsReady = true);
  }

  void _bump() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final m = model;
    final energy = m is EnergyModel ? m : null;
    final lab = m is LabModel ? m : null;

    return SizedBox(
      width: PlConstants.layoutWidth,
      height: PlConstants.layoutHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Scene (non-interactive paints)
          IgnorePointer(
            child: Stack(
              children: [
                CustomPaint(
                  size: PlConstants.layoutSize,
                  painter: ProtractorPainter(pendula: m.pendula),
                ),
                CustomPaint(
                  size: PlConstants.layoutSize,
                  painter: DegreeReadoutPainter(pendula: m.pendula),
                ),
                CustomPaint(
                  size: PlConstants.layoutSize,
                  painter: PeriodTracePainter(
                    pendula: m.pendula,
                    traces: widget.controller.traces,
                  ),
                ),
                CustomPaint(
                  size: PlConstants.layoutSize,
                  painter: PendulaPainter(pendula: m.pendula),
                ),
                if (lab != null)
                  CustomPaint(
                    size: PlConstants.layoutSize,
                    painter: VectorArrowsPainter(
                      pendula: m.pendula,
                      showVelocity: lab.isVelocityVisible,
                      showAcceleration: lab.isAccelerationVisible,
                    ),
                  ),
              ],
            ),
          ),

          // Pendulum drag plane (below panels / tools)
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: (_) => _endDrag(),
              onPointerCancel: (_) => _endDrag(),
              child: const SizedBox.expand(),
            ),
          ),

          // Left floating: one full-height column — mirrors the original
          // ScreenView where the energy accordion's chart grows until its
          // bottom sits PANEL_PADDING above the tools panel
          // (EnergyScreenView.resizeEnergyGraphToFit).
          Positioned(
            left: PlConstants.panelPadding,
            top: PlConstants.panelPadding,
            bottom: PlConstants.panelPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.showArrowPanel && lab != null) ...[
                  ArrowVisibilityPanel(model: lab),
                  const SizedBox(height: PlConstants.panelPadding),
                ],
                if (widget.showEnergyGraph && energy != null)
                  if (energy.isEnergyBoxExpanded)
                    Expanded(child: EnergyGraphAccordion(model: energy))
                  else ...[
                    EnergyGraphAccordion(model: energy),
                    const Spacer(),
                  ]
                else
                  const Spacer(),
                ToolsPanel(model: m),
              ],
            ),
          ),

          // Right panels — static during bob drags; isolate their paint so
          // per-frame scene repaints don't repaint the controls.
          Positioned(
            right: PlConstants.panelPadding,
            top: PlConstants.panelPadding,
            child: RepaintBoundary(
              child: Column(
                children: [
                  PendulumControlPanel(model: m),
                  const SizedBox(height: PlConstants.panelPadding),
                  GlobalControlPanel(
                    model: m,
                    hasGravityTweakers: widget.hasGravityTweakers,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: PlConstants.panelPadding,
            bottom: PlConstants.panelPadding,
            child: RepaintBoundary(
              child: PlResetAllButton(onPressed: widget.controller.reset),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: PlConstants.panelPadding,
            child: RepaintBoundary(
              child: Center(
                child: PlaybackControls(controller: widget.controller),
              ),
            ),
          ),

          if (_toolsReady) ...[
            DraggableRuler(ruler: m.ruler, onMoved: _bump),
            if (m.periodTimer != null)
              DraggablePeriodTimer(
                timer: m.periodTimer!,
                secondVisible: m.pendula[1].isVisible,
                onChanged: _bump,
              ),
            DraggableStopwatch(stopwatch: m.stopwatch, onChanged: _bump),
          ],
        ],
      ),
    );
  }

  void _onPointerDown(PointerDownEvent e) {
    final local = e.localPosition;
    final touch = e.kind == PointerDeviceKind.touch;
    final threshold =
        touch ? PlConstants.closestDragTouchMeters : 0.0;

    Pendulum? best;
    var bestDist = double.infinity;
    for (final p in model.pendula) {
      if (!p.isVisible || p.isUserControlled) continue;
      final d = PendulumDragLogic.distanceToBob(
        viewPoint: local,
        angle: p.angle,
        length: p.length,
        mass: p.mass,
      );
      if (d < bestDist) {
        bestDist = d;
        best = p;
      }
    }
    if (best == null) return;
    if (bestDist > threshold && threshold == 0 && bestDist > 0) {
      // mouse: must be on bob (distance 0 inside AABB)
      if (bestDist > 1e-9) return;
    }
    if (threshold > 0 && bestDist > threshold) return;

    final dragA = PendulumDragLogic.dragAngle(local);
    _angleOffset = best.angle - dragA;
    // setUserControlled notifies the model -> controller -> ListenableBuilder,
    // which rebuilds this layout; a local setState would rebuild it twice.
    best.setUserControlled(true);
    _dragging = best;
  }

  void _onPointerMove(PointerMoveEvent e) {
    final p = _dragging;
    if (p == null) return;
    final continuous =
        Pendulum.modAngle(_angleOffset + PendulumDragLogic.dragAngle(e.localPosition));
    final rounded = PendulumDragLogic.roundedAngle(continuous);
    // Notifies through the model; no extra setState here (avoids double
    // rebuild per pointer event).
    p.setAngle(rounded, fromUser: true);
  }

  void _endDrag() {
    final p = _dragging;
    if (p == null) return;
    p.setUserControlled(false);
    _dragging = null;
  }
}
