import 'package:flutter/material.dart';
import 'package:kratos/beers_law_lab/model/beers_law_model.dart';
import 'package:kratos/beers_law_lab/view/beers_law_screen.dart';
import 'package:kratos/common/widgets/kratos_tab_bar.dart';
import 'package:kratos/concentration/audio/concentration_audio.dart';
import 'package:kratos/concentration/model/concentration_model.dart';
import 'package:kratos/concentration/view/concentration_screen.dart';
import 'package:kratos/beers_law_lab/bll_strings.dart';

/// Dual-screen product shell — PhET Beer's Law Lab.
///
/// Screen 1: existing [ConcentrationScreen] (frozen, reused).
/// Screen 2: [BeersLawScreen].
///
/// Models are owned here, kept mounted across tab switches (no shared state).
/// Wired into KartosLab Home under 化学 → 溶液与浓度 (upgrades former「浓度」card).
class BeersLawLabHome extends StatefulWidget {
  const BeersLawLabHome({
    super.key,
    this.concentrationAudio,
  });

  static const String title = BllStrings.title;
  static const String subtitle = BllStrings.subtitle;
  static const Color accentColor = Color(0xFF00695C);

  /// Optional inject; production Home leaves null (real Concentration audio).
  final ConcentrationAudio? concentrationAudio;

  /// Test hook: when non-null, [HomeScreen] builder passes this as audio.
  /// Must be null in production.
  static ConcentrationAudio? debugTestAudio;

  @override
  State<BeersLawLabHome> createState() => BeersLawLabHomeState();
}

class BeersLawLabHomeState extends State<BeersLawLabHome> {
  late final ConcentrationModel concentrationModel;
  late final BeersLawModel beersLawModel;

  @override
  void initState() {
    super.initState();
    concentrationModel = ConcentrationModel();
    beersLawModel = BeersLawModel();
  }

  @override
  void dispose() {
    concentrationModel.dispose();
    beersLawModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: BeersLawLabHome.title,
      accentColor: BeersLawLabHome.accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: BllStrings.concentration,
          child: ConcentrationScreen(
            key: const Key('bll_concentration_tab'),
            model: concentrationModel,
            showAppBar: false,
            audio: widget.concentrationAudio,
          ),
        ),
        KratosTab(
          label: BllStrings.beersLaw,
          child: BeersLawScreen(
            key: const Key('bll_beers_law_tab'),
            model: beersLawModel,
            showAppBar: false,
          ),
        ),
      ],
    );
  }
}
