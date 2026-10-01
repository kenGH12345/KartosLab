import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:kratos/quantum_measurement/bloch_sphere/model/bloch_sphere_model.dart';
import 'package:kratos/quantum_measurement/bloch_sphere/view/bloch_screen.dart';
import 'package:kratos/quantum_measurement/coins/components/coins_scene_primitives.dart';
import 'package:kratos/quantum_measurement/coins/view/coins_screen.dart';
import 'package:kratos/quantum_measurement/debug_quantum_measurement_main.dart';
import 'package:kratos/quantum_measurement/photons/components/photon_source.dart';
import 'package:kratos/quantum_measurement/photons/view/photons_screen.dart';
import 'package:kratos/quantum_measurement/spin/components/experiment_selector.dart';
import 'package:kratos/quantum_measurement/spin/view/spin_screen.dart';

/// PHASE 9 — Android device runtime gate (real emulator touch).
///
/// `flutter test integration_test/quantum_measurement_android_runtime_test.dart -d emulator-5554`
///
/// Live Tickers: never pumpAndSettle on Photons/Spin/Bloch.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFrames(WidgetTester tester, [int n = 12]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> launch(WidgetTester tester) async {
    await tester.pumpWidget(const QuantumMeasurementAndroidRuntimeApp());
    await pumpFrames(tester, 25);
  }

  Future<void> goTab(WidgetTester tester, String name) async {
    final key = Key('qm_tab_${name.toLowerCase()}');
    await tester.tap(find.byKey(key));
    await pumpFrames(tester, 20);
  }

  Future<void> tapText(WidgetTester tester, String label) async {
    final f = find.text(label);
    expect(f, findsWidgets, reason: 'missing "$label"');
    await tester.ensureVisible(f.first);
    await tester.tap(f.first, warnIfMissed: false);
    await pumpFrames(tester, 8);
  }

  Future<void> waitFor(WidgetTester tester, Finder finder, {int frames = 40}) async {
    for (var i = 0; i < frames; i++) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(finder, findsWidgets);
  }

  testWidgets('A1 Launch + four screens first frame', (tester) async {
    await launch(tester);
    expect(find.byType(QuantumMeasurementCoinsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    await goTab(tester, 'Photons');
    expect(find.byType(QuantumMeasurementPhotonsScreen), findsOneWidget);
    await goTab(tester, 'Spin');
    expect(find.byType(QuantumMeasurementSpinScreen), findsOneWidget);
    await goTab(tester, 'Bloch');
    expect(find.byType(QuantumMeasurementBlochScreen), findsOneWidget);
    await goTab(tester, 'Coins');
    expect(find.byType(QuantumMeasurementCoinsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A2 Coins Classical + Quantum path', (tester) async {
    await launch(tester);
    await goTab(tester, 'Coins');
    await waitFor(tester, find.byType(StartMeasurementButton));

    await tester.tap(find.byType(StartMeasurementButton));
    await pumpFrames(tester, 10);
    await tapText(tester, 'Flip and Reveal');
    expect(find.text('Hide'), findsWidgets);

    await tapText(tester, "Quantum 'Coin'");
    await waitFor(tester, find.byType(StartMeasurementButton));
    await tester.tap(find.byType(StartMeasurementButton));
    await pumpFrames(tester, 10);
    await tapText(tester, 'Reprepare');
    await tapText(tester, 'Observe');
    expect(find.text('Reprepare'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A3 Coins count 10 / 100 / 10000', (tester) async {
    await launch(tester);
    await goTab(tester, 'Coins');
    await tapText(tester, '10');
    await tapText(tester, '100');
    await tapText(tester, '10000');
    await pumpFrames(tester, 40);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A4 Photons Classical/Quantum/Continuous stop', (tester) async {
    await launch(tester);
    await goTab(tester, 'Photons');
    await waitFor(tester, find.text('Single Photon'));

    await tapText(tester, 'Classical');
    final ink = find.descendant(
      of: find.byType(PhotonSourceNode),
      matching: find.byType(InkWell),
    );
    if (ink.evaluate().isNotEmpty) {
      await tester.tap(ink.first, warnIfMissed: false);
      await pumpFrames(tester, 25);
    }

    await tapText(tester, 'Quantum');
    await tapText(tester, 'Many Photons');
    // Raise emission rate via Slider if present
    final slider = find.byType(Slider);
    if (slider.evaluate().isNotEmpty) {
      await tester.drag(slider.first, const Offset(40, 0));
      await pumpFrames(tester, 60); // ~3s continuous
    }
    await tapText(tester, 'Single Photon');
    expect(find.text('Single Photon'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A5 Spin Exp / Block / Cont', (tester) async {
    await launch(tester);
    await goTab(tester, 'Spin');
    await waitFor(tester, find.byType(ExperimentSelector));

    await tester.tap(find.byType(ExperimentSelector));
    await pumpFrames(tester, 15);
    await tester.tap(find.text('Experiment 2 [SGx]').last, warnIfMissed: false);
    await pumpFrames(tester, 12);

    await tester.tap(find.byType(ExperimentSelector));
    await pumpFrames(tester, 15);
    await tester.tap(find.text('Experiment 3 [SGz, SGx]').last,
        warnIfMissed: false);
    await pumpFrames(tester, 12);

    await tapText(tester, 'Cont.');
    await pumpFrames(tester, 30);
    if (find.text('Block ↓').evaluate().isNotEmpty) {
      await tester.tap(find.text('Block ↓'));
      await pumpFrames(tester, 10);
      await tester.tap(find.text('Block ↑'));
      await pumpFrames(tester, 10);
    }

    await tester.tap(find.byType(ExperimentSelector));
    await pumpFrames(tester, 15);
    await tester.tap(find.text('Custom').last, warnIfMissed: false);
    await pumpFrames(tester, 12);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A6 Bloch presets Observe Erase Reset Field', (tester) async {
    await launch(tester);
    await goTab(tester, 'Bloch');
    await waitFor(tester, find.byType(DropdownButton<BlochStateDirection>));

    await tester.tap(find.byType(DropdownButton<BlochStateDirection>));
    await pumpFrames(tester, 12);
    await tester.tap(find.text('+X').last, warnIfMissed: false);
    await pumpFrames(tester, 8);

    await tapText(tester, 'Observe');
    await tapText(tester, 'Erase');
    await tapText(tester, 'Reprepare');

    await tapText(tester, 'Magnetic Field');
    await pumpFrames(tester, 60);
    await tapText(tester, 'Magnetic Field');

    await tester.tap(find.byTooltip('Reset All'));
    await pumpFrames(tester, 8);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A7 Rapid screen switch ×10 + leave dispose', (tester) async {
    await launch(tester);
    for (var i = 0; i < 10; i++) {
      for (final t in ['Coins', 'Photons', 'Spin', 'Bloch']) {
        await goTab(tester, t);
      }
    }
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await pumpFrames(tester, 12);
    expect(find.byType(QuantumMeasurementCoinsScreen), findsNothing);
    expect(find.byType(QuantumMeasurementPhotonsScreen), findsNothing);
    expect(find.byType(QuantumMeasurementSpinScreen), findsNothing);
    expect(find.byType(QuantumMeasurementBlochScreen), findsNothing);
  });

  testWidgets('A8 Full Android user journey (long path)', (tester) async {
    await launch(tester);

    await goTab(tester, 'Coins');
    await waitFor(tester, find.byType(StartMeasurementButton));
    await tester.tap(find.byType(StartMeasurementButton));
    await pumpFrames(tester, 8);
    await tapText(tester, 'Flip and Reveal');
    await tapText(tester, "Quantum 'Coin'");
    await waitFor(tester, find.byType(StartMeasurementButton));
    await tester.tap(find.byType(StartMeasurementButton));
    await pumpFrames(tester, 8);
    await tapText(tester, 'Reprepare');
    await tapText(tester, 'Observe');

    await goTab(tester, 'Photons');
    await waitFor(tester, find.text('Single Photon'));
    await tapText(tester, 'Classical');
    await tapText(tester, 'Quantum');
    await tapText(tester, 'Many Photons');
    await pumpFrames(tester, 25);
    await tapText(tester, 'Single Photon');

    await goTab(tester, 'Spin');
    await tester.tap(find.byType(ExperimentSelector));
    await pumpFrames(tester, 12);
    await tester.tap(find.text('Experiment 2 [SGx]').last, warnIfMissed: false);
    await pumpFrames(tester, 10);
    await tester.tap(find.byType(ExperimentSelector));
    await pumpFrames(tester, 12);
    await tester.tap(find.text('Experiment 5 [SGx, SGz]').last,
        warnIfMissed: false);
    await pumpFrames(tester, 10);
    await tapText(tester, 'Cont.');
    await pumpFrames(tester, 30);
    await tapText(tester, 'Single');
    await tester.tap(find.byType(ExperimentSelector));
    await pumpFrames(tester, 12);
    await tester.tap(find.text('Custom').last, warnIfMissed: false);
    await pumpFrames(tester, 10);

    await goTab(tester, 'Bloch');
    await tester.tap(find.byType(DropdownButton<BlochStateDirection>));
    await pumpFrames(tester, 10);
    await tester.tap(find.text('+X').last, warnIfMissed: false);
    await pumpFrames(tester, 8);
    await tapText(tester, 'Observe');
    await tapText(tester, 'Erase');
    await tester.tap(find.byTooltip('Reset All'));
    await pumpFrames(tester, 8);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await pumpFrames(tester, 8);
    await launch(tester);
    expect(find.byType(QuantumMeasurementCoinsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
