import 'package:flutter/material.dart';

import '../controller/gas_simulation_controller.dart';
import '../gas_properties_constants.dart';
import '../model/hold_constant.dart';
import '../model/ideal_gas_law_model.dart';
import '../render/gas_render_state.dart';
import '../transform/gas_coordinate_transform.dart';
import 'drag_state.dart';
import 'interaction_hit_test.dart';

/// Discrete scene hit regions for Ideal / Explore / Energy.
///
/// Does **not** use a full-screen GestureDetector that guesses the target.
/// Z-order: lid above wall; pump/heater are separate Positioned widgets.
class SceneLidWallOverlay extends StatefulWidget {
  const SceneLidWallOverlay({
    super.key,
    required this.controller,
    required this.transform,
    required this.drag,
    required this.onDragChanged,
    this.lidOnTop = true,
    this.wallEnabledOverride,
  });

  final GasSimulationController controller;
  final GasCoordinateTransform transform;
  final SceneDragState drag;
  final VoidCallback onDragChanged;

  /// When false, only the wall hit region is built (lid handled elsewhere).
  final bool lidOnTop;

  /// When non-null, forces wall on/off regardless of profile.
  final bool? wallEnabledOverride;

  @override
  State<SceneLidWallOverlay> createState() => _SceneLidWallOverlayState();
}

class _SceneLidWallOverlayState extends State<SceneLidWallOverlay> {
  GasSimulationController get c => widget.controller;
  GasCoordinateTransform get t => widget.transform;
  SceneDragState get drag => widget.drag;
  late final InteractionHitTest _hits = InteractionHitTest(t);

  @override
  Widget build(BuildContext context) {
    final state = c.renderState;
    final lid = _hits.lidHit(state);
    final wall = _hits.wallHit(state);
    final wallEnabled = widget.wallEnabledOverride ??
        (c.profile != IdealGasProfile.energy &&
            c.model.holdConstant != HoldConstant.volume &&
            !c.model.container.isFixedWidth);
    final lidEnabled = widget.lidOnTop &&
        state.lidIsOn &&
        c.model.holdConstant != HoldConstant.temperature;

    return Stack(
      children: [
        if (wallEnabled)
          Positioned.fromRect(
            rect: wall,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => _startWall(d, state),
              onPanUpdate: _updateWall,
              onPanEnd: (_) => _endWall(),
              onPanCancel: _endWall,
              child: const SizedBox.expand(),
            ),
          ),
        if (lidEnabled && lid.width > 0)
          Positioned.fromRect(
            rect: lid,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) => _startLid(d, state),
              onPanUpdate: _updateLid,
              onPanEnd: (_) => _endLid(),
              onPanCancel: _endLid,
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }

  void _startLid(DragStartDetails d, GasRenderState state) {
    if (drag.kind != SceneDragKind.idle && drag.kind != SceneDragKind.lid) {
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(d.globalPosition);
    final mx = t.viewToModelX(local.dx);
    drag.kind = SceneDragKind.lid;
    drag.modelOffsetX = state.openingLeft - mx;
    widget.onDragChanged();
  }

  void _updateLid(DragUpdateDetails d) {
    if (drag.kind != SceneDragKind.lid) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(d.globalPosition);
    final mx = t.viewToModelX(local.dx) + drag.modelOffsetX;
    c.setLidWidthFromOpeningLeft(mx);
  }

  void _endLid() {
    if (drag.kind == SceneDragKind.lid) {
      drag.kind = SceneDragKind.idle;
      drag.modelOffsetX = 0;
      widget.onDragChanged();
    }
  }

  void _startWall(DragStartDetails d, GasRenderState state) {
    if (drag.kind != SceneDragKind.idle) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(d.globalPosition);
    final mx = t.viewToModelX(local.dx);
    drag.kind = SceneDragKind.wall;
    drag.modelOffsetX = state.containerLeft - mx;
    c.beginWidthAdjust();
    widget.onDragChanged();
  }

  void _updateWall(DragUpdateDetails d) {
    if (drag.kind != SceneDragKind.wall) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(d.globalPosition);
    final mx = t.viewToModelX(local.dx) + drag.modelOffsetX;
    final newWidth = (-mx).clamp(
      GasPropertiesConstants.widthMin,
      GasPropertiesConstants.widthMax,
    );
    c.setWidthDuringAdjust(newWidth.toDouble());
  }

  void _endWall() {
    if (drag.kind == SceneDragKind.wall) {
      c.endWidthAdjust();
      drag.kind = SceneDragKind.idle;
      drag.modelOffsetX = 0;
      widget.onDragChanged();
    }
  }
}

/// Pump handle: vertical drag only; inject on downward stroke (no tap inject).
class ScenePumpHandle extends StatefulWidget {
  const ScenePumpHandle({
    super.key,
    required this.controller,
    required this.drag,
    required this.onDragChanged,
    required this.width,
    required this.height,
  });

  final GasSimulationController controller;
  final SceneDragState drag;
  final VoidCallback onDragChanged;
  final double width;
  final double height;

  @override
  State<ScenePumpHandle> createState() => _ScenePumpHandleState();
}

class _ScenePumpHandleState extends State<ScenePumpHandle> {
  static const _strokePxForInject = 48.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (_) {
        if (widget.drag.kind != SceneDragKind.idle) return;
        widget.drag.kind = SceneDragKind.pump;
        widget.drag.pumpDownAccum = 0;
        widget.onDragChanged();
      },
      onVerticalDragUpdate: (d) {
        if (widget.drag.kind != SceneDragKind.pump) return;
        // Positive dy = downward in Flutter
        if (d.delta.dy > 0) {
          widget.drag.pumpDownAccum += d.delta.dy;
          widget.drag.pumpLift =
              (1.0 - widget.drag.pumpDownAccum / _strokePxForInject)
                  .clamp(0.0, 1.0);
        } else {
          // Upward resets stroke accumulator (PhET)
          widget.drag.pumpDownAccum = 0;
          widget.drag.pumpLift =
              (widget.drag.pumpLift - d.delta.dy / 60).clamp(0.0, 1.0);
        }
        widget.onDragChanged();
      },
      onVerticalDragEnd: (_) => _endPump(),
      onVerticalDragCancel: _endPump,
      child: const SizedBox.expand(),
    );
  }

