import 'dart:math';

/// Mutable state for the sound wave simulation.
///
/// Holds a 1D amplitude array (like Java Wavefront.amplitude[400]).
/// Each tick shifts the array right and generates a new sine sample at index 0.
class SoundState {
  /// Number of amplitude samples along the propagation axis.
  static const int arrayLength = 400;

  /// Propagation speed in pixels per tick (Java: PROPOGATION_SPEED = 3).
  static const int propagationSpeed = 3;

  /// Max amplitude (maps to max gray-scale deviation; Java: s_maxAmplitude = 1).
  static const double maxAmplitude = 1.0;

  /// The amplitude array -- index 0 = newest, index N-1 = oldest.
  final List<double> _amplitude = List.filled(arrayLength, 0.0);

  /// Current frequency in Hz (display value, Java: s_defaultFrequency = 500).
  double frequency = 500;

  /// Current amplitude multiplier [0, 1] (Java: maxAmplitude).
  double amplitude = 0.5;

  /// Sim time accumulator (seconds).
  double _time = 0;

  /// Speaker position in logical pixels.
  double speakerX;
  double speakerY;

  /// Base radius for the first wave arc (pixels).
  double baseRadius;

  SoundState({
    this.frequency = 500,
    this.amplitude = 0.5,
    this.speakerX = 100,
    this.speakerY = 200,
    this.baseRadius = 80,
  });

  /// Read-only snapshot of the amplitude array (for painting).
  List<double> get amplitudes => _amplitude;

  double get time => _time;

  /// Advance the wave by one dt.
  void stepInTime(double dt) {
    _time += dt;

    final double angularFreq = frequency * 2.0 * pi;

    // Shift existing samples right by propagationSpeed
    for (int i = arrayLength - 1; i >= propagationSpeed; i--) {
      _amplitude[i] = _amplitude[i - propagationSpeed];

      // Spherical attenuation: amplitude falls off with distance (1/r-like).
      // Apply incremental attenuation only to avoid cumulative product.
      // Uses ratio atten(newPos) / atten(oldPos) instead of absolute atten.
      final double distOld = (i - propagationSpeed).toDouble();
      final double distNew = i.toDouble();
      final double attenOld = 1.0 / (1.0 + distOld * 0.003);
      final double attenNew = 1.0 / (1.0 + distNew * 0.003);
      final double ratio = (attenOld > 0) ? (attenNew / attenOld) : attenNew;
      _amplitude[i] *= ratio;
    }

    // Generate new samples at the front
    final double newVal = sin(angularFreq * _time) * amplitude;
    for (int i = 0; i < propagationSpeed; i++) {
      _amplitude[i] = newVal;
    }
  }

  /// Get amplitude at a given distance index (clamped).
  double amplitudeAt(int index) {
    return _amplitude[index.clamp(0, arrayLength - 1)];
  }

  void setFrequency(double hz) {
    frequency = hz.clamp(0, 1000);
  }

  void setAmplitude(double amp) {
    amplitude = amp.clamp(0, 1.0);
  }

  void reset() {
    _time = 0;
    for (int i = 0; i < arrayLength; i++) {
      _amplitude[i] = 0;
    }
  }

  void dispose() {
    reset();
  }
}
