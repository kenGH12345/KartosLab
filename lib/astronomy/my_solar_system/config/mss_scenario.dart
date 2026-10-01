/// Orbital-system scenario. Data from JSON, not if/else.
///
/// [MSS] `OrbitalSystem.ts` + ComboBox `visible`.
library;

import '../model/body_info.dart';

class MssScenario {
  const MssScenario({
    required this.scenarioId,
    required this.name,
    required this.comboVisible,
    required this.bodies,
    this.gravityForceScalePower,
  });

  final String scenarioId;
  final String name;

  /// [MSS] ComboBox item `visible`. OS1–4 = false.
  final bool comboVisible;
  final List<BodyInfo> bodies;

  /// [MSS] Four Star Ballet sets -1.1 after load. Null = reset to 0.
  final double? gravityForceScalePower;

  factory MssScenario.fromJson(Map<String, dynamic> json) {
    return MssScenario(
      scenarioId: json['scenarioId'] as String,
      name: json['name'] as String,
      comboVisible: json['comboVisible'] as bool? ?? true,
      gravityForceScalePower:
          (json['gravityForceScalePower'] as num?)?.toDouble(),
      bodies: [
        for (final raw in json['bodies'] as List<dynamic>? ?? const [])
          BodyInfo.fromJson(raw as Map<String, dynamic>),
      ],
    );
  }
}
