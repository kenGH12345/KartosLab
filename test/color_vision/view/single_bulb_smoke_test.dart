import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/color_vision/model/single_bulb_model.dart';
import 'package:kratos/color_vision/view/single_bulb_screen_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SingleBulbScreenView smoke: reset key + flashlight toggle',
      (tester) async {
    final model = SingleBulbModel();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleBulbScreenView(
            model: model,
            autoStartClock: false,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('color_vision_reset_all')), findsOneWidget);
    expect(model.flashlightOn, isFalse);

    await tester.tap(find.byKey(const Key('color_vision_flashlight_toggle')));
    await tester.pump();
    expect(model.flashlightOn, isTrue);

    await tester.tap(find.byKey(const Key('color_vision_flashlight_toggle')));
    await tester.pump();
    expect(model.flashlightOn, isFalse);

    await tester.tap(find.byKey(const Key('color_vision_reset_all')));
    await tester.pump();
    expect(model.flashlightOn, isFalse);
    expect(model.flashlightWavelength, 570);
  });
}
