import '../fmw_constants.dart';
import '../solver/waveform_presets.dart';
import 'axis_description.dart';
import 'discrete_measurement_tool.dart';
import 'domain.dart';
import 'equation_form.dart';
import 'fourier_series.dart';
import 'series_type.dart';
import 'waveform_kind.dart';

/// Top-level Discrete screen model. PhET `DiscreteModel.ts`
class DiscreteModel {
  DiscreteModel() {
    fourierSeries = FourierSeries();
    wavelengthTool = DiscreteMeasurementTool(symbol: 'λ');
    periodTool = DiscreteMeasurementTool(symbol: 'T');
    // Period clock shares periodTool selection; separate view position.
    periodClockPositionX = FmwConstants.chartWidth * 0.75;
    periodClockPositionY = FmwConstants.chartHeight * 0.5;
    updateAmplitudes();
  }

  bool isPlaying = true;

  /// Time in milliseconds (scaled). Relevant for Domain.spaceAndTime only.
  double t = 0;

  WaveformKind waveform = WaveformKind.sinusoid;
  SeriesType seriesType = SeriesType.sin;
  Domain domain = Domain.space;
  EquationForm equationForm = EquationForm.hidden;

  late final FourierSeries fourierSeries;
  late final DiscreteMeasurementTool wavelengthTool;
  late final DiscreteMeasurementTool periodTool;

  /// SPACE_AND_TIME period clock center in harmonics-chart view coords.
  double periodClockPositionX = 0;
  double periodClockPositionY = 0;

  AxisDescription xAxisDescription =
      DiscreteAxisDescriptions.defaultXAxisDescription;

  void Function()? onOopsSawtoothWithCosines;

  bool infiniteHarmonicsVisible = false;

  /// λ calipers visible: selected ∧ (SPACE | SPACE_AND_TIME)
  bool get wavelengthCalipersVisible =>
      wavelengthTool.isSelected &&
      (domain == Domain.space || domain == Domain.spaceAndTime);

  /// T calipers visible: selected ∧ TIME
  bool get periodCalipersVisible =>
      periodTool.isSelected && domain == Domain.time;

  /// Period clock visible: selected ∧ SPACE_AND_TIME
  bool get periodClockVisible =>
      periodTool.isSelected && domain == Domain.spaceAndTime;

  void step(double dtSeconds) {
    if (isPlaying && domain == Domain.spaceAndTime) {
      final milliseconds = dtSeconds * 1000;
      t += milliseconds * FmwConstants.timeScale;
    }
  }

  void stepOnce() {
    t += FmwConstants.stepDt * FmwConstants.timeScale;
  }

  void reset() {
    isPlaying = true;
    t = 0;
    waveform = WaveformKind.sinusoid;
    seriesType = SeriesType.sin;
    domain = Domain.space;
    equationForm = EquationForm.hidden;
    xAxisDescription = DiscreteAxisDescriptions.defaultXAxisDescription;
    infiniteHarmonicsVisible = false;
    wavelengthTool.reset();
    periodTool.reset();
    periodClockPositionX = FmwConstants.chartWidth * 0.75;
    periodClockPositionY = FmwConstants.chartHeight * 0.5;
    fourierSeries.reset();
    updateAmplitudes();
  }

  void setWaveform(WaveformKind value) {
    waveform = value;
    t = 0;
    updateAmplitudes();
  }

  void setDomain(Domain value) {
    domain = value;
    t = 0;
    if (equationForm != EquationForm.mode) {
      equationForm = EquationForm.hidden;
    }
  }

  void setEquationForm(EquationForm value) {
    equationForm = value;
  }

  void setSeriesType(SeriesType value) {
    seriesType = value;
    updateAmplitudes();
  }

  void setNumberOfHarmonics(int n) {
    fourierSeries.numberOfHarmonics = n;
    wavelengthTool.syncWithNumberOfHarmonics(n);
    periodTool.syncWithNumberOfHarmonics(n);
    updateAmplitudes();
  }

  void markCustom() {
    waveform = WaveformKind.custom;
  }

  void eraseAmplitudes() {
    waveform = WaveformKind.custom;
    fourierSeries.setAllAmplitudes(0);
  }

  void updateAmplitudes() {
    if (waveform == WaveformKind.sawtooth && seriesType == SeriesType.cos) {
      onOopsSawtoothWithCosines?.call();
      fourierSeries.setAllAmplitudes(0);
      seriesType = SeriesType.sin;
    }

    if (waveform != WaveformKind.custom) {
      final n = fourierSeries.numberOfHarmonics;
      final preset = WaveformPresets.getAmplitudes(waveform, n, seriesType);
      final amplitudes = List<double>.from(preset);
      while (amplitudes.length < FmwConstants.maxHarmonics) {
        amplitudes.add(0);
      }
      fourierSeries.setAmplitudes(amplitudes);
    }
  }
}
