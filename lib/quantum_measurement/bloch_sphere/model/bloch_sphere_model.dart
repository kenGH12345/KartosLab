/// Bloch Sphere screen model — mirrors ComplexBlochSphere + BlochSphereModel.
library;

import 'dart:math' as math;

import '../../common/qm_random.dart';

/// Max precession rate (rad/s) — QuantumMeasurementConstants.MAX_PRECESSION_RATE.
const maxPrecessionRate = math.pi / 2;

enum BlochStateDirection {
  xPlus,
  xMinus,
  yPlus,
  yMinus,
  zPlus,
  zMinus,
  custom;

  double get polarAngle {
    switch (this) {
      case BlochStateDirection.xPlus:
      case BlochStateDirection.xMinus:
      case BlochStateDirection.yPlus:
      case BlochStateDirection.yMinus:
        return math.pi / 2;
      case BlochStateDirection.zPlus:
      case BlochStateDirection.custom:
        return 0;
      case BlochStateDirection.zMinus:
        return math.pi;
    }
  }

  double get azimuthalAngle {
    switch (this) {
      case BlochStateDirection.xPlus:
      case BlochStateDirection.zPlus:
      case BlochStateDirection.zMinus:
      case BlochStateDirection.custom:
        return 0;
      case BlochStateDirection.xMinus:
        return math.pi;
      case BlochStateDirection.yPlus:
        return math.pi / 2;
      case BlochStateDirection.yMinus:
        return 3 * math.pi / 2;
    }
  }
}

enum MeasurementAxis {
  x,
  y,
  z;

  double get polarAngle => this == MeasurementAxis.z ? 0 : math.pi / 2;
  double get azimuthalAngle =>
      this == MeasurementAxis.x ? 0 : this == MeasurementAxis.y ? math.pi / 2 : 0;

  BlochStateDirection get opposite {
    switch (this) {
      case MeasurementAxis.x:
        return BlochStateDirection.xMinus;
      case MeasurementAxis.y:
        return BlochStateDirection.yMinus;
      case MeasurementAxis.z:
        return BlochStateDirection.zMinus;
    }
  }

  BlochStateDirection get plusDirection {
    switch (this) {
      case MeasurementAxis.x:
        return BlochStateDirection.xPlus;
      case MeasurementAxis.y:
        return BlochStateDirection.yPlus;
      case MeasurementAxis.z:
        return BlochStateDirection.zPlus;
    }
  }
}

enum BlochMeasurementState {
  prepared,
  timingObservation,
  observed,
}

class BlochVector3 {
  const BlochVector3(this.x, this.y, this.z);
  final double x, y, z;

  double get magnitude => math.sqrt(x * x + y * y + z * z);

  double dot(BlochVector3 o) => x * o.x + y * o.y + z * o.z;

  static BlochVector3 fromAngles(double polar, double azimuthal) => BlochVector3(
        math.sin(polar) * math.cos(azimuthal),
        math.sin(polar) * math.sin(azimuthal),
        math.cos(polar),
      );
}

/// |ψ⟩ = cos(θ/2)|↑⟩ + e^{iφ} sin(θ/2)|↓⟩  (Z basis)
class QuantumStateAmplitudes {
  QuantumStateAmplitudes(this.theta, this.phi);

  final double theta; // polar
  final double phi; // azimuthal

  double get alpha => math.cos(theta / 2);
  double get betaMagnitude => math.sin(theta / 2);
  double get pUp => alpha * alpha;
  double get pDown => betaMagnitude * betaMagnitude;
}

class ComplexBlochSphere {
  ComplexBlochSphere({
    double initialPolar = 0,
    double initialAzimuthal = math.pi / 2,
  })  : polarAngle = initialPolar,
        azimuthalAngle = initialAzimuthal;

  double polarAngle;
  double azimuthalAngle;
  double rotatingSpeed = 0; // ∈ [-1, 1], scales MAX_PRECESSION_RATE

  BlochVector3 get vector => BlochVector3.fromAngles(polarAngle, azimuthalAngle);

  QuantumStateAmplitudes get zBasisAmplitudes =>
      QuantumStateAmplitudes(polarAngle, azimuthalAngle);

  void setDirection(double polar, double azimuthal) {
    polarAngle = polar;
    azimuthalAngle = azimuthal;
  }

  void step(double dt) {
    final precession = rotatingSpeed * maxPrecessionRate * dt;
    azimuthalAngle = _modulo(azimuthalAngle + precession, 0, 2 * math.pi);
  }

  /// Measure along axis; collapses state to ± eigenstate.
  /// P(up) = (1 + n̂·r̂) / 2  via: isUp = (2U-1) < dot
  bool measure(MeasurementAxis axis, QmRandom random) {
    final measurement = BlochVector3.fromAngles(axis.polarAngle, axis.azimuthalAngle);
    final state = vector;
    final dot = measurement.dot(state);
    final isUp = (random.nextDouble() * 2 - 1) < dot;
    if (isUp) {
      setDirection(axis.polarAngle, axis.azimuthalAngle);
    } else {
      final opp = axis.opposite;
      setDirection(opp.polarAngle, opp.azimuthalAngle);
    }
    return isUp;
  }

  void reset() {
    polarAngle = 0;
    azimuthalAngle = math.pi / 2;
    rotatingSpeed = 0;
  }

