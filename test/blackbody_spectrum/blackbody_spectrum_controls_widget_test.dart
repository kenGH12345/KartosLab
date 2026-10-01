// Widget tests: control panel + zoom + save/erase/reset hit targets.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/blackbody_spectrum/blackbody_spectrum_constants.dart';
import 'package:kratos/blackbody_spectrum/screens/blackbody_spectrum_home.dart';

Offset _phetToScreen(Offset phet, Size homeSize) {
  final scale = homeSize.width / 1024 < homeSize.height / 768
      ? homeSize.width / 1024
      : homeSize.height / 768;
  // Centered 1024×768 canvas inside home
  final canvasW = 1024 * scale;
  final canvasH = 768 * scale;
  final originX = (homeSize.width - canvasW) / 2;
  final originY = (homeSize.height - canvasH) / 2;
  return Offset(originX + phet.dx * scale, originY + phet.dy * scale);
}

Future<BlackbodySpectrumHomeState> _pump(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: BlackbodySpectrumHome()));
  await tester.pumpAndSettle();
  return tester.state<BlackbodySpectrumHomeState>(
    find.byType(BlackbodySpectrumHome),
  );
}

void main() {
  testWidgets('checkbox toggles graph values', (tester) async {
    final home = await _pump(tester);
    final model = home.model;
    expect(model.graphValuesVisible, isFalse);

    final size = tester.getSize(find.byType(BlackbodySpectrumHome));
    // Panel left ≈ 672; first checkbox row
    await tester.tapAt(_phetToScreen(const Offset(700, 65), size));
    await tester.pumpAndSettle();

    expect(model.graphValuesVisible, isTrue);
  });

  testWidgets('horizontal zoom out increases wavelengthMax', (tester) async {
    final home = await _pump(tester);
    final model = home.model;
    final before = model.wavelengthMax;

    final size = tester.getSize(find.byType(BlackbodySpectrumHome));
    // hZoom out: graphRight=672, cy=graphBottom+35=713
    await tester.tapAt(_phetToScreen(const Offset(672, 713), size));
    await tester.pumpAndSettle();

    expect(model.wavelengthMax, greaterThan(before));
  });

  testWidgets('save then erase FIFO', (tester) async {
    final home = await _pump(tester);
    final model = home.model;
    expect(model.savedBodyOne.temperature, isNull);

    final size = tester.getSize(find.byType(BlackbodySpectrumHome));
    // Panel left ≈ 672; Save/Erase centers ≈ (712, 202) / (772, 202)
    await tester.tapAt(_phetToScreen(const Offset(712, 202), size));
    await tester.pumpAndSettle();
    expect(model.savedBodyOne.temperature, equals(5800));

    await tester.tapAt(_phetToScreen(const Offset(772, 202), size));
    await tester.pumpAndSettle();
    expect(model.savedBodyOne.temperature, isNull);
  });

  testWidgets('reset restores defaults after edits', (tester) async {
    final home = await _pump(tester);
    final model = home.model;
    model.temperature = 3000;
    model.setLabelsVisible(true);
    model.zoomHorizontalOut();
    await tester.pump();

    final size = tester.getSize(find.byType(BlackbodySpectrumHome));
    await tester.tapAt(_phetToScreen(const Offset(964, 738), size));
    await tester.pumpAndSettle();

    expect(model.temperature, equals(BlackbodySpectrumConstants.sunTemperature));
    expect(model.labelsVisible, isFalse);
    expect(model.wavelengthMax,
        equals(BlackbodySpectrumConstants.defaultHorizontalZoom));
  });
}
