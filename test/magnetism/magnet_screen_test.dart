import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/common/widgets/nine_grid_layout.dart';
import 'package:kratos/magnetism/magnet_and_compass/mac_strings.dart';
import 'package:kratos/magnetism/magnet_and_compass/magnet_and_compass_constants.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/bar_magnet_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/compass_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/painters/field_needle_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/screens/magnet_and_compass_screen.dart';
import 'package:kratos/magnetism/magnet_and_compass/widgets/field_meter.dart';

Finder _paint(bool Function(CustomPainter? p) pred) => find.byWidgetPredicate(
      (w) => w is CustomPaint && pred(w.painter),
    );

Finder _resetCircle() => find.byWidgetPredicate((w) {
      if (w is! Container) return false;
      final d = w.decoration;
      if (d is! BoxDecoration) return false;
      return d.shape == BoxShape.circle && d.color == const Color(0xffe65100);
    });

T _painter<T extends CustomPainter>(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(_paint((p) => p is T).first);
  return paint.painter as T;
}

Size _canvasSize(WidgetTester tester) =>
    tester.getSize(_paint((p) => p is FieldNeedlePainter));

void _expectNoOverflow(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}

Future<void> _pumpScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 600);
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

/// Do not tap the Earth checkbox — earth.svg is missing.
List<Checkbox> _boxes(WidgetTester tester) => tester
    .widgetList<Checkbox>(find.byType(Checkbox))
    .toList();

