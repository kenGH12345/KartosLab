/// Minimal Simulation Module Contract — KartosLab platform boundary.
///
/// Home / Registry own navigation + metadata.
/// Simulations own physics / view / animation.
library;

import 'package:flutter/widgets.dart';

/// Stable product identity for a simulation module.
class SimulationDescriptor {
  const SimulationDescriptor({
    required this.id,
    required this.title,
    required this.category,
    required this.builder,
    this.subtitle = '',
    this.enabled = true,
    this.iconAsset,
    this.sourceVersion,
  });

  /// Stable ID — e.g. `quantum-measurement`. Never vary casing/aliases.
  final String id;
  final String title;
  final String category;
  final String subtitle;
  final WidgetBuilder builder;
  final bool enabled;
  final String? iconAsset;

  /// PhET / upstream sim version string when known (not app package version).
  final String? sourceVersion;
}
