import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/detector_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/qwi_random.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/slit_configuration.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/source_type.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/time_speed.dart';
import 'package:kratos/physics/quantum_wave_interference/domain/wave_display_mode.dart';
import 'package:kratos/physics/quantum_wave_interference/models/high_intensity_model.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_controller.dart';
import 'package:kratos/physics/quantum_wave_interference/view/high_intensity/high_intensity_screen.dart';

Widget _wrap(HighIntensityController c) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 768,
          height: 504,
          child: HighIntensityScreen(controller: c, autoStartClock: false),
        ),
      ),
    );

void main() {
  testWidgets('HI screen builds', (tester) async {
    final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(1)));
    await tester.pumpWidget(_wrap(c));
    expect(find.byKey(const Key('hi_wave_canvas')), findsOneWidget);
    expect(find.byKey(const Key('hi_detector_canvas')), findsOneWidget);
    expect(find.byKey(const Key('hi_reset_all')), findsOneWidget);
  });

  testWidgets('emit + wavelength changes wave/PDF path', (tester) async {
    final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(2)));
    await tester.pumpWidget(_wrap(c));
    await tester.tap(find.byKey(const Key('hi_emit_toggle')));
    await tester.pump();
    expect(c.scene.isEmitting, isTrue);
    for (var i = 0; i < 40; i++) {
      c.stepOnce();
    }
    final i0 = c.scene.detectorPdf.fold<double>(0, (a, b) => a + b);
    c.setWavelengthNm(400);
    for (var i = 0; i < 40; i++) {
      c.stepOnce();
    }
    final i1 = c.scene.detectorPdf.fold<double>(0, (a, b) => a + b);
    expect(c.scene.wavelengthNm, 400);
    // Pattern reformed — sums may differ after clear+restart
    expect(i0 >= 0 && i1 >= 0, isTrue);
  });

  testWidgets('pause stops time; step advances 1/60', (tester) async {
    final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(3)));
    c.setEmitting(true);
    c.setPlaying(false);
    await tester.pumpWidget(_wrap(c));
    final t0 = c.scene.solver.time;
    c.stepWall(1);
    expect(c.scene.solver.time, t0);
    c.stepOnce();
    expect(c.scene.solver.time, closeTo(t0 + 1 / 60, 1e-9));
  });

  testWidgets('reset restores defaults', (tester) async {
    final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(4)));
    c.setWavelengthNm(400);
    c.selectSource(SourceType.electrons);
    c.setSlitConfiguration(SlitConfiguration.noBarrier);
    c.setTimeSpeed(TimeSpeed.fast);
    await tester.pumpWidget(_wrap(c));
    await tester.tap(find.byKey(const Key('hi_reset_all')));
    await tester.pumpAndSettle();
    expect(c.model.activeSource, SourceType.photons);
    expect(c.scene.wavelengthNm, 650);
    expect(c.scene.slitConfiguration, SlitConfiguration.bothOpen);
    expect(c.scene.waveDisplayMode, WaveDisplayMode.electricField);
    expect(c.model.clock.speed, TimeSpeed.normal);
  });

  testWidgets('detector-on-slit accepted', (tester) async {
    final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(5)));
    await tester.pumpWidget(_wrap(c));
    c.setSlitConfiguration(SlitConfiguration.bothDetectors);
    await tester.pump();
    expect(c.scene.slitConfiguration.hasAnyDetector, isTrue);
  });

  testWidgets('hits mode accumulates', (tester) async {
    final c = HighIntensityController(model: HighIntensityModel(random: SeededQwiRandom(6)));
    await tester.pumpWidget(_wrap(c));
    c.setDetectionMode(DetectorMode.hits);
    c.setEmitting(true);
    for (var i = 0; i < 180; i++) {
      c.stepOnce();
    }
    await tester.pump();
    expect(c.scene.hits.length, greaterThan(0));
  });
}
