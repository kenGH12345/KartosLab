import 'dart:ui';

import '../pm_constants.dart';
import 'data_point.dart';
import 'trajectory.dart';

/// PhET `DataProbe.ts`：数据探针（tracer）。
/// 可读点规则（DataProbe.ts:104-108, 118-122）：
/// apex / 地面点 / time*1000 整除 100ms 的点。
class PmDataProbe {
  PmDataProbe({
    required List<PmTrajectory> Function() trajectories,
    required double Function() zoom,
  })  : _trajectories = trajectories,
        _zoom = zoom;

  final List<PmTrajectory> Function() _trajectories;
  final double Function() _zoom;

  Offset position = const Offset(10, 10);
  PmDataPoint? dataPoint;
  bool isActive = false;

  void reset() {
    position = const Offset(10, 10);
    dataPoint = null;
    isActive = false;
  }

  bool _withinTolerance(Offset p) =>
      (p - position).distance <=
      PmConstants.dataProbeSensingRadius / _zoom();

  static bool _isReadable(PmDataPoint point) =>
      point.apex ||
      point.position.dy == 0 ||
      (point.time * 1000).round() %
              (PmConstants.timePerMinorDot * 1000).round() ==
          0;

  /// DataProbe.ts:95-112 — 从新到旧遍历轨迹，apex 优先
  void updateData() {
    final trajectories = _trajectories();
    for (var i = trajectories.length - 1; i >= 0; i--) {
      final trajectory = trajectories[i];
      final apex = trajectory.apexPoint;
      if (apex != null && _withinTolerance(apex.position)) {
        dataPoint = apex;
        return;
      }
      final point = trajectory.getNearestPoint(position.dx, position.dy);
      if (point != null && _isReadable(point) && _withinTolerance(point.position)) {
        dataPoint = point;
        return;
      }
    }
    dataPoint = null;
  }

  /// DataProbe.ts:117-123 — 新数据点产生时增量更新
  void updateDataIfWithinRange(PmDataPoint point) {
    if (_isReadable(point) && _withinTolerance(point.position)) {
      dataPoint = point;
    }
  }
}
