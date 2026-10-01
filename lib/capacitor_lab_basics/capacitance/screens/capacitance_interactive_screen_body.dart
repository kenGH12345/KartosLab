import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../clb_colors.dart';
import '../../clb_constants.dart';
import '../../common/painters/plate_handles_painter.dart';
import '../../common/render/circuit_render_data.dart';
import '../../common/transform/yaw_pitch_mvt.dart';
import '../../common/widgets/bar_meter_panel.dart';
import '../../common/widgets/battery_voltage_slider.dart';
import '../../common/widgets/clb_reset_all_button.dart';
import '../../common/widgets/clb_view_control_panel.dart';
import '../../common/widgets/current_indicators_layer.dart';
import '../../common/widgets/plate_handle_gesture_layer.dart';
import '../../common/widgets/static_circuit_view.dart';
import '../../common/widgets/switch_gesture_layer.dart';
import '../../common/widgets/toolbox_panel.dart';
import '../../common/widgets/voltmeter_drag_layer.dart';
import '../model/capacitance_model.dart';

/// Capacitance screen interactive body — Phase 4+.
///
/// Used from [CapacitorLabBasicsHome] Capacitance tab.
///
/// Simulation clock: `Ticker` → [CapacitanceModel.step] → `currentAmplitude`
/// (PhET `CLBModel.step`). Gated by ancestor [TickerMode] so a hidden tab
/// does not advance time-dependent state (`KratosTabSwitcher`).
class CapacitanceInteractiveScreenBody extends StatefulWidget {
  const CapacitanceInteractiveScreenBody({
    super.key,
    required this.model,
  });

  final CapacitanceModel model;

  @override
  State<CapacitanceInteractiveScreenBody> createState() =>
      _CapacitanceInteractiveScreenBodyState();
}

class _CapacitanceInteractiveScreenBodyState
    extends State<CapacitanceInteractiveScreenBody>
    with SingleTickerProviderStateMixin {
  final YawPitchMvt _mvt = YawPitchMvt();
  final GlobalKey _rightColumnKey = GlobalKey();
  final GlobalKey _toolboxKey = GlobalKey();
  Rect _toolboxBounds = const Rect.fromLTWH(
    ClbConstants.canvasWidth - 185,
    220,
    175,
    100,
  );

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  CapacitanceModel get model => widget.model;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    // Belt-and-suspenders: muted by [TickerMode] when tab hidden.
    if (!TickerMode.valuesOf(context).enabled) return;
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt <= 0 || dt > 0.1) return;
    if (model.isPlaying) {
      model.step(dt);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Rect _readToolboxBounds() {
    final toolbox =
        _toolboxKey.currentContext?.findRenderObject() as RenderBox?;
    if (toolbox == null || !toolbox.hasSize) return _toolboxBounds;
    RenderBox? root;
    var p = context.findRenderObject();
    while (p != null) {
      if (p is RenderBox &&
          p.hasSize &&
          (p.size.width - ClbConstants.canvasWidth).abs() < 1 &&
          (p.size.height - ClbConstants.canvasHeight).abs() < 1) {
        root = p;
        break;
      }
      p = p.parent;
    }
    if (root == null || !root.hasSize) return _toolboxBounds;
    final topLeft = root.globalToLocal(toolbox.localToGlobal(Offset.zero));
    return topLeft & toolbox.size;
  }

  void _measureToolbox() {
    final next = _readToolboxBounds();
    if (next != _toolboxBounds) {
      setState(() => _toolboxBounds = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ClbColors.screenBackground,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: ClbConstants.canvasWidth,
          height: ClbConstants.canvasHeight,
          child: ColoredBox(
            color: ClbColors.screenBackground,
            child: ListenableBuilder(
              listenable: model,
              builder: (context, _) {
                final data = CircuitRenderData.fromClbModel(
                  model,
                  mvt: _mvt,
                  toolboxBounds: _toolboxBounds,
                );
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _measureToolbox());
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    StaticCircuitView(
                      data: data,
                      showVoltmeterOverlays: false,
                    ),
                    CustomPaint(
                      size: const Size(
                        ClbConstants.canvasWidth,
                        ClbConstants.canvasHeight,
                      ),
                      painter: PlateHandlesPainter(data: data),
                    ),
                    SwitchGestureLayer(
                      model: model,
                      data: data,
                      mvt: _mvt,
                    ),
                    PlateHandleGestureLayer(
                      capacitor: model.circuit.capacitor,
                      data: data,
                      mvt: _mvt,
                    ),
                    // Above switch/plate hit targets so thumb drag is never stolen.
                    BatteryVoltageSlider(
                      battery: model.circuit.battery,
                      batteryCenter: data.batteryCenter,
                      showTickLabels: true,
                    ),
                    CurrentIndicatorsLayer(model: model, data: data),
                    Positioned(
                      left: (data.topWireLeft - 40).clamp(10.0, 400.0),
                      top: 10,
                      child: BarMeterPanel(model: model, data: data),
                    ),
                    // View control + toolbox stacked like CapacitanceScreenView
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Column(
                        key: _rightColumnKey,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClbViewControlPanel(model: model),
                          const SizedBox(height: 10),
                          KeyedSubtree(
                            key: _toolboxKey,
                            child: ToolboxPanel(
                              model: model,
                              mvt: _mvt,
                              onBounds: (_) => _measureToolbox(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Above toolbox so body can be dragged onto the dock and returned.
                    VoltmeterDragLayer(
                      model: model,
                      data: data,
                      toolboxBounds: _toolboxBounds,
                      toolboxBoundsOf: _readToolboxBounds,
                      mvt: _mvt,
                    ),
                    Positioned(
                      right: 30,
                      bottom: 30,
                      child: ClbResetAllButton(
                        radius: 25,
                        onPressed: () => model.reset(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
