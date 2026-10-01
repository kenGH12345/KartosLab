import 'dart:ui' as ui;

import 'package:flutter/services.dart';

import '../model/density_material.dart';

/// Runtime cache for Intro material color maps extracted from PhET `*_col_jpg.ts`.
class DensityTextureCache {
  DensityTextureCache._();

  static bool _loaded = false;
  static final Map<DensityMaterialId, ui.Image> _images = {};

  static const _assetByMaterial = <DensityMaterialId, String>{
    DensityMaterialId.styrofoam: 'assets/density/images/materials/styrofoam_col.jpg',
    DensityMaterialId.wood: 'assets/density/images/materials/wood_col.jpg',
    DensityMaterialId.ice: 'assets/density/images/materials/ice_col.jpg',
    DensityMaterialId.pvc: 'assets/density/images/materials/pvc_col.jpg',
    DensityMaterialId.brick: 'assets/density/images/materials/brick_col.jpg',
    DensityMaterialId.aluminum: 'assets/density/images/materials/aluminum_col.jpg',
    DensityMaterialId.copper: 'assets/density/images/materials/copper_col.jpg',
    DensityMaterialId.steel: 'assets/density/images/materials/steel_col.jpg',
    DensityMaterialId.gold: 'assets/density/images/materials/gold_col.jpg',
  };

  static bool get isLoaded => _loaded;

  static Future<void> load() async {
    if (_loaded) return;
    for (final entry in _assetByMaterial.entries) {
      final data = await rootBundle.load(entry.value);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _images[entry.key] = frame.image;
    }
    _loaded = true;
  }

  static ui.Image? imageFor(DensityMaterialId? id) {
    if (id == null) return null;
    return _images[id];
  }

  /// Compare/Mystery custom blocks use flat colors; Intro named materials use JPEG.
  static ui.Image? imageForBlock({
    required DensityMaterialId materialId,
    int? colorArgb,
  }) {
    if (colorArgb != null || materialId == DensityMaterialId.custom) {
      return null;
    }
    return _images[materialId];
  }

  /// Release decoded images when leaving the sim (Loop 11 lifecycle).
  static void dispose() {
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
    _loaded = false;
  }
}
