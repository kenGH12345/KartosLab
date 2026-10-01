// M1 verification: print state changes during simulated drag.
// Run: flutter test test/blackbody_spectrum/m1_verify_test.dart
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/blackbody_spectrum/blackbody_spectrum_constants.dart';
import 'package:kratos/blackbody_spectrum/model/blackbody_spectrum_model.dart';
import 'package:kratos/blackbody_spectrum/model/blackbody_body_model.dart';
import 'package:kratos/blackbody_spectrum/render/blackbody_render_data.dart';

const thermTop = 60.0;
const tubeH = 400.0;

double tempToYPos(double t) =>
    ((t - BlackbodySpectrumConstants.minTemperature) /
        (BlackbodySpectrumConstants.maxTemperature -
            BlackbodySpectrumConstants.minTemperature)) *
    tubeH;

double yPosToTemp(double phetY) {
  final yFromBottom = (thermTop + tubeH) - phetY;
  final ratio = yFromBottom / tubeH;
  final clamped = ratio.clamp(0.0, 1.0);
  final temp = BlackbodySpectrumConstants.minTemperature +
      clamped *
          (BlackbodySpectrumConstants.maxTemperature -
              BlackbodySpectrumConstants.minTemperature);
  return (temp / 50).round() * 50.0;
}

void main() {
  test('M1 — full drag verification with printed evidence', () {
    print('\n=== M1 THERMOMETER DRAG VERIFICATION ===\n');

    // --- Direction test ---
    print('--- DIRECTION TEST ---');
    final tempAtTop = yPosToTemp(thermTop);
    final tempAtBottom = yPosToTemp(thermTop + tubeH);
    final tempAtMid = yPosToTemp(thermTop + tubeH / 2);
    print('  Y=top(60)     → T=$tempAtTop K');
    print('  Y=mid(260)    → T=$tempAtMid K');
    print('  Y=bottom(460) → T=$tempAtBottom K');
    expect(tempAtTop > tempAtBottom, isTrue,
        reason: 'up=hotter, down=cooler');
    print('  Direction: PASS (up=hotter)\n');

    // --- Drag up from 5800K ---
    print('--- DRAG UP FROM 5800K ---');
    final model = BlackbodySpectrumModel();
    print('  Initial: T=${model.temperature}K');
    final thumbY5800 = thermTop + tubeH - tempToYPos(5800);
    print('  Thumb Y at 5800K: ${thumbY5800.toStringAsFixed(1)}');

    model.temperature = yPosToTemp(150); // drag up to Y=150
    print('  After drag to Y=150: T=${model.temperature}K');

    final peakBefore = BlackbodyBodyModel(5800).peakWavelength;
    final peakAfter = model.mainBody.peakWavelength;
    print('  Peak λ: 5800K=${peakBefore.round()}nm → now=${peakAfter.round()}nm');
    expect(peakAfter < peakBefore, isTrue, reason: 'Wien: hotter→shorter');
    print('  Wien: PASS (hotter→shorter)\n');

    // --- Curve non-degenerate ---
    final render = BlackbodyRenderData(
      mainBody: model.mainBody,
      savedBodyOne: model.savedBodyOne,
      savedBodyTwo: model.savedBodyTwo,
      graphValuesVisible: false,
      intensityVisible: false,
      labelsVisible: false,
      wavelengthMax: model.wavelengthMax,
      verticalZoom: model.verticalZoom,
      graphPointWavelength: model.mainBody.peakWavelength,
      cueingArrowsVisible: false,
    );
    final pts = render.sampleCurvePoints(model.mainBody);
    final maxY = pts.map((p) => p.dy.abs()).fold(0.0, math.max);
    print('  Curve points: ${pts.length}, max|Y|=${maxY.toStringAsFixed(1)}');
    expect(pts.length > 100 && maxY > 1, isTrue, reason: 'curve non-degenerate');
    print('  Curve: PASS (non-degenerate)\n');

    // --- Drag down from 5800K ---
    print('--- DRAG DOWN FROM 5800K ---');
    model.temperature = 5800;
    print('  Reset to: T=${model.temperature}K');
    model.temperature = yPosToTemp(360); // drag down to Y=360
    print('  After drag to Y=360: T=${model.temperature}K');
    final peakDown = model.mainBody.peakWavelength;
    print('  Peak λ: now=${peakDown.round()}nm');
    expect(peakDown > peakBefore, isTrue, reason: 'Wien: cooler→longer');
    print('  Wien: PASS (cooler→longer)');

    final starColor = model.mainBody.starColor;
    final star5800 = BlackbodyBodyModel(5800).starColor;
    print('  Star color: R=${starColor.red} G=${starColor.green} B=${starColor.blue} '
        '(vs 5800K R=${star5800.red} G=${star5800.green} B=${star5800.blue})');
    expect(starColor != star5800, isTrue, reason: 'star color must change');
    print('  Star color: PASS (changed)\n');

    // --- Clamp ---
    print('--- CLAMP TEST ---');
    model.temperature = 50000;
    expect(model.temperature, equals(BlackbodySpectrumConstants.maxTemperature));
    print('  T=50000 → ${model.temperature}K (max)');
    model.temperature = -1000;
    expect(model.temperature, equals(BlackbodySpectrumConstants.minTemperature));
    print('  T=-1000 → ${model.temperature}K (min)');
    print('  Clamp: PASS\n');

    // --- Reset ---
    print('--- RESET TEST ---');
    model.temperature = 3000;
    print('  Set to 3000K: T=${model.temperature}K');
    model.reset();
    expect(model.temperature, equals(5800));
    print('  After reset: T=${model.temperature}K');
    print('  Reset: PASS\n');

    // --- Spectrum table ---
    print('--- SPECTRUM TABLE ---');
    final body5800 = BlackbodyBodyModel(5800);
    final body9950 = BlackbodyBodyModel(9950);
    final body3000 = BlackbodyBodyModel(3000);
    final wls = [500.0, 1000.0, 2000.0, 3000.0];
    for (final (t, b) in [(3000, body3000), (5800, body5800), (9950, body9950)]) {
      final vals = wls.map((w) => b.getSpectralPowerDensityAt(w).toStringAsExponential(3));
      print('  T=${t}K: ${vals.join(" | ")}');
    }
    final spd3000 = body3000.getSpectralPowerDensityAt(500);
    final spd5800 = body5800.getSpectralPowerDensityAt(500);
    final spd9950 = body9950.getSpectralPowerDensityAt(500);
    expect(spd3000 != spd5800 && spd5800 != spd9950, isTrue);
    print('  SPD@500nm differs across T: PASS');
    expect(body3000.peakWavelength > body5800.peakWavelength, isTrue);
    expect(body5800.peakWavelength > body9950.peakWavelength, isTrue);
    print('  Wien monotonic: PASS\n');

    print('=== M1 VERIFICATION SUMMARY ===');
    print('  Direction (up=hotter):       PASS');
    print('  Drag up → T increase:        PASS');
    print('  Drag down → T decrease:       PASS');
    print('  Clamp (min=200, max=11000):  PASS');
    print('  Reset → 5800K:               PASS');
    print('  Peak wavelength (Wien):      PASS');
    print('  SPD curve changes:           PASS');
    print('  Star color changes:           PASS');
    print('  Curve non-degenerate:         PASS');
  });
}
