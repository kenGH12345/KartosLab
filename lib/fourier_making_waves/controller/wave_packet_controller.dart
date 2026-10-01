import 'package:flutter/foundation.dart';

import '../model/axis_description.dart';
import '../model/domain.dart';
import '../model/series_type.dart';
import '../model/wave_packet.dart';
import '../model/wave_packet_model.dart';

/// Owns [WavePacketModel] for the Wave Packet screen.
class WavePacketController extends ChangeNotifier {
  WavePacketController() : model = WavePacketModel();

  final WavePacketModel model;

  void setDomain(Domain value) {
    if (value == Domain.spaceAndTime) return;
    model.setDomain(value);
    notifyListeners();
  }

  void setSeriesType(SeriesType value) {
    model.seriesType = value;
    notifyListeners();
  }

  void setComponentSpacing(double value) {
    model.wavePacket.setComponentSpacing(value);
    notifyListeners();
  }

  void setCenter(double value) {
    model.wavePacket.setCenter(value);
    notifyListeners();
  }

  void setStandardDeviation(double value) {
    model.wavePacket.setStandardDeviation(value);
    notifyListeners();
  }

  void setConjugateStandardDeviation(double value) {
    model.wavePacket.conjugateStandardDeviation = value.clamp(
      model.wavePacket.conjugateStandardDeviationMin,
      model.wavePacket.conjugateStandardDeviationMax,
    );
    notifyListeners();
  }

  void setWidthIndicatorsVisible(bool value) {
    model.widthIndicatorsVisible = value;
    notifyListeners();
  }

  void setWaveformEnvelopeVisible(bool value) {
    model.waveformEnvelopeVisible = value;
    notifyListeners();
  }

  void setContinuousWaveformVisible(bool value) {
    model.continuousWaveformVisible = value;
    notifyListeners();
  }

  void zoomIn() {
    final list = WavePacketAxisDescriptions.xAxisDescriptions;
    final i = list.indexOf(model.xAxisDescription);
    if (i < 0) {
      model.xAxisDescription =
          WavePacketAxisDescriptions.defaultXAxisDescription;
    } else if (i < list.length - 1) {
      model.xAxisDescription = list[i + 1];
    }
    notifyListeners();
  }

  void zoomOut() {
    final list = WavePacketAxisDescriptions.xAxisDescriptions;
    final i = list.indexOf(model.xAxisDescription);
    if (i < 0) {
      model.xAxisDescription =
          WavePacketAxisDescriptions.defaultXAxisDescription;
    } else if (i > 0) {
      model.xAxisDescription = list[i - 1];
    }
    notifyListeners();
  }

  void cycleAmplitudesYZoom() {
    final n = WavePacketAxisDescriptions.amplitudesYAxisDescriptions.length;
    model.amplitudesYAxisDescriptionIndex =
        (model.amplitudesYAxisDescriptionIndex + 1) % n;
    notifyListeners();
  }

  List<double> get componentSpacingValues => WavePacket.componentSpacingValues;

  void reset() {
    model.reset();
    notifyListeners();
  }
}
