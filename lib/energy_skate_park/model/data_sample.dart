import 'package:kratos/energy_skate_park/model/esp_vec.dart';
import 'package:kratos/energy_skate_park/model/skater_state.dart';
import 'package:kratos/energy_skate_park/model/track.dart';

/// Snapshot from EnergySkateParkDataSample.ts.
class DataSample {
  DataSample({
    required this.skaterState,
    required this.friction,
    required this.time,
    required this.stickingToTrack,
    this.fadeDecay = 0.95,
  })  : speed = skaterState.getSpeed(),
        referenceHeight = skaterState.referenceHeight,
        positionX = skaterState.positionX,
        positionY = skaterState.positionY,
        track = skaterState.track,
        kineticEnergy = skaterState.getKineticEnergy(),
        potentialEnergy = skaterState.getPotentialEnergy(),
        thermalEnergy = skaterState.thermalEnergy,
        totalEnergy = skaterState.getTotalEnergy(),
        trackControlPointPositions = skaterState.track == null
            ? const <EspVec>[]
            : [
                for (final cp in skaterState.track!.controlPoints)
                  EspVec(cp.x, cp.y),
              ];

  static const double minOpacity = 0.05;

  final SkaterState skaterState;
  final double friction;
  final double time;
  final bool stickingToTrack;
  final double fadeDecay;

  final double speed;
  double referenceHeight;
  final double positionX;
  final double positionY;
  final Track? track;
  final List<EspVec> trackControlPointPositions;

  final double kineticEnergy;
  double potentialEnergy;
  final double thermalEnergy;
  double totalEnergy;

  double opacity = 1;
  bool _initiateRemove = false;
  bool inspected = false;

  EspVec get position => EspVec(positionX, positionY);

  void initiateRemove() => _initiateRemove = true;

  void setNewReferenceHeight(double href) {
    referenceHeight = href;
    potentialEnergy =
        -skaterState.mass * skaterState.gravity * (positionY - href);
    totalEnergy = kineticEnergy + potentialEnergy + thermalEnergy;
  }

  /// Fade when removal initiated; returns true when opacity below threshold.
  bool step(double dt) {
    if (_initiateRemove) {
      opacity *= fadeDecay;
    }
    return opacity < minOpacity;
  }
}
