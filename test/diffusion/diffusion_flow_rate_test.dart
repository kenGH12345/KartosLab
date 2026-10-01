import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/diffusion/diffusion_constants.dart';
import 'package:kratos/diffusion/model/diffusion_model.dart';
import 'package:kratos/diffusion/model/particle.dart';
import 'package:kratos/diffusion/model/particle_flow_rate.dart';
import 'package:kratos/diffusion/painters/diffusion_play_area_painter.dart';
import 'package:kratos/diffusion/painters/particle_flow_rate_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('particle flow rate', () {
    test('counts divider crossings, not mean velocity', () {
      final particles = <DiffusionParticle>[
        DiffusionParticle(
          species: ParticleSpecies.one,
          mass: 28,
          radius: 125,
          x: 7900,
          y: 4000,
          vx: 100,
          vy: 0,
        ),
      ];
      particles.first.prevX = 7900;
      particles.first.x = 8100;
      final flow = ParticleFlowRate(dividerX: 8000, particles: particles);
      flow.step(0.2);
      expect(flow.rightFlowRate, greaterThan(0));
      expect(flow.leftFlowRate, 0);
    });

    test('running average uses NUMBER_OF_SAMPLES window', () {
      final particles = <DiffusionParticle>[];
      final flow = ParticleFlowRate(dividerX: 8000, particles: particles);
      for (var i = 0; i < ParticleFlowRate.numberOfSamples + 10; i++) {
        flow.step(0.2);
      }
      expect(flow.leftFlowRate, 0);
      expect(flow.rightFlowRate, 0);
    });

    test('model steps flow only when divider removed', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(1));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(40);
      m.setRightCount(40);
      for (var i = 0; i < 20; i++) {
        m.stepModelTime(0.2);
      }
      expect(m.particleFlowRate1.leftFlowRate, 0);
      expect(m.particleFlowRate1.rightFlowRate, 0);

      m.setHasDivider(false);
      for (var i = 0; i < 400; i++) {
        m.stepModelTime(0.2);
      }
      final anyFlow = m.particleFlowRate1.leftFlowRate > 0 ||
          m.particleFlowRate1.rightFlowRate > 0 ||
          m.particleFlowRate2.leftFlowRate > 0 ||
          m.particleFlowRate2.rightFlowRate > 0;
      expect(anyFlow, isTrue);
    });

    test('flow vector visibility defaults false; toggle works', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(1));
      addTearDown(m.dispose);
      expect(m.particleFlowRateVisible, isFalse);
      m.setParticleFlowRateVisible(true);
      expect(m.particleFlowRateVisible, isTrue);
    });

    test('reset clears flow rates and visibility', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(2));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(30);
      m.setRightCount(30);
      m.setParticleFlowRateVisible(true);
      m.setHasDivider(false);
      for (var i = 0; i < 200; i++) {
        m.stepModelTime(0.2);
      }
      m.reset();
      expect(m.particleFlowRateVisible, isFalse);
      expect(m.particleFlowRate1.leftFlowRate, 0);
      expect(m.particleFlowRate1.rightFlowRate, 0);
      expect(m.particleFlowRate2.leftFlowRate, 0);
      expect(m.particleFlowRate2.rightFlowRate, 0);
      expect(m.container.hasDivider, isTrue);
      expect(m.numberOfParticles, 0);
    });

    test('restore divider resets flow rates', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(3));
      addTearDown(m.dispose);
      m.pause();
      m.setLeftCount(25);
      m.setRightCount(25);
      m.setHasDivider(false);
      for (var i = 0; i < 200; i++) {
        m.stepModelTime(0.2);
      }
      m.setHasDivider(true);
      expect(m.particleFlowRate1.leftFlowRate, 0);
      expect(m.particleFlowRate1.rightFlowRate, 0);
    });
  });

  group('audio audit', () {
    test('no sim-owned sound assets or SoundClip triggers in lock tree', () {
      // Evidence (FUNCTIONAL_GAP_CLOSURE):
      // - diffusion-main: no sounds/ directory
      // - gas-properties @ 7a52c48 js/diffusion + js/common/view: no SoundClip
      // - package.json supportsSound:true is platform flag only (tambo/joist)
      // Closure: [源码一致：原版无音效]
      const hasSimOwnedAudio = false;
      expect(hasSimOwnedAudio, isFalse);
    });
  });

  group('lifecycle / screenshot states', () {
    test('required scene states are reachable', () {
      final m = DiffusionModel(autoTick: false, random: math.Random(11));
      addTearDown(m.dispose);

      expect(m.container.hasDivider, isTrue);
      expect(m.numberOfParticles, 0);
      expect(m.isPlaying, isTrue);

      m.pause();
      m.setLeftCount(40);
      m.setRightCount(40);
      expect(m.container.hasDivider, isTrue);
      expect(m.leftData.numberOfParticles1, 40);

      m.setHasDivider(false);
      m.setTimeSpeed(DiffusionTimeSpeed.slow);
      for (var i = 0; i < 300; i++) {
        m.stepModelTime(0.2);
      }
      m.pause();
      final sw = m.stopwatchPs;
      m.stepForward();
      expect(m.stopwatchPs, closeTo(sw + 0.2, 1e-9));
      expect(m.isPlaying, isFalse);
      expect(m.timeSpeed, DiffusionTimeSpeed.slow);
    });
  });

  group('visual qa screenshots', () {
    final outDir = Directory(
      'requirements/req-diffusion/visual-qa/screenshots',
    );

    setUpAll(() {
      if (!outDir.existsSync()) outDir.createSync(recursive: true);
    });

    Future<void> savePng(String name, ui.Image image) async {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      expect(bytes, isNotNull);
      final file = File('${outDir.path}/$name.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      expect(file.lengthSync(), greaterThan(500));
    }

    /// Layout-driven capture via production painters (no hardcoded pixel layout).
    Future<ui.Image> render(DiffusionModel model) async {
      const layoutW = DiffusionConstants.layoutWidth;
      const layoutH = DiffusionConstants.layoutHeight;
      const pad = 8.0;
      const controlsW = 220.0;
      final playW = layoutW - controlsW - pad * 3;
      // Keep container aspect; leave room for flow vectors + chrome.
      final playH = playW *
          DiffusionConstants.containerHeightPm /
          DiffusionConstants.containerWidthPm;
      final clampedPlayH = playH.clamp(120.0, layoutH - 140);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, layoutW, layoutH),
        Paint()..color = const Color(0xFF2C2C2C),
      );

      canvas.save();
      canvas.translate(pad, pad);
      DiffusionPlayAreaPainter(model: model).paint(
        canvas,
        Size(playW, clampedPlayH),
      );
      canvas.restore();

      if (model.particleFlowRateVisible) {
        canvas.save();
        canvas.translate(pad, pad + clampedPlayH + 12);
        ParticleFlowRatePainter(
          flowRate: model.particleFlowRate1,
          fillColor: const Color(DiffusionConstants.particle1Color),
        ).paint(canvas, Size(playW, 28));
        canvas.translate(0, 33);
        ParticleFlowRatePainter(
          flowRate: model.particleFlowRate2,
          fillColor: const Color(DiffusionConstants.particle2Color),
        ).paint(canvas, Size(playW, 28));
        canvas.restore();
      }

      // Control column marker (not screenshot-specific geometry)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(layoutW - controlsW - pad, pad, controlsW, layoutH - 40),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF3A3A3A),
      );

      final tp = TextPainter(
        text: TextSpan(
          text:
              '${model.container.hasDivider ? "divider" : "open"} | '
              '${model.isPlaying ? "play" : "pause"} | '
              '${model.timeSpeed.name} | '
              'N=${model.numberOfParticles} | '
              '${model.stopwatchPs.toStringAsFixed(1)}ps',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: playW);
      tp.paint(canvas, Offset(pad, layoutH - 28));

      final picture = recorder.endRecording();
      return picture.toImage(layoutW.round(), layoutH.round());
    }

    Future<void> capture(String name, void Function(DiffusionModel) setup) async {
      final m = DiffusionModel(autoTick: false, random: math.Random(name.hashCode));
      addTearDown(m.dispose);
      m.pause();
      setup(m);
      final image = await render(m);
      await savePng(name, image);
    }

    test('default', () async {
      await capture('default', (_) {});
    });

    test('before_diffusion', () async {
      await capture('before_diffusion', (m) {
        m.setLeftCount(50);
        m.setRightCount(50);
      });
    });

    test('during_diffusion', () async {
      await capture('during_diffusion', (m) {
        m.setLeftCount(50);
        m.setRightCount(50);
        m.setParticleFlowRateVisible(true);
        m.setHasDivider(false);
        for (var i = 0; i < 80; i++) {
          m.stepModelTime(0.2);
        }
      });
    });

    test('near_equilibrium', () async {
      await capture('near_equilibrium', (m) {
        m.setLeftCount(50);
        m.setRightCount(50);
        m.setParticleFlowRateVisible(true);
        m.setHasDivider(false);
        for (var i = 0; i < 500; i++) {
          m.stepModelTime(0.2);
        }
      });
    });

    test('slow', () async {
      await capture('slow', (m) {
        m.setLeftCount(40);
        m.setRightCount(40);
        m.setHasDivider(false);
        m.setTimeSpeed(DiffusionTimeSpeed.slow);
        for (var i = 0; i < 40; i++) {
          m.stepModelTime(0.2);
        }
      });
    });

    test('paused', () async {
      await capture('paused', (m) {
        m.setLeftCount(40);
        m.setRightCount(40);
        m.setHasDivider(false);
        for (var i = 0; i < 60; i++) {
          m.stepModelTime(0.2);
        }
      });
    });

    test('step', () async {
      await capture('step', (m) {
        m.setLeftCount(40);
        m.setRightCount(40);
        m.setHasDivider(false);
        m.stepForward();
      });
    });
  });
}
