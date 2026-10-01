import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../common/widgets/kratos_tab_bar.dart';
import '../../controller/density_controller.dart';
import '../../data/density_texture_cache.dart';
import '../../density_strings.dart';
import '../dialogs/density_about_dialog.dart';
import 'compare_screen.dart';
import 'introduction_screen.dart';
import 'mystery_screen.dart';

class DensityHome extends StatefulWidget {
  const DensityHome({super.key});

  @override
  State<DensityHome> createState() => _DensityHomeState();
}

class _DensityHomeState extends State<DensityHome>
    with SingleTickerProviderStateMixin {
  late final DensityController _controller;
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  bool _texturesReady = false;

  @override
  void initState() {
    super.initState();
    _controller = DensityController();
    DensityTextureCache.load().then((_) {
      if (mounted) setState(() => _texturesReady = true);
    });
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 1 / 60
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    _controller.step(dt.clamp(0.0, 1 / 30).toDouble());
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _controller.dispose();
    DensityTextureCache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_texturesReady) {
      return Scaffold(
        appBar: AppBar(title: const Text(DensityStrings.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return KratosTabbedScreen(
      title: DensityStrings.title,
      accentColor: const Color(0xFF0F766E),
      appBarActions: [
        IconButton(
          tooltip: DensityStrings.aboutTitle,
          icon: const Icon(Icons.info_outline),
          onPressed: () => showDensityAboutDialog(context),
        ),
      ],
      onTabChanged: (index) {
        _controller.selectScreen(DensityScreenId.values[index]);
      },
      tabs: [
        KratosTab(
          label: DensityStrings.intro,
          icon: Icons.science_outlined,
          child: IntroductionScreen(controller: _controller),
        ),
        KratosTab(
          label: DensityStrings.compare,
          icon: Icons.compare_arrows,
          child: CompareScreen(controller: _controller),
        ),
        KratosTab(
          label: DensityStrings.mystery,
          icon: Icons.help_outline,
          child: MysteryScreen(controller: _controller),
        ),
      ],
    );
  }
}
