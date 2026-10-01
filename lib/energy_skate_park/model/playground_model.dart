import 'package:kratos/energy_skate_park/esp_constants.dart';
import 'package:kratos/energy_skate_park/model/control_point.dart';
import 'package:kratos/energy_skate_park/model/esp_model.dart';
import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/track.dart';

/// EnergySkateParkPlaygroundModel.ts — empty tracks; create / clear / join / split.
class PlaygroundModel extends EspModel {
  PlaygroundModel() : super(tracks: []);

  /// Toolbox drag-out: 3-point interactive track (physical immediately).
  /// PhET Track.FULLY_INTERACTIVE_OPTIONS: draggable/configurable/splittable/attachable.
  Track createDraggableTrack({
    double x0 = -1,
    double y0 = 0.5,
  }) {
    final track = Track(
      [
        ControlPoint(x0, y0),
        ControlPoint(x0 + 1, y0),
        ControlPoint(x0 + 2, y0),
      ],
      draggable: true,
      configurable: true,
      splittable: true,
      attachable: true,
      physical: true,
    );
    tracks.add(track);
    return track;
  }

  void clearTracks() {
    tracks.clear();
    if (skater.track != null) {
      skater.track = null;
      skater.parametricSpeed = 0;
    }
  }

  int getNumberOfControlPoints() =>
      tracks.fold(0, (s, t) => s + t.controlPoints.length);

  int getNumberOfPhysicalControlPoints() => getPhysicalTracks()
      .fold(0, (s, t) => s + t.controlPoints.length);

  /// EnergySkateParkModel.canCutTrackControlPoint — soft MAX 15 physical CPs.
  bool canCutTrackControlPoint() =>
      getNumberOfPhysicalControlPoints() < EspConstants.maxNumberControlPoints;

  Track _fullyInteractive(List<ControlPoint> points) => Track(
        points,
        draggable: true,
        configurable: true,
        splittable: true,
        attachable: true,
        physical: true,
      );

  /// Basic join: merge [a] into [b] when endpoints are within [threshold] m.
  /// Returns the joined track, or null if no join.
  Track? joinTracks(Track a, Track b, {double threshold = 0.3}) {
    if (!tracks.contains(a) || !tracks.contains(b)) return null;
    if (identical(a, b)) return null;

    final aStart = a.controlPoints.first;
    final aEnd = a.controlPoints.last;
    final bStart = b.controlPoints.first;
    final bEnd = b.controlPoints.last;

    List<ControlPoint>? merged;

    double dist(ControlPoint p, ControlPoint q) {
      final dx = p.x - q.x;
      final dy = p.y - q.y;
      return dx * dx + dy * dy;
    }

    final thr2 = threshold * threshold;

    if (dist(aEnd, bStart) <= thr2) {
      merged = [
        for (final cp in a.controlPoints) ControlPoint(cp.x, cp.y),
        for (var i = 1; i < b.controlPoints.length; i++)
          ControlPoint(b.controlPoints[i].x, b.controlPoints[i].y),
      ];
    } else if (dist(aEnd, bEnd) <= thr2) {
      merged = [
        for (final cp in a.controlPoints) ControlPoint(cp.x, cp.y),
        for (var i = b.controlPoints.length - 2; i >= 0; i--)
          ControlPoint(b.controlPoints[i].x, b.controlPoints[i].y),
      ];
    } else if (dist(aStart, bEnd) <= thr2) {
      merged = [
        for (final cp in b.controlPoints) ControlPoint(cp.x, cp.y),
        for (var i = 1; i < a.controlPoints.length; i++)
          ControlPoint(a.controlPoints[i].x, a.controlPoints[i].y),
      ];
    } else if (dist(aStart, bStart) <= thr2) {
      merged = [
        for (var i = a.controlPoints.length - 1; i >= 0; i--)
          ControlPoint(a.controlPoints[i].x, a.controlPoints[i].y),
        for (var i = 1; i < b.controlPoints.length; i++)
          ControlPoint(b.controlPoints[i].x, b.controlPoints[i].y),
      ];
    }

    if (merged == null || merged.length < 2) return null;

    final joined = _fullyInteractive(merged);
    tracks.remove(a);
    tracks.remove(b);
    tracks.add(joined);
    if (skater.track == a || skater.track == b) {
      skater.track = null;
    }
    return joined;
  }

