import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/membrane_transport/screens/membrane_transport_home.dart';
import 'package:kratos/screens/home_screen.dart';

/// PHASE 8 Home golden — MT card visible; does not replace MT5 sim goldens.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpHome(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(MembraneTransportHome.title));
    await tester.pump();
  }

  testWidgets('MT8-H-01 Home with Membrane Transport card visible',
      (tester) async {
    await pumpHome(tester, const Size(1280, 900));
    expect(find.text(MembraneTransportHome.title), findsOneWidget);
    expect(find.text('热学与气体'), findsOneWidget);
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/MT8-H-01_home_mt_card.png'),
    );
  });

  testWidgets('MT8-H-02 Home → Membrane Transport opened', (tester) async {
    await pumpHome(tester, const Size(1280, 800));
    await tester.tap(find.text(MembraneTransportHome.title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    while (tester.takeException() != null) {}
    expect(find.byType(MembraneTransportHome), findsOneWidget);
    await expectLater(
      find.byType(MembraneTransportHome),
      matchesGoldenFile('goldens/MT8-H-02_mt_opened.png'),
    );
  });
}
