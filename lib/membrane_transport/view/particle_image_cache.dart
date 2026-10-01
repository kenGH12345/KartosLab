import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../layout/membrane_transport_layout.dart';
import '../model/solute_type.dart';

/// Rasterize original particle SVGs once for canvas drawImage.
class ParticleImageCache {
  ParticleImageCache._();

  static final Map<ParticleType, ui.Image> images = {};
  static bool _loading = false;
  static bool ready = false;

  static Future<void> ensureLoaded() async {
    if (ready || _loading) return;
    _loading = true;
    final types = [
      ParticleType.oxygen,
      ParticleType.carbonDioxide,
      ParticleType.sodiumIon,
      ParticleType.potassiumIon,
      ParticleType.glucose,
      ParticleType.atp,
      ParticleType.adp,
      ParticleType.phosphate,
      ParticleType.triangleLigand,
      ParticleType.starLigand,
    ];
    for (final t in types) {
      try {
        final path = MembraneTransportAssets.forParticleType(t.name);
        final pictureInfo =
            await vg.loadPicture(SvgAssetLoader(path), null);
        final w = pictureInfo.size.width.ceil().clamp(1, 2048);
        final h = pictureInfo.size.height.ceil().clamp(1, 2048);
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.drawPicture(pictureInfo.picture);
        pictureInfo.picture.dispose();
        final image = await recorder.endRecording().toImage(w, h);
        images[t] = image;
      } catch (_) {
        // Painter falls back to colored ellipses if SVG fails.
      }
    }
    ready = true;
    _loading = false;
  }
}
