import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/vector_addition/model/screen_models.dart';
import 'package:kratos/vector_addition/vector_addition_colors.dart';
import 'package:kratos/vector_addition/vector_addition_constants.dart';
import 'package:kratos/vector_addition/widgets/va_screen_body.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final outDir = Directory(
    'requirements/req-vector-addition/visual-qa/flutter',
  );

  setUpAll(() {
    if (!outDir.existsSync()) outDir.createSync(recursive: true);
  });

  Future<void> capture(
    WidgetTester tester,
    String file,
    VaScreenModel model,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 700));
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: VectorAdditionColors.screenBackground,
          body: Center(
            child: SizedBox(
              width: VectorAdditionConstants.layoutWidth,
              height: VectorAdditionConstants.layoutHeight,
              child: RepaintBoundary(
                key: key,
                child: VaScreenBody(model: model, embedded: true),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image =
        await tester.runAsync(() => boundary.toImage(pixelRatio: 1.0));
    expect(image, isNotNull);
    final bytes = await tester
        .runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
    File('${outDir.path}/$file.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
    await tester.pumpWidget(const SizedBox.shrink());
  }

  testWidgets('screen1 explore1d', (tester) async {
    await capture(tester, 'screen1', Explore1DModel());
    await capture(tester, 'screen1_final', Explore1DModel());
  });

  testWidgets('screen2 explore2d', (tester) async {
    await capture(tester, 'screen2', Explore2DModel());
    await capture(tester, 'screen2_final', Explore2DModel());
  });

  testWidgets('screen3 lab', (tester) async {
    await capture(tester, 'screen3', LabModel());
    await capture(tester, 'screen3_final', LabModel());
  });

  testWidgets('screen4 equations', (tester) async {
    await capture(tester, 'screen4', EquationsModel());
    await capture(tester, 'screen4_final', EquationsModel());
  });
}
