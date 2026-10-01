/// Nominal photon path segments in meters (for tests / documentation).
library;

import '../model/photon_scene_meters.dart';

enum PhotonPathBranch { vertical, horizontal }

class PhotonTrajectorySpec {
  const PhotonTrajectorySpec({this.meters = const PhotonsSceneMeters()});

  final PhotonsSceneMeters meters;

  /// Laser → PBS (always).
  List<PhotonVec2> approach() => [meters.laser, meters.pbs];

  /// Classical / quantum vertical branch after PBS.
  List<PhotonVec2> verticalBranch() => [meters.pbs, meters.verticalDetector];

  /// Transmit → mirror → horizontal detector.
  List<PhotonVec2> horizontalBranch() => [
        meters.pbs,
        meters.mirror,
        meters.horizontalDetector,
      ];

  List<PhotonVec2> fullPath(PhotonPathBranch branch) {
    if (branch == PhotonPathBranch.vertical) {
      return [...approach(), meters.verticalDetector];
    }
    return [...approach(), meters.mirror, meters.horizontalDetector];
  }
}
