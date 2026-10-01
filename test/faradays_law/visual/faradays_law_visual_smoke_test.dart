import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/faradays_law/faradays_law_assets.dart';
import 'package:kratos/faradays_law/faradays_law_constants.dart';
import 'package:kratos/faradays_law/model/faradays_law_model.dart';
import 'package:kratos/faradays_law/model/magnet_orientation.dart';
import 'package:kratos/faradays_law/view/faradays_law_play_area.dart';
import 'package:kratos/faradays_law/view/faradays_law_screen.dart';
import 'package:kratos/faradays_law/view/painters/magnet_painter.dart';

Widget _app(FaradaysLawModel model) {
  return MaterialApp(
    home: FaradaysLawScreen(model: model, autoStartClock: false),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('viewport final gate', () {
    testWidgets('logical play area is source 834×504', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      expect(FaradaysLawConstants.layoutSize, const Size(834, 504));
      expect(FaradaysLawConstants.layoutBounds.width, 834);
      expect(FaradaysLawConstants.layoutBounds.height, 504);
      expect(
        FaradaysLawConstants.backgroundColorValue,
        0xFF97D0FF,
      );

      // Scaffold AppBar is KartosLab Home chrome (Phase 6); play area stays 834×504.
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.appBar, isNotNull);
      expect(scaffold.backgroundColor, const Color(0xFF97D0FF));
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(FaradaysLawScreen.title),
        ),
        findsOneWidget,
      );
    });

    testWidgets('play area expands to fill body (no left-cluster shrink-wrap)',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      final play = tester.getRect(find.byType(FaradaysLawPlayArea));
      expect(play.width, greaterThan(1000));
      expect(play.height, greaterThan(500));

      // Default magnet at layout x≈647; after contain-scale it must sit well
      // into the right half — not stuck in a left shrink-wrapped cluster.
      final magnet = tester.getRect(find.byKey(const Key('faradays_law_magnet')));
      expect(magnet.center.dx, greaterThan(700));
    });
  });

  group('visual smoke — core structure', () {
    testWidgets('initial: magnet, coils, bulb, controls; voltmeter/field off',
        (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      expect(find.byKey(const Key('faradays_law_magnet')), findsOneWidget);
      expect(find.byKey(const Key('faradays_law_magnet_gesture')), findsOneWidget);
      expect(find.byKey(const Key('faradays_law_voltmeter_checkbox')), findsOneWidget);
      expect(find.byKey(const Key('faradays_law_field_lines_checkbox')), findsOneWidget);
      expect(find.byKey(const Key('faradays_law_coil_single')), findsOneWidget);
      expect(find.byKey(const Key('faradays_law_coil_double')), findsOneWidget);
      expect(find.byKey(const Key('faradays_law_flip_magnet')), findsOneWidget);
      expect(find.byKey(const Key('faradays_law_reset_all')), findsOneWidget);

      expect(model.voltmeterVisible, isFalse);
      expect(model.magnet.fieldLinesVisible, isFalse);
      expect(model.topCoilVisible, isFalse);
      expect(model.magnet.orientation, MagnetOrientation.ns);
      expect(model.magnet.position, FaradaysLawConstants.defaultMagnetPosition);
      expect(model.bulb.brightness, 0);
      expect(model.magnetArrowsVisible, isTrue);
    });

    testWidgets('no Material Icons in Faraday screen tree', (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('original coil/bulb assets resolve via Image.asset',
        (tester) async {
      final model = FaradaysLawModel();
      model.setTopCoilVisible(true);
      await tester.pumpWidget(_app(model));
      await tester.pump();

      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      final paths = images
          .map((w) => w.image)
          .whereType<AssetImage>()
          .map((a) => a.assetName)
          .toSet();

      expect(paths.contains(FaradaysLawAssets.fourLoopFront), isTrue);
      expect(paths.contains(FaradaysLawAssets.fourLoopBack), isTrue);
      expect(paths.contains(FaradaysLawAssets.twoLoopFront), isTrue);
      expect(paths.contains(FaradaysLawAssets.twoLoopBack), isTrue);
      expect(paths.contains(FaradaysLawAssets.lightBulbBase), isTrue);
    });

    testWidgets('magnet polarity uses MagnetPainter not scaleX mirror',
        (tester) async {
      final model = FaradaysLawModel();
      await tester.pumpWidget(_app(model));
      await tester.pump();

      final paint = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final magnetPaints = paint
          .where((c) => c.painter is MagnetPainter)
          .map((c) => c.painter! as MagnetPainter)
          .toList();
      expect(magnetPaints, isNotEmpty);
      expect(magnetPaints.any((p) => p.orientation == MagnetOrientation.ns),
          isTrue);

      model.flipPolarity();
      await tester.pump();
      final after = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .where((c) => c.painter is MagnetPainter)
          .map((c) => c.painter! as MagnetPainter)
          .toList();
      expect(after.any((p) => p.orientation == MagnetOrientation.sn), isTrue);
    });
  });
}
