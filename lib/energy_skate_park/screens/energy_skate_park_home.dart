import 'package:flutter/material.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/energy_skate_park/controller/graphs_controller.dart';
import 'package:kratos/energy_skate_park/controller/intro_controller.dart';
import 'package:kratos/energy_skate_park/controller/measure_controller.dart';
import 'package:kratos/energy_skate_park/controller/playground_controller.dart';
import 'package:kratos/energy_skate_park/esp_colors.dart';
import 'package:kratos/energy_skate_park/esp_strings.dart';
import 'package:kratos/energy_skate_park/widgets/esp_screen_tab_icon.dart';
import 'package:kratos/energy_skate_park/screens/graphs_screen.dart';
import 'package:kratos/energy_skate_park/screens/intro_screen.dart';
import 'package:kratos/energy_skate_park/screens/measure_screen.dart';
import 'package:kratos/energy_skate_park/screens/playground_screen.dart';

class EnergySkateParkHome extends StatefulWidget {
  const EnergySkateParkHome({super.key});

  static const String title = EspStrings.title;
  static const Color accentColor = EspColors.accent;

  @override
  State<EnergySkateParkHome> createState() => _EnergySkateParkHomeState();
}

class _EnergySkateParkHomeState extends State<EnergySkateParkHome> {
  late final IntroController _intro;
  late final MeasureController _measure;
  late final GraphsController _graphs;
  late final PlaygroundController _playground;

  @override
  void initState() {
    super.initState();
    _intro = IntroController();
    _measure = MeasureController();
    _graphs = GraphsController();
    _playground = PlaygroundController();
  }

  @override
  void dispose() {
    _intro.dispose();
    _measure.dispose();
    _graphs.dispose();
    _playground.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: EnergySkateParkHome.title,
      accentColor: EnergySkateParkHome.accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: EspStrings.intro,
          tabIcon: const EspScreenTabIcon.intro(),
          child: IntroScreen(controller: _intro, embedded: true),
        ),
        KratosTab(
          label: EspStrings.measure,
          tabIcon: const EspScreenTabIcon.measure(),
          child: MeasureScreen(controller: _measure, embedded: true),
        ),
        KratosTab(
          label: EspStrings.graphs,
          tabIcon: const EspScreenTabIcon.graphs(),
          child: GraphsScreen(controller: _graphs, embedded: true),
        ),
        KratosTab(
          label: EspStrings.playground,
          tabIcon: const EspScreenTabIcon.playground(),
          child: PlaygroundScreen(controller: _playground, embedded: true),
        ),
      ],
    );
  }
}
