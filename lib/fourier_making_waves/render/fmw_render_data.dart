import 'dart:ui';

import 'package:flutter/material.dart';

/// One polyline already mapped into chart-local coordinates.
class FmwPolylineData {
  const FmwPolylineData({
    required this.points,
    required this.color,
    this.strokeWidth = 1.5,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
}

/// Vertical amplitude bar (order 1-based or wave-number keyed).
class FmwAmplitudeBarData {
  const FmwAmplitudeBarData({
    required this.order,
    required this.value,
    required this.color,
    this.waveNumber,
  });

  final int order;
  final double value;
  final Color color;

  /// When set (Wave Packet), bar is placed on k-axis at this wave number.
  final double? waveNumber;
}

/// Horizontal width-indicator (dimensional arrow) in chart view coords.
class FmwWidthIndicatorData {
  const FmwWidthIndicatorData({
    required this.centerView,
    required this.halfWidthView,
    required this.label,
  });

  final Offset centerView;
  final double halfWidthView;
  final String label;
}

/// λ / T calipers overlay in harmonics-chart view coords.
class FmwCalipersData {
  const FmwCalipersData({
    required this.origin,
    required this.measuredWidthView,
    required this.color,
    required this.label,
  });

  /// Left jaw tip (view coords).
  final Offset origin;

  /// Width in view pixels (= modelToViewDeltaX(λₙ or Tₙ)).
  final double measuredWidthView;
  final Color color;
  final String label;
}

/// Period clock overlay for SPACE_AND_TIME.
class FmwPeriodClockData {
  const FmwPeriodClockData({
    required this.center,
    required this.radius,
    required this.percentTime,
    required this.color,
    required this.label,
  });

  final Offset center;
  final double radius;

  /// Fraction of period elapsed: (t % Tₙ) / Tₙ ∈ [0,1).
  final double percentTime;
  final Color color;
  final String label;
}

/// Chart frame + polylines for one plot.
class FmwChartRenderData {
  const FmwChartRenderData({
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.gridXSpacing,
    required this.gridYSpacing,
    required this.polylines,
    this.width = 645,
    this.height = 123,
    this.widthIndicator,
  });

  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final double gridXSpacing;
  final double gridYSpacing;
  final List<FmwPolylineData> polylines;
  final double width;
  final double height;
  final FmwWidthIndicatorData? widthIndicator;
}

/// Discrete screen render DTO.
class DiscreteRenderData {
  const DiscreteRenderData({
    required this.bars,
    required this.amplitudesYMin,
    required this.amplitudesYMax,
    required this.harmonicsChart,
    required this.sumChart,
    required this.numberOfHarmonics,
    this.wavelengthCalipers,
    this.periodCalipers,
    this.periodClock,
    this.equationText = '',
  });

  final List<FmwAmplitudeBarData> bars;
  final double amplitudesYMin;
  final double amplitudesYMax;
  final FmwChartRenderData harmonicsChart;
  final FmwChartRenderData sumChart;
  final int numberOfHarmonics;
  final FmwCalipersData? wavelengthCalipers;
  final FmwCalipersData? periodCalipers;
  final FmwPeriodClockData? periodClock;
  final String equationText;
}

/// Wave Game in-level render DTO.
class WaveGameRenderData {
  const WaveGameRenderData({
    required this.bars,
    required this.amplitudesYMin,
    required this.amplitudesYMax,
    required this.harmonicsChart,
    required this.sumChart,
    required this.numberOfAmplitudeControls,
    required this.isSolved,
    required this.isMatched,
  });

  final List<FmwAmplitudeBarData> bars;
  final double amplitudesYMin;
  final double amplitudesYMax;
  final FmwChartRenderData harmonicsChart;
  final FmwChartRenderData sumChart;
  final int numberOfAmplitudeControls;
  final bool isSolved;
  final bool isMatched;
}

/// Wave Packet screen render DTO.
class WavePacketRenderData {
  const WavePacketRenderData({
    required this.amplitudeBars,
    required this.amplitudesYMin,
    required this.amplitudesYMax,
    required this.amplitudesXMin,
    required this.amplitudesXMax,
    required this.continuousPolyline,
    required this.amplitudesWidthIndicator,
    required this.componentsChart,
    required this.sumChart,
  });

  final List<FmwAmplitudeBarData> amplitudeBars;
  final double amplitudesYMin;
  final double amplitudesYMax;
  final double amplitudesXMin;
  final double amplitudesXMax;
  final List<Offset> continuousPolyline;
  final FmwWidthIndicatorData? amplitudesWidthIndicator;
  final FmwChartRenderData componentsChart;
  final FmwChartRenderData sumChart;
}
