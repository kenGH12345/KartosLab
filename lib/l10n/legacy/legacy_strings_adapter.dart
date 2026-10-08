import 'package:kratos/l10n/kartos_localization.dart';

/// Bridge from legacy per-sim `*Strings` bags to [KartosLocalization].
///
/// PHASE 1: adapters exist so simulations can migrate **incrementally**.
/// Do not delete legacy `*Strings` files until a sim reaches LOCALIZED.
///
/// Example:
/// ```dart
/// class DensityStringsAdapter extends LegacyStringsAdapter {
///   @override
///   String resolve(String legacyField) => switch (legacyField) {
///     'resetAll' => loc.common.resetAll,
///     'mass' => loc.physics.mass,
///     _ => loc.resolve('sim.density.$legacyField'),
///   };
/// }
/// ```
abstract class LegacyStringsAdapter {
  const LegacyStringsAdapter();

  /// Map a legacy field name (e.g. `resetAll`) to localized text.
  String resolve(String legacyField);

  /// Optional namespace prefix for documentation / scanners.
  String get namespace;

  KartosLocalization get localization => loc;
}

/// Thin common adapter for shared chrome fields reused across sims.
class CommonLegacyStringsAdapter extends LegacyStringsAdapter {
  const CommonLegacyStringsAdapter();

  @override
  String get namespace => 'common';

  @override
  String resolve(String legacyField) {
    switch (legacyField) {
      case 'resetAll':
      case 'reset_all':
      case 'RESET_ALL':
        return loc.common.resetAll;
      case 'reset':
        return loc.common.reset;
      case 'play':
        return loc.common.play;
      case 'pause':
        return loc.common.pause;
      case 'step':
        return loc.common.step;
      case 'back':
        return loc.common.back;
      case 'close':
        return loc.common.close;
      case 'ok':
      case 'OK':
        return loc.common.ok;
      case 'normal':
        return loc.common.normal;
      case 'slow':
        return loc.common.slow;
      case 'fast':
        return loc.common.fast;
      default:
        return loc.resolve('common.$legacyField');
    }
  }
}
