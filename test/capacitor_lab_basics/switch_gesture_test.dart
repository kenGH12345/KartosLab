import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/model/capacitance_model.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/circuit_state.dart';
import 'package:kratos/capacitor_lab_basics/common/model/clb_model.dart';
import 'package:kratos/capacitor_lab_basics/common/render/circuit_render_data.dart';
import 'package:kratos/capacitor_lab_basics/common/transform/yaw_pitch_mvt.dart';
import 'package:kratos/capacitor_lab_basics/common/widgets/switch_gesture_layer.dart';
import 'package:kratos/capacitor_lab_basics/light_bulb/model/clb_light_bulb_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> setCanvas(WidgetTester tester) async {
    tester.view.physicalSize = const Size(
      ClbConstants.canvasWidth,
      ClbConstants.canvasHeight,
    );
    tester.view.devicePixelRatio = 1;
    await tester.binding.setSurfaceSize(
      const Size(ClbConstants.canvasWidth, ClbConstants.canvasHeight),
    );
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      await tester.binding.setSurfaceSize(null);
    });
  }

  Future<void> pumpSwitch(
    WidgetTester tester,
    ClbModel model,
    YawPitchMvt mvt,
  ) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: ClbConstants.canvasWidth,
            height: ClbConstants.canvasHeight,
            child: ListenableBuilder(
              listenable: model,
              builder: (context, _) {
                final data = CircuitRenderData.fromClbModel(model, mvt: mvt);
                return SwitchGestureLayer(
                  model: model,
                  data: data,
                  mvt: mvt,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Offset _globalOnSwitch(
    WidgetTester tester, {
    required SwitchBladeView blade,
    required Offset canvas,
    required bool isTop,
  }) {
    final topLeft = tester.getTopLeft(
      find.byKey(ValueKey(isTop ? 'clb_switch_top' : 'clb_switch_bottom')),
    );
    final bounds = switchPointerBounds(blade);
    return topLeft + (canvas - bounds.topLeft);
  }

  test('connectionAt hits open vs battery', () {
    final model = CapacitanceModel(shared: ClbSharedState());
    final data = CircuitRenderData.fromClbModel(model);
    final blade = data.topSwitch;
    expect(
      connectionAt(
        blade: blade,
        canvas: blade.openContact,
        allowed: model.circuit.allowedConnections,
      )?.state,
      CircuitState.openCircuit,
    );
    expect(
      connectionAt(
        blade: blade,
        canvas: blade.batteryContact,
        allowed: model.circuit.allowedConnections,
      )?.state,
      CircuitState.batteryConnected,
    );
    expect(
      connectionAt(
        blade: blade,
        canvas: blade.hinge,
        allowed: model.circuit.allowedConnections,
      ),
      isNull,
    );
  });

  testWidgets('click ConnectionNode switches battery → open', (tester) async {
    await setCanvas(tester);
    final model = CapacitanceModel(shared: ClbSharedState());
    final mvt = YawPitchMvt();
    await pumpSwitch(tester, model, mvt);
    await tester.pump();

    final data = CircuitRenderData.fromClbModel(model, mvt: mvt);
    final at = _globalOnSwitch(
      tester,
      blade: data.topSwitch,
      canvas: data.topSwitch.openContact,
      isTop: true,
    );
    await tester.tapAt(at);
    await tester.pump();
    expect(model.circuit.circuitConnection, CircuitState.openCircuit);
    expect(model.shared.switchUsed, isTrue);
  });

  testWidgets('drag blade from battery tip to open snaps open', (tester) async {
    await setCanvas(tester);
    final model = CapacitanceModel(shared: ClbSharedState());
    final mvt = YawPitchMvt();
    await pumpSwitch(tester, model, mvt);
    await tester.pump();

    final data = CircuitRenderData.fromClbModel(model, mvt: mvt);
    final start = _globalOnSwitch(
      tester,
      blade: data.topSwitch,
      canvas: data.topSwitch.tip,
      isTop: true,
    );
    final end = _globalOnSwitch(
      tester,
      blade: data.topSwitch,
      canvas: data.topSwitch.openContact,
      isTop: true,
    );
    await tester.timedDragFrom(
      start,
      end - start,
      const Duration(milliseconds: 300),
    );
    await tester.pump();
    expect(model.circuit.circuitConnection, CircuitState.openCircuit);
  });

  testWidgets('Light Bulb: click bulb contact', (tester) async {
    await setCanvas(tester);
    final model = ClbLightBulbModel(shared: ClbSharedState());
    final mvt = YawPitchMvt();
    await pumpSwitch(tester, model, mvt);
    await tester.pump();

    final data = CircuitRenderData.fromClbModel(model, mvt: mvt);
    expect(data.topSwitch.lightBulbContact, isNotNull);
    final at = _globalOnSwitch(
      tester,
      blade: data.topSwitch,
      canvas: data.topSwitch.lightBulbContact!,
      isTop: true,
    );
    await tester.tapAt(at);
    await tester.pump();
    expect(model.circuit.circuitConnection, CircuitState.lightBulbConnected);
  });
}
