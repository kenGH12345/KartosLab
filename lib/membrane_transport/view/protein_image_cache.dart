import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../layout/membrane_transport_layout.dart';
import '../model/transport_protein_type.dart';

/// Rasterize transport-protein SVGs for observation / toolbox.
class ProteinImageCache {
  ProteinImageCache._();

  static final Map<String, ui.Image> images = {};
  static bool _loading = false;
  static bool ready = false;

  static const _assetPaths = [
    MembraneTransportAssets.sodiumLeakage,
    MembraneTransportAssets.potassiumLeakage,
    MembraneTransportAssets.sodiumVoltageGatedOpen,
    MembraneTransportAssets.sodiumVoltageGatedClosed,
    MembraneTransportAssets.potassiumVoltageGatedOpen,
    MembraneTransportAssets.potassiumVoltageGatedClosed,
    MembraneTransportAssets.sodiumLigandGatedOpen,
    MembraneTransportAssets.sodiumLigandGatedClosed,
    MembraneTransportAssets.potassiumLigandGatedOpen,
    MembraneTransportAssets.potassiumLigandGatedClosed,
    MembraneTransportAssets.naKPumpState1,
    MembraneTransportAssets.naKPumpState2,
    MembraneTransportAssets.sodiumGlucoseCotransporterState1,
    MembraneTransportAssets.sodiumGlucoseCotransporterState3,
  ];

  static Future<void> ensureLoaded() async {
    if (ready || _loading) return;
    _loading = true;
    for (final path in _assetPaths) {
      try {
        final pictureInfo = await vg.loadPicture(SvgAssetLoader(path), null);
        final w = pictureInfo.size.width.ceil().clamp(1, 2048);
        final h = pictureInfo.size.height.ceil().clamp(1, 2048);
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        canvas.drawPicture(pictureInfo.picture);
        pictureInfo.picture.dispose();
        images[path] = await recorder.endRecording().toImage(w, h);
      } catch (_) {
        // Painter falls back to a placeholder rect.
      }
    }
    ready = true;
    _loading = false;
  }

  static ui.Image? forType(TransportProteinType type, {String? state}) {
    return images[MembraneTransportAssets.forProtein(type, state: state)];
  }
}
