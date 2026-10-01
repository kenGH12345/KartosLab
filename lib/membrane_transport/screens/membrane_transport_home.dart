import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../layout/membrane_transport_layout.dart';
import '../membrane_transport_feature_set.dart';
import 'simple_diffusion_screen.dart';

/// Formal KartosLab Home entry — all four FeatureSet screens.
class MembraneTransportHome extends StatelessWidget {
  const MembraneTransportHome({super.key});

  static const String title = 'Membrane Transport';

  static const String subtitle =
      'Simple · Facilitated · Active · Playground';

  static const Color accentColor = Color(0xFF0288D1);

  /// Original PhET Simple Diffusion screen home icon (Home card).
  static const String homeIconAsset =
      MembraneTransportAssets.simpleDiffusionHome;

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      tabBarIsScrollable: true,
      tabs: [
        KratosTab(
          label: 'Simple Diffusion',
          tabIcon: SvgPicture.asset(
            MembraneTransportAssets.simpleDiffusionNav,
            width: 28,
            height: 20,
            fit: BoxFit.contain,
          ),
          color: MembraneTransportColors.outsideCell,
          child: const MembraneTransportScreenBody(
            key: ValueKey(MembraneTransportFeatureSet.simpleDiffusion),
            featureSet: MembraneTransportFeatureSet.simpleDiffusion,
          ),
        ),
        KratosTab(
          label: 'Facilitated Diffusion',
          tabIcon: SvgPicture.asset(
            MembraneTransportAssets.facilitatedDiffusionNav,
            width: 28,
            height: 20,
            fit: BoxFit.contain,
          ),
          color: MembraneTransportColors.outsideCell,
          child: const MembraneTransportScreenBody(
            key: ValueKey(MembraneTransportFeatureSet.facilitatedDiffusion),
            featureSet: MembraneTransportFeatureSet.facilitatedDiffusion,
          ),
        ),
        KratosTab(
          label: 'Active Transport',
          tabIcon: SvgPicture.asset(
            MembraneTransportAssets.activeTransportNav,
            width: 28,
            height: 20,
            fit: BoxFit.contain,
          ),
          color: MembraneTransportColors.outsideCell,
          child: const MembraneTransportScreenBody(
            key: ValueKey(MembraneTransportFeatureSet.activeTransport),
            featureSet: MembraneTransportFeatureSet.activeTransport,
          ),
        ),
        KratosTab(
          label: 'Playground',
          tabIcon: SvgPicture.asset(
            MembraneTransportAssets.playgroundNav,
            width: 28,
            height: 20,
            fit: BoxFit.contain,
          ),
          color: MembraneTransportColors.outsideCell,
          child: const MembraneTransportScreenBody(
            key: ValueKey(MembraneTransportFeatureSet.playground),
            featureSet: MembraneTransportFeatureSet.playground,
          ),
        ),
      ],
    );
  }
}
