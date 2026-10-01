// Integration test: real thermometer drag interaction (M1 verification).
//
// Starts the actual BlackbodySpectrumHome widget, finds the thermometer
// thumb, and performs real GestureDetector drag operations to verify:
//   1. drag up → temperature increases
//   2. drag down → temperature decreases
//   3. clamp at min/max
//   4. spectrum/peak wavelength changes with drag
//   5. reset restores original temperature
//
// [来源: BlackbodySpectrumThermometer.js:91-108 (DragListener)]
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/blackbody_spectrum/screens/blackbody_spectrum_home.dart';
import 'package:kratos/blackbody_spectrum/blackbody_spectrum_constants.dart';

void main() {
  testWidgets('drag up increases temperature', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BlackbodySpectrumHome()));
    await tester.pumpAndSettle();

    final homeState = tester.state<BlackbodySpectrumHomeState>(
      find.byType(BlackbodySpectrumHome),
    );
    final model = homeState.model;
    expect(model.temperature, equals(5800));

    final size = tester.getSize(find.byType(BlackbodySpectrumHome));
    final scale = size.width / 1024 < size.height / 768
        ? size.width / 1024
        : size.height / 768;

    final thumbCx = (1009 - 35 + 20 / 2 + 2) * scale;
    final thumbY5800 = (60 + 400 - ((5800 - 200) / (11000 - 200)) * 400) * scale;

    // Real drag: press down on thumb, move up, release
    final gesture = await tester.startGesture(Offset(thumbCx, thumbY5800));
    await tester.pump();
    // Move up in steps
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, -10));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(model.temperature, greaterThan(5800),
        reason: 'dragging up must increase temperature');
  });

  testWidgets('drag down decreases temperature', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BlackbodySpectrumHome()));
    await tester.pumpAndSettle();

    final homeState = tester.state<BlackbodySpectrumHomeState>(
      find.byType(BlackbodySpectrumHome),
    );
    final model = homeState.model;
    expect(model.temperature, equals(5800));

    final size = tester.getSize(find.byType(BlackbodySpectrumHome));
    final scale = size.width / 1024 < size.height / 768
        ? size.width / 1024
        : size.height / 768;

    final thumbCx = (1009 - 35 + 20 / 2 + 2) * scale;
    final thumbY5800 = (60 + 400 - ((5800 - 200) / (11000 - 200)) * 400) * scale;

    final gesture = await tester.startGesture(Offset(thumbCx, thumbY5800));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(model.temperature, lessThan(5800),
        reason: 'dragging down must decrease temperature');
  });

  testWidgets('drag up to max clamps at 11000K', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BlackbodySpectrumHome()));
    await tester.pumpAndSettle();

    final homeState = tester.state<BlackbodySpectrumHomeState>(
      find.byType(BlackbodySpectrumHome),
    );
    final model = homeState.model;

    final size = tester.getSize(find.byType(BlackbodySpectrumHome));
    final scale = size.width / 1024 < size.height / 768
        ? size.width / 1024
        : size.height / 768;

    final thumbCx = (1009 - 35 + 20 / 2 + 2) * scale;
    final thumbY5800 = (60 + 400 - ((5800 - 200) / (11000 - 200)) * 400) * scale;

    // Drag way up — far beyond tube top
    final gesture = await tester.startGesture(Offset(thumbCx, thumbY5800));
    await tester.pump();
    for (var i = 0; i < 50; i++) {
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(model.temperature, equals(BlackbodySpectrumConstants.maxTemperature),
        reason: 'must clamp at max temperature');
  });

  testWidgets('drag down to min clamps at 200K', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BlackbodySpectrumHome()));
    await tester.pumpAndSettle();

    final homeState = tester.state<BlackbodySpectrumHomeState>(
      find.byType(BlackbodySpectrumHome),
    );
    final model = homeState.model;

    final size = tester.getSize(find.byType(BlackbodySpectrumHome));
    final scale = size.width / 1024 < size.height / 768
        ? size.width / 1024
        : size.height / 768;

    final thumbCx = (1009 - 35 + 20 / 2 + 2) * scale;
    final thumbY5800 = (60 + 400 - ((5800 - 200) / (11000 - 200)) * 400) * scale;

    final gesture = await tester.startGesture(Offset(thumbCx, thumbY5800));
    await tester.pump();
    for (var i = 0; i < 50; i++) {
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(model.temperature, equals(BlackbodySpectrumConstants.minTemperature),
        reason: 'must clamp at min temperature');
  });

  testWidgets('drag changes peak wavelength (Wien)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BlackbodySpectrumHome()));
    await tester.pumpAndSettle();

    final homeState = tester.state<BlackbodySpectrumHomeState>(
      find.byType(BlackbodySpectrumHome),
    );
    final model = homeState.model;
    final peakBefore = model.mainBody.peakWavelength;

    final size = tester.getSize(find.byType(BlackbodySpectrumHome));
    final scale = size.width / 1024 < size.height / 768
        ? size.width / 1024
        : size.height / 768;

    final thumbCx = (1009 - 35 + 20 / 2 + 2) * scale;
    final thumbY5800 = (60 + 400 - ((5800 - 200) / (11000 - 200)) * 400) * scale;

    final gesture = await tester.startGesture(Offset(thumbCx, thumbY5800));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, -10));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();

    final peakAfter = model.mainBody.peakWavelength;
    expect(peakAfter, lessThan(peakBefore),
        reason: 'higher T → shorter peak wavelength (Wien)');
  });

  testWidgets('reset restores temperature to 5800K after drag', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BlackbodySpectrumHome()));
    await tester.pumpAndSettle();

    final homeState = tester.state<BlackbodySpectrumHomeState>(
      find.byType(BlackbodySpectrumHome),
    );
    final model = homeState.model;
    expect(model.temperature, equals(5800));

    final size = tester.getSize(find.byType(BlackbodySpectrumHome));
    final scale = size.width / 1024 < size.height / 768
        ? size.width / 1024
        : size.height / 768;
    final thumbCx = (1009 - 35 + 20 / 2 + 2) * scale;
    final thumbY5800 = (60 + 400 - ((5800 - 200) / (11000 - 200)) * 400) * scale;

    final gesture = await tester.startGesture(Offset(thumbCx, thumbY5800));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(model.temperature, lessThan(5800));

    model.reset();
    await tester.pumpAndSettle();
    expect(model.temperature, equals(5800),
        reason: 'reset must restore original temperature');
  });
}
