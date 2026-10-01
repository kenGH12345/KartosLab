import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

import 'package:kratos/fourier_making_waves/fmw_constants.dart';
import 'package:kratos/fourier_making_waves/model/discrete_model.dart';
import 'package:kratos/fourier_making_waves/model/domain.dart';
import 'package:kratos/fourier_making_waves/model/equation_form.dart';
import 'package:kratos/fourier_making_waves/model/series_type.dart';
import 'package:kratos/fourier_making_waves/model/wave_packet_model.dart';
import 'package:kratos/fourier_making_waves/render/fmw_mvt.dart';
import 'package:kratos/fourier_making_waves/solver/equation_markup.dart';
import 'package:kratos/fourier_making_waves/solver/harmonic_quantities.dart';
import 'package:kratos/fourier_making_waves/solver/wave_packet_math.dart';

void main() {
  group('HarmonicQuantities measurement', () {
    test('λₙ = L/n', () {
      expect(HarmonicQuantities.wavelength(1), 1.0);
      expect(HarmonicQuantities.wavelength(2), 0.5);
      expect(HarmonicQuantities.wavelength(4), 0.25);
    });

    test('Tₙ = T₀/n', () {
      expect(
        HarmonicQuantities.period(1),
        closeTo(FmwConstants.T, 1e-12),
      );
      expect(
        HarmonicQuantities.period(2),
        closeTo(FmwConstants.T / 2, 1e-12),
      );
    });

    test('fₙ = 440·n', () {
      expect(HarmonicQuantities.frequency(1), 440);
      expect(HarmonicQuantities.frequency(3), 1320);
    });

    test('calipers width uses modelToViewDeltaX not screen pixels', () {
      final mvt = FmwMvt.forChart(
        xMin: -0.5,
        xMax: 0.5,
        yMin: -1.5,
        yMax: 1.5,
        width: 645,
        height: 123,
      );
      final lambda2 = HarmonicQuantities.wavelength(2); // 0.5 m
      final viewW = mvt.modelToViewDeltaX(lambda2);
      // Full chart is 1.0 model units → 645 px; 0.5 → 322.5
      expect(viewW, closeTo(322.5, 1e-9));
    });
  });

  group('Discrete measurement tools', () {
    test('visibility gated by domain', () {
      final m = DiscreteModel();
      m.wavelengthTool.isSelected = true;
      m.periodTool.isSelected = true;
      expect(m.wavelengthCalipersVisible, isTrue); // SPACE
      expect(m.periodCalipersVisible, isFalse);
      expect(m.periodClockVisible, isFalse);

      m.setDomain(Domain.time);
      expect(m.wavelengthCalipersVisible, isFalse);
      expect(m.periodCalipersVisible, isTrue);
      expect(m.periodClockVisible, isFalse);

      m.setDomain(Domain.spaceAndTime);
      expect(m.wavelengthCalipersVisible, isTrue);
      expect(m.periodCalipersVisible, isFalse);
      expect(m.periodClockVisible, isTrue);
    });

    test('order clamps when harmonics shrink', () {
      final m = DiscreteModel();
      m.wavelengthTool.isSelected = true;
      m.wavelengthTool.order = 8;
      m.setNumberOfHarmonics(5);
      expect(m.wavelengthTool.isSelected, isFalse);
      expect(m.wavelengthTool.order, 5);
    });

    test('reset clears selection and order', () {
      final m = DiscreteModel();
      m.wavelengthTool.isSelected = true;
      m.wavelengthTool.order = 3;
      m.periodTool.isSelected = true;
      m.reset();
      expect(m.wavelengthTool.isSelected, isFalse);
      expect(m.wavelengthTool.order, 1);
      expect(m.periodTool.isSelected, isFalse);
    });

    test('period clock percent from t mod Tₙ', () {
      final m = DiscreteModel();
      m.setDomain(Domain.spaceAndTime);
      m.periodTool.isSelected = true;
      m.periodTool.order = 1;
      final T1 = HarmonicQuantities.period(1);
      m.t = T1 * 0.25;
      final percent = (m.t % T1) / T1;
      expect(percent, closeTo(0.25, 1e-12));
    });
  });

  group('EquationForm presentation', () {
    test('does not change sampling — markup only', () {
      final mode = EquationMarkup.getGeneralFormMarkup(
        Domain.space,
        SeriesType.sin,
        EquationForm.mode,
      );
      final wavelength = EquationMarkup.getGeneralFormMarkup(
        Domain.space,
        SeriesType.sin,
        EquationForm.wavelength,
      );
      expect(mode.contains('L'), isTrue);
      expect(wavelength.contains('λ'), isTrue);
      expect(EquationMarkup.getGeneralFormMarkup(
        Domain.space,
        SeriesType.sin,
        EquationForm.hidden,
      ), '');
    });

    test('domain switch forms list', () {
      expect(
        EquationMarkup.formsForDomain(Domain.space),
        contains(EquationForm.wavelength),
      );
      expect(
        EquationMarkup.formsForDomain(Domain.time),
        contains(EquationForm.frequency),
      );
      expect(
        EquationMarkup.formsForDomain(Domain.spaceAndTime),
        contains(EquationForm.wavelengthAndPeriod),
      );
    });

    test('setDomain resets non-mode form to hidden', () {
      final m = DiscreteModel();
      m.setEquationForm(EquationForm.wavelength);
      m.setDomain(Domain.time);
      expect(m.equationForm, EquationForm.hidden);
    });
  });

  group('Wave packet indicators', () {
    test('continuous waveform default true and samples π/10', () {
      final m = WavePacketModel();
      expect(m.continuousWaveformVisible, isTrue);
      final pts = m.createContinuousWaveformDataSet();
      expect(pts.length, greaterThan(10));
      // x is wave number
      expect(pts.first.x, 0);
    });

    test('continuous hidden returns empty', () {
      final m = WavePacketModel();
      m.continuousWaveformVisible = false;
      expect(m.createContinuousWaveformDataSet(), isEmpty);
    });

    test('amplitudes width indicator = 2σ at (center, A(center+σ)·Δk)', () {
      final m = WavePacketModel();
      final p = m.wavePacket;
      final ind = WavePacketMath.amplitudesWidthIndicator(
        center: p.center,
        standardDeviation: p.standardDeviation,
        componentSpacing: p.componentSpacing,
      );
      expect(ind.width, closeTo(2 * p.standardDeviation, 1e-12));
      expect(ind.x, closeTo(p.center, 1e-12));
      final expectedY = WavePacketMath.gaussianAmplitude(
            waveNumber: p.center + p.standardDeviation,
            center: p.center,
            standardDeviation: p.standardDeviation,
          ) *
          p.componentSpacing;
      expect(ind.y, closeTo(expectedY, 1e-12));
    });

    test('sum width indicator = 2σₓ at (0, 1/√e)', () {
      final m = WavePacketModel();
      final ind = WavePacketMath.sumWidthIndicator(
        conjugateStandardDeviation: m.wavePacket.conjugateStandardDeviation,
      );
      expect(
        ind.width,
        closeTo(2 * m.wavePacket.conjugateStandardDeviation, 1e-12),
      );
      expect(ind.x, 0);
      expect(ind.y, closeTo(1 / math.sqrt(math.e), 1e-12));
    });

    test('envelope still produced when visible', () {
      final m = WavePacketModel();
      expect(m.waveformEnvelopeVisible, isTrue);
      final env = m.createEnvelopeDataSet();
      expect(env, isNotEmpty);
      m.waveformEnvelopeVisible = false;
      expect(m.createEnvelopeDataSet(), isEmpty);
    });

    test('reset restores continuous default true', () {
      final m = WavePacketModel();
      m.continuousWaveformVisible = false;
      m.widthIndicatorsVisible = true;
      m.reset();
      expect(m.continuousWaveformVisible, isTrue);
      expect(m.widthIndicatorsVisible, isFalse);
      expect(m.waveformEnvelopeVisible, isTrue);
    });
  });
}
