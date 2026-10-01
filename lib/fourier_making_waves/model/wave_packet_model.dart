import '../solver/fourier_synthesis.dart';
import '../solver/wave_packet_math.dart';
import 'axis_description.dart';
import 'domain.dart';
import 'series_type.dart';
import 'wave_packet.dart';

/// Top-level Wave Packet screen model. PhET `WavePacketModel.ts`
class WavePacketModel {
  WavePacketModel() {
    wavePacket = WavePacket();
  }

  /// SPACE and TIME only (not SPACE_AND_TIME).
  Domain domain = Domain.space;
  SeriesType seriesType = SeriesType.sin;
  bool widthIndicatorsVisible = false;
  bool waveformEnvelopeVisible = true;
  /// PhET default true. `WavePacketAmplitudesChart.continuousWaveformVisibleProperty`
  bool continuousWaveformVisible = true;

  late final WavePacket wavePacket;

  AxisDescription xAxisDescription =
      WavePacketAxisDescriptions.defaultXAxisDescription;

  int amplitudesYAxisDescriptionIndex = 0;

  AxisDescription get amplitudesYAxisDescription =>
      WavePacketAxisDescriptions.amplitudesYAxisDescriptions[
          amplitudesYAxisDescriptionIndex];

  void setDomain(Domain value) {
    assert(value == Domain.space || value == Domain.time);
    domain = value;
  }

  void reset() {
    domain = Domain.space;
    seriesType = SeriesType.sin;
    widthIndicatorsVisible = false;
    waveformEnvelopeVisible = true;
    continuousWaveformVisible = true;
    xAxisDescription = WavePacketAxisDescriptions.defaultXAxisDescription;
    amplitudesYAxisDescriptionIndex = 0;
    wavePacket.reset();
  }

  /// Continuous waveform samples for Amplitudes chart (empty if hidden).
  List<FmwPoint> createContinuousWaveformDataSet() {
    if (!continuousWaveformVisible) return const [];
    return WavePacketMath.createContinuousWaveformDataSet(
      center: wavePacket.center,
      standardDeviation: wavePacket.standardDeviation,
      componentSpacing: wavePacket.componentSpacing,
      waveNumberMin: WavePacket.waveNumberMin,
      waveNumberMax: WavePacket.waveNumberMax,
    );
  }

  /// Finite component waveforms, or empty when spacing is 0 (infinite).
  List<List<FmwPoint>> createComponentDataSets() {
    final components = wavePacket.components;
    if (components.isEmpty) return const [];
    final xRange = xAxisDescription.createRange(1);
    return WavePacketMath.createComponentsDataSets(
      components: components,
      componentSpacing: wavePacket.componentSpacing,
      domain: domain,
      seriesType: seriesType,
      xMin: xRange.$1,
      xMax: xRange.$2,
    );
  }

  /// Sum data set (finite components or infinite analytic packet).
  List<FmwPoint> createSumDataSet() {
    final xRange = xAxisDescription.createRange(1);
    if (wavePacket.hasInfiniteComponents) {
      return WavePacketMath.createWavePacketDataSet(
        center: wavePacket.center,
        conjugateStandardDeviation: wavePacket.conjugateStandardDeviation,
        seriesType: seriesType,
        xMin: xRange.$1,
        xMax: xRange.$2,
      );
    }
    final componentSets = createComponentDataSets();
    if (componentSets.isEmpty) return const [];
    return WavePacketMath.createFiniteSumDataSet(componentSets);
  }

  /// Envelope data set when visible; empty otherwise.
  List<FmwPoint> createEnvelopeDataSet() {
    if (!waveformEnvelopeVisible) return const [];
    final xRange = xAxisDescription.createRange(1);

    if (wavePacket.hasInfiniteComponents) {
      final sinSet = WavePacketMath.createWavePacketDataSet(
        center: wavePacket.center,
        conjugateStandardDeviation: wavePacket.conjugateStandardDeviation,
        seriesType: SeriesType.sin,
        xMin: xRange.$1,
        xMax: xRange.$2,
      );
      final cosSet = WavePacketMath.createWavePacketDataSet(
        center: wavePacket.center,
        conjugateStandardDeviation: wavePacket.conjugateStandardDeviation,
        seriesType: SeriesType.cos,
        xMin: xRange.$1,
        xMax: xRange.$2,
      );
      return WavePacketMath.createEnvelopeDataSet(sinSet, cosSet);
    }

    final components = wavePacket.components;
    if (components.isEmpty) return const [];

    final sinSets = WavePacketMath.createComponentsDataSets(
      components: components,
      componentSpacing: wavePacket.componentSpacing,
      domain: domain,
      seriesType: SeriesType.sin,
      xMin: xRange.$1,
      xMax: xRange.$2,
    );
    final cosSets = WavePacketMath.createComponentsDataSets(
      components: components,
      componentSpacing: wavePacket.componentSpacing,
      domain: domain,
      seriesType: SeriesType.cos,
      xMin: xRange.$1,
      xMax: xRange.$2,
    );
    return WavePacketMath.createEnvelopeDataSet(
      WavePacketMath.createFiniteSumDataSet(sinSets),
      WavePacketMath.createFiniteSumDataSet(cosSets),
    );
  }
}
