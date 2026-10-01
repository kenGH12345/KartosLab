import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/bending_light/components/intensity_meter_widget.dart';
import 'package:kratos/bending_light/components/play_area_painters.dart';
import 'package:kratos/bending_light/components/wave_view.dart';
import 'package:kratos/bending_light/model/bl_vec2.dart';
import 'package:kratos/bending_light/model/enums.dart';
import 'package:kratos/bending_light/model/more_tools_model.dart';
import 'package:kratos/bending_light/model/wire_geometry.dart';
import 'package:kratos/bending_light/transform/bl_mvt.dart';

/// Canvas capture of real painters. Widget toImage hangs while the clock ticker runs.
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

class _NotePainter extends CustomPainter {
  _NotePainter(this.lines);

  final List<(Offset, String)> lines;

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      final tp = TextPainter(
        text: TextSpan(
          text: line.$2,
          style: const TextStyle(color: Colors.black, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 220);
      tp.paint(canvas, line.$1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ToolboxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const box = Rect.fromLTWH(4, 304, 128, 192);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, const Radius.circular(4)),
      Paint()..color = const Color(0xCCE8E8E8),
    );
    var y = box.top + 8.0;
    for (final label in ['Protractor', 'Intensity', 'Velocity', 'Wave']) {
      const chip = Size(96, 24);
      final rect = Rect.fromLTWH(box.left + 8, y, chip.width, chip.height);
      canvas.drawRect(rect, Paint()..color = const Color(0xFFE0E0E0));
      final tp = TextPainter(
        text: TextSpan(text: label, style: const TextStyle(fontSize: 11, color: Colors.black)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, rect.topLeft + const Offset(8, 5));
      y += 32;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

MoreToolsModel _waved() {
  final model = MoreToolsModel()..setLaserOn(true);
  model.setLaserView(LaserViewEnum.wave);
  model.waveSensor.enabled = true;
  final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
  final mid = BlVec2(
    (incident.tail.x + incident.tip.x) / 2,
    (incident.tail.y + incident.tip.y) / 2,
  );
  model.waveSensor.probe1.position = mid;
  model.waveSensor.probe2.position = mid.plusXY(0, -4e-6);
  model.updateModel();
  for (var i = 0; i < 48; i++) {
    model.stepOnce();
  }
  return model;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('capture PHASE_4_MORE_TOOLS.png', () async {
    final model = _waved();
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
      WaveParticlePainter(mvt: mvt, rays: model.rays),
      _ToolboxPainter(),
      _NotePainter(const [
        (Offset(640, 16), 'Material  Air'),
        (Offset(640, 180), 'Wavelength 650 nm'),
        (Offset(640, 210), 'Material  Glass'),
        (Offset(150, 470), 'Play  Step  Normal'),
      ]),
    ], 'PHASE_4_MORE_TOOLS.png');
  });

  test('capture PHASE_4_WAVE.png', () async {
    final model = _waved();
    final mvt = BlMvt.moreTools();
    await _save([
      IntroMediumPainter(
        mvt: mvt,
        topSubstance: model.topMedium.substance,
        bottomSubstance: model.bottomMedium.substance,
        showNormal: false,
      ),
      WaveFrontPainter(mvt: mvt, rays: model.rays),
      WaveParticlePainter(mvt: mvt, rays: model.rays),
      _InsetPainter(
        WaveChartPainter(
          readTime: () => model.time,
          probe1: model.waveSensor.probe1.series,
          probe2: model.waveSensor.probe2.series,
        ),
        const Rect.fromLTWH(520, 40, 280, 140),
      ),
    ], 'PHASE_4_WAVE.png');
  });

  test('capture PHASE_4_SENSORS.png', () async {
    final model = _waved();
    final mvt = BlMvt.moreTools();
    final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
    model.intensityMeter.enabled = true;
    model.intensityMeter.sensorPosition = BlVec2(
      (incident.tail.x + incident.tip.x) / 2,
      (incident.tail.y + incident.tip.y) / 2,
    );
    model.intensityMeter.bodyPosition = model.intensityMeter.sensorPosition.plusXY(8e-6, 6e-6);
    model.velocitySensor.enabled = true;
    model.velocitySensor.position = incident.tail.plusXY(2e-6, 0);
    model.updateModel();
    final body = mvt.worldToScreen(model.intensityMeter.bodyPosition);
    final probe = mvt.worldToScreen(model.intensityMeter.sensorPosition);
    final chart = mvt.worldToScreen(model.waveSensor.bodyPosition);
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
          start: BlVec2(body.dx + 36, body.dy),
          startNormal: CubicWire.bodyNormal,
          end: BlVec2(probe.dx, probe.dy),
          endNormal: CubicWire.sensorNormal,
        ),
      ),
      _InsetPainter(
        WaveChartPainter(
          readTime: () => model.time,
          probe1: model.waveSensor.probe1.series,
          probe2: model.waveSensor.probe2.series,
        ),
        Rect.fromLTWH(chart.dx - 40, chart.dy - 30, 160, 80),
      ),
      _NotePainter([
        (body + const Offset(-20, -24), model.intensityMeter.reading.displayPercent.toStringAsFixed(2)),
        (
          mvt.worldToScreen(model.velocitySensor.position) + const Offset(8, -12),
          model.velocitySensor.value.magnitude.toStringAsExponential(2),
        ),
      ]),
    ], 'PHASE_4_SENSORS.png');
  });

  test('capture PHASE_4_TOOLBOX.png', () async {
    final model = MoreToolsModel()..setLaserOn(true);
    final mvt = BlMvt.moreTools();
    model.intensityMeter.enabled = true;
    final incident = model.rays.firstWhere((r) => r.rayType == 'incident');
    model.intensityMeter.bodyPosition = BlVec2(
      (incident.tail.x + incident.tip.x) / 2 + 6e-6,
      (incident.tail.y + incident.tip.y) / 2,
    );
    model.intensityMeter.sensorPosition = BlVec2(
      (incident.tail.x + incident.tip.x) / 2,
      (incident.tail.y + incident.tip.y) / 2,
    );
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
      _ToolboxPainter(),
      _NotePainter(const [
        (Offset(160, 320), 'drag-out placed Intensity'),
      ]),
    ], 'PHASE_4_TOOLBOX.png');
  });
}
