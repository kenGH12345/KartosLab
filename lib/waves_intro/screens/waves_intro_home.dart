import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../model/scene_kind.dart';
import 'waves_intro_medium_screen.dart';

/// Waves Intro home: Water / Sound / Light tabs. Default: Water.
class WavesIntroHome extends StatefulWidget {
  const WavesIntroHome({super.key});

  static const String title = 'Waves Intro';
  static const Color accentColor = Color(0xFF1177AA);

  @override
  State<WavesIntroHome> createState() => _WavesIntroHomeState();
}

class _WavesIntroHomeState extends State<WavesIntroHome>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(WavesIntroHome.title),
        backgroundColor: WavesIntroHome.accentColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: _ScreenIcon('assets/phet/waves_intro/waterScreenIcon.png'),
              text: 'Water',
            ),
            Tab(
              icon: _ScreenIcon('assets/phet/waves_intro/soundScreenIcon.png'),
              text: 'Sound',
            ),
            Tab(
              icon: _ScreenIcon('assets/phet/waves_intro/lightScreenIcon.png'),
              text: 'Light',
            ),
          ],
        ),
      ),
      body: KratosTabSwitcher(
        controller: _tabs,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
        backdropColor: Colors.white,
        children: const [
          WavesIntroMediumScreen(kind: SceneKind.water, embedded: true),
          WavesIntroMediumScreen(kind: SceneKind.sound, embedded: true),
          WavesIntroMediumScreen(kind: SceneKind.light, embedded: true),
        ],
      ),
    );
  }
}

class _ScreenIcon extends StatelessWidget {
  const _ScreenIcon(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: 28,
      height: 28,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.waves, size: 22),
    );
  }
}
