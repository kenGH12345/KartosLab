/// BodyInfo snapshot. [MSS] `solar-system-common` BodyInfo 字段子集。
library;

import 'mss_vec.dart';

class BodyInfo {
  const BodyInfo({
    required this.mass,
    required this.position,
    required this.velocity,
    this.isActive = true,
  });

  final double mass;
  final MssVec position;
  final MssVec velocity;
  final bool isActive;

  factory BodyInfo.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] as Map<String, dynamic>;
    final vel = json['velocity'] as Map<String, dynamic>;
    return BodyInfo(
      mass: (json['mass'] as num).toDouble(),
      position: MssVec(
        (pos['x'] as num).toDouble(),
        (pos['y'] as num).toDouble(),
      ),
      velocity: MssVec(
        (vel['x'] as num).toDouble(),
        (vel['y'] as num).toDouble(),
      ),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
