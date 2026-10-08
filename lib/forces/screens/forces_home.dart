import 'package:flutter/material.dart';

import 'package:kratos/forces/config/forces_strings.dart';

import 'net_force_screen.dart';
import 'motion_screen_v2.dart';
import '../../common/widgets/kratos_tab_bar.dart';

/// Forces and Motion: Basics — 4 PhET screens (PHASE 2 Chinese labels).
class ForcesHome extends StatelessWidget {
  const ForcesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const KratosTabbedScreen(
      title: ForcesStrings.forcesHomeTitle,
      accentColor: Color(0xFF166534),
      tabBarPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      tabs: [
        KratosTab(
          label: ForcesStrings.screenNetForce,
          child: NetForceScreen(),
        ),
        KratosTab(
          label: ForcesStrings.screenMotion,
          child: MotionScreenV2(style: MotionScreenStyleTab.motion),
        ),
        KratosTab(
          label: ForcesStrings.screenFriction,
          child: MotionScreenV2(style: MotionScreenStyleTab.friction),
        ),
        KratosTab(
          label: ForcesStrings.screenAcceleration,
          child: MotionScreenV2(style: MotionScreenStyleTab.acceleration),
        ),
      ],
    );
  }
}
