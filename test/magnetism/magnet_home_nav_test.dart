import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/magnetism/magnet_and_compass/painters/bar_magnet_painter.dart';
import 'package:kratos/magnetism/magnet_and_compass/screens/magnet_and_compass_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// Home → MagnetAndCompassScreen → Back. Compass ticker is always on;
/// do not pumpAndSettle while the sim is on the stack.
void main() {
  Future<void> setDesktop(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpHome(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> openMagnet(WidgetTester tester) async {
    final card = find.text('磁铁与罗盘');
    expect(card, findsWidgets);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MagnetAndCompassScreen), findsOneWidget);
  }

  Future<void> backToHome(WidgetTester tester) async {
    await tester.pageBack();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(MagnetAndCompassScreen), findsNothing);
  }

  Finder magnetPaint() => find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is BarMagnetPainter,
      );

  BarMagnetPainter magnetPainter(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(magnetPaint().first);
    return paint.painter as BarMagnetPainter;
  }

  testWidgets('Home 出现磁铁与罗盘卡片', (tester) async {
    await setDesktop(tester);
    await pumpHome(tester);

    expect(find.text('磁铁与罗盘'), findsOneWidget);
    expect(find.text('电磁学'), findsOneWidget);
    expect(find.text('条形磁铁 · 磁场 · 罗盘'), findsOneWidget);
  });

  testWidgets('点击进入：标题正确，可 Back 回 Home', (tester) async {
    await setDesktop(tester);
    await pumpHome(tester);
    await openMagnet(tester);

    expect(find.text('磁铁与罗盘'), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('磁铁与罗盘'),
      ),
      findsOneWidget,
    );
    expect(find.byType(MagnetAndCompassScreen), findsOneWidget);

    await backToHome(tester);
    expect(find.text('磁铁与罗盘'), findsOneWidget);
  });

  testWidgets('离开后旧 Screen 不再推进（controller dispose）', (tester) async {
    await setDesktop(tester);
    await pumpHome(tester);
    await openMagnet(tester);

    await backToHome(tester);

    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
    expect(find.byType(MagnetAndCompassScreen), findsNothing);
  });

  testWidgets('再进入得到新实例默认状态', (tester) async {
    await setDesktop(tester);
    await pumpHome(tester);
    await openMagnet(tester);

    await tester.tap(find.text('Flip Polarity'));
    await tester.pump();
    expect(magnetPainter(tester).flipped, isTrue);
    expect(find.text('75%'), findsOneWidget);

    await backToHome(tester);
    await openMagnet(tester);

    expect(find.byType(MagnetAndCompassScreen), findsOneWidget);
    expect(magnetPainter(tester).flipped, isFalse);
    expect(find.text('75%'), findsOneWidget);
    expect(find.textContaining('B ='), findsNothing);

    await backToHome(tester);
  });
}
