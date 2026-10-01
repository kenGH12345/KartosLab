import '../fmw_constants.dart';
import 'domain.dart';

/// Axis zoom description. PhET `AxisDescription.ts`
class AxisDescription {
  const AxisDescription({
    required this.rangeMin,
    required this.rangeMax,
    required this.gridLineSpacing,
    required this.tickMarkSpacing,
    required this.tickLabelSpacing,
  });

  /// Coefficient (or absolute) min for the axis range.
  final double rangeMin;

  /// Coefficient (or absolute) max for the axis range.
  final double rangeMax;

  final double gridLineSpacing;
  final double tickMarkSpacing;
  final double tickLabelSpacing;

  double get rangeLength => rangeMax - rangeMin;

  bool get hasSymmetricRange => (rangeMin + rangeMax) == 0;

  /// Scale coefficients by [scale] (L, T, or π depending on context).
  (double min, double max) createRange(double scale) {
    return (rangeMin * scale, rangeMax * scale);
  }

  /// PhET `AxisDescription.createRangeForDomain`.
  (double min, double max) createRangeForDomain(
    Domain domain,
    double spaceMultiplier,
    double timeMultiplier,
  ) {
    final value = domain == Domain.time ? timeMultiplier : spaceMultiplier;
    return createRange(value);
  }

  static bool isSortedDescending(List<AxisDescription> descriptions) {
    for (var i = 1; i < descriptions.length; i++) {
      if (descriptions[i - 1].rangeLength <= descriptions[i].rangeLength) {
        return false;
      }
    }
    return true;
  }

  static AxisDescription getBestFit(
    double rangeMax,
    List<AxisDescription> axisDescriptions,
  ) {
    for (final d in axisDescriptions) {
      if (rangeMax >= d.rangeMax) return d;
    }
    return axisDescriptions.last;
  }
}

/// Discrete / Wave Game axis presets. PhET `DiscreteAxisDescriptions.ts`
class DiscreteAxisDescriptions {
  DiscreteAxisDescriptions._();

  static const AxisDescription defaultXAxisDescription = AxisDescription(
    rangeMin: -1 / 2,
    rangeMax: 1 / 2,
    gridLineSpacing: 1 / 8,
    tickMarkSpacing: 1 / 4,
    tickLabelSpacing: 1 / 4,
  );

  static const AxisDescription defaultYAxisDescription = AxisDescription(
    rangeMin: -FmwConstants.maxAmplitude,
    rangeMax: FmwConstants.maxAmplitude,
    gridLineSpacing: 0.5,
    tickMarkSpacing: 0.5,
    tickLabelSpacing: 0.5,
  );

  /// X coefficients for L or T. Zoomed-out → zoomed-in.
  static const List<AxisDescription> xAxisDescriptions = [
    AxisDescription(
      rangeMin: -2,
      rangeMax: 2,
      gridLineSpacing: 1 / 8,
      tickMarkSpacing: 1 / 4,
      tickLabelSpacing: 1 / 2,
    ),
    AxisDescription(
      rangeMin: -3 / 2,
      rangeMax: 3 / 2,
      gridLineSpacing: 1 / 8,
      tickMarkSpacing: 1 / 4,
      tickLabelSpacing: 1 / 2,
    ),
    AxisDescription(
      rangeMin: -1,
      rangeMax: 1,
      gridLineSpacing: 1 / 8,
      tickMarkSpacing: 1 / 4,
      tickLabelSpacing: 1 / 4,
    ),
    AxisDescription(
      rangeMin: -3 / 4,
      rangeMax: 3 / 4,
      gridLineSpacing: 1 / 8,
      tickMarkSpacing: 1 / 4,
      tickLabelSpacing: 1 / 4,
    ),
    defaultXAxisDescription,
  ];

  static const List<AxisDescription> yAxisDescriptions = [
    AxisDescription(
      rangeMin: -5,
      rangeMax: 5,
      gridLineSpacing: 1,
      tickMarkSpacing: 5,
      tickLabelSpacing: 5,
    ),
    AxisDescription(
      rangeMin: -4,
      rangeMax: 4,
      gridLineSpacing: 1,
      tickMarkSpacing: 2,
      tickLabelSpacing: 2,
    ),
    AxisDescription(
      rangeMin: -2,
      rangeMax: 2,
      gridLineSpacing: 1,
      tickMarkSpacing: 1,
      tickLabelSpacing: 1,
    ),
    defaultYAxisDescription,
  ];
}

/// Wave Packet axis presets. PhET `WavePacketAxisDescriptions.ts`
class WavePacketAxisDescriptions {
  WavePacketAxisDescriptions._();

  static const AxisDescription defaultXAxisDescription = AxisDescription(
    rangeMin: -2,
    rangeMax: 2,
    gridLineSpacing: 0.5,
    tickMarkSpacing: 0.5,
    tickLabelSpacing: 0.5,
  );

  /// Coefficients of π for Amplitudes chart x-axis.
  static const AxisDescription amplitudesXAxisDescription = AxisDescription(
    rangeMin: 0,
    rangeMax: 24,
    gridLineSpacing: 24,
    tickMarkSpacing: 1,
    tickLabelSpacing: 2,
  );

  static const List<AxisDescription> xAxisDescriptions = [
    AxisDescription(
      rangeMin: -8,
      rangeMax: 8,
      gridLineSpacing: 1,
      tickMarkSpacing: 1,
      tickLabelSpacing: 1,
    ),
    AxisDescription(
      rangeMin: -4,
      rangeMax: 4,
      gridLineSpacing: 1,
      tickMarkSpacing: 0.5,
      tickLabelSpacing: 1,
    ),
    defaultXAxisDescription,
    AxisDescription(
      rangeMin: -1,
      rangeMax: 1,
      gridLineSpacing: 0.5,
      tickMarkSpacing: 0.1,
      tickLabelSpacing: 0.5,
    ),
    AxisDescription(
      rangeMin: -0.5,
      rangeMax: 0.5,
      gridLineSpacing: 0.1,
      tickMarkSpacing: 0.1,
      tickLabelSpacing: 0.1,
    ),
  ];

  static const List<AxisDescription> amplitudesYAxisDescriptions = [
    AxisDescription(
      rangeMin: 0,
      rangeMax: 1,
      gridLineSpacing: 1,
      tickMarkSpacing: 0.5,
      tickLabelSpacing: 1,
    ),
    AxisDescription(
      rangeMin: 0,
      rangeMax: 0.5,
      gridLineSpacing: 0.2,
      tickMarkSpacing: 0.1,
      tickLabelSpacing: 0.2,
    ),
    AxisDescription(
      rangeMin: 0,
      rangeMax: 0.05,
      gridLineSpacing: 0.05,
      tickMarkSpacing: 0.01,
      tickLabelSpacing: 0.05,
    ),
    AxisDescription(
      rangeMin: 0,
      rangeMax: 0.02,
      gridLineSpacing: 0.01,
      tickMarkSpacing: 0.005,
      tickLabelSpacing: 0.01,
    ),
    AxisDescription(
      rangeMin: 0,
      rangeMax: 0.01,
      gridLineSpacing: 0.005,
      tickMarkSpacing: 0.001,
      tickLabelSpacing: 0.005,
    ),
  ];

  static const AxisDescription sumYAxisDescription = AxisDescription(
    rangeMin: -1.1,
    rangeMax: 1.1,
    gridLineSpacing: 1,
    tickMarkSpacing: 1,
    tickLabelSpacing: 1,
  );
}
