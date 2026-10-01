import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/balancing_act/balancing_act.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SizedBox(width: 800, height: 600, child: child)),
  );
}

void main() {
  testWidgets('Intro viewport is 768x504 stage', (tester) async {
    await tester.pumpWidget(_wrap(const BaIntroScreen()));
    await tester.pump();
    expect(find.byKey(const Key('ba_intro_viewport')), findsOneWidget);
    final stage = tester.getSize(find.byKey(const Key('ba_intro_viewport')));
    // FittedBox child intrinsic; key is on SizedBox inside FittedBox
    // Verify layout constants match source.
    expect(BaSharedConstants.layoutWidth, 768);
    expect(BaSharedConstants.layoutHeight, 504);
    expect(stage.width, greaterThan(0));
  });

  testWidgets('Intro shows Reset All and control chrome', (tester) async {
    await tester.pumpWidget(_wrap(const BaIntroScreen()));
    await tester.pump();
    expect(find.byKey(const Key('ba_intro_reset_all')), findsOneWidget);
    expect(find.byType(KratosResetAllButton), findsOneWidget);
    expect(find.text('Show'), findsOneWidget);
    expect(find.text('Mass Labels'), findsOneWidget);
    expect(find.text('Position'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
  });

  testWidgets('MVT scale and origin match source', (tester) async {
    final mvt = BaModelViewTransform();
    expect(mvt.scale, 105);
    expect(mvt.originInView.dx, closeTo(768 * 0.375, 1e-9));
    expect(mvt.originInView.dy, closeTo(504 * 0.79, 1e-9));
    // Y inverted
    expect(mvt.modelToViewY(1), lessThan(mvt.modelToViewY(0)));
    expect(mvt.viewToModel(mvt.modelToView(const BaVector2(1, 0.5))).x,
        closeTo(1, 1e-9));
  });
}
