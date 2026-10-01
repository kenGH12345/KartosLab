import 'package:flutter/material.dart';

import '../audio/gfl_audio.dart';
import '../gfl_colors.dart';
import '../gfl_strings.dart';
import '../model/gravity_force_lab_model.dart';
import '../widgets/gfl_page_shell.dart';
import 'gfl_screen_body.dart';

/// Full Gravity Force Lab — Home entry (`GravityForceLabScreenView`).
///
/// Pattern matches sibling sims: each Home navigate creates a fresh
/// [GravityForceLabModel] via [initState] (no cross-visit residue).
class GravityForceLabScreen extends StatefulWidget {
  const GravityForceLabScreen({
    super.key,
    this.audio,
  });

  /// Optional inject for tests (`playEnabled: false`).
  final GflAudio? audio;

  static const String title = GflStrings.title;
  static const String subtitle = GflStrings.subtitle;
  static const Color accentColor = GflColors.accent;
  static const IconData homeIcon = Icons.language_rounded;

  @override
  State<GravityForceLabScreen> createState() => GravityForceLabScreenState();
}

class GravityForceLabScreenState extends State<GravityForceLabScreen> {
  late GravityForceLabModel model;

  @override
  void initState() {
    super.initState();
    model = GravityForceLabModel();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  /// Test helper: replace with a fresh model (lifecycle).
  void recreateModel() {
    model.dispose();
    setState(() => model = GravityForceLabModel());
  }

  @override
  Widget build(BuildContext context) {
    // White chrome + max body height so 768×464 contain-fit matches PhET’s
    // full-bleed white ScreenView (Home card accent stays [accentColor]).
    return Scaffold(
      backgroundColor: GflColors.screenBackground,
      appBar: AppBar(
        title: const Text(
          GravityForceLabScreen.title,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: GflColors.screenBackground,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 44,
      ),
      body: SafeArea(
        top: false,
        child: GflPageShell(
          child: GflScreenBody(model: model, audio: widget.audio),
        ),
      ),
    );
  }
}
