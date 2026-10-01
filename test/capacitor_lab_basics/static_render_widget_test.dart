import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/model/capacitance_model.dart';
import 'package:kratos/capacitor_lab_basics/capacitance/screens/capacitance_static_screen_body.dart';
import 'package:kratos/capacitor_lab_basics/clb_constants.dart';
import 'package:kratos/capacitor_lab_basics/common/model/clb_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CapacitanceStaticScreenBody paints 1024×618 circuit', (tester) async {
    final model = CapacitanceModel(shared: ClbSharedState());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CapacitanceStaticScreenBody(model: model),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CapacitanceStaticScreenBody), findsOneWidget);
    final box = tester.getSize(find.byType(CapacitanceStaticScreenBody));
    // FittedBox may shrink; design child is 1024×618
    expect(box.width, greaterThan(0));
    expect(box.height, greaterThan(0));

    // Original voltmeter asset present in tree when visible=false still overlays
    // at model origin — Image.asset for body should exist.
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('design SizedBox is 1024×618 inside FittedBox', (tester) async {
    final model = CapacitanceModel(shared: ClbSharedState());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OverflowBox(
            maxWidth: 2000,
            maxHeight: 2000,
            child: CapacitanceStaticScreenBody(model: model),
          ),
        ),
      ),
    );
    await tester.pump();

    final sized = find.byWidgetPredicate(
      (w) =>
          w is SizedBox &&
          w.width == ClbConstants.canvasWidth &&
          w.height == ClbConstants.canvasHeight,
    );
    expect(sized, findsWidgets);
  });
}
