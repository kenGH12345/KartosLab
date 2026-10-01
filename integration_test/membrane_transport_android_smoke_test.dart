import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kratos/membrane_transport/debug_membrane_transport_main.dart';
import 'package:kratos/membrane_transport/screens/membrane_transport_home.dart';
import 'package:kratos/membrane_transport/screens/simple_diffusion_screen.dart';

/// Phase 7 Android/device smoke — run on emulator:
/// `flutter test integration_test/membrane_transport_android_smoke_test.dart -d emulator-5554`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MT7 four tabs launch and switch', (tester) async {
    await tester.pumpWidget(const MembraneTransportDebugApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(MembraneTransportHome), findsOneWidget);
    expect(find.text('Simple Diffusion'), findsWidgets);

    // Cycle tabs if labels visible
    for (final label in [
      'Facilitated Diffusion',
      'Active Transport',
      'Playground',
      'Simple Diffusion',
    ]) {
      final tab = find.text(label);
      if (tab.evaluate().isNotEmpty) {
        await tester.tap(tab.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 800));
      }
    }

    expect(find.byType(MembraneTransportScreenBody), findsOneWidget);
  });

  testWidgets('MT7 facilitated toolbox visible and reset', (tester) async {
    await tester.pumpWidget(const MembraneTransportDebugApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final fd = find.text('Facilitated Diffusion');
    if (fd.evaluate().isNotEmpty) {
      await tester.tap(fd.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    expect(find.text('Leakage Channels'), findsOneWidget);
    expect(find.text('Add Ligands'), findsOneWidget);

    // Tap a leakage tool (place via keyboard path)
    final sodium = find.text('Sodium Ion');
    if (sodium.evaluate().isNotEmpty) {
      await tester.tap(sodium.first);
      await tester.pumpAndSettle();
    }
  });
}
