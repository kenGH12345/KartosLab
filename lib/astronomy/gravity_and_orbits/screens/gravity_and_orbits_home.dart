/// Model | To Scale tabs. Title: Gravity and Orbits.
///
/// Not registered in home_screen.dart (caller wires navigation).
library;

import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_tab_bar.dart';
import '../gao_colors.dart';
import '../gao_constants.dart';
import '../gao_strings.dart';
import 'gravity_and_orbits_screen.dart';

class GravityAndOrbitsHome extends StatelessWidget {
  const GravityAndOrbitsHome({super.key});

  static const String title = GaoStrings.title;
  static const Color accentColor = Color(0xFF1E90FF);

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: GaoStrings.model,
          tabIcon: Image.asset(
            GaoConstants.modelIconAsset,
            width: 28,
            height: 28,
          ),
          child: const GravityAndOrbitsScreen(
            isModelScreen: true,
            embedded: true,
          ),
        ),
        KratosTab(
          label: GaoStrings.toScale,
          tabIcon: Image.asset(
            GaoConstants.toScaleIconAsset,
            width: 28,
            height: 28,
          ),
          child: const GravityAndOrbitsScreen(
            isModelScreen: false,
            embedded: true,
          ),
        ),
      ],
    );
  }
}
