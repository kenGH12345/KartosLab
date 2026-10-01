import 'dart:ui';

/// Lightweight jump landmark (a11y strings deferred to Phase 2/3).
class JumpPosition {
  const JumpPosition({
    required this.id,
    required this.position,
  });

  final String id;
  final Offset position;
}
