/// Snapshot helpers for restart. Not a second source of truth — Controller owns
/// live bodies/engine; this only stores last user-committed BodyInfo.
library;

import 'kl_vec.dart';

class BodyInfo {
  const BodyInfo({
    required this.mass,
    required this.position,
    required this.velocity,
    this.isActive = true,
  });

  final double mass;
  final KlVec position;
  final KlVec velocity;
  final bool isActive;
}
