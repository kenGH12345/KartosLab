import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/components/play_area_painters.dart';
import 'package:kratos/bending_light/components/wave_view.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';
import 'package:kratos/bending_light/model/prism.dart';
import 'package:kratos/bending_light/model/prisms_model.dart';
import 'package:kratos/bending_light/model/wire_geometry.dart';
import 'package:kratos/bending_light/components/intensity_meter_widget.dart';
import 'package:kratos/bending_light/transform/bl_mvt.dart';

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
  expect(file.lengthSync(), greaterThan(2000));
}

class _InsetPainter extends CustomPainter {
  _InsetPainter(this.child, this.rect);
  final CustomPainter child;
  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(rect.left, rect.top);
    canvas.clipRect(Offset.zero & rect.size);
    child.paint(canvas, rect.size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

MoreToolsModel _wave() {
  final model = MoreToolsModel()..setLaserOn(true);
  model.setLaserView(LaserViewEnum.wave);
  model.waveSensor.enabled = true;
  final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
  model.waveSensor.probe1.position = BlVec2(
    (incident.tail.x + incident.tip.x) / 2,
    (incident.tail.y + incident.tip.y) / 2,
  );
  model.updateModel();
  for (var i = 0; i < 40; i++) {
    model.stepOnce();
  }
  return model;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('capture PHASE_5_INTRO.png', () async {
    final model = MoreToolsModel()..setLaserOn(true);
    final mvt = BlMvt.intro();
    await _save([
      IntroMediumPainter(
        mvt: mvt,
        topSubstance: model.topMedium.substance,
        bottomSubstance: model.bottomMedium.substance,
        showNormal: true,
      ),
      RaysPainter(mvt: mvt, rays: model.rays),
    ], 'PHASE_5_INTRO.png');
  });

  test('capture PHASE_5_MORE_TOOLS.png', () async {
    final model = _wave();
    final mvt = BlMvt.moreTools();
    await _save([
      IntroMediumPainter(
        mvt: mvt,
        topSubstance: model.topMedium.substance,
        bottomSubstance: model.bottomMedium.substance,
        showNormal: true,
      ),
      RaysPainter(mvt: mvt, rays: model.rays),
      WaveFrontPainter(mvt: mvt, rays: model.rays),
    ], 'PHASE_5_MORE_TOOLS.png');
  });

  test('capture PHASE_5_PRISMS.png', () async {
    final model = PrismsModel()..setLaserOn(true);
    final square = model.getPrismPrototypes().firstWhere((e) => e.$2 == 'square');
    model.addPrism(Prism(square.$1, square.$2).copy());
    await _save([
      PrismScenePainter(
        mvt: BlMvt.prisms(),
        prisms: List.of(model.prisms),
        rays: model.rays,
        intersections: model.intersections,
        prismMedium: model.prismMedium.substance,
        showNormals: true,
      ),
    ], 'PHASE_5_PRISMS.png');
  });

  test('capture PHASE_5_WHITE_LIGHT.png', () async {
    final model = PrismsModel()..setLaserOn(true);
    final tri = model.getPrismPrototypes().firstWhere((e) => e.$2 == 'triangle');
    model.addPrism(Prism(tri.$1, tri.$2).copy());
    model.setLightType(LightType.white);
    final mvt = BlMvt.prisms();
    await _save([
      WhiteLightPainter(mvt: mvt, rays: model.rays),
      PrismScenePainter(
        mvt: mvt,
        prisms: List.of(model.prisms),
        rays: model.rays,
        intersections: model.intersections,
        prismMedium: model.prismMedium.substance,
        showNormals: false,
        includeRays: false,
        fillBackground: false,
      ),
    ], 'PHASE_5_WHITE_LIGHT.png');
  });

  test('capture PHASE_5_GRAPH.png', () async {
    final model = _wave();
    await _save([
      _InsetPainter(
        WaveChartPainter(
          readTime: () => model.time,
          probe1: model.waveSensor.probe1.series,
          probe2: model.waveSensor.probe2.series,
        ),
        const Rect.fromLTWH(80, 80, 400, 220),
      ),
    ], 'PHASE_5_GRAPH.png');
  });

  test('capture PHASE_5_SENSORS.png', () async {
    final model = MoreToolsModel()..setLaserOn(true);
    final mvt = BlMvt.moreTools();
    final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
    final mid = BlVec2(
      (incident.tail.x + incident.tip.x) / 2,
      (incident.tail.y + incident.tip.y) / 2,
    );
    model.intensityMeter.enabled = true;
    model.intensityMeter.sensorPosition = mid;
    model.intensityMeter.bodyPosition = mid.plusXY(1e-5, 4e-6);
    model.velocitySensor.enabled = true;
    model.velocitySensor.position = incident.tail.plusXY(3e-6, 0);
    model.updateModel();
    final body = mvt.worldToScreen(model.intensityMeter.bodyPosition);
    final probe = mvt.worldToScreen(model.intensityMeter.sensorPosition);
    await _save([
      IntroMediumPainter(
        mvt: mvt,
        topSubstance: model.topMedium.substance,
        bottomSubstance: model.bottomMedium.substance,
        showNormal: true,
      ),
      RaysPainter(mvt: mvt, rays: model.rays),
      CubicWirePainter(
        wire: CubicWire.between(
          start: BlVec2(body.dx, body.dy),
          startNormal: CubicWire.bodyNormal,
          end: BlVec2(probe.dx, probe.dy),
          endNormal: CubicWire.sensorNormal,
        ),
      ),
    ], 'PHASE_5_SENSORS.png');
  });
}
