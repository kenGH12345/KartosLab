import 'dart:math';

/// Mutable state for the radio-waves simulation.
///
/// Models an oscillating electron on a transmitting antenna.
/// The electric field propagates outward from the antenna at the speed of light,
/// with amplitude proportional to the electron's acceleration at retarded time.
class RadioState {
  /// Antenna position (base center).
  double antennaX = 120;
  double antennaY = 220;

  /// Antenna half-length (total = 2 * halfLength).
  double antennaHalfLength = 80;

  /// Current electron Y position on the antenna.
  double get electronY => _electronY;
  double _electronY = 0;

  /// Frequency
  /// Frequency in display units (maps roughly to electron oscillation speed).
  double frequency = 0.5;

  /// Amplitude multiplier [0, 1].
  double amplitude = 0.5;

  /// Sim time accumulator.
  double time = 0;

  /// Static field enabled (Coulomb field, 1/r^2).
  bool staticFieldEnabled = true;

  /// Dynamic field enabled (acceleration field, propagating wave).
  bool dynamicFieldEnabled = true;

  /// Display curve through field arrow tips.
  bool showCurve = true;

  /// Display field arrows along X-axis.
  bool showArrows = true;

  /// Number of field sample points along X-axis.
  static const int numFieldSamples = 40;

  /// Spacing between field samples in pixels.
  double fieldSampleSpacing = 18;

  /// Field values at each sample point (Y component of field vector).
  final List<double> _fieldValues = List.filled(numFieldSamples, 0.0);

  List<double> get fieldValues => _fieldValues;

  void stepInTime(double dt) {
    time += dt;

    if (dynamicFieldEnabled) {
      _electronY = sin(time * frequency * 2.0 * pi) * amplitude * antennaHalfLength * 0.9;
    } else {
      _electronY = 0;
    }

    // Fill field values at each sample point with retarded propagation
    final speed = 12.0; // pixels per sim-time unit (retardation speed)
    for (int i = 0; i < numFieldSamples; i++) {
      double distance = fieldSampleSpacing * (i + 1);
      double retardation = distance / speed;

      if (retardation > time) {
        _fieldValues[i] = 0;
      } else {
        // Field = retarded acceleration * attenuation
        double retardedTime = time - retardation;
        double retardedPhase = retardedTime * frequency * 2.0 * pi;
        double retardedAccel = -sin(retardedPhase) * amplitude * antennaHalfLength * 0.9 * frequency * frequency * 4 * pi * pi;
        double attenuation = 1.0 / (1.0 + distance * 0.003);
        _fieldValues[i] = retardedAccel * attenuation * 0.00005;
      }
    }
  }

  void setFrequency(double f) => frequency = f.clamp(0.01, 2.0);
  void setAmplitude(double a) => amplitude = a.clamp(0, 1.0);
  void toggleStaticField() => staticFieldEnabled = !staticFieldEnabled;
  void toggleDynamicField() => dynamicFieldEnabled = !dynamicFieldEnabled;
  void toggleCurve() => showCurve = !showCurve;
  void toggleArrows() => showArrows = !showArrows;

  void reset() {
    time = 0;
    _electronY = 0;
    for (int i = 0; i < numFieldSamples; i++) { _fieldValues[i] = 0; }
  }
  void dispose() => reset();
}