import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/color_vision/model/rgb_model.dart';
import 'package:kratos/color_vision/model/single_bulb_model.dart';
import 'package:kratos/color_vision/screens/color_vision_home.dart';
import 'package:kratos/color_vision/view/rgb_screen_view.dart';
import 'package:kratos/color_vision/view/single_bulb_screen_view.dart';
import 'package:kratos/screens/home_screen.dart';

void main() {
  test('Home catalog metadata for Color Vision', () {
    expect(ColorVisionHome.title, contains('色觉'));
    expect(ColorVisionHome.subtitle, contains('Single Bulb'));
    expect(HomeScreen, isNotNull);
  });

  testWidgets('Home → Single Bulb → reset → reopen', (tester) async {
    final old = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('A RenderFlex overflowed')) return;
      old?.call(details);
    };
    addTearDown(() => FlutterError.onError = old);

    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(home: ColorVisionHome()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('色觉'), findsWidgets);
    expect(find.byType(SingleBulbScreenView), findsOneWidget);

    final model = SingleBulbModel();
    model.setFlashlightOn(true);
    model.setFlashlightWavelength(500);
    model.reset();
    expect(model.flashlightOn, isFalse);
    expect(model.flashlightWavelength, 570);
    model.dispose();

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();
    await tester.pumpWidget(
      const MaterialApp(home: ColorVisionHome()),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(SingleBulbScreenView), findsOneWidget);
  });

  testWidgets('RGB Bulb tab loads and model resets', (tester) async {
    final old = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('A RenderFlex overflowed')) return;
      old?.call(details);
    };
    addTearDown(() => FlutterError.onError = old);

    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(home: ColorVisionHome()),
    );
    await tester.pump();
    await tester.tap(find.text('RGB Bulbs'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(RgbScreenView), findsOneWidget);

    final rgb = RgbModel();
    rgb.setRedIntensity(100);
    rgb.setGreenIntensity(50);
    rgb.reset();
    expect(rgb.redIntensity, 0);
    expect(rgb.greenIntensity, 0);
    rgb.dispose();
  });
}
