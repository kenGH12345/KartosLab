import 'package:flutter/services.dart';
import 'package:kratos/energy_skate_park/assets/esp_assets.dart';

/// Verifies Flutter bundle contains PhET-extracted assets.
class EspAssetLoader {
  EspAssetLoader._();

  static Future<void> load(String path) async {
    await rootBundle.load(path);
  }

  static Future<void> loadAll(Iterable<String> paths) async {
    for (final p in paths) {
      await load(p);
    }
  }

  static Future<void> loadCoreRuntime() =>
      loadAll(EspAssets.coreRuntimeBundle);

  static Future<void> loadUsaSkaters() =>
      loadAll(EspAssets.usaSkaterBundle);
}
