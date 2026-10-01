import '../pl_constants.dart';
import '../pl_strings.dart';

/// Gravitational body. Source: `Body.js`.
enum PlBody {
  moon,
  earth,
  jupiter,
  planetX,
  custom,
}

extension PlBodyData on PlBody {
  String get title => switch (this) {
        PlBody.moon => PlStrings.moon,
        PlBody.earth => PlStrings.earth,
        PlBody.jupiter => PlStrings.jupiter,
        PlBody.planetX => PlStrings.planetX,
        PlBody.custom => PlStrings.custom,
      };

  /// null for Custom.
  double? get gravity => switch (this) {
        PlBody.moon => PlConstants.moonGravity,
        PlBody.earth => PlConstants.earthGravity,
        PlBody.jupiter => PlConstants.jupiterGravity,
        PlBody.planetX => PlConstants.planetXGravity,
        PlBody.custom => null,
      };

  static const List<PlBody> bodies = [
    PlBody.moon,
    PlBody.earth,
    PlBody.jupiter,
    PlBody.planetX,
    PlBody.custom,
  ];

  static PlBody? matchingGravity(double g) {
    for (final body in bodies) {
      final bg = body.gravity;
      if (bg != null && bg == g) return body;
    }
    return null;
  }
}
