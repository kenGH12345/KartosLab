/// Photon sprites — greenPhoton.png + outline; TARGET_PHOTON_VIEW_RADIUS = 5.
library;

import 'package:flutter/material.dart';

import '../../qm_assets.dart';
import '../qm_photons_colors.dart';
import '../transform/photon_view_transform.dart';
import '../animation/photon_visual_state.dart';
import '../model/photon_particle.dart';

class PhotonRenderer extends StatelessWidget {
  const PhotonRenderer({
    super.key,
    required this.photons,
    required this.transform,
  });

  final List<PhotonParticle> photons;
  final PhotonViewTransform transform;

  /// PhotonSprites.TARGET_PHOTON_VIEW_RADIUS
  static const targetRadius = 5.0;

  /// greenPhoton.png is 50×50 → scale = 5 / 25 = 0.2
  static const assetIntrinsic = 50.0;
  static final displayDiameter = targetRadius * 2;
  static final assetScale = displayDiameter / assetIntrinsic;

  @override
  Widget build(BuildContext context) {
    final sprites = <Widget>[];
    for (final photon in photons) {
      for (final vs in visualStatesFor(photon)) {
        if (vs.probability <= 0) continue;
        final view = transform.physicsToView(vs.positionMeters);
        sprites.add(
          Positioned(
            left: view.dx - targetRadius,
            top: view.dy - targetRadius,
            width: displayDiameter,
            height: displayDiameter,
            child: Opacity(
              opacity: vs.probability.clamp(0.05, 1.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: displayDiameter,
                    height: displayDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: QmPhotonsColors.photonStroke,
                        width: 1.5,
                      ),
                    ),
                  ),
                  Image.asset(
                    QmAssets.greenPhoton,
                    width: displayDiameter,
                    height: displayDiameter,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return Stack(clipBehavior: Clip.none, children: sprites);
  }
}
