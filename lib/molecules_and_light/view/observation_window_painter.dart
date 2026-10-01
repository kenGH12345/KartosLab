import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/molecules_and_light_model.dart';
import '../molecules_and_light_constants.dart';
import 'molecules_and_light_mvt.dart';

/// Observation window: black field, emitter PNG, photons, molecule.
class ObservationWindowPainter extends CustomPainter {
  ObservationWindowPainter({
    required this.model,
    required this.mvt,
    required this.photonImages,
    required this.emitterOnImages,
    required this.emitterOffImages,
  });

  final MoleculesAndLightModel model;
  final MoleculesAndLightMvt mvt;
  final Map<LightType, ui.Image?> photonImages;
  final Map<LightType, ui.Image?> emitterOnImages;
  final Map<LightType, ui.Image?> emitterOffImages;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(7),
    );
    canvas.drawRRect(rrect, Paint()..color = Colors.black);
    canvas.save();
    canvas.clipRRect(rrect);

    _paintEmitter(canvas);
    _paintMolecule(canvas);
    for (final photon in model.photons) {
      _paintPhoton(canvas, photon.x, photon.y, photon.lightType);
    }
    canvas.restore();
  }

  void _paintEmitter(Canvas canvas) {
    final emission = mvt.modelToView(
      MoleculesAndLightConstants.photonEmissionX + 100,
      0,
    );
    final image = model.emitterOn
        ? emitterOnImages[model.light]
        : (model.light == LightType.microwave
            ? emitterOnImages[model.light]
            : emitterOffImages[model.light] ?? emitterOnImages[model.light]);
    if (image == null) {
      return;
    }
    const width = 125.0;
    final height = width * image.height / image.width;
    paintImage(
      canvas: canvas,
      rect: Rect.fromCenter(center: emission, width: width, height: height),
      image: image,
    );
    // Green sticky on/off affordance over the lamp body.
    canvas.drawCircle(
      emission.translate(-width * 0.15, 0),
      15,
      Paint()
        ..color = model.emitterOn
            ? const Color(0xFF33DD33)
            : const Color(0xFF888888),
    );
  }

  void _paintPhoton(Canvas canvas, double x, double y, LightType type) {
    final p = mvt.modelToView(x, y);
    final image = photonImages[type];
    if (image != null) {
      const s = 28.0;
      paintImage(
        canvas: canvas,
        rect: Rect.fromCenter(center: p, width: s, height: s),
        image: image,
      );
      return;
    }
    canvas.drawCircle(p, 6, Paint()..color = Colors.yellow);
  }

  void _paintMolecule(Canvas canvas) {
    final molecule = model.molecule;
    if (molecule.brokenApart) {
      return;
    }
    final positions = molecule.atomPositions();
    final atoms = molecule.geometry.atoms;
    if (molecule.highElectronicEnergy) {
      final glow = mvt.modelToView(molecule.centerX, molecule.centerY);
      canvas.drawCircle(
        glow,
        48,
        Paint()..color = const Color(0x66FFFF66),
      );
    }
    for (final bond in molecule.geometry.bonds) {
      final a = mvt.modelToView(positions[bond.a].$1, positions[bond.a].$2);
      final b = mvt.modelToView(positions[bond.b].$1, positions[bond.b].$2);
      for (var i = 0; i < bond.bondCount; i++) {
        final offset = (i - (bond.bondCount - 1) / 2) * 4;
        final dx = b.dx - a.dx;
        final dy = b.dy - a.dy;
        final len = (Offset(dx, dy).distance).clamp(1.0, 1e9);
        final nx = -dy / len * offset;
        final ny = dx / len * offset;
        canvas.drawLine(
          a.translate(nx, ny),
          b.translate(nx, ny),
          Paint()
            ..color = Colors.white
            ..strokeWidth = 3,
        );
      }
    }
    for (var i = 0; i < atoms.length; i++) {
      final atom = atoms[i];
      final p = mvt.modelToView(positions[i].$1, positions[i].$2);
      final r = mvt.modelToViewDelta(atom.radius);
      canvas.drawCircle(p, r, Paint()..color = atom.color);
      canvas.drawCircle(
        p,
        r,
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ObservationWindowPainter oldDelegate) => true;
}
