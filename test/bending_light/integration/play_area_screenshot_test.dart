import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/components/play_area_painters.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/intro_model.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';
import 'package:kratos/bending_light/model/prism.dart';
import 'package:kratos/bending_light/model/prisms_model.dart';
import 'package:kratos/bending_light/model/substance.dart';
import 'package:kratos/bending_light/transform/bl_mvt.dart';

Future<void> _savePainter(CustomPainter painter, String filename) async {
  const size = Size(834, 504);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  painter.paint(canvas, size);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  expect(bytes, isNotNull);

  final dir = Directory('requirements/req-bending-light/visual-qa');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  expect(file.lengthSync(), greaterThan(500));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('capture PHASE_2_INTRO.png from model rays', () async {
    final model = IntroModel(
      bottomSubstance: Substance.water,
      horizontalPlayAreaOffset: true,
    )..setLaserOn(true);
    final mvt = BlMvt.intro();
    await _savePainter(
      _CompositePainter([
        IntroMediumPainter(
          mvt: mvt,
          topSubstance: model.topMedium.substance,
          bottomSubstance: model.bottomMedium.substance,
          showNormal: true,
        ),
        RaysPainter(mvt: mvt, rays: model.rays),
      ]),
      'PHASE_2_INTRO.png',
    );
  });

  test('capture PHASE_2_PRISMS.png from model rays', () async {
    final model = PrismsModel();
    final square =
        model.getPrismPrototypes().firstWhere((e) => e.$2 == 'square');
    model.addPrism(Prism(square.$1, square.$2));
    model.laser.pivot = const BlVec2(0, 0);
    model.laser.emissionPoint = const BlVec2(-2.5e-5, 0);
    model.setLaserOn(true);
    final mvt = BlMvt.prisms();
    await _savePainter(
      PrismScenePainter(
        mvt: mvt,
        prisms: List.of(model.prisms),
        rays: model.rays,
        intersections: model.intersections,
        prismMedium: model.prismMedium.substance,
        showNormals: false,
      ),
      'PHASE_2_PRISMS.png',
    );
  });

  test('capture PHASE_2_MORE_TOOLS.png from model rays', () async {
    final model = MoreToolsModel()..setLaserOn(true);
    final mvt = BlMvt.moreTools();
    await _savePainter(
      _CompositePainter([
        IntroMediumPainter(
          mvt: mvt,
          topSubstance: model.topMedium.substance,
          bottomSubstance: model.bottomMedium.substance,
          showNormal: true,
        ),
        RaysPainter(mvt: mvt, rays: model.rays),
      ]),
      'PHASE_2_MORE_TOOLS.png',
    );
  });
}

class _CompositePainter extends CustomPainter {
  _CompositePainter(this.painters);
  final List<CustomPainter> painters;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in painters) {
      p.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
