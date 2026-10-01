import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/normal_modes/model/amplitude_direction.dart';
import 'package:kratos/normal_modes/model/nm_vec.dart';
import 'package:kratos/normal_modes/model/one_dimension_model.dart';
import 'package:kratos/normal_modes/model/time_speed.dart';
import 'package:kratos/normal_modes/normal_modes_constants.dart';
import 'package:kratos/normal_modes/solver/normal_mode_math.dart';

void main() {
  group('OneDimensionModel defaults', () {
    test('default state matches NormalModesModel + OneDimensionModel', () {
      final m = OneDimensionModel();
      expect(m.numberOfMasses, 3);
      expect(m.playing, isTrue);
      expect(m.timeSpeed, NmTimeSpeed.normal);
      expect(m.time, 0);
      expect(m.springsVisible, isTrue);
      expect(m.arrowsVisible, isTrue);
      expect(m.amplitudeDirection, AmplitudeDirection.vertical);
      expect(m.phasesVisible, isFalse);
      expect(m.draggingMassIndex, 0);
      expect(m.modeAmplitudes, everyElement(0));
      expect(m.modePhases, everyElement(0));
      for (var i = 1; i <= 3; i++) {
        expect(m.masses[i].visible, isTrue);
        expect(m.masses[i].displacement, NmVec.zero);
      }
      expect(m.masses[0].equilibriumPosition.x, NormalModesConstants.leftWallX);
      expect(m.masses[3].equilibriumPosition.x, closeTo(0.5, 1e-12));
    });

    test('wall masses sit at ±1', () {
      final m = OneDimensionModel();
      expect(m.masses[0].equilibriumPosition.x, -1);
      expect(m.masses.last.equilibriumPosition.x, 1);
    });
  });

  group('frequencies', () {
    test('ω_i = 2 sqrt(k/m) sin(π/2 · (i+1)/(N+1))', () {
      const n = 3;
      for (var i = 0; i < 10; i++) {
        final expected = i >= n
            ? 0.0
            : 2 *
                NormalModeMath.sqrtKOverM() *
                math.sin(math.pi / 2 * (i + 1) / (n + 1));
        expect(NormalModeMath.frequency1D(i, n), closeTo(expected, 1e-12));
      }
    });

    test('N=3 frequency labels 0.77 / 1.41 / 1.85 ω0', () {
      expect(NormalModeMath.frequencyLabel(0, 3), '0.77ω₀');
      expect(NormalModeMath.frequencyLabel(1, 3), '1.41ω₀');
      expect(NormalModeMath.frequencyLabel(2, 3), '1.85ω₀');
    });

    test('sqrt(k/m) is 2π', () {
      expect(NormalModeMath.sqrtKOverM(), closeTo(2 * math.pi, 1e-12));
    });
  });

  group('exact superposition', () {
    test('single mode 1 vertical displacement at t=0', () {
      final m = OneDimensionModel();
      m.modeAmplitudes[0] = 0.1;
      m.setExactPositions();
      for (var i = 1; i <= 3; i++) {
        final shape = math.sin(i * 1 * math.pi / 4);
        expect(m.masses[i].displacement.y, closeTo(0.1 * shape, 1e-12));
        expect(m.masses[i].displacement.x, 0);
      }
    });

    test('horizontal direction writes x not y', () {
      final m = OneDimensionModel();
      m.amplitudeDirection = AmplitudeDirection.horizontal;
      m.modeAmplitudes[0] = 0.05;
      m.setExactPositions();
      expect(m.masses[1].displacement.x, isNot(0));
      expect(m.masses[1].displacement.y, 0);
    });

    test('time evolution is A sin(kx) cos(ωt)', () {
      final m = OneDimensionModel();
      m.modeAmplitudes[0] = 0.1;
      m.time = 0.25;
      m.setExactPositions();
      final w = m.modeFrequencies[0];
      final shape = math.sin(1 * math.pi / 4);
      expect(
        m.masses[1].displacement.y,
        closeTo(0.1 * shape * math.cos(w * 0.25), 1e-12),
      );
    });
  });

  group('step / pause / speed', () {
    test('playing advances time by FIXED_DT * scale per singleStep', () {
      final m = OneDimensionModel();
      m.modeAmplitudes[0] = 0.05;
      m.singleStep(NormalModesConstants.fixedDt);
      expect(m.time, closeTo(NormalModesConstants.fixedDt, 1e-12));
    });

    test('slow speed scales dt inside singleStep', () {
      final m = OneDimensionModel();
      m.timeSpeed = NmTimeSpeed.slow;
      m.singleStep(NormalModesConstants.fixedDt);
      expect(
        m.time,
        closeTo(
          NormalModesConstants.fixedDt * NormalModesConstants.slowSpeed,
          1e-12,
        ),
      );
    });

    test('paused still applies exact positions when amplitude changes', () {
      final m = OneDimensionModel();
      m.playing = false;
      m.setModeAmplitude(0, 0.1);
      expect(m.masses[1].displacement.y, isNot(0));
    });

    test('step() clamps dt > 0.15', () {
      final m = OneDimensionModel();
      m.modeAmplitudes[0] = 0.05;
      m.step(2.0);
      expect(m.time, closeTo(NormalModesConstants.fixedDt * 9, 1e-9));
    });
  });

  group('reset / zero / initial', () {
    test('zeroPositions clears A and displacements without pausing', () {
      final m = OneDimensionModel();
      m.modeAmplitudes[0] = 0.1;
      m.setExactPositions();
      m.playing = true;
      m.zeroPositions();
      expect(m.playing, isTrue);
      expect(m.modeAmplitudes[0], 0);
      expect(m.masses[1].displacement, NmVec.zero);
    });

    test('initialPositions pauses and sets t=0', () {
      final m = OneDimensionModel();
      m.modeAmplitudes[0] = 0.1;
      m.time = 1.5;
      m.playing = true;
      m.initialPositions();
      expect(m.playing, isFalse);
      expect(m.time, 0);
      expect(m.modeAmplitudes[0], 0.1);
    });

    test('reset restores N=3 and defaults; does not require time=0', () {
      final m = OneDimensionModel();
      m.setNumberOfMasses(8);
      m.modeAmplitudes[0] = 0.1;
      m.phasesVisible = true;
      m.playing = false;
      m.reset();
      expect(m.numberOfMasses, 3);
      expect(m.playing, isTrue);
      expect(m.phasesVisible, isFalse);
      expect(m.modeAmplitudes[0], 0);
      expect(m.arrowsVisible, isTrue);
    });
  });

  group('number of masses', () {
    test('N=1 equilibrium spacing 2/2=1', () {
      final m = OneDimensionModel();
      m.setNumberOfMasses(1);
      expect(m.masses[0].equilibriumPosition.x, -1);
      expect(m.masses[1].equilibriumPosition.x, closeTo(0, 1e-12));
      expect(m.masses[1].visible, isTrue);
      expect(m.masses[2].visible, isFalse);
    });

    test('N=10 all interior visible; amplitudes reset', () {
      final m = OneDimensionModel();
      m.modeAmplitudes[0] = 0.1;
      m.setNumberOfMasses(10);
      expect(m.modeAmplitudes[0], 0);
      for (var i = 1; i <= 10; i++) {
        expect(m.masses[i].visible, isTrue);
      }
    });

    test('invalid N is clamped', () {
      final m = OneDimensionModel();
      m.setNumberOfMasses(0);
      expect(m.numberOfMasses, 1);
      m.setNumberOfMasses(99);
      expect(m.numberOfMasses, 10);
    });
  });

  group('mode decomposition', () {
    test('round-trip A,φ at t=0', () {
      final m = OneDimensionModel();
      m.modeAmplitudes[0] = 0.08;
      m.modePhases[0] = 0.3;
      m.time = 0;
      m.setExactPositions();
      m.computeModeAmplitudesAndPhases();
      expect(m.time, 0);
      expect(m.modeAmplitudes[0], closeTo(0.08, 1e-10));
      expect(m.modePhases[0], closeTo(0.3, 1e-10));
    });
  });

  group('verlet', () {
    test('dragged mass stays put; neighbors move', () {
      final m = OneDimensionModel();
      m.masses[1].displacement = const NmVec(0, 0.05);
      m.masses[1].acceleration = const NmVec(0, -1);
      m.draggingMassIndex = 2;
      m.masses[2].displacement = const NmVec(0, 0.1);
      OneDimensionModel().singleStep;
      m.singleStep(NormalModesConstants.fixedDt);
      expect(m.masses[2].displacement.y, closeTo(0.1, 1e-12));
      expect(m.masses[2].velocity, NmVec.zero);
    });
  });
}
