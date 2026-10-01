import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/normal_modes/model/amplitude_direction.dart';
import 'package:kratos/normal_modes/model/nm_vec.dart';
import 'package:kratos/normal_modes/model/two_dimensions_model.dart';
import 'package:kratos/normal_modes/normal_modes_constants.dart';
import 'package:kratos/normal_modes/solver/normal_mode_math.dart';

void main() {
  group('TwoDimensionsModel defaults', () {
    test('N=3 means 3 per row; 9 visible interior masses', () {
      final m = TwoDimensionsModel();
      expect(m.numberOfMasses, 3);
      var visible = 0;
      for (var i = 1; i <= 3; i++) {
        for (var j = 1; j <= 3; j++) {
          expect(m.masses[i][j].visible, isTrue);
          visible++;
        }
      }
      expect(visible, 9);
      expect(m.playing, isTrue);
      expect(m.amplitudeDirection, AmplitudeDirection.vertical);
    });

    test('maxAmplitude = 0.3 * 2/(N+1)  [N=1 → 0.3, comment: range [0, baseMax] for 1 mass]', () {
      expect(NormalModeMath.maxAmplitude2D(1), closeTo(0.3, 1e-12));
      expect(NormalModeMath.maxAmplitude2D(3), closeTo(0.15, 1e-12));
      expect(NormalModeMath.maxAmplitude2D(10), closeTo(0.3 * 2 / 11, 1e-12));
    });
  });

  group('2D frequency', () {
    test('ω_ij = hypot(ω_i, ω_j)', () {
      const n = 3;
      final w00 = NormalModeMath.frequency2D(0, 0, n);
      final wi = NormalModeMath.frequency1D(0, n);
      expect(w00, closeTo(math.sqrt(2) * wi, 1e-12));
      expect(NormalModeMath.frequency2D(5, 0, n), 0);
    });
  });

  group('exact positions Y sign', () {
    test('Y amplitude uses minus in model coordinates', () {
      final m = TwoDimensionsModel();
      m.modeYAmplitudes[0][0] = 0.1;
      m.setExactPositions();
      final sine = m.sineProduct[1][1][1][1];
      expect(m.masses[1][1].displacement.y, closeTo(-sine * 0.1, 1e-12));
      expect(m.masses[1][1].displacement.x, 0);
    });

    test('X amplitude is positive sine product', () {
      final m = TwoDimensionsModel();
      m.modeXAmplitudes[0][0] = 0.1;
      m.setExactPositions();
      final sine = m.sineProduct[1][1][1][1];
      expect(m.masses[1][1].displacement.x, closeTo(sine * 0.1, 1e-12));
    });
  });

  group('amplitude cell toggle', () {
    test('click sets max then near-max sets 0', () {
      final m = TwoDimensionsModel();
      m.toggleAmplitudeCell(0, 0);
      expect(m.modeYAmplitudes[0][0], closeTo(m.maxAmplitude, 1e-12));
      m.toggleAmplitudeCell(0, 0);
      expect(m.modeYAmplitudes[0][0], 0);
    });

    test('horizontal direction writes X grid', () {
      final m = TwoDimensionsModel();
      m.amplitudeDirection = AmplitudeDirection.horizontal;
      m.toggleAmplitudeCell(1, 2);
      expect(m.modeXAmplitudes[1][2], closeTo(m.maxAmplitude, 1e-12));
      expect(m.modeYAmplitudes[1][2], 0);
    });
  });

  group('2D decompose round-trip', () {
    test('A_x round-trip at t=0', () {
      final m = TwoDimensionsModel();
      m.modeXAmplitudes[0][1] = 0.07;
      m.modeXPhases[0][1] = 0.2;
      m.setExactPositions();
      m.computeModeAmplitudesAndPhases();
      expect(m.modeXAmplitudes[0][1], closeTo(0.07, 1e-9));
      expect(m.modeXPhases[0][1], closeTo(0.2, 1e-9));
    });
  });

  group('reset', () {
    test('reset restores 3×3 and zeros amplitudes', () {
      final m = TwoDimensionsModel();
      m.setNumberOfMasses(6);
      m.toggleAmplitudeCell(0, 0);
      m.reset();
      expect(m.numberOfMasses, 3);
      expect(m.modeYAmplitudes[0][0], 0);
      expect(m.draggingMassIndexes, isNull);
    });
  });

  group('verlet neighbor coupling', () {
    test('dragged mass velocity forced to 0', () {
      final m = TwoDimensionsModel();
      m.draggingMassIndexes = const DragIndex(1, 1);
      m.masses[1][1].displacement = const NmVec(0.05, 0.05);
      m.singleStep(NormalModesConstants.fixedDt);
      expect(m.masses[1][1].velocity, NmVec.zero);
      expect(m.masses[1][1].displacement.x, closeTo(0.05, 1e-12));
    });
  });
}
