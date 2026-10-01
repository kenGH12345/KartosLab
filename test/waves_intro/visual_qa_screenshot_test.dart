import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/waves_intro/model/scene_kind.dart';
import 'package:kratos/waves_intro/model/waves_intro_model.dart';
import 'package:kratos/waves_intro/painters/lattice_painter.dart';
import 'package:kratos/waves_intro/painters/light_screen_painter.dart';
import 'package:kratos/waves_intro/painters/sound_particles_painter.dart';
import 'package:kratos/waves_intro/view/wave_render_visibility.dart';
import 'package:kratos/waves_intro/waves_intro_constants.dart';

/// Visual QA after view reconciliation — PictureRecorder + production painters.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final outDir = Directory(
    'requirements/req-waves-intro/visual-qa/screenshots',
  );

  setUpAll(() {
    if (!outDir.existsSync()) outDir.createSync(recursive: true);
  });

  Future<void> savePng(String name, ui.Image image) async {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    expect(bytes, isNotNull);
    final file = File('${outDir.path}/$name.png');
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    expect(file.lengthSync(), greaterThan(800));
  }

  Future<ui.Image> render(WavesIntroModel model) async {
    final vis = WaveRenderVisibility(model);
    const layoutW = WavesIntroConstants.layoutWidth;
    const layoutH = WavesIntroConstants.layoutHeight;
    const wave = WavesIntroConstants.waveAreaViewSize;
    const pad = WavesIntroConstants.layoutMargin;
    const controlsW = WavesIntroConstants.controlColumnWidth;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, layoutW, layoutH),
      Paint()..color = const Color(0xFFE8E8E8),
    );

    final waveOrigin = const Offset(48, pad);
    Color bg;
    if (vis.kind == SceneKind.light) {
      bg = Colors.black;
    } else if (vis.kind == SceneKind.sound) {
      bg = const Color(0xFF4A4A4A);
    } else {
      bg = const Color(0xFFB8DFF5);
    }
    canvas.drawRect(
      Rect.fromLTWH(waveOrigin.dx, waveOrigin.dy, wave, wave),
      Paint()..color = bg,
    );

    canvas.save();
    canvas.translate(waveOrigin.dx, waveOrigin.dy);
    canvas.clipRect(const Rect.fromLTWH(0, 0, wave, wave));
    final scene = model.scene;
    if (vis.showWaves) {
      LatticePainter(
        lattice: scene.lattice,
        kind: scene.config.kind,
        wavelengthNm:
            scene.config.kind == SceneKind.light ? scene.wavelength : null,
      ).paint(canvas, const Size(wave, wave));
    }
    if (vis.showParticles) {
      SoundParticlesPainter(
        particles: scene.soundParticles,
        waveAreaWidth: scene.config.waveAreaWidth,
      ).paint(canvas, const Size(wave, wave));
    }
    canvas.restore();

    if (vis.showLightScreen) {
      canvas.save();
      canvas.translate(waveOrigin.dx + wave + 6, waveOrigin.dy);
      LightScreenPainter(
        lattice: scene.lattice,
        intensitySample: scene.intensitySample!,
        baseColor: lightBaseColorFromWavelengthNm(scene.wavelength),
      ).paint(
        canvas,
        Size(LightScreenPainter.canvasWidth.toDouble(), wave),
      );
      canvas.restore();
    }

    // Right control column marker
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(layoutW - controlsW - pad, pad, controlsW, layoutH - 80),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFF2F2F2),
    );

    final labels = [
      vis.kind.name.toUpperCase(),
      'waves=${vis.showWaves} particles=${vis.showParticles}',
      'graph=${vis.showGraph} screen=${vis.showLightScreen}',
      'soundView=${scene.soundViewType.name}',
    ].join('\n');
    final tp = TextPainter(
      text: TextSpan(
        text: labels,
        style: const TextStyle(color: Colors.black87, fontSize: 11, height: 1.3),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: controlsW - 12);
    tp.paint(canvas, Offset(layoutW - controlsW - pad + 6, pad + 8));

    // Bottom bar
    canvas.drawRect(
      Rect.fromLTWH(0, layoutH - 48, layoutW, 48),
      Paint()..color = const Color(0xFFD8D8D8),
    );

    final picture = recorder.endRecording();
    return picture.toImage(layoutW.round(), layoutH.round());
  }

  Future<void> capture({
    required SceneKind kind,
    required String name,
    required void Function(WavesIntroModel) setup,
  }) async {
    final model = WavesIntroModel(kind: kind, autoTick: false)
      ..audio.platformEnabled = false;
    model.pause();
    setup(model);
    await savePng('${kind.name}_$name', await render(model));
    model.dispose();
  }

  test('Water default + interaction', () async {
    await capture(kind: SceneKind.water, name: 'default', setup: (_) {});
    await capture(
      kind: SceneKind.water,
      name: 'interaction',
      setup: (m) {
        m.setButtonPressed(true);
        m.setShowGraph(true);
        for (var i = 0; i < 50; i++) {
          m.manualStep();
        }
        m.takeOutWaveMeter();
      },
    );
  });

  test('Sound waves / particles / both', () async {
    await capture(kind: SceneKind.sound, name: 'default', setup: (_) {});
    await capture(
      kind: SceneKind.sound,
      name: 'interaction',
      setup: (m) {
        m.setButtonPressed(true);
        m.setSoundViewType(SoundViewType.both);
        for (var i = 0; i < 50; i++) {
          m.manualStep();
        }
      },
    );
  });

  test('Light with screen', () async {
    await capture(kind: SceneKind.light, name: 'default', setup: (_) {});
    await capture(
      kind: SceneKind.light,
      name: 'interaction',
      setup: (m) {
        m.setButtonPressed(true);
        m.setShowScreen(true);
        m.setShowGraph(true);
        for (var i = 0; i < 50; i++) {
          m.manualStep();
        }
      },
    );
  });
}