  static double _modulo(double v, double min, double max) {
    final range = max - min;
    var x = (v - min) % range;
    if (x < 0) x += range;
    return x + min;
  }
}

class BlochSphereModel {
  BlochSphereModel({QmRandom? random}) : _random = random ?? SystemQmRandom() {
    preparation = ComplexBlochSphere(
      initialPolar: BlochStateDirection.xPlus.polarAngle,
      initialAzimuthal: BlochStateDirection.xPlus.azimuthalAngle,
    );
    singleMeasurement = ComplexBlochSphere(
      initialPolar: preparation.polarAngle,
      initialAzimuthal: preparation.azimuthalAngle,
    );
    multipleMeasurements = List.generate(
      10,
      (_) => ComplexBlochSphere(
        initialPolar: preparation.polarAngle,
        initialAzimuthal: preparation.azimuthalAngle,
      ),
    );
  }

  final QmRandom _random;

  late final ComplexBlochSphere preparation;
  late final ComplexBlochSphere singleMeasurement;
  late final List<ComplexBlochSphere> multipleMeasurements;

  BlochStateDirection spinState = BlochStateDirection.xPlus;
  BlochStateDirection equationBasis = BlochStateDirection.zPlus;
  MeasurementAxis measurementAxis = MeasurementAxis.z;
  BlochMeasurementState measurementState = BlochMeasurementState.prepared;
  bool isSingleMeasurementMode = true;
  bool magneticFieldEnabled = false;
  double magneticFieldStrength = 1.0; // [-1, 1]

  int upMeasurementCount = 0;
  int downMeasurementCount = 0;

  static const maxObservationTime = 2 * math.pi / maxPrecessionRate; // seconds
  static const modelToViewTime = 1 / maxObservationTime;

  double measurementDelay = modelToViewTime * 0.75 * maxObservationTime;
  double timeElapsed = 0;

  void setSpinState(BlochStateDirection direction) {
    spinState = direction;
    if (direction != BlochStateDirection.custom) {
      preparation.setDirection(direction.polarAngle, direction.azimuthalAngle);
      reprepare();
    }
  }

  void setAngles(double polar, double azimuthal) {
    preparation.setDirection(polar, azimuthal);
    spinState = BlochStateDirection.custom;
    resetCounts();
    reprepare();
  }

  void initiateObservation() {
    assert(measurementState == BlochMeasurementState.prepared);
    if (magneticFieldEnabled) {
      measurementState = BlochMeasurementState.timingObservation;
      timeElapsed = 0;
      _updateRotationRates();
    } else {
      _observe();
    }
  }

  void _observe() {
    if (isSingleMeasurementMode) {
      final isUp = singleMeasurement.measure(measurementAxis, _random);
      if (isUp) {
        upMeasurementCount++;
      } else {
        downMeasurementCount++;
      }
    } else {
      for (final sphere in multipleMeasurements) {
        final isUp = sphere.measure(measurementAxis, _random);
        if (isUp) {
          upMeasurementCount++;
        } else {
          downMeasurementCount++;
        }
      }
    }
    measurementState = BlochMeasurementState.observed;
    _updateRotationRates();
  }

  void reprepare() {
    singleMeasurement.setDirection(preparation.polarAngle, preparation.azimuthalAngle);
    for (final s in multipleMeasurements) {
      s.setDirection(preparation.polarAngle, preparation.azimuthalAngle);
    }
    timeElapsed = 0;
    measurementState = BlochMeasurementState.prepared;
    _updateRotationRates();
  }

  /// Erase = clear histogram counts only (not full reset).
  void erase() => resetCounts();

  void resetCounts() {
    upMeasurementCount = 0;
    downMeasurementCount = 0;
  }

  void setMagneticFieldEnabled(bool enabled) {
    magneticFieldEnabled = enabled;
    _updateRotationRates();
  }

  void setMagneticFieldStrength(double strength) {
    magneticFieldStrength = strength.clamp(-1.0, 1.0);
    _updateRotationRates();
  }

  void _updateRotationRates() {
    final rate = measurementState == BlochMeasurementState.timingObservation &&
            magneticFieldEnabled
        ? magneticFieldStrength
        : 0.0;
    singleMeasurement.rotatingSpeed = rate;
    for (final s in multipleMeasurements) {
      s.rotatingSpeed = rate;
    }
  }

  void step(double dt) {
    singleMeasurement.step(dt);
    for (final s in multipleMeasurements) {
      s.step(dt);
    }
    if (measurementState == BlochMeasurementState.timingObservation) {
      timeElapsed = math.min(
        timeElapsed + dt * modelToViewTime,
        measurementDelay,
      );
      if (timeElapsed >= measurementDelay) {
        _observe();
      }
    }
  }

  void reset() {
    resetCounts();
    preparation.reset();
    singleMeasurement.reset();
    for (final s in multipleMeasurements) {
      s.reset();
    }
    magneticFieldEnabled = false;
    magneticFieldStrength = 1.0;
    measurementState = BlochMeasurementState.prepared;
    measurementAxis = MeasurementAxis.z;
    isSingleMeasurementMode = true;
    measurementDelay = modelToViewTime * 0.75 * maxObservationTime;
    timeElapsed = 0;
    spinState = BlochStateDirection.xPlus;
    equationBasis = BlochStateDirection.zPlus;
    setSpinState(BlochStateDirection.xPlus);
  }
}
