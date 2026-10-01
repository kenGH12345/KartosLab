import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../model/resistance_in_a_wire_model.dart';
import '../resistance_in_a_wire_view_constants.dart';
import 'riaw_audio_hooks.dart';
import 'riaw_play_area.dart';

/// Single-screen Resistance in a Wire — PhET screen + screen view.
///
/// Home → 电学与电路 → [title] opens this screen (fresh model each push).
class ResistanceInAWireScreen extends StatefulWidget {
  const ResistanceInAWireScreen({
    super.key,
    this.model,
    this.dotRandom,
    this.showAppBar = true,
    this.audio,
    this.resistivityFocusNode,
    this.lengthFocusNode,
    this.areaFocusNode,
  });

  /// Home card / AppBar title — Chinese discoverability (Home taxonomy).
  /// Internal PhET name remains "Resistance in a Wire".
  static const String title = '导线电阻';
  static const String subtitle = '电阻率 · 长度 · 截面积 · R = ρL/A';
  static const Color accentColor = Color(0xFF0F0FFB);
  static const IconData homeIcon = Icons.straighten_rounded;

  final ResistanceInAWireModel? model;
  final math.Random? dotRandom;
  final bool showAppBar;
  final ResistanceInAWireAudioHooks? audio;
  final FocusNode? resistivityFocusNode;
  final FocusNode? lengthFocusNode;
  final FocusNode? areaFocusNode;

  @override
  State<ResistanceInAWireScreen> createState() =>
      ResistanceInAWireScreenState();
}

class ResistanceInAWireScreenState extends State<ResistanceInAWireScreen> {
  late final ResistanceInAWireModel model;
  late final bool _ownsModel;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      model = widget.model!;
      _ownsModel = false;
    } else {
      model = ResistanceInAWireModel();
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
    final body = ResistanceInAWirePlayArea(
      model: model,
      // null → WireNode uses undeterministic Random (source dotRandom).
      // Golden / view tests pass an explicit seeded Random.
      dotRandom: widget.dotRandom,
      audio: widget.audio,
      resistivityFocusNode: widget.resistivityFocusNode,
      lengthFocusNode: widget.lengthFocusNode,
      areaFocusNode: widget.areaFocusNode,
    );

    if (!widget.showAppBar) {
      return ColoredBox(
        color: ResistanceInAWireViewConstants.background,
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: ResistanceInAWireViewConstants.background,
      appBar: AppBar(
        title: const Text(
          ResistanceInAWireScreen.title,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: ResistanceInAWireScreen.accentColor,
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: SafeArea(top: false, child: body),
    );
  }
}
