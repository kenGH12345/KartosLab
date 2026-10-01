/// Visual state snapshot for photon sprites.
library;

import '../model/photon_particle.dart';
import '../model/photon_scene_meters.dart';

class PhotonVisualState {
  const PhotonVisualState({
    required this.positionMeters,
    required this.probability,
  });

  final PhotonVec2 positionMeters;
  final double probability;
}

List<PhotonVisualState> visualStatesFor(PhotonParticle photon) {
  return [
    for (final s in photon.possibleMotionStates)
      PhotonVisualState(
        positionMeters: s.position,
        probability: s.probability,
      ),
  ];
}
