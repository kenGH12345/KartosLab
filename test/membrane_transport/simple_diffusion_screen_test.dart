import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/membrane_transport/layout/membrane_transport_layout.dart';
import 'package:kratos/membrane_transport/screens/simple_diffusion_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Simple Diffusion screen builds and shows Solutes', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SimpleDiffusionScreenBody(seed: 7),
        ),
      ),
    );
    await tester.pump(); // first frame
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Solutes'), findsOneWidget);
    expect(find.text('Solute Concentrations'), findsOneWidget);
    expect(find.text('Outside'), findsWidgets);
    expect(find.text('Inside'), findsWidgets);
    expect(find.text('Normal'), findsOneWidget);
    expect(MembraneTransportLayoutPrimitives.designWidth, 1024);
  });
}
