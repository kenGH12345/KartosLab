import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/chemistry/build_an_atom/constants/baa_constants.dart';
import 'package:kratos/chemistry/build_an_atom/model/baa_model.dart';
import 'package:kratos/chemistry/build_an_atom/screens/atom_screen.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/baa_accordion_box.dart';
import 'package:kratos/chemistry/build_an_atom/widgets/baa_periodic_table.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bare accordion collapses to header height', (tester) async {
    var expanded = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return BaaAccordionBox(
                title: 'Net Charge',
                expanded: expanded,
                onToggle: () => setState(() => expanded = !expanded),
                child: const SizedBox(width: 200, height: 120),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    final openH = tester.getSize(find.byType(BaaAccordionBox)).height;
    expect(openH, greaterThan(100));

    await tester.tap(find.text('Net Charge'));
    await tester.pump();
    final closedH = tester.getSize(find.byType(BaaAccordionBox)).height;
    expect(closedH, lessThan(50));
    expect(closedH, lessThan(openH * 0.4));
  });

  testWidgets('periodic table shows full main-table symbols (H…Og path)',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BaaPeriodicTable(selectedZ: 1, scale: 1),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('H'), findsWidgets);
    expect(find.text('He'), findsOneWidget);
    expect(find.text('Ne'), findsOneWidget);
    expect(find.text('Fe'), findsOneWidget);
    expect(find.text('Og'), findsOneWidget);
    expect(BaaPeriodicTable.buildCells().length, 90);
  });

  testWidgets('Atom accordion header Y stays fixed when collapsed',
      (tester) async {
    final model = BAAModel();
    await tester.binding.setSurfaceSize(
      const Size(BAAConstants.designWidth, BAAConstants.designHeight + 56),
    );
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(BAAConstants.designWidth, BAAConstants.designHeight + 56),
            devicePixelRatio: 1,
            textScaler: TextScaler.linear(1),
          ),
          child: BuildAnAtomAtomScreen(model: model),
        ),
      ),
    );
    await tester.pump();

    final net = find.text('Net Charge');
    final mass = find.text('Mass Number');
    final netTopOpen = tester.getTopLeft(net).dy;
    final massTopOpen = tester.getTopLeft(mass).dy;

    await tester.tap(net);
    await tester.pump();
    await tester.tap(mass);
    await tester.pump();

    // Headers keep absolute seats — no upward shift when body hides.
    expect(tester.getTopLeft(net).dy, closeTo(netTopOpen, 1));
    expect(tester.getTopLeft(mass).dy, closeTo(massTopOpen, 1));
    expect(massTopOpen - netTopOpen, greaterThan(60));
  });
}
