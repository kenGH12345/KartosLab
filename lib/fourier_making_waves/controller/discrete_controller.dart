import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

import '../fmw_constants.dart';
import '../model/axis_description.dart';
import '../model/discrete_model.dart';
import '../model/domain.dart';
import '../model/equation_form.dart';
import '../model/series_type.dart';
import '../model/waveform_kind.dart';
import '../solver/equation_markup.dart';

/// Owns [DiscreteModel] + wall-clock [Ticker] for space&time animation.
class DiscreteController extends ChangeNotifier {
  DiscreteController({required TickerProvider vsync}) {
    model = DiscreteModel();
    model.onOopsSawtoothWithCosines = () {
      _oopsMessage = true;
      notifyListeners();
    };
    _ticker = vsync.createTicker(_onTick)..start();
  }

  late final DiscreteModel model;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  bool _oopsMessage = false;
  bool get oopsMessage => _oopsMessage;

  void clearOops() {
    if (!_oopsMessage) return;
    _oopsMessage = false;
    notifyListeners();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (model.isPlaying && model.domain == Domain.spaceAndTime) {
      model.step(dt.clamp(0.0, 0.15));
      notifyListeners();
    }
  }

  void playPause() {
    model.isPlaying = !model.isPlaying;
    notifyListeners();
  }

  void stepOnce() {
    model.stepOnce();
    notifyListeners();
  }

  void setWaveform(WaveformKind value) {
    model.setWaveform(value);
    notifyListeners();
  }

  void setDomain(Domain value) {
    model.setDomain(value);
    notifyListeners();
  }

  void setEquationForm(EquationForm value) {
    model.setEquationForm(value);
    notifyListeners();
  }

  void setSeriesType(SeriesType value) {
    model.setSeriesType(value);
    notifyListeners();
  }

  void setNumberOfHarmonics(int n) {
    model.setNumberOfHarmonics(n);
    notifyListeners();
  }

  void setAmplitude(int order, double amplitude) {
    final clamped = amplitude.clamp(
      -FmwConstants.maxAmplitude,
      FmwConstants.maxAmplitude,
    );
    model.markCustom();
    model.fourierSeries.setAmplitude(order, clamped.toDouble());
    notifyListeners();
  }

  void eraseAmplitudes() {
    model.eraseAmplitudes();
    notifyListeners();
  }

  void setInfiniteHarmonicsVisible(bool value) {
    model.infiniteHarmonicsVisible = value;
    notifyListeners();
  }

  void setWavelengthToolSelected(bool value) {
    model.wavelengthTool.isSelected = value;
    notifyListeners();
  }

  void setPeriodToolSelected(bool value) {
    model.periodTool.isSelected = value;
    notifyListeners();
  }

  void setWavelengthToolOrder(int order) {
    model.wavelengthTool.order =
        order.clamp(1, model.fourierSeries.numberOfHarmonics);
    notifyListeners();
  }

  void setPeriodToolOrder(int order) {
    model.periodTool.order =
        order.clamp(1, model.fourierSeries.numberOfHarmonics);
    notifyListeners();
  }

  void dragWavelengthCalipers(Offset delta) {
    model.wavelengthTool.positionX =
        (model.wavelengthTool.positionX + delta.dx)
            .clamp(0.0, FmwConstants.chartWidth);
    model.wavelengthTool.positionY =
        (model.wavelengthTool.positionY + delta.dy)
            .clamp(0.0, FmwConstants.chartHeight);
    notifyListeners();
  }

  void dragPeriodCalipers(Offset delta) {
    model.periodTool.positionX = (model.periodTool.positionX + delta.dx)
        .clamp(0.0, FmwConstants.chartWidth);
    model.periodTool.positionY = (model.periodTool.positionY + delta.dy)
        .clamp(0.0, FmwConstants.chartHeight);
    notifyListeners();
  }

  void dragPeriodClock(Offset delta) {
    model.periodClockPositionX = (model.periodClockPositionX + delta.dx)
        .clamp(0.0, FmwConstants.chartWidth);
    model.periodClockPositionY = (model.periodClockPositionY + delta.dy)
        .clamp(0.0, FmwConstants.chartHeight);
    notifyListeners();
  }

  void zoomIn() {
    final list = DiscreteAxisDescriptions.xAxisDescriptions;
    final i = list.indexOf(model.xAxisDescription);
    if (i < 0) {
      model.xAxisDescription = DiscreteAxisDescriptions.defaultXAxisDescription;
    } else if (i < list.length - 1) {
      model.xAxisDescription = list[i + 1];
    }
    notifyListeners();
  }

  void zoomOut() {
    final list = DiscreteAxisDescriptions.xAxisDescriptions;
    final i = list.indexOf(model.xAxisDescription);
    if (i < 0) {
      model.xAxisDescription = DiscreteAxisDescriptions.defaultXAxisDescription;
    } else if (i > 0) {
      model.xAxisDescription = list[i - 1];
    }
    notifyListeners();
  }

  void reset() {
    model.reset();
    _oopsMessage = false;
    notifyListeners();
  }

  List<EquationForm> get availableEquationForms =>
      EquationMarkup.formsForDomain(model.domain);

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
