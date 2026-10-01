import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/magnetism/magnet_and_compass/painters/bar_magnet_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/field_needle_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/screens/magnet_and_compass_screen.dart';
import 'package:kratos/magnetism/magnet_and_compass/widgets/control_panel.dart';

Finder _paint(bool Function(CustomPainter? p) pred) => find.byWidgetPredicate(
      (w) => w is CustomPaint && pred(w.painter),
    );

void _expectNoOverflow(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}

Future<void> _pumpAt(WidgetTester tester, Size logical) async {
  tester.view.physicalSize = logical;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const MaterialApp(home: MagnetAndCompassScreen()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  _expectNoOverflow(tester);
}

Future<void> _teardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 20));
}

void main() {
  group('ControlPanel layout · no overflow', () {
    for (final size in const [
      Size(1280, 800),
      Size(1024, 768),
      Size(640, 360),
    ]) {
      testWidgets('${size.width.toInt()}×${size.height.toInt()}', (tester) async {
        await _pumpAt(tester, size);

        expect(find.byType(MagnetControlPanel), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
        expect(find.text('Bar Magnet'), findsOneWidget);
        expect(find.text('Flip Polarity'), findsOneWidget);
        expect(find.text('Compass'), findsOneWidget);
        expect(find.text('Field Meter'), findsOneWidget);

        final panel = tester.getRect(find.byType(MagnetControlPanel));
        final canvas = tester.getRect(_paint((p) => p is FieldNeedlePainter));
        expect(panel.width, closeTo(230, 0.5));
        expect(panel.top, closeTo(canvas.top + 12, 1.0));
        expect(panel.right, closeTo(canvas.right - 12, 1.0));
        expect(panel.left, greaterThanOrEqualTo(canvas.left - 0.5));

        await _teardown(tester);
      });
    }
  });

  group('ControlPanel interaction', () {
    testWidgets('slider drag changes strength; arrows still step', (tester) async {
      await _pumpAt(tester, const Size(1280, 800));

      expect(find.text('75%'), findsOneWidget);
      await tester.drag(find.byType(Slider), const Offset(-80, 0));
      await tester.pump();
      _expectNoOverflow(tester);
      expect(find.text('75%'), findsNothing);

      await tester.tap(find.byIcon(Icons.arrow_right));
      await tester.pump();
      _expectNoOverflow(tester);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      _expectNoOverflow(tester);
      expect(find.text('75%'), findsOneWidget);

      await _teardown(tester);
    });

    testWidgets('panel survives hide-compass and reset', (tester) async {
      await _pumpAt(tester, const Size(1280, 800));

      expect(find.byType(MagnetControlPanel), findsOneWidget);
      await tester.tap(find.byType(Checkbox).at(3));
      await tester.pump();
      _expectNoOverflow(tester);
      expect(find.byType(MagnetControlPanel), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      _expectNoOverflow(tester);
      expect(find.byType(MagnetControlPanel), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(_paint((p) => p is BarMagnetPainter), findsOneWidget);

      await _teardown(tester);
    });
  });
}
