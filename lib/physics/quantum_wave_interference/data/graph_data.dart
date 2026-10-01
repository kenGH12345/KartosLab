import '../constants/qwi_constants.dart';
import '../domain/hit.dart';

/// Pure graph data — no Flutter Paths/Widgets.
class IntensityGraphData {
  const IntensityGraphData({required this.positions, required this.intensities});

  final List<double> positions;
  final List<double> intensities;
}

class HitsHistogramData {
  HitsHistogramData({
    required this.bins,
    this.binCount = QwiConstants.hitsGraphBinCount,
  }) : assert(bins.length == binCount);

  final int binCount;
  final List<int> bins;

  factory HitsHistogramData.fromHits(List<DetectorHit> hits, {int binCount = QwiConstants.hitsGraphBinCount}) {
    final bins = List<int>.filled(binCount, 0);
    for (final hit in hits) {
      // Map x ∈ [-1,1] → bin
      final t = ((hit.x + 1) / 2).clamp(0.0, 1.0 - 1e-12);
      final index = (t * binCount).floor();
      bins[index]++;
    }
    return HitsHistogramData(bins: bins, binCount: binCount);
  }

  /// Histogram of hits that fall inside the current detector zoom window.
  factory HitsHistogramData.fromHitsInVisibleWindow(
    List<DetectorHit> hits, {
    required double visibleHalfWidthM,
    required double fullHalfWidthM,
    int binCount = QwiConstants.hitsGraphBinCount,
  }) {
    final bins = List<int>.filled(binCount, 0);
    if (visibleHalfWidthM <= 0 || fullHalfWidthM <= 0) {
      return HitsHistogramData(bins: bins, binCount: binCount);
    }
    for (final hit in hits) {
      final physicalX = hit.x * fullHalfWidthM;
      final normalizedVisibleX = physicalX / visibleHalfWidthM;
      if (normalizedVisibleX.abs() > 1) {
        continue;
      }
      final raw = ((normalizedVisibleX + 1) / 2 * binCount).floor();
      final index = raw.clamp(0, binCount - 1);
      bins[index]++;
    }
    return HitsHistogramData(bins: bins, binCount: binCount);
  }
}

/// Graph zoom level property (1…6). Rendering interprets window later.
class GraphZoomState {
  GraphZoomState({this.level = 4, this.minLevel = 1, this.maxLevel = 6});

  int level;
  final int minLevel;
  final int maxLevel;

  void setLevel(int value) {
    level = value.clamp(minLevel, maxLevel);
  }

  void reset({int defaultLevel = 4}) {
    level = defaultLevel.clamp(minLevel, maxLevel);
  }
}
