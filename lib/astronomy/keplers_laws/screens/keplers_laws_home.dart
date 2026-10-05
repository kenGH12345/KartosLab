/// Kepler's Laws entry: First | Second | Third | All Laws.
///
/// [已确认] keplers-laws-main.ts screen order
library;

import 'package:flutter/material.dart';

import '../../../common/widgets/kratos_tab_bar.dart';
import '../keplers_laws_strings.dart';
import '../keplers_motion.dart';
import '../model/law_mode.dart';
import 'keplers_laws_screen.dart';

class KeplersLawsHome extends StatelessWidget {
  const KeplersLawsHome({super.key});

  static const String title = KeplersLawsStrings.title;
  static const Color accentColor = Color(0xFF1A365D);

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: title,
      accentColor: accentColor,
      initialIndex: 0,
      switchDuration: KeplersMotion.duration,
      switchCurve: KeplersMotion.curve,
      switchBackdropColor: Colors.black,
      switchIncomingScale: 0.988,
      tabs: [
        KratosTab(
          label: KeplersLawsStrings.firstLaw,
          icon: Icons.circle_outlined,
          child: KeplersLawsScreen(
            initialLaw: LawMode.first,
            embedded: true,
          ),
        ),
        KratosTab(
          label: KeplersLawsStrings.secondLaw,
          icon: Icons.pie_chart_outline,
          child: KeplersLawsScreen(
            initialLaw: LawMode.second,
            embedded: true,
          ),
        ),
        KratosTab(
          label: KeplersLawsStrings.thirdLaw,
          icon: Icons.show_chart,
          child: KeplersLawsScreen(
            initialLaw: LawMode.third,
            embedded: true,
          ),
        ),
        KratosTab(
          label: KeplersLawsStrings.allLaws,
          icon: Icons.hub_outlined,
          child: KeplersLawsScreen(
            initialLaw: LawMode.first,
            isAllLaws: true,
            embedded: true,
          ),
        ),
      ],
    );
  }
}
