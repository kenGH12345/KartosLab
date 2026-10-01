import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../collision_lab_colors.dart';
import '../collision_lab_strings.dart';
import '../controller/explore1d_controller.dart';
import '../controller/explore2d_controller.dart';
import '../controller/inelastic_controller.dart';
import '../controller/intro_controller.dart';
import 'explore1d_screen.dart';
import 'explore2d_screen.dart';
import 'inelastic_screen.dart';
import 'intro_screen.dart';

class CollisionLabHome extends StatefulWidget {
  const CollisionLabHome({super.key});

  static const String title = CollisionLabStrings.title;
  static const Color accentColor = CollisionLabColors.accent;

  @override
  State<CollisionLabHome> createState() => _CollisionLabHomeState();
}

class _CollisionLabHomeState extends State<CollisionLabHome> {
  late final IntroController _intro;
  late final Explore1dController _explore1d;
  late final Explore2dController _explore2d;
  late final InelasticController _inelastic;

  @override
  void initState() {
    super.initState();
    _intro = IntroController();
    _explore1d = Explore1dController();
    _explore2d = Explore2dController();
    _inelastic = InelasticController();
  }

  @override
  void dispose() {
    _intro.dispose();
    _explore1d.dispose();
    _explore2d.dispose();
    _inelastic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: CollisionLabHome.title,
      accentColor: CollisionLabHome.accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: CollisionLabStrings.intro,
          child: IntroScreen(controller: _intro, embedded: true),
        ),
        KratosTab(
          label: CollisionLabStrings.explore1d,
          child: Explore1dScreen(controller: _explore1d, embedded: true),
        ),
        KratosTab(
          label: CollisionLabStrings.explore2d,
          child: Explore2dScreen(controller: _explore2d, embedded: true),
        ),
        KratosTab(
          label: CollisionLabStrings.inelastic,
          child: InelasticScreen(controller: _inelastic, embedded: true),
        ),
      ],
    );
  }
}
