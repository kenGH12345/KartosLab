import 'package:kratos/l10n/kartos_locale.dart';
import 'package:kratos/l10n/namespaces/accessibility_l10n.dart';
import 'package:kratos/l10n/namespaces/chemistry_l10n.dart';
import 'package:kratos/l10n/namespaces/common_l10n.dart';
import 'package:kratos/l10n/namespaces/electricity_l10n.dart';
import 'package:kratos/l10n/namespaces/fluids_l10n.dart';
import 'package:kratos/l10n/namespaces/home_l10n.dart';
import 'package:kratos/l10n/namespaces/mechanics_l10n.dart';
import 'package:kratos/l10n/namespaces/optics_waves_l10n.dart';
import 'package:kratos/l10n/namespaces/physics_l10n.dart';
import 'package:kratos/l10n/namespaces/quantum_l10n.dart';
import 'package:kratos/l10n/namespaces/shared_chrome_l10n.dart';
import 'package:kratos/l10n/namespaces/sim_titles_l10n.dart';

/// Project-level localization entry point.
///
/// Usage:
/// ```dart
/// Text(loc.common.resetAll);
/// Text(loc.home.appTitle);
/// Text(loc.sim.title('bending-light'));
/// ```
///
/// Default locale is Simplified Chinese. Call [KartosLocalization.setLocale]
/// to switch (English kept for future bilingual / archaeology).
class KartosLocalization {
  KartosLocalization._(this.locale)
      : common = CommonL10n(locale),
        home = HomeL10n(locale),
        physics = PhysicsL10n(locale),
        mechanics = MechanicsL10n(locale),
        fluids = FluidsL10n(locale),
        electricity = ElectricityL10n(locale),
        opticsWaves = OpticsWavesL10n(locale),
        quantum = QuantumL10n(locale),
        chemistry = ChemistryL10n(locale),
        accessibility = AccessibilityL10n(locale),
        sim = SimTitlesL10n(locale) {
    shared = SharedChromeL10n(common: common, accessibility: accessibility);
  }

  factory KartosLocalization.zhCN() =>
      KartosLocalization._(KartosLocale.zhCN);

  factory KartosLocalization.en() => KartosLocalization._(KartosLocale.en);

  final KartosLocale locale;
  final CommonL10n common;
  final HomeL10n home;
  final PhysicsL10n physics;
  final MechanicsL10n mechanics;
  final FluidsL10n fluids;
  final ElectricityL10n electricity;
  final OpticsWavesL10n opticsWaves;
  final QuantumL10n quantum;
  final ChemistryL10n chemistry;
  final AccessibilityL10n accessibility;
  final SimTitlesL10n sim;
  late final SharedChromeL10n shared;

  static KartosLocalization instance = KartosLocalization.zhCN();

  static void setLocale(KartosLocale locale) {
    instance = KartosLocalization._(locale);
  }

  /// Flat key lookup for adapters / scanners (`common.resetAll`, …).
  String resolve(String key, [Map<String, Object?>? params]) {
    if (key.startsWith('common.')) {
      return _resolveFromTable(CommonL10n.keys, common, key, params);
    }
    if (key.startsWith('home.') || key.startsWith('category.')) {
      return _resolveHome(key, params);
    }
    if (key.startsWith('physics.')) {
      return _resolvePhysics(key, params);
    }
    if (key.startsWith('accessibility.')) {
      return _resolveA11y(key, params);
    }
    if (key.startsWith('sim.')) {
      final parts = key.split('.');
      if (parts.length == 3) {
        final id = parts[1];
        final field = parts[2];
        if (field == 'title') return sim.title(id);
        if (field == 'subtitle') return sim.subtitle(id);
      }
    }
    assert(false, 'Unknown localization key: $key');
    return key;
  }

  String _resolveFromTable(
    Iterable<String> keys,
    CommonL10n ns,
    String key,
    Map<String, Object?>? params,
  ) {
    // CommonL10n exposes typed getters; map a few parameterized ones.
    switch (key) {
      case 'common.resetAll':
        return ns.resetAll;
      case 'common.reset':
        return ns.reset;
      case 'common.play':
        return ns.play;
      case 'common.pause':
        return ns.pause;
      case 'common.step':
        return ns.step;
      case 'common.stepForward':
        return ns.stepForward;
      case 'common.restart':
        return ns.restart;
      case 'common.back':
        return ns.back;
      case 'common.close':
        return ns.close;
      case 'common.ok':
        return ns.ok;
      case 'common.cancel':
        return ns.cancel;
      case 'common.simCount':
        return ns.simCount(params?['count'] as int? ?? 0);
      default:
        // Fallback: scan is enough for integrity; typed access preferred.
        return key;
    }
  }

  String _resolveHome(String key, Map<String, Object?>? params) {
    switch (key) {
      case 'home.appTitle':
        return home.appTitle;
      case 'home.tagline':
        return home.tagline(params?['count'] as int? ?? 0);
      case 'home.search':
        return home.search;
      case 'home.settings':
        return home.settings;
      case 'home.empty':
        return home.empty;
      case 'home.error':
        return home.error;
      case 'home.loading':
        return home.loading;
      case 'home.unavailable':
        return home.unavailable('${params?['title'] ?? ''}');
      case 'home.simCountBadge':
        return home.simCountBadge(params?['count'] as int? ?? 0);
      case 'category.physics':
        return home.physics;
      case 'category.chemistry':
        return home.chemistry;
      case 'category.mechanics':
        return home.mechanics;
      default:
        return key;
    }
  }

  String _resolvePhysics(String key, Map<String, Object?>? params) {
    switch (key) {
      case 'physics.mass':
        return physics.mass;
      case 'physics.gravity':
        return physics.gravity;
      case 'physics.density':
        return physics.density;
      case 'physics.volume':
        return physics.volume;
      case 'physics.pressure':
        return physics.pressure;
      case 'physics.massWithValue':
        return physics.massWithValue(params?['value'] ?? '');
      default:
        return key;
    }
  }

  String _resolveA11y(String key, Map<String, Object?>? params) {
    switch (key) {
      case 'accessibility.resetAll':
        return accessibility.resetAll;
      case 'accessibility.increaseMass':
        return accessibility.increaseMass;
      case 'accessibility.decreaseMass':
        return accessibility.decreaseMass;
      case 'accessibility.openSimulation':
        return accessibility.openSimulation('${params?['title'] ?? ''}');
      default:
        return key;
    }
  }

  /// All registered keys across namespaces (integrity tests).
  static Set<String> get allKeys => {
        ...CommonL10n.keys,
        ...HomeL10n.keys,
        ...PhysicsL10n.keys,
        ...MechanicsL10n.keys,
        ...FluidsL10n.keys,
        ...ElectricityL10n.keys,
        ...OpticsWavesL10n.keys,
        ...QuantumL10n.keys,
        ...ChemistryL10n.keys,
        ...AccessibilityL10n.keys,
        ...SimTitlesL10n.keys,
      };
}

/// Shorthand for [KartosLocalization.instance].
KartosLocalization get loc => KartosLocalization.instance;
