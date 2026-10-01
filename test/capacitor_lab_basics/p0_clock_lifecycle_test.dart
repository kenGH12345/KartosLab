import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/model/capacitance_model.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/screens/capacitance_interactive_screen_body.dart';
import 'package:kratos/capacitor_lab_basics/clb_strings.dart';
import 'package:kratos/capacitor_lab_basics/common/model/circuit_state.dart';
import 'package:kratos/capacitor_lab_basics/common/model/clb_model.dart';
import 'package:kratos/capacitor_lab_basics/light_bulb/model/clb_light_bulb_model.dart';
import 'package:kratos/capacitor_lab_basics/screens/capacitor_lab_basics_home.dart';

Finder _tab(String label) => find.descendant(
      of: find.byType(TabBar),
      matching: find.text(label),
    );

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(_tab(label));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('hidden_tab_does_not_step', () {
    testWidgets('LB discharge freezes while Capacitance tab is active',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final key = GlobalKey<CapacitorLabBasicsHomeState>();
      await tester.pumpWidget(
        MaterialApp(home: CapacitorLabBasicsHome(key: key)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final lb = key.currentState!.lightBulb;
      lb.circuit.battery.voltage = 1.5;
      lb.circuit.setCircuitConnection(CircuitState.lightBulbConnected);
      expect(lb.circuit.capacitor.plateVoltage.abs(), greaterThan(0.1));

      await _tapTab(tester, ClbStrings.screenLightBulb);
      await tester.pump(const Duration(milliseconds: 200));

      await _tapTab(tester, ClbStrings.screenCapacitance);
      final vHiddenStart = lb.circuit.capacitor.plateVoltage;
      await tester.pump(const Duration(seconds: 2));
      expect(
        lb.circuit.capacitor.plateVoltage,
        closeTo(vHiddenStart, 1e-18),
        reason: 'hidden Light Bulb must not keep discharging',
      );
    });
  });

  group('tab_switch_does_not_duplicate_ticker', () {
    testWidgets('return to LB discharges at single-clock rate (not 2×)',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final key = GlobalKey<CapacitorLabBasicsHomeState>();
      await tester.pumpWidget(
        MaterialApp(home: CapacitorLabBasicsHome(key: key)),
      );
      await tester.pump();

      final lb = key.currentState!.lightBulb;
      lb.circuit.battery.voltage = 1.5;
      lb.circuit.setCircuitConnection(CircuitState.lightBulbConnected);

      await _tapTab(tester, ClbStrings.screenLightBulb);
      final v0 = lb.circuit.capacitor.plateVoltage;
      await tester.pump(const Duration(milliseconds: 100));
      final drop1 = (v0 - lb.circuit.capacitor.plateVoltage).abs();

      await _tapTab(tester, ClbStrings.screenCapacitance);
      await _tapTab(tester, ClbStrings.screenLightBulb);

      lb.circuit.setCircuitConnection(CircuitState.batteryConnected);
      lb.circuit.battery.voltage = 1.5;
      lb.circuit.setCircuitConnection(CircuitState.lightBulbConnected);
      final v2 = lb.circuit.capacitor.plateVoltage;
      await tester.pump(const Duration(milliseconds: 100));
      final drop2 = (v2 - lb.circuit.capacitor.plateVoltage).abs();

      expect(drop1, greaterThan(0));
      expect(drop2, greaterThan(0));
      expect(drop2 / drop1, lessThan(1.8));
      expect(drop2 / drop1, greaterThan(0.4));
    });
  });

  group('capacitance_model_step_updates_current', () {
    test('step after ΔQ updates currentAmplitude', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      model.circuit.battery.voltage = 0;
      model.step(0.016);
      expect(model.circuit.currentAmplitude, 0);

      model.circuit.battery.voltage = 1.0;
      model.step(0.02);
      expect(model.circuit.currentAmplitude.abs(), greaterThan(0));
      model.dispose();
    });

    testWidgets('visible Capacitance ticker drives currentAmplitude',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final key = GlobalKey<CapacitorLabBasicsHomeState>();
      await tester.pumpWidget(
        MaterialApp(home: CapacitorLabBasicsHome(key: key)),
      );
      await tester.pump();
      final cap = key.currentState!.capacitance;
      cap.circuit.battery.voltage = 0;
      await tester.pump(const Duration(milliseconds: 32));
      cap.circuit.battery.voltage = 1.2;
      await tester.pump(const Duration(milliseconds: 32));
      expect(cap.circuit.currentAmplitude.abs(), greaterThan(0));
    });
  });

  group('pause_freezes_current_state', () {
    test('isPlaying=false → ClbModel.step does not mutate amplitude', () {
      final model = CapacitanceModel(shared: ClbSharedState());
      model.circuit.battery.voltage = 1.0;
      model.step(0.02);
      final amp = model.circuit.currentAmplitude;
      final q = model.circuit.getTotalCharge();

      model.setPlaying(false);
      model.circuit.battery.voltage = 0.5;
      model.step(0.02);
      expect(model.circuit.currentAmplitude, amp);
      expect(model.circuit.previousTotalCharge, q);
      model.dispose();
    });

    testWidgets('LB Pause survives Capacitance round-trip', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final key = GlobalKey<CapacitorLabBasicsHomeState>();
      await tester.pumpWidget(
        MaterialApp(home: CapacitorLabBasicsHome(key: key)),
      );
      await tester.pump();

      final lb = key.currentState!.lightBulb;
      await _tapTab(tester, ClbStrings.screenLightBulb);

      lb.circuit.battery.voltage = 1.5;
      lb.circuit.setCircuitConnection(CircuitState.lightBulbConnected);
      lb.setPlaying(false);
      final vPause = lb.circuit.capacitor.plateVoltage;

      await _tapTab(tester, ClbStrings.screenCapacitance);
      await tester.pump(const Duration(seconds: 1));
      await _tapTab(tester, ClbStrings.screenLightBulb);
      await tester.pump(const Duration(milliseconds: 500));

      expect(lb.isPlaying, isFalse);
      expect(lb.circuit.capacitor.plateVoltage, closeTo(vPause, 1e-18));
    });
  });

  group('reenter_restores_clock', () {
    testWidgets('after Capacitance visit, LB resume continues discharge',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final key = GlobalKey<CapacitorLabBasicsHomeState>();
      await tester.pumpWidget(
        MaterialApp(home: CapacitorLabBasicsHome(key: key)),
      );
      await tester.pump();

      final lb = key.currentState!.lightBulb;
      await _tapTab(tester, ClbStrings.screenLightBulb);
      lb.circuit.battery.voltage = 1.5;
      lb.circuit.setCircuitConnection(CircuitState.lightBulbConnected);

      await _tapTab(tester, ClbStrings.screenCapacitance);
      await _tapTab(tester, ClbStrings.screenLightBulb);

      expect(lb.isPlaying, isTrue);
      final v0 = lb.circuit.capacitor.plateVoltage;
      // Many small frames: a single large pump makes dt>0.1 and skips step.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(lb.circuit.capacitor.plateVoltage.abs(), lessThan(v0.abs()));
    });
  });

  group('dispose_stops_clock', () {
    testWidgets('leaving Home disposes without continued step crashes',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      final key = GlobalKey<CapacitorLabBasicsHomeState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CapacitorLabBasicsHome(key: key),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final lb = key.currentState!.lightBulb;
      lb.circuit.battery.voltage = 1.5;
      lb.circuit.setCircuitConnection(CircuitState.lightBulbConnected);
      await _tapTab(tester, ClbStrings.screenLightBulb);

      Navigator.of(tester.element(find.byType(CapacitorLabBasicsHome))).pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(CapacitorLabBasicsHome), findsNothing);
    });

    testWidgets('Capacitance body dispose stops its ticker', (tester) async {
      final shared = ClbSharedState();
      final model = CapacitanceModel(shared: shared);
      await tester.pumpWidget(
        MaterialApp(
          home: CapacitanceInteractiveScreenBody(model: model),
        ),
      );
      await tester.pump();
      model.circuit.battery.voltage = 1.0;
      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();
      final amp = model.circuit.currentAmplitude;
      model.circuit.battery.voltage = 0.2;
      await tester.pump(const Duration(seconds: 1));
      expect(model.circuit.currentAmplitude, amp);
      model.dispose();
      shared.dispose();
    });
  });

  group('reset_and_clock', () {
    test('Reset restores isPlaying and clears currentAmplitude', () {
      final model = ClbLightBulbModel(shared: ClbSharedState());
      model.circuit.battery.voltage = 1.5;
      model.circuit.setCircuitConnection(CircuitState.lightBulbConnected);
      model.step(0.05);
      model.setPlaying(false);
      model.reset();
      expect(model.isPlaying, isTrue);
      expect(model.circuit.currentAmplitude, 0);
      expect(
        model.circuit.circuitConnection,
        CircuitState.batteryConnected,
      );
      model.dispose();
    });
  });
}
