import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/cck_ac_virtual_lab/cck_strings.dart';
import 'package:kratos/cck_ac_virtual_lab/painters/circuit_painter.dart';
import 'package:kratos/cck_ac_virtual_lab/screens/cck_ac_virtual_lab_screen.dart';

void main() {
  testWidgets('Lab screen matches empty-lab chrome', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CckAcVirtualLabScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text(CckStrings.title), findsOneWidget);
    expect(find.text(CckStrings.wire), findsWidgets);
    expect(find.text(CckStrings.battery), findsOneWidget);
    expect(find.text(CckStrings.acVoltage), findsOneWidget);
    expect(find.text(CckStrings.inductor), findsOneWidget);
    expect(find.text(CckStrings.showCurrent), findsOneWidget);
    expect(find.text(CckStrings.advanced), findsOneWidget);
    expect(find.text(CckStrings.voltmeter), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.add), findsWidgets);

    final paints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
    expect(
      paints.any((p) => p.painter is CircuitPainter),
      isTrue,
    );

    await tester.tap(find.byKey(const Key('cck-view-schematic')));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
  });
}
