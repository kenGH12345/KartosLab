import 'package:flutter/material.dart';

import '../friction_strings.dart';
import '../model/friction_model.dart';
import 'friction_play_area.dart';

/// Single-screen Friction — PhET `FrictionScreenView`.
///
/// Home entry (物理 → 力学) pushes this widget directly.
class FrictionScreen extends StatefulWidget {
  const FrictionScreen({
    super.key,
    this.model,
    this.autoStartClock = true,
    this.enableAudio = true,
  });

  static const String title = FrictionStrings.title;
  static const String subtitle = FrictionStrings.subtitle;
  static const Color accentColor = Color(0xFF0288D1);

  final FrictionModel? model;
  final bool autoStartClock;
  final bool enableAudio;

  @override
  State<FrictionScreen> createState() => FrictionScreenState();
}

class FrictionScreenState extends State<FrictionScreen> {
  late final FrictionModel model;
  late final bool _ownsModel;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      model = widget.model!;
      _ownsModel = false;
    } else {
      model = FrictionModel();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          FrictionScreen.title,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: FrictionScreen.accentColor,
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: SafeArea(
        top: false,
        child: FrictionPlayArea(
          model: model,
          autoStartClock: widget.autoStartClock,
          enableAudio: widget.enableAudio,
        ),
      ),
    );
  }
}
