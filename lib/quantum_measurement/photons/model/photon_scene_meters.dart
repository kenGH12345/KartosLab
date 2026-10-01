/// Meter-space geometry for Photons experiment — PhotonsExperimentSceneModel.ts
library;

import 'dart:math' as math;

/// Distances from PhotonsExperimentSceneModel.ts
const laserToBeamSplitterDistance = 0.15;
const beamSplitterToMirrorDistance = 0.11;
const totalPhotonPathLength = 0.35; // 0.15 + 0.11 + 0.09
const pbsSizeMeters = 0.07;
const photonBeamWidthMeters = 0.04;
const mirrorLengthMeters = 0.095;
const photonSpeedMetersPerSecond = 0.3;
const maxPhotonEmissionRate = 200.0;
const slowMotionTimeScale = 0.4;

class PhotonVec2 {
  const PhotonVec2(this.x, this.y);
  final double x;
  final double y;

  PhotonVec2 operator +(PhotonVec2 o) => PhotonVec2(x + o.x, y + o.y);
  PhotonVec2 operator -(PhotonVec2 o) => PhotonVec2(x - o.x, y - o.y);
  PhotonVec2 scaled(double s) => PhotonVec2(x * s, y * s);
  double get length => math.sqrt(x * x + y * y);
  PhotonVec2 get normalized {
    final len = length;
    if (len == 0) return const PhotonVec2(0, 0);
    return scaled(1 / len);
  }

  static const zero = PhotonVec2(0, 0);
  static const up = PhotonVec2(0, 1);
  static const down = PhotonVec2(0, -1);
  static const left = PhotonVec2(-1, 0);
  static const right = PhotonVec2(1, 0);
}

class PhotonLineSegment {
  const PhotonLineSegment(this.start, this.end);
  final PhotonVec2 start;
  final PhotonVec2 end;
}

/// Fixed apparatus positions in meters (PBS at origin).
class PhotonsSceneMeters {
  const PhotonsSceneMeters();

  PhotonVec2 get laser =>
      const PhotonVec2(-laserToBeamSplitterDistance, 0);
  PhotonVec2 get pbs => PhotonVec2.zero;
  PhotonVec2 get mirror =>
      const PhotonVec2(beamSplitterToMirrorDistance, 0);

  /// Vertical detector (looking up).
  PhotonVec2 get verticalDetector => PhotonVec2(
        0,
        totalPhotonPathLength - laserToBeamSplitterDistance,
      );

  /// Horizontal detector after mirror (looking down).
  PhotonVec2 get horizontalDetector => PhotonVec2(
        beamSplitterToMirrorDistance,
        -(totalPhotonPathLength -
            laserToBeamSplitterDistance -
            beamSplitterToMirrorDistance),
      );

  PhotonLineSegment get pbsSurface {
    final half = pbsSizeMeters / 2;
    return PhotonLineSegment(
      PhotonVec2(-half, -half),
      PhotonVec2(half, half),
    );
  }

  PhotonLineSegment get mirrorSurface {
    final half = mirrorLengthMeters / 2;
    final c = mirror;
    final a = math.pi / 4;
    // endpoints: center ± (half,0) rotated -π/4
    final dx = half * math.cos(-a);
    final dy = half * math.sin(-a);
    return PhotonLineSegment(
      PhotonVec2(c.x + dx, c.y + dy),
      PhotonVec2(c.x - dx, c.y - dy),
    );
  }

  double get apertureDiameter => photonBeamWidthMeters * 1.75;
  double get apertureHeight => 0.05;

  PhotonLineSegment detectorDetectionLine(PhotonVec2 position) {
    final half = apertureDiameter / 2;
    return PhotonLineSegment(
      PhotonVec2(position.x - half, position.y),
      PhotonVec2(position.x + half, position.y),
    );
  }

  PhotonLineSegment detectorAbsorptionLine(
    PhotonVec2 position, {
    required bool lookingUp,
  }) {
    final half = apertureDiameter / 2;
    final yOff = lookingUp ? apertureHeight : -apertureHeight;
    return PhotonLineSegment(
      PhotonVec2(position.x - half, position.y + yOff),
      PhotonVec2(position.x + half, position.y + yOff),
    );
  }
}

/// Segment intersection (dot.js lineSegmentIntersection). Returns null if none.
PhotonVec2? lineSegmentIntersection(
  PhotonVec2 a1,
  PhotonVec2 a2,
  PhotonVec2 b1,
  PhotonVec2 b2,
) {
  final x1 = a1.x, y1 = a1.y, x2 = a2.x, y2 = a2.y;
  final x3 = b1.x, y3 = b1.y, x4 = b2.x, y4 = b2.y;
  final den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
  if (den.abs() < 1e-14) return null;
  final t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den;
  final u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den;
  if (t < 0 || t > 1 || u < 0 || u > 1) return null;
  return PhotonVec2(x1 + t * (x2 - x1), y1 + t * (y2 - y1));
}
