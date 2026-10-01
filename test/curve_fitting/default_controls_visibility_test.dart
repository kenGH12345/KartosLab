import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/curve_fitting/curve_fitting_strings.dart';
import 'package:kratos/curve_fitting/screens/curve_fitting_home.dart';

void main() {
  testWidgets(
    'default: ViewOptions visible; Order/Fit hidden until Curve on',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: CurveFittingHome()));
      await tester.pumpAndSettle();

      expect(find.text(CurveFittingStrings.curve), findsOneWidget);
      expect(find.text(CurveFittingStrings.residuals), findsOneWidget);
      expect(find.text(CurveFittingStrings.values), findsOneWidget);

      expect(find.text(CurveFittingStrings.linear), findsNothing);
      expect(find.text(CurveFittingStrings.bestFit), findsNothing);

      await tester.tap(find.text(CurveFittingStrings.curve));
      await tester.pumpAndSettle();

      expect(find.text(CurveFittingStrings.linear), findsOneWidget);
      expect(find.text(CurveFittingStrings.bestFit), findsOneWidget);
    },
  );
}
