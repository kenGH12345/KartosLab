import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/ohms_law_model.dart';
import '../ohms_law_view_constants.dart';
import 'ohms_law_audio_hooks.dart';
import 'ohms_law_play_area.dart';

/// Single-screen Ohm's Law — PhET `OhmsLawScreen` + `OhmsLawScreenView`.
///
/// Home entry (物理 → 电学与电路) pushes this widget directly (Capacitor peer).
class OhmsLawScreen extends StatefulWidget {
  const OhmsLawScreen({
    super.key,
    this.model,
    this.dotRandom,
    this.showAppBar = true,
    this.audio,
    this.voltageFocusNode,
    this.resistanceFocusNode,
    this.unitsFocusNode,
  });

  /// Home card / AppBar title (PhET English name; peer: Faraday's Law).
  static const String title = "Ohm's Law";

  /// Home card subtitle (Chinese discoverability keywords).
  static const String subtitle = '欧姆定律 · 电压 · 电阻 · 电流';

  /// Home card accent (KartosLab Material card chrome).
  static const Color accentColor = Color(0xFF1565C0);

  /// Home card icon (Material peer pattern; no equation graphic as icon).
  static const IconData homeIcon = Icons.electrical_services_rounded;

  final OhmsLawModel? model;
  final math.Random? dotRandom;
  final bool showAppBar;
  final OhmsLawAudioHooks? audio;
  final FocusNode? voltageFocusNode;
  final FocusNode? resistanceFocusNode;
  final FocusNode? unitsFocusNode;

  @override
  State<OhmsLawScreen> createState() => OhmsLawScreenState();
}

class OhmsLawScreenState extends State<OhmsLawScreen> {
  late final OhmsLawModel model;
  late final bool _ownsModel;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      model = widget.model!;
      _ownsModel = false;
    } else {
      model = OhmsLawModel();
      _ownsModel = true;
    }
  }

  @override
  void dispose() {
    if (_ownsModel) {
      model.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = OhmsLawPlayArea(
      model: model,
      dotRandom: widget.dotRandom ?? math.Random(0x4F484D53),
      audio: widget.audio,
      voltageFocusNode: widget.voltageFocusNode,
      resistanceFocusNode: widget.resistanceFocusNode,
      unitsFocusNode: widget.unitsFocusNode,
    );

    if (!widget.showAppBar) {
      return ColoredBox(
        color: OhmsLawViewConstants.background,
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: OhmsLawViewConstants.background,
      appBar: AppBar(
        title: const Text(OhmsLawScreen.title, style: TextStyle(fontSize: 16)),
        backgroundColor: OhmsLawScreen.accentColor,
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: SafeArea(top: false, child: body),
    );
  }
}
