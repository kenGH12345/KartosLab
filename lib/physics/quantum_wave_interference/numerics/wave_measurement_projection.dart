import 'dart:math' as math;

import 'complex.dart';
import 'field_sample.dart';
import 'wave_kernel_types.dart';
import 'wave_math.dart';

/// Port of `WaveMeasurementProjection.ts`.
const double measurementBiteInitialSaturation = 1.6487212707001282; // Math.exp(0.5)
const double measurementBiteReferenceRadiusToPacketSigmaX = 2 / 3;
const double measurementBiteReferenceSpreadTime = 0.5;
const double measurementBiteMaxSpreadTime = 1.1;
const double measurementBiteEdgeDeficit = 0.02;
const double measurementBiteMaxSuperGaussianExponent = 24;

class MeasurementProjectionSpread {
  const MeasurementProjectionSpread({
    required this.falloffScale,
    required this.deficitStrength,
    required this.exponent,
  });

  final double falloffScale;
  final double deficitStrength;
  final double exponent;
}

/// Applies failed-measurement masks to a gaussian-packet field sample.
FieldSample applyMeasurementProjections(
  FieldSample sample,
  List<MeasurementProjection> projections,
  WaveSource source,
  double x,
  double y,
  double t,
) {
  if (sample is! FieldValueSample || projections.isEmpty || source is! GaussianPacketSource) {
    return sample;
  }

  var scale = 1.0;
  for (final projection in projections) {
    if (t + kWaveEpsilon < projection.measurementTime) {
      continue;
    }
    final mask = getMeasurementProjectionMask(projection, source, x, y, t);
    scale *= mask * projection.renormScale;
    if (scale == 0) {
      break;
    }
  }

  if (scale == 1) {
    return sample;
  }

  return FieldValueSample(
    sample.components.map((component) {
      return FieldComponent(
        source: component.source,
        coherenceGroup: component.coherenceGroup,
        value: Complex(component.value.real * scale, component.value.imaginary * scale),
        support: component.support == null ? null : component.support! * scale,
      );
    }).toList(),
  );
}

double getMeasurementProjectionMask(
  MeasurementProjection projection,
  GaussianPacketSource source,
  double x,
  double y,
  double t,
) {
  final dt = math.max(0.0, t - projection.measurementTime);
  final projectionCenterX = projection.centerX + source.speed * dt;
  final projectionRadius = math.max(projection.radius, kWaveEpsilon);
  final distance = math.sqrt(
    (x - projectionCenterX) * (x - projectionCenterX) + (y - projection.centerY) * (y - projection.centerY),
  );
  final edgeFeather = math.max(projection.edgeFeather ?? 0.0, 0.0);

  if (dt > kWaveEpsilon) {
    final spread = getMeasurementProjectionSpread(source, projectionRadius, dt);
    final deficit =
        spread.deficitStrength * math.exp(-0.5 * math.pow(distance / spread.falloffScale, spread.exponent).toDouble());
    return clampDouble(1 - deficit, 0, 1);
  }

  if (distance >= projectionRadius) {
    return 1;
  }

  return getInitialMeasurementProjectionMask(distance, projectionRadius, edgeFeather);
}

double getInitialMeasurementProjectionMask(double distance, double projectionRadius, double edgeFeather) {
  final saturatedGaussian =
      measurementBiteInitialSaturation * math.exp(-0.5 * math.pow(distance / projectionRadius, 2).toDouble());
  final localMask = math.max(0.0, 1 - saturatedGaussian);
  final boundaryBlend = edgeFeather > kWaveEpsilon
      ? smoothStep(math.max(0.0, projectionRadius - edgeFeather), projectionRadius, distance)
      : 0.0;
  return localMask + (1 - localMask) * boundaryBlend;
}

MeasurementProjectionSpread getMeasurementProjectionSpread(
  GaussianPacketSource source,
  double projectionRadius,
  double dt,
) {
  final referenceRadius = math.max(source.sigmaX0 * measurementBiteReferenceRadiusToPacketSigmaX, kWaveEpsilon);
  final proportionalSpreadTime = measurementBiteReferenceSpreadTime * projectionRadius / referenceRadius;
  final spreadTime = math.max(kWaveEpsilon, math.min(proportionalSpreadTime, measurementBiteMaxSpreadTime));
  final sigma = projectionRadius * math.sqrt(1 + math.pow(dt / spreadTime, 2).toDouble());
  final spreadRatio = projectionRadius / sigma;
  final exponent = 2 + (measurementBiteMaxSuperGaussianExponent - 2) * spreadRatio * spreadRatio;

  return MeasurementProjectionSpread(
    falloffScale: sigma / math.pow(-2 * math.log(measurementBiteEdgeDeficit), 1 / exponent).toDouble(),
    deficitStrength: spreadRatio * spreadRatio,
    exponent: exponent,
  );
}
