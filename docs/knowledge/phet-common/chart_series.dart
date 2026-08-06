import 'dart:ui';

/// 图表上的一条数据线（如 "位置 x" 或 "速度 v"）。
class ChartSeries {
  final String title;
  final String abbr;
  final String unit;
  final Color color;
  final double strokeWidth;
  final bool visible;
  final bool editable;
  final String? character;

  const ChartSeries({
    required this.title,
    required this.color,
    this.abbr = '',
    this.unit = '',
    this.strokeWidth = 2.0,
    this.visible = true,
    this.editable = false,
    this.character,
  });
}

/// 时间序列上的一个数据点。
class TimeDataPoint {
  final double time;
  final double value;
  const TimeDataPoint(this.time, this.value);
}

/// 为 Chart 提供数据。由 Model 层实现。
abstract class SeriesDataProvider {
  List<TimeDataPoint> getAllPoints();
  List<TimeDataPoint> getRecentPoints(int count);
  void clear();
}

/// 简单的内存缓存实现。
class MemorySeriesDataProvider implements SeriesDataProvider {
  final List<TimeDataPoint> _points = [];

  void add(TimeDataPoint p) => _points.add(p);

  @override
  List<TimeDataPoint> getAllPoints() => List.unmodifiable(_points);

  @override
  List<TimeDataPoint> getRecentPoints(int count) {
    final start = _points.length > count ? _points.length - count : 0;
    return List.unmodifiable(_points.sublist(start));
  }

  @override
  void clear() => _points.clear();
}
