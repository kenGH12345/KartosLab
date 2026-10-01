import 'package:flutter/material.dart';

import '../../common/widgets/kratos_tab_bar.dart';
import '../controller/discrete_controller.dart';
import '../controller/wave_game_controller.dart';
import '../controller/wave_packet_controller.dart';
import '../fmw_strings.dart';
import 'discrete_screen.dart';
import 'wave_game_screen.dart';
import 'wave_packet_screen.dart';

class FourierMakingWavesHome extends StatefulWidget {
  const FourierMakingWavesHome({super.key});

  static const String title = FmwStrings.title;
  static const Color accentColor = Color(0xFF0F766E);

  @override
  State<FourierMakingWavesHome> createState() => _FourierMakingWavesHomeState();
}

class _FourierMakingWavesHomeState extends State<FourierMakingWavesHome>
    with TickerProviderStateMixin {
  late final DiscreteController _discrete;
  late final WaveGameController _waveGame;
  late final WavePacketController _wavePacket;

  @override
  void initState() {
    super.initState();
    _discrete = DiscreteController(vsync: this);
    _waveGame = WaveGameController();
    _wavePacket = WavePacketController();
  }

  @override
  void dispose() {
    _discrete.dispose();
    _waveGame.dispose();
    _wavePacket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KratosTabbedScreen(
      title: FourierMakingWavesHome.title,
      accentColor: FourierMakingWavesHome.accentColor,
      initialIndex: 0,
      tabs: [
        KratosTab(
          label: FmwStrings.tabDiscrete,
          child: DiscreteScreen(controller: _discrete, embedded: true),
        ),
        KratosTab(
          label: FmwStrings.tabWaveGame,
          child: WaveGameScreen(controller: _waveGame, embedded: true),
        ),
        KratosTab(
          label: FmwStrings.tabWavePacket,
          child: WavePacketScreen(controller: _wavePacket, embedded: true),
        ),
      ],
    );
  }
}
