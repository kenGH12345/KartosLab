import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../buoyancy_sim_host.dart';
import '../rendering/texture/buoyancy_texture_asset.dart';

/// KartosLab Home entry for Buoyancy (five screens).
class BuoyancyHome extends StatelessWidget {
  const BuoyancyHome({super.key});

  static const String simulationId = 'buoyancy';
  static const String title = '浮力';
  static const String subtitle = 'Compare · Explore · Lab · Shapes · Applications';
  static const Color accentColor = Color(0xFF1177AA);
  static const String homeIconAsset = BuoyancyTextureAsset.bottleIcon;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 19, 165, 224),
        appBar: AppBar(
          title: const Text(title),
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const BuoyancySimHost(
          key: Key('buoyancy_sim_host'),
        ),
      ),
    );
  }
}