  /// EnergySkateParkModel.splitControlPoint — interior CP only; [modelAngle] from
  /// Track.getModelAngleAt. New endpoints offset by createPolar(0.5, angle).
  /// Skips PhET Track.smooth / bumpAboveGround ([行为近似]).
  bool splitControlPoint(Track track, int controlPointIndex, double modelAngle) {
    if (!tracks.contains(track)) return false;
    if (!track.splittable) return false;
    if (controlPointIndex <= 0 ||
        controlPointIndex >= track.controlPoints.length - 1) {
      return false;
    }
    if (!canCutTrackControlPoint()) return false;

    final split = track.controlPoints[controlPointIndex];
    final vector = EspVec.createPolar(0.5, modelAngle);
    final newPoint1 = ControlPoint(split.x - vector.x, split.y - vector.y);
    final newPoint2 = ControlPoint(split.x + vector.x, split.y + vector.y);

    final points1 = <ControlPoint>[
      for (var i = 0; i < controlPointIndex; i++)
        ControlPoint(track.controlPoints[i].x, track.controlPoints[i].y),
      newPoint1,
    ];
    final points2 = <ControlPoint>[
      newPoint2,
      for (var i = controlPointIndex + 1; i < track.controlPoints.length; i++)
        ControlPoint(track.controlPoints[i].x, track.controlPoints[i].y),
    ];

    final newTrack1 = _fullyInteractive(points1);
    final newTrack2 = _fullyInteractive(points2);

    tracks.remove(track);
    tracks.add(newTrack1);
    tracks.add(newTrack2);

    if (skater.track == track) {
      skater.track = null;
    }

    // PhET drops a non-physical toolbox track when over MAX; playground has none.
    while (getNumberOfControlPoints() > EspConstants.maxNumberControlPoints) {
      final nonPhysical = tracks.where((t) => !t.physical).toList();
      if (nonPhysical.isEmpty) break;
      tracks.remove(nonPhysical.first);
    }

    return true;
  }

  /// EnergySkateParkModel.deleteControlPoint — interior preferred; ≤2 CPs removes track.
  bool deleteControlPoint(Track track, int controlPointIndex) {
    if (!tracks.contains(track)) return false;
    if (controlPointIndex < 0 ||
        controlPointIndex >= track.controlPoints.length) {
      return false;
    }

    if (skater.track == track) {
      skater.track = null;
    }

    if (track.controlPoints.length > 2) {
      final points = <ControlPoint>[
        for (var i = 0; i < track.controlPoints.length; i++)
          if (i != controlPointIndex)
            ControlPoint(track.controlPoints[i].x, track.controlPoints[i].y),
      ];
      final newTrack = _fullyInteractive(points);
      // Soft clamp Y ≥ 0 (PhET bumpAboveGround subset).
      for (final cp in newTrack.controlPoints) {
        if (cp.y < 0) cp.y = 0;
      }
      newTrack.updateLinSpace();
      newTrack.updateSplines();
      tracks.remove(track);
      tracks.add(newTrack);
    } else {
      tracks.remove(track);
    }
    return true;
  }

  /// Model angle at a control-point index (linear map to parametric range).
  double modelAngleAtControlPoint(Track track, int controlPointIndex) {
    final n = track.controlPoints.length;
    if (n < 2) return 0;
    final t = controlPointIndex / (n - 1);
    final u = track.minPoint + t * (track.maxPoint - track.minPoint);
    return track.getModelAngleAt(u.clamp(track.minPoint, track.maxPoint));
  }

  /// Parametric u for CP index (ControlPointUI LinearFunction).
  double parametricAtControlPoint(Track track, int controlPointIndex) {
    final n = track.controlPoints.length;
    if (n < 2) return track.minPoint;
    final t = controlPointIndex / (n - 1);
    return track.minPoint + t * (track.maxPoint - track.minPoint);
  }

  @override
  void reset() {
    super.reset();
    clearTracks();
  }
}
