import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/rutherford_scattering/rs_assets.dart';
import 'package:kratos/rutherford_scattering/rs_colors.dart';
import 'package:kratos/rutherford_scattering/rs_strings.dart';
import 'package:kratos/rutherford_scattering/screens/plum_pudding_atom_screen.dart';
import 'package:kratos/rutherford_scattering/screens/rutherford_atom_screen.dart';

/// Rutherford Scattering home — two independent screens (tabs).
class RutherfordScatteringHome extends StatelessWidget {
  const RutherfordScatteringHome({super.key});

  static const String title = RsStrings.title;
  static const String subtitle = 'Rutherford · Plum Pudding';
  static const Color accentColor = Color(0xFFB45309);

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      tabs: [
        KratosTab(
          label: RsStrings.rutherfordAtom,
          tabIcon: Image.asset(RsAssets.atom, height: 22, fit: BoxFit.contain),
          child: const RutherfordAtomScreen(),
        ),
        KratosTab(
          label: RsStrings.plumPuddingAtom,
          tabIcon: Image.asset(
            RsAssets.plumPuddingScreenIcon,
            height: 22,
            fit: BoxFit.contain,
          ),
          color: RsColors.panelTitle,
          child: const PlumPuddingAtomScreen(),
        ),
      ],
    );
  }
}
