import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/common/widgets/kratos_reset_all_button.dart';
import 'package:kratos/friction/friction_constants.dart';
import 'package:kratos/friction/model/friction_model.dart';
import 'package:kratos/friction/view/friction_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FrictionScreen builds and reset restores model', (tester) async {
    final model = FrictionModel();
    await tester.pumpWidget(
      MaterialApp(
        home: FrictionScreen(
          model: model,
          autoStartClock: false,
          enableAudio: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Friction'), findsOneWidget);
    expect(find.byType(FrictionScreen), findsOneWidget);
    expect(find.byType(KratosResetAllButton), findsOneWidget);

    model.setTopBookPosition(const Offset(0, 30));
    model.moveTopBookBy(const Offset(200, 0));
    expect(
      model.vibrationAmplitude,
      greaterThan(FrictionConstants.vibrationAmplitudeMin),
    );

    await tester.tap(find.byType(KratosResetAllButton));
    await tester.pump();

    expect(model.topBookPosition, Offset.zero);
    expect(model.vibrationAmplitude, FrictionConstants.vibrationAmplitudeMin);
  });

  testWidgets('lifecycle dispose stops without crash', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FrictionScreen(autoStartClock: true, enableAudio: false),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
