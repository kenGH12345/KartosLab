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

/// Canvas capture. Widget toImage hangs while the model clock ticker is running.
Future<void> _save(List<CustomPainter> painters, String filename) async {
  const size = Size(834, 504);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFFFFF));
  for (final painter in painters) {
    painter.paint(canvas, size);
  }
  final picture = recorder.endRecording();
  final image = await picture.toImage(834, 504);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final dir = Directory('requirements/req-bending-light/visual-qa');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  expect(file.lengthSync(), greaterThan(1000));
}

void _label(Canvas canvas, String text, Offset at) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: const TextStyle(color: Colors.black, fontSize: 11),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: 180);
  tp.paint(canvas, at);
}

void _box(Canvas canvas, Rect rect, String title) {
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, const Radius.circular(4)),
    Paint()..color = const Color(0xCCE8E8E8),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(rect, const Radius.circular(4)),
    Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black54,
  );
  _label(canvas, title, rect.topLeft + const Offset(6, 6));
}

class _ChromePainter extends CustomPainter {
  _ChromePainter(this.boxes, this.resetCenter);
  final List<(Rect, String)> boxes;
  final Offset resetCenter;

  @override
  void paint(Canvas canvas, Size size) {
    for (final box in boxes) {
      _box(canvas, box.$1, box.$2);
    }
    canvas.drawCircle(resetCenter, 19, Paint()..color = const Color(0xFFF79722));
    _label(canvas, 'Reset', resetCenter + const Offset(-14, -6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('capture PHASE_3_INTRO_CONTROLS.png', () async {
    final model = IntroModel(
      bottomSubstance: Substance.water,
      horizontalPlayAreaOffset: true,
    )..setLaserOn(true);
    final mvt = BlMvt.intro();
    await _save([
      IntroMediumPainter(
        mvt: mvt,
        topSubstance: model.topMedium.substance,
        bottomSubstance: model.bottomMedium.substance,
        showNormal: true,
      ),
      RaysPainter(mvt: mvt, rays: model.rays),
      _ChromePainter(
        [
          (const Rect.fromLTWH(638, 8, 190, 160), 'Material  Air'),
          (const Rect.fromLTWH(638, 188, 190, 160), 'Material  Water'),
          (const Rect.fromLTWH(4, 336, 120, 160), 'Protractor\nIntensity'),
          (const Rect.fromLTWH(620, 400, 186, 48), 'Ray  Normal'),
        ],
        const Offset(800, 470),
      ),
    ], 'PHASE_3_INTRO_CONTROLS.png');
  });

  test('capture PHASE_3_PRISMS_CONTROLS.png', () async {
    final model = PrismsModel()..setLaserOn(true);
    final square = model.getPrismPrototypes().firstWhere((e) => e.$2 == 'square');
    model.addPrism(Prism(square.$1, square.$2).copy());
    model.laser.pivot = BlVec2.zero;
    model.laser.emissionPoint = const BlVec2(-2.5e-5, 0);
    model.laser.setAngle(3.141592653589793);
    model.updateModel();
    await _save([
      PrismScenePainter(
        mvt: BlMvt.prisms(),
        prisms: List.of(model.prisms),
        rays: model.rays,
        intersections: model.intersections,
        prismMedium: model.prismMedium.substance,
        showNormals: false,
      ),
      _ChromePainter(
        [
          (const Rect.fromLTWH(638, 8, 190, 120), 'Environment'),
          (const Rect.fromLTWH(638, 150, 190, 110), '1x  5x  White'),
          (const Rect.fromLTWH(4, 284, 210, 212), 'Objects toolbox'),
          (const Rect.fromLTWH(650, 400, 160, 90), 'Reflections\nNormal\nProtractor'),
        ],
        const Offset(800, 470),
      ),
    ], 'PHASE_3_PRISMS_CONTROLS.png');
  });

  test('capture PHASE_3_MORE_TOOLS_CONTROLS.png', () async {
    final model = MoreToolsModel()..setLaserOn(true);
    final mvt = BlMvt.moreTools();
    await _save([
      IntroMediumPainter(
        mvt: mvt,
        topSubstance: model.topMedium.substance,
        bottomSubstance: model.bottomMedium.substance,
        showNormal: true,
      ),
      RaysPainter(mvt: mvt, rays: model.rays),
      _ChromePainter(
        [
          (const Rect.fromLTWH(638, 4, 190, 140), 'Material  Air'),
          (const Rect.fromLTWH(638, 168, 190, 180), '650 nm\nMaterial  Glass'),
          (const Rect.fromLTWH(4, 304, 128, 192), 'Protractor\nIntensity\nVelocity\nWave'),
          (const Rect.fromLTWH(620, 400, 186, 70), 'Ray  Normal  Angles'),
        ],
        const Offset(800, 470),
      ),
    ], 'PHASE_3_MORE_TOOLS_CONTROLS.png');
  });
}
