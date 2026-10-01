import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';
import 'package:kratos/screens/home_screen.dart';

/// Home → Faraday's Law lifecycle (peer: magnet_home_nav_test).
/// Clock may be running — avoid pumpAndSettle while sim is on the stack.
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

  Future<void> openFaraday(WidgetTester tester) async {
    final card = find.text(FaradaysLawScreen.title);
    expect(card, findsWidgets);
    await tester.ensureVisible(card.first);
    await tester.pump();
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(FaradaysLawScreen), findsOneWidget);
  }

  Future<void> backToHome(WidgetTester tester) async {
    final back = find.byType(BackButton);
    if (back.evaluate().isNotEmpty) {
      await tester.tap(back);
    } else {
      await tester.pageBack();
    }
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(FaradaysLawScreen), findsNothing);
  }

  FaradaysLawModel screenModel(WidgetTester tester) {
    final state = tester.state<FaradaysLawScreenState>(
      find.byType(FaradaysLawScreen),
    );
    return state.model;
  }

  group('home entry', () {
    testWidgets('Home lists Faraday card under 电磁学', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      expect(find.text('电磁学'), findsOneWidget);
      expect(find.text(FaradaysLawScreen.title), findsOneWidget);
      expect(find.text(FaradaysLawScreen.subtitle), findsOneWidget);
    });

    testWidgets('tap card opens FaradaysLawScreen with AppBar', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openFaraday(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(FaradaysLawScreen.title),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('faradays_law_magnet')), findsOneWidget);
      expect(find.byKey(const Key('faradays_law_reset_all')), findsOneWidget);

      final model = screenModel(tester);
      expect(model.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
      expect(model.magnet.orientation, MagnetOrientation.ns);
      expect(model.topCoilVisible, isFalse);
      expect(model.voltmeterVisible, isFalse);
      expect(model.magnet.fieldLinesVisible, isFalse);
    });
  });

  group('navigation / back', () {
    testWidgets('Back returns Home and disposes screen', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openFaraday(tester);
      await backToHome(tester);
      expect(find.text(FaradaysLawScreen.title), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });
  });

  group('lifecycle / re-entry', () {
    testWidgets('mutate then Back then re-enter → fresh initial', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openFaraday(tester);

      final a = screenModel(tester);
      a.setTopCoilVisible(true);
      a.setFieldLinesVisible(true);
      a.setVoltmeterVisible(true);
      a.flipPolarity();
      a.setMagnetPositionForTest(const Offset(480, 250));
      a.voltmeter.voltage = 0.4;
      a.notifyListeners();
      await tester.pump();
      expect(a.magnet.orientation, MagnetOrientation.sn);
      expect(a.topCoilVisible, isTrue);

      await backToHome(tester);
      await openFaraday(tester);

      final b = screenModel(tester);
      expect(identical(a, b), isFalse);
      expect(b.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
      expect(b.magnet.orientation, MagnetOrientation.ns);
      expect(b.topCoilVisible, isFalse);
      expect(b.voltmeterVisible, isFalse);
      expect(b.magnet.fieldLinesVisible, isFalse);
      expect(b.voltage, 0);
      expect(b.magnetArrowsVisible, isTrue);

      await backToHome(tester);
    });

    testWidgets('re-entry ×3 keeps independent fresh models', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      final models = <FaradaysLawModel>[];
      for (var i = 0; i < 3; i++) {
        await openFaraday(tester);
        final m = screenModel(tester);
        models.add(m);
        expect(m.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
        expect(m.voltage, 0);
        m.setMagnetPositionForTest(Offset(400 + i * 10.0, 250));
        m.flipPolarity();
        await tester.pump();
        await backToHome(tester);
      }

      expect(identical(models[0], models[1]), isFalse);
      expect(identical(models[1], models[2]), isFalse);
    });

    testWidgets('Back while clock ticking does not throw', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openFaraday(tester);

      final model = screenModel(tester);
      model.moveMagnetToPosition(const Offset(500, 250));
      await tester.pump(const Duration(milliseconds: 80));
      model.step(1 / 60);
      await tester.pump(const Duration(milliseconds: 80));

      await backToHome(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.byType(FaradaysLawScreen), findsNothing);
    });

    testWidgets('controls changed then Reset then Back', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);
      await openFaraday(tester);

      await tester.tap(find.byKey(const Key('faradays_law_coil_double')));
      await tester.tap(find.byKey(const Key('faradays_law_flip_magnet')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('faradays_law_reset_all')));
      await tester.pump();

      final model = screenModel(tester);
      expect(model.topCoilVisible, isFalse);
      expect(model.magnet.orientation, MagnetOrientation.ns);

      await backToHome(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cross-sim: Faraday → Magnet → Faraday no leak', (tester) async {
      await setDesktop(tester);
      await pumpHome(tester);

      await openFaraday(tester);
      screenModel(tester).flipPolarity();
      await tester.pump();
      await backToHome(tester);

      final magnetCard = find.text('磁铁与罗盘');
      await tester.ensureVisible(magnetCard.first);
      await tester.tap(magnetCard.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.pageBack();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(HomeScreen), findsOneWidget);

      await openFaraday(tester);
      final m = screenModel(tester);
      expect(m.magnet.orientation, MagnetOrientation.ns);
      expect(m.voltage, 0);
      await backToHome(tester);
    });
  });

  group('isolation without Home', () {
    test('instances A/B/C are independent', () {
      final a = FaradaysLawModel();
      a.flipPolarity();
      a.setTopCoilVisible(true);
      a.setMagnetPositionForTest(const Offset(400, 200));

      final b = FaradaysLawModel();
      expect(b.magnet.orientation, MagnetOrientation.ns);
      expect(b.topCoilVisible, isFalse);
      expect(b.magnet.position, FaradaysLawConstants.defaultMagnetPosition);

      b.voltmeter.voltage = 0.9;
      final c = FaradaysLawModel();
      expect(c.voltage, 0);
      expect(identical(a, b), isFalse);
      expect(identical(b, c), isFalse);
    });
  });
}
