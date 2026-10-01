/// Detector hit domain conventions (must not mix screens).
enum DetectorHitDomain {
  /// Experiment: y ∈ [-1, 1]
  experiment,

  /// High Intensity / Single Particles: y ∈ [0, 1]
  waveRegion,
}

class DetectorHit {
  const DetectorHit({
    required this.x,
    required this.y,
    required this.domain,
  });

  /// Pattern coordinate along the detector (typically ∈ [-1, 1] for both families' x).
  final double x;

  /// Vertical sample coordinate — meaning depends on [domain].
  final double y;

  final DetectorHitDomain domain;
}

/// Bounded hit buffer — model may store up to [maxHits]; renderer may draw fewer.
class HitBuffer {
  HitBuffer({this.maxHits = 25000});

  final int maxHits;
  final List<DetectorHit> _hits = <DetectorHit>[];

  List<DetectorHit> get hits => List<DetectorHit>.unmodifiable(_hits);

  int get length => _hits.length;

  bool get isAtMax => _hits.length >= maxHits;

  bool tryAdd(DetectorHit hit) {
    if (isAtMax) {
      return false;
    }
    _hits.add(hit);
    return true;
  }

  void clear() => _hits.clear();
}
