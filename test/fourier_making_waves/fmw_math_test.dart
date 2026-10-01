import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/fourier_making_waves/fmw_constants.dart';
import 'package:kratos/fourier_making_waves/model/axis_description.dart';
import 'package:kratos/fourier_making_waves/model/discrete_model.dart';
import 'package:kratos/fourier_making_waves/model/domain.dart';
import 'package:kratos/fourier_making_waves/model/series_type.dart';
import 'package:kratos/fourier_making_waves/model/wave_game_model.dart';
import 'package:kratos/fourier_making_waves/model/wave_packet_model.dart';
import 'package:kratos/fourier_making_waves/model/waveform_kind.dart';
import 'package:kratos/fourier_making_waves/solver/amplitude_function.dart';
import 'package:kratos/fourier_making_waves/solver/fourier_synthesis.dart';
import 'package:kratos/fourier_making_waves/solver/wave_packet_math.dart';
import 'package:kratos/fourier_making_waves/solver/waveform_presets.dart';

void main() {
  group('AmplitudeFunctions', () {
    test('space sine at x=L/4, n=1, A=1 → 1', () {
      final y = AmplitudeFunctions.getAmplitudeSpaceSine(
        1,
        1,
        FmwConstants.L / 4,
        0,
        FmwConstants.L,
        FmwConstants.T,
      );
      expect(y, closeTo(1.0, 1e-12));
    });

    test('spaceAndTime sine shifts with t', () {
      final f = AmplitudeFunctions.getAmplitudeFunction(
        Domain.spaceAndTime,
        SeriesType.sin,
      );
      final y0 = f(1, 1, 0, 0, FmwConstants.L, FmwConstants.T);
      final y1 = f(1, 1, 0, FmwConstants.T / 4, FmwConstants.L, FmwConstants.T);
      expect(y0, closeTo(0.0, 1e-12));
      expect(y1, closeTo(-1.0, 1e-12));
    });
  });

  group('WaveformPresets', () {
    test('sinusoid only A1=1', () {
      final a = WaveformPresets.getAmplitudes(
        WaveformKind.sinusoid,
        11,
        SeriesType.sin,
      );
      expect(a[0], 1.0);
      expect(a.skip(1).every((v) => v == 0), isTrue);
    });

    test('square odd harmonics 4/(nπ)', () {
      final a = WaveformPresets.getAmplitudes(
        WaveformKind.square,
        5,
        SeriesType.sin,
      );
      expect(a[0], closeTo(4 / math.pi, 1e-12));
      expect(a[1], 0);
      expect(a[2], closeTo(4 / (3 * math.pi), 1e-12));
    });

    test('sawtooth formula', () {
      final a = WaveformPresets.getAmplitudes(
        WaveformKind.sawtooth,
        3,
        SeriesType.sin,
      );
      expect(a[0], closeTo(2 / math.pi, 1e-12));
      expect(a[1], closeTo(-2 / (2 * math.pi), 1e-12));
      expect(a[2], closeTo(2 / (3 * math.pi), 1e-12));
    });

    test('wave packet hardcoded row for n=5', () {
      final a = WaveformPresets.getAmplitudes(
        WaveformKind.wavePacket,
        5,
        SeriesType.sin,
      );
      expect(a, [
        0.135335,
        0.606531,
        1.000000,
        0.606531,
        0.135335,
      ]);
    });

    test('triangle infinite harmonics data set non-empty', () {
      final pts = WaveformPresets.getInfiniteHarmonicsDataSet(
        WaveformKind.triangle,
        Domain.space,
        SeriesType.sin,
        0,
        FmwConstants.L,
        FmwConstants.T,
      );
      expect(pts, isNotNull);
      expect(pts!.length, greaterThan(4));
    });
  });

  group('FourierSynthesis', () {
    test('sinusoid sum peaks near ±1', () {
      final amplitudes = List<double>.filled(FmwConstants.maxHarmonics, 0.0);
      final preset = WaveformPresets.getAmplitudes(
        WaveformKind.sinusoid,
        11,
        SeriesType.sin,
      );
      for (var i = 0; i < preset.length; i++) {
        amplitudes[i] = preset[i];
      }
      final sum = FourierSynthesis.createSumDataSet(
        amplitudes: amplitudes,
        xAxisDescription: DiscreteAxisDescriptions.defaultXAxisDescription,
        domain: Domain.space,
        seriesType: SeriesType.sin,
        t: 0,
      );
      final ys = sum.map((p) => p.y);
      final peak = ys.reduce(math.max);
      final trough = ys.reduce(math.min);
      expect(peak, closeTo(1.0, 0.02));
      expect(trough, closeTo(-1.0, 0.02));
    });
  });

  group('DiscreteModel', () {
    test('default sinusoid', () {
      final m = DiscreteModel();
      expect(m.waveform, WaveformKind.sinusoid);
      expect(m.domain, Domain.space);
      expect(m.fourierSeries.amplitudes[0], 1.0);
    });

    test('step only advances in spaceAndTime when playing', () {
      final m = DiscreteModel();
      m.step(1.0);
      expect(m.t, 0);
      m.setDomain(Domain.spaceAndTime);
      m.isPlaying = true;
      m.step(1.0);
      expect(m.t, closeTo(1000 * FmwConstants.timeScale, 1e-12));
      m.isPlaying = false;
      final tPaused = m.t;
      m.step(1.0);
      expect(m.t, tPaused);
    });

    test('erase → custom all zero', () {
      final m = DiscreteModel();
      m.eraseAmplitudes();
      expect(m.waveform, WaveformKind.custom);
      expect(m.fourierSeries.amplitudes.every((a) => a == 0), isTrue);
    });

    test('reset restores sinusoid', () {
      final m = DiscreteModel();
      m.setWaveform(WaveformKind.square);
      m.setDomain(Domain.spaceAndTime);
      m.stepOnce();
      m.reset();
      expect(m.waveform, WaveformKind.sinusoid);
      expect(m.domain, Domain.space);
      expect(m.t, 0);
      expect(m.fourierSeries.amplitudes[0], 1.0);
    });

    test('custom edit skips preset overwrite', () {
      final m = DiscreteModel();
      m.markCustom();
      m.fourierSeries.setAmplitude(1, 0.5);
      expect(m.waveform, WaveformKind.custom);
      expect(m.fourierSeries.amplitudes[0], 0.5);
      m.setNumberOfHarmonics(5);
      expect(m.fourierSeries.amplitudes[0], 0.5);
    });
  });

  group('WaveGame', () {
    test('match requires exact amplitudes', () {
      final game = WaveGameModel(random: math.Random(1));
      final level = game.levels[0];
      expect(level.isMatched, isFalse);
      level.guessSeries.setAmplitudes(level.answerSeries.amplitudesCopy);
      expect(level.isMatched, isTrue);
      final scoreBefore = level.score;
      level.checkAnswer();
      expect(level.score, scoreBefore + FmwConstants.pointsPerChallenge);
      expect(level.isSolved, isTrue);
    });

    test('mismatch does not score', () {
      final game = WaveGameModel(random: math.Random(2));
      final level = game.levels[0];
      level.guessSeries.setAmplitude(1, 0.5);
      final scoreBefore = level.score;
      level.checkAnswer();
      expect(level.score, scoreBefore);
      expect(level.isSolved, isFalse);
    });

    test('showAnswer solves without score', () {
      final game = WaveGameModel(random: math.Random(3));
      final level = game.levels[0];
      final scoreBefore = level.score;
      level.showAnswer();
      expect(level.isSolved, isTrue);
      expect(level.score, scoreBefore);
      expect(level.isMatched, isTrue);
    });
  });

  group('WavePacket', () {
    test('gaussian peak at center', () {
      final m = WavePacketModel();
      final center = m.wavePacket.center;
      final sigma = m.wavePacket.standardDeviation;
      final peak = WavePacketMath.gaussianAmplitude(
        waveNumber: center,
        center: center,
        standardDeviation: sigma,
      );
      final side = WavePacketMath.gaussianAmplitude(
        waveNumber: center + sigma,
        center: center,
        standardDeviation: sigma,
      );
      expect(peak, greaterThan(side));
      expect(peak, closeTo(1 / (sigma * math.sqrt(2 * math.pi)), 1e-12));
    });

    test('infinite packet envelope near 1 at x≈0', () {
      final center = 12 * math.pi;
      final dx = 1 / (3 * math.pi);
      final sinSet = WavePacketMath.createWavePacketDataSet(
        center: center,
        conjugateStandardDeviation: dx,
        seriesType: SeriesType.sin,
        xMin: -1,
        xMax: 1,
      );
      final cosSet = WavePacketMath.createWavePacketDataSet(
        center: center,
        conjugateStandardDeviation: dx,
        seriesType: SeriesType.cos,
        xMin: -1,
        xMax: 1,
      );
      final env = WavePacketMath.createEnvelopeDataSet(sinSet, cosSet);
      final e0 = env.reduce((a, b) => a.x.abs() < b.x.abs() ? a : b);
      expect(e0.y, closeTo(1.0, 0.05));
    });

    test('reset restores defaults', () {
      final m = WavePacketModel();
      m.wavePacket.center = 10 * math.pi;
      m.reset();
      expect(m.wavePacket.center, closeTo(12 * math.pi, 1e-12));
    });
  });
}
