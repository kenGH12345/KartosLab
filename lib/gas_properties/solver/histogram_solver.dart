import '../gas_properties_constants.dart';
import '../model/particle.dart';
import '../model/particle_type.dart';

/// HistogramsModel + AverageSpeedModel — Energy screen sampling (1 ps).
class EnergySamplingState {
  EnergySamplingState() {
    _emptyBins();
  }

  final int binCount = GasPropertiesConstants.histogramBinCount;
  final double speedBinWidth = GasPropertiesConstants.speedBinWidth;
  final double keBinWidth = GasPropertiesConstants.kineticEnergyBinWidth;

  int zoomLevelIndex = GasPropertiesConstants.defaultHistogramZoomIndex;

  // Averaged outputs
  List<double> heavySpeedBins = [];
  List<double> lightSpeedBins = [];
  List<double> totalSpeedBins = [];
  List<double> heavyKeBins = [];
  List<double> lightKeBins = [];
  List<double> totalKeBins = [];

  double? heavyAverageSpeed;
  double? lightAverageSpeed;

  // Accumulators
  double dtAccumulator = 0;
  int numberOfSamples = 0;
  late List<double> _heavySpeedCum;
  late List<double> _lightSpeedCum;
  late List<double> _heavyKeCum;
  late List<double> _lightKeCum;
  double _heavySpeedSum = 0;
  double _lightSpeedSum = 0;

  double get zoomYMax =>
      GasPropertiesConstants.histogramZoomYMax[zoomLevelIndex];

  void reset() {
    zoomLevelIndex = GasPropertiesConstants.defaultHistogramZoomIndex;
    clearSamples();
    _emptyBins();
    heavyAverageSpeed = null;
    lightAverageSpeed = null;
  }

  void _emptyBins() {
    heavySpeedBins = List.filled(binCount, 0);
    lightSpeedBins = List.filled(binCount, 0);
    totalSpeedBins = List.filled(binCount, 0);
    heavyKeBins = List.filled(binCount, 0);
    lightKeBins = List.filled(binCount, 0);
    totalKeBins = List.filled(binCount, 0);
    _heavySpeedCum = List.filled(binCount, 0);
    _lightSpeedCum = List.filled(binCount, 0);
    _heavyKeCum = List.filled(binCount, 0);
    _lightKeCum = List.filled(binCount, 0);
  }

  void clearSamples() {
    dtAccumulator = 0;
    numberOfSamples = 0;
    _heavySpeedCum = List.filled(binCount, 0);
    _lightSpeedCum = List.filled(binCount, 0);
    _heavyKeCum = List.filled(binCount, 0);
    _lightKeCum = List.filled(binCount, 0);
    _heavySpeedSum = 0;
    _lightSpeedSum = 0;
  }

  void zoomIn() {
    if (zoomLevelIndex < GasPropertiesConstants.histogramZoomYMax.length - 1) {
      zoomLevelIndex++;
    }
  }

  void zoomOut() {
    if (zoomLevelIndex > 0) zoomLevelIndex--;
  }

  /// Bin index for value; out-of-range ignored (PhET).
  static int binIndex(double value, double binWidth, int binCount) {
    final i = (value / binWidth).floor();
    if (i < 0 || i >= binCount) return -1;
    return i;
  }

  void step({
    required double dt,
    required bool isPlaying,
    required List<Particle> heavy,
    required List<Particle> light,
  }) {
    assert(dt > 0);
    dtAccumulator += dt;
    _sample(heavy, light);

    if (dtAccumulator >= GasPropertiesConstants.energySamplePeriodPs ||
        !isPlaying) {
      _updateAverages(heavy, light);
    }
  }

  void _sample(List<Particle> heavy, List<Particle> light) {
    _accumulate(heavy, _heavySpeedCum, _heavyKeCum, speed: true);
    _accumulate(light, _lightSpeedCum, _lightKeCum, speed: true);
    _heavySpeedSum += _meanSpeed(heavy);
    _lightSpeedSum += _meanSpeed(light);
    numberOfSamples++;
  }

  void _accumulate(
    List<Particle> particles,
    List<double> speedCum,
    List<double> keCum, {
    required bool speed,
  }) {
    for (final p in particles) {
      final si = binIndex(p.speed, speedBinWidth, binCount);
      if (si >= 0) speedCum[si]++;
      final ki = binIndex(p.kineticEnergy, keBinWidth, binCount);
      if (ki >= 0) keCum[ki]++;
    }
  }

  double _meanSpeed(List<Particle> particles) {
    if (particles.isEmpty) return 0;
    var s = 0.0;
    for (final p in particles) {
      s += p.speed;
    }
    return s / particles.length;
  }

  void _updateAverages(List<Particle> heavy, List<Particle> light) {
    assert(numberOfSamples > 0);
    final n = numberOfSamples.toDouble();
    heavySpeedBins = _heavySpeedCum.map((c) => c / n).toList();
    lightSpeedBins = _lightSpeedCum.map((c) => c / n).toList();
    totalSpeedBins = [
      for (var i = 0; i < binCount; i++)
        heavySpeedBins[i] + lightSpeedBins[i],
    ];
    heavyKeBins = _heavyKeCum.map((c) => c / n).toList();
    lightKeBins = _lightKeCum.map((c) => c / n).toList();
    totalKeBins = [
      for (var i = 0; i < binCount; i++) heavyKeBins[i] + lightKeBins[i],
    ];

    heavyAverageSpeed = heavy.isEmpty ? null : _heavySpeedSum / n;
    lightAverageSpeed = light.isEmpty ? null : _lightSpeedSum / n;

    clearSamples();
  }
}

/// Convenience for injection temperature range checks.
bool isInjectionTemperatureInRange(double t) =>
    t >= GasPropertiesConstants.injectionTemperatureMin &&
    t <= GasPropertiesConstants.injectionTemperatureMax;

ParticleType? particleTypeOrNull(Particle p) => p.type;
