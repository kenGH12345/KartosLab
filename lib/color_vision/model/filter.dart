/// Filter type for the single-bulb screen.
enum FilterType { none, red, green, blue, custom }

/// A color filter that selectively transmits light.
///
/// [type] determines preset pass rates.
/// For [FilterType.custom], [customR], [customG], [customB] define
/// per-channel pass rates (0.0 = completely blocked, 1.0 = fully passed).
class Filter {
  final FilterType type;
  final double customR;
  final double customG;
  final double customB;

  const Filter({
    this.type = FilterType.none,
    this.customR = 1.0,
    this.customG = 1.0,
    this.customB = 1.0,
  });

  /// Pass rates for (R, G, B) channels based on filter type.
  (double, double, double) get passRates {
    switch (type) {
      case FilterType.none:
        return (1.0, 1.0, 1.0);
      case FilterType.red:
        return (1.0, 0.0, 0.0);
      case FilterType.green:
        return (0.0, 1.0, 0.0);
      case FilterType.blue:
        return (0.0, 0.0, 1.0);
      case FilterType.custom:
        return (customR, customG, customB);
    }
  }
}