void main() {
  group('MagnetAndCompassScreen init', () {
    testWidgets('loads AppBar, NineGrid, canvas, and B defaults',
        (tester) async {
      await _pumpScreen(tester);

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('磁铁与罗盘'), findsOneWidget);
      expect(find.byType(NineGridLayout), findsOneWidget);
      expect(find.text(MacStrings.barMagnet), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text(MacStrings.flipPolarity), findsOneWidget);
      expect(find.text(MacStrings.compass), findsOneWidget);
      expect(find.text(MacStrings.fieldMeter), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      final boxes = _boxes(tester);
      expect(boxes, hasLength(5));
      expect(boxes[0].value, isTrue); // Magnetic Field (B)
      expect(boxes[1].value, isFalse); // See Inside
      expect(boxes[2].value, isFalse); // Earth — leave untouched
      expect(boxes[3].value, isTrue); // Compass
      expect(boxes[4].value, isFalse); // Field Meter

      expect(_paint((p) => p is FieldNeedlePainter), findsOneWidget);
      expect(_paint((p) => p is BarMagnetPainter), findsOneWidget);
      expect(_paint((p) => p is CompassPainter), findsWidgets);

      final magnet = _painter<BarMagnetPainter>(tester);
      expect(magnet.flipped, isFalse);
      expect(magnet.seeInside, isFalse);

      await _teardown(tester);
    });
  });

  group('Screen interactions', () {
    testWidgets('flip, see-inside, field meter, strength step', (tester) async {
      await _pumpScreen(tester);

      await tester.tap(find.text(MacStrings.flipPolarity));
      await tester.pump();
      _expectNoOverflow(tester);
      expect(_painter<BarMagnetPainter>(tester).flipped, isTrue);

      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();
      _expectNoOverflow(tester);
      expect(_painter<BarMagnetPainter>(tester).seeInside, isTrue);

      await tester.tap(find.byType(Checkbox).at(4));
      await tester.pump();
      _expectNoOverflow(tester);
      expect(find.textContaining('B ='), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_right));
      await tester.pump();
      _expectNoOverflow(tester);
      expect(find.text('80%'), findsOneWidget);

      await _teardown(tester);
    });

    testWidgets('compass needleAngle changes over time', (tester) async {
      await _pumpScreen(tester);
      final before = _painter<CompassPainter>(tester).needleAngle;

      await tester.pump(const Duration(milliseconds: 200));
      _expectNoOverflow(tester);
      final after = _painter<CompassPainter>(tester).needleAngle;
      expect(after, isNot(equals(before)));

      await _teardown(tester);
    });
  });

  group('Reset and lifecycle', () {
    testWidgets('reset restores B defaults after mutations', (tester) async {
      await _pumpScreen(tester);

      await tester.tap(find.text(MacStrings.flipPolarity));
      await tester.pump();
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();
      await tester.tap(find.byType(Checkbox).at(4));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_right));
      await tester.pump();
      await tester.tap(find.byType(Checkbox).at(3));
      await tester.pump();
      _expectNoOverflow(tester);

      expect(find.text('80%'), findsOneWidget);
      expect(_paint((p) => p is CompassPainter), findsNothing);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      _expectNoOverflow(tester);

      expect(find.text('75%'), findsOneWidget);
      expect(_painter<BarMagnetPainter>(tester).flipped, isFalse);
      expect(_painter<BarMagnetPainter>(tester).seeInside, isFalse);
      expect(find.textContaining('B ='), findsNothing);
      expect(_paint((p) => p is CompassPainter), findsWidgets);

      final boxes = _boxes(tester);
      expect(boxes[0].value, isTrue);
      expect(boxes[1].value, isFalse);
      expect(boxes[2].value, isFalse);
      expect(boxes[3].value, isTrue);
      expect(boxes[4].value, isFalse);

      final magnetRect = tester.getRect(_paint((p) => p is BarMagnetPainter));
      final windowW =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final windowH =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(magnetRect.width, kMagnetWidth);
      expect(magnetRect.height, kMagnetHeight);
      expect(magnetRect.center.dx, closeTo(windowW * 0.42, 1.5));
      expect(magnetRect.center.dy, closeTo(windowH * 0.50, 1.5));

      final compassRect = tester.getRect(_paint((p) => p is CompassPainter).first);
      expect(compassRect.width, kCompassRadius * 2);
      expect(compassRect.height, kCompassRadius * 2);
      expect(compassRect.center.dx, closeTo(windowW * 0.60, 1.5));
      expect(compassRect.center.dy, closeTo(windowH * 0.66, 1.5));

      await _teardown(tester);
    });

    testWidgets('dispose AnimationController without error', (tester) async {
      await _pumpScreen(tester);
      await _teardown(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('Window-mapped geometry', () {
    testWidgets('Pixel Tablet: magnet and compass window centers match original fractions',
        (tester) async {
      tester.view.physicalSize = const Size(2560, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: MagnetAndCompassScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      _expectNoOverflow(tester);

      final magnet = tester.getRect(_paint((p) => p is BarMagnetPainter));
      final compass = tester.getRect(_paint((p) => p is CompassPainter).first);
      expect(magnet.width, kMagnetWidth);
      expect(magnet.height, kMagnetHeight);
      expect(compass.width, kCompassRadius * 2);
      expect(compass.height, kCompassRadius * 2);
      expect(magnet.center.dx, closeTo(1280 * 0.42, 1.5));
      expect(magnet.center.dy, closeTo(800 * 0.50, 1.5));
      expect(compass.center.dx, closeTo(1280 * 0.60, 1.5));
      expect(compass.center.dy, closeTo(800 * 0.66, 1.5));
      expect(
        compass.center.dx - magnet.center.dx,
        closeTo(230.4, 1.5),
      );
      expect(
        compass.center.dy - magnet.center.dy,
        closeTo(128.0, 1.5),
      );

      await tester.tap(find.byType(Checkbox).at(4));
      await tester.pump();
      _expectNoOverflow(tester);
      final meter = tester.getRect(find.byType(FieldMeter));
      expect(meter.width, 260);
      expect(meter.height, 192);
      expect(meter.center.dx, closeTo(1280 * 0.28, 1.5));
      expect(meter.center.dy, closeTo(800 * 0.30, 1.5));
      expect(magnet.center.dx - meter.center.dx, closeTo(179.2, 1.5));
      expect(magnet.center.dy - meter.center.dy, closeTo(160.0, 1.5));

      final reset = tester.getRect(_resetCircle());
      expect(reset.width, closeTo(52, 1.5));
      expect(reset.height, closeTo(52, 1.5));

      await _teardown(tester);
    });

    testWidgets('1024×768: field meter uses window fraction (unclamped)',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: MagnetAndCompassScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      _expectNoOverflow(tester);

      await tester.tap(find.byType(Checkbox).at(4));
      await tester.pump();
      _expectNoOverflow(tester);

      final magnet = tester.getRect(_paint((p) => p is BarMagnetPainter));
      final meter = tester.getRect(find.byType(FieldMeter));
      expect(meter.center.dx, closeTo(1024 * 0.28, 1.5));
      expect(meter.center.dy, closeTo(768 * 0.30, 1.5));
      expect(magnet.center.dx - meter.center.dx, closeTo(1024 * 0.14, 1.5));
      expect(magnet.center.dy - meter.center.dy, closeTo(768 * 0.20, 1.5));

      final reset = tester.getRect(_resetCircle());
      expect(reset.width, closeTo(52, 1.5));
      expect(reset.height, closeTo(52, 1.5));

      await _teardown(tester);
    });

    testWidgets('640×360: Reset stays in bottomRight and is fully visible',
        (tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: MagnetAndCompassScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      _expectNoOverflow(tester);

      // Field Meter checkbox sits below the 220px center (panel 298) — cannot
      // tap it on this viewport. Clamp of the meter init point is covered by
      // magnet_canvas_mapping_test.
      final reset = tester.getRect(_resetCircle());
      expect(reset.width, lessThanOrEqualTo(52.5));
      expect(reset.height, lessThanOrEqualTo(52.5));
      expect(reset.width, greaterThan(40));
      expect(reset.height, greaterThan(40));
      expect(reset.left, greaterThanOrEqualTo(-0.5));
      expect(reset.top, greaterThanOrEqualTo(-0.5));
      expect(reset.right, lessThanOrEqualTo(640.5));
      expect(reset.bottom, lessThanOrEqualTo(360.5));

      await _teardown(tester);
    });
  });

  group('Magnet position', () {
    testWidgets('drag updates position and clamps to canvas', (tester) async {
      await _pumpScreen(tester);

      Positioned posed() => tester.widget<Positioned>(
            find
                .ancestor(
                  of: _paint((p) => p is BarMagnetPainter),
                  matching: find.byType(Positioned),
                )
                .first,
          );

      final canvas = _canvasSize(tester);
      final magnet = _paint((p) => p is BarMagnetPainter);
      final startLeft = posed().left!;

      // Drag from the magnet body, not its center (center can sit under
      // the floating ControlPanel after a right clamp).
      Future<void> dragMagnet(Offset delta) async {
        final rect = tester.getRect(magnet);
        await tester.dragFrom(rect.centerLeft + const Offset(24, 0), delta);
        await tester.pump();
      }

      await dragMagnet(const Offset(40, 0));
      _expectNoOverflow(tester);
      expect(posed().left, greaterThan(startLeft));

      await dragMagnet(const Offset(10000, 0));
      _expectNoOverflow(tester);
      expect(posed().left, closeTo(canvas.width - kMagnetWidth, 0.5));

      await dragMagnet(const Offset(-10000, 0));
      _expectNoOverflow(tester);
      expect(posed().left, closeTo(0, 0.5));

      await _teardown(tester);
    });
  });
}
