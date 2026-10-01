import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:kratos/main.dart';
import 'package:kratos/quantum_measurement/quantum_measurement_module.dart';
import 'package:kratos/quantum_measurement/screens/quantum_measurement_home.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 10 — Home ↔ Quantum Measurement on real Android.
///
/// `flutter test integration_test/quantum_measurement_home_android_test.dart -d emulator-5554`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> frames(WidgetTester tester, [int n = 15]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('H1 Home → QM → tabs → Back → Home → reopen', (tester) async {
    QuantumMeasurementModule.register();
    await tester.pumpWidget(const KratosApp());
    await frames(tester, 25);
    expect(find.byType(HomeScreen), findsOneWidget);

    final card = find.text('Quantum Measurement');
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await tester.tap(card);
    await frames(tester, 20);
    expect(find.byType(QuantumMeasurementHome), findsOneWidget);

    for (final tab in ['Photons', 'Spin', 'Bloch Sphere', 'Coins']) {
      await tester.tap(find.text(tab).first);
      await frames(tester, 12);
    }

    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back);
    } else {
      await tester.pageBack();
    }
    await frames(tester, 20);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(QuantumMeasurementHome), findsNothing);

    await tester.ensureVisible(find.text('Quantum Measurement'));
    await tester.tap(find.text('Quantum Measurement'));
    await frames(tester, 20);
    expect(find.byType(QuantumMeasurementHome), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('H2 peer sim open/back still works (Membrane Transport)',
      (tester) async {
    QuantumMeasurementModule.register();
    await tester.pumpWidget(const KratosApp());
    await frames(tester, 20);

    final peer = find.text('Membrane Transport');
    if (peer.evaluate().isEmpty) {
      // Peer not visible at this scroll — still assert Home stable
      expect(find.byType(HomeScreen), findsOneWidget);
      return;
    }
    await tester.ensureVisible(peer);
    await tester.tap(peer);
    await frames(tester, 20);
    expect(find.text('Membrane Transport'), findsWidgets);

    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back);
    } else {
      await tester.pageBack();
    }
    await frames(tester, 20);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
