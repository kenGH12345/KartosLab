import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../layout/membrane_transport_layout.dart';
import '../membrane_transport_feature_set.dart';
import 'simple_diffusion_screen.dart';
import 'package:kratos/membrane_transport/membrane_transport_strings.dart';

/// Formal KartosLab Home entry — all four FeatureSet screens.
class MembraneTransportHome extends StatelessWidget {
  const MembraneTransportHome({super.key});

  static const String title = MembraneTransportStrings.title;

  static const String subtitle =
      '简单扩散 · 协助扩散 · 主动运输 · 练习场';

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
          label: '简单扩散',
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
          label: '协助扩散',
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
          label: '主动运输',
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
          label: '练习场',
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
