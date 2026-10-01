import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/simulation/simulation_event.dart';
import 'package:kratos/common/simulation/simulation_registry.dart';
import 'package:kratos/common/simulation/simulation_session.dart';
import 'package:kratos/quantum_measurement/bloch_sphere/view/bloch_screen.dart';
import 'package:kratos/quantum_measurement/coins/view/coins_screen.dart';
import 'package:kratos/quantum_measurement/photons/view/photons_screen.dart';
import 'package:kratos/quantum_measurement/quantum_measurement_module.dart';
import 'package:kratos/quantum_measurement/screens/quantum_measurement_home.dart';
import 'package:kratos/quantum_measurement/spin/view/spin_screen.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  setUp(() {
    SimulationRegistry.instance.clear();
    QuantumMeasurementModule.register();
    simulationEventSink =
        IsolatingSimulationEventSink(const NoOpSimulationEventSink());
  });

  group('Registry + Descriptor', () {
    test('stable id quantum-measurement', () {
      final d = SimulationRegistry.instance.require('quantum-measurement');
      expect(d.id, 'quantum-measurement');
      expect(d.title, QuantumMeasurementHome.title);
      expect(d.category, contains('光学与波动'));
      expect(d.sourceVersion, '1.0.4');
      expect(d.enabled, isTrue);
      expect(d.iconAsset, isNotNull);
    });

    test('idempotent register', () {
      QuantumMeasurementModule.register();
      QuantumMeasurementModule.register();
      expect(SimulationRegistry.instance.all.length, 1);
    });
  });

  group('Event boundary', () {
    test('Isolating sink swallows adapter failures', () {
      simulationEventSink = IsolatingSimulationEventSink(_ThrowingSink());
      expect(
        () => simulationEventSink.emit(
          const SimulationEvent(
            simulationId: 'quantum-measurement',
            kind: SimulationEventKind.action,
          ),
        ),
        returnsNormally,
      );
    });
  });

  group('Session persistence boundary', () {
    test('NoOp store returns null — NOT IMPLEMENTED', () async {
      final restored =
          await simulationSessionStore.restoreSessionState('quantum-measurement');
      expect(restored, isNull);
    });
  });

  group('Home → QM Entry', () {
    testWidgets('Home card opens QuantumMeasurementHome', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();

      expect(find.text('Quantum Measurement'), findsOneWidget);
      await tester.ensureVisible(find.text('Quantum Measurement'));
      await tester.tap(find.text('Quantum Measurement'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(QuantumMeasurementHome), findsOneWidget);
      expect(find.byType(QuantumMeasurementCoinsScreen), findsOneWidget);

      // Back exits Simulation (not internal tab)
      final back = find.byType(BackButton);
      expect(back, findsOneWidget);
      await tester.tap(back);
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(QuantumMeasurementHome), findsNothing);
    });

    testWidgets('QM internal tabs: Photons / Spin / Bloch', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: QuantumMeasurementHome()),
      );
      await tester.pump();

      Future<void> frames([int n = 8]) async {
        for (var i = 0; i < n; i++) {
          await tester.pump(const Duration(milliseconds: 40));
        }
      }

      await tester.tap(find.text('Photons'));
      await frames(12);
      expect(find.byType(QuantumMeasurementPhotonsScreen), findsOneWidget);

      await tester.tap(find.text('Spin'));
      await frames(12);
      expect(find.byType(QuantumMeasurementSpinScreen), findsOneWidget);

      await tester.tap(find.text('Bloch Sphere'));
      await frames(12);
      expect(find.byType(QuantumMeasurementBlochScreen), findsOneWidget);
    });

    testWidgets('leave QM disposes runtime (no QM home)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: QuantumMeasurementHome()),
      );
      await tester.pump();
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      expect(find.byType(QuantumMeasurementHome), findsNothing);
      expect(find.byType(QuantumMeasurementPhotonsScreen), findsNothing);
    });
  });
}

class _ThrowingSink implements SimulationEventSink {
  @override
  void emit(SimulationEvent event) => throw StateError('backend down');
}