  void _endPump() {
    if (widget.drag.kind != SceneDragKind.pump) return;
    if (widget.drag.pumpDownAccum >= _strokePxForInject * 0.55) {
      widget.controller.pump(50);
    }
    widget.drag.kind = SceneDragKind.idle;
    widget.drag.pumpLift = 0;
    widget.drag.pumpDownAccum = 0;
    widget.onDragChanged();
  }
}

/// Heater/Cooler: continuous Y drag; snap factor to 0 on release.
class SceneHeaterDrag extends StatefulWidget {
  const SceneHeaterDrag({
    super.key,
    required this.controller,
    required this.drag,
    required this.onDragChanged,
    required this.child,
  });

  final GasSimulationController controller;
  final SceneDragState drag;
  final VoidCallback onDragChanged;
  final Widget child;

  @override
  State<SceneHeaterDrag> createState() => _SceneHeaterDragState();
}

class _SceneHeaterDragState extends State<SceneHeaterDrag> {
  @override
  Widget build(BuildContext context) {
    final hide = widget.controller.model.holdConstant == HoldConstant.temperature ||
        widget.controller.model.holdConstant == HoldConstant.pressureT;
    final enabled = widget.controller.model.isPlaying && !hide;
    return Opacity(
      opacity: hide ? 0 : 1,
      child: IgnorePointer(
        ignoring: !enabled,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (_) {
            if (widget.drag.kind != SceneDragKind.idle) return;
            widget.drag.kind = SceneDragKind.heater;
            widget.onDragChanged();
          },
          onVerticalDragUpdate: (d) {
            if (widget.drag.kind != SceneDragKind.heater) return;
            // Up = heat (+), down = cool (−)
            final next =
                (widget.drag.heatFactor - d.delta.dy / 40).clamp(-1.0, 1.0);
            widget.drag.heatFactor = next;
            widget.controller.setHeatCool(next);
            widget.onDragChanged();
          },
          onVerticalDragEnd: (_) => _end(),
          onVerticalDragCancel: _end,
          child: widget.child,
        ),
      ),
    );
  }

  void _end() {
    if (widget.drag.kind != SceneDragKind.heater) return;
    widget.controller.setHeatCool(0);
    widget.drag.heatFactor = 0;
    widget.drag.kind = SceneDragKind.idle;
    widget.onDragChanged();
  }
}

/// Unit selector hit targets (thermometer / pressure readout).
class SceneUnitSelectors extends StatelessWidget {
  const SceneUnitSelectors({
    super.key,
    required this.controller,
    required this.transform,
  });

  final GasSimulationController controller;
  final GasCoordinateTransform transform;

  @override
  Widget build(BuildContext context) {
    final hits = InteractionHitTest(transform);
    final state = controller.renderState;
    final tHit = hits.temperatureUnitHit(state);
    final pHit = hits.pressureUnitHit(state);
    return Stack(
      children: [
        Positioned.fromRect(
          rect: tHit,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.setTemperatureUnitsKelvin(
              !controller.temperatureUnitsKelvin,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        Positioned.fromRect(
          rect: pHit,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                controller.setPressureUnitsAtm(!controller.pressureUnitsAtm),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}
