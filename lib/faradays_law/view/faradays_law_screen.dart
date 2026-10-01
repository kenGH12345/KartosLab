import 'package:flutter/material.dart';

import '../model/faradays_law_model.dart';
import 'faradays_law_play_area.dart';

/// Single-screen Faraday's Law — PhET `FaradaysLawScreen`.
///
/// Home entry (物理 → 电磁学) pushes this widget directly (Magnet peer).
/// Play-area physics / visuals unchanged from Phase 2–5.
class FaradaysLawScreen extends StatefulWidget {
  const FaradaysLawScreen({
    super.key,
    this.model,
    this.autoStartClock = true,
  });

  /// Home card / AppBar title (PhET English name).
  static const String title = "Faraday's Law";

  /// Home card subtitle.
  static const String subtitle = '磁铁 · 线圈 · 感应电动势';

  /// Home card accent (KartosLab Material card chrome).
  static const Color accentColor = Color(0xFF0277BD);

  final FaradaysLawModel? model;
  final bool autoStartClock;

  @override
  State<FaradaysLawScreen> createState() => FaradaysLawScreenState();
}

class FaradaysLawScreenState extends State<FaradaysLawScreen> {
  late final FaradaysLawModel model;
  late final bool _ownsModel;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      model = widget.model!;
      _ownsModel = false;
    } else {
      model = FaradaysLawModel();
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
      backgroundColor: const Color(0xFF97D0FF),
      appBar: AppBar(
        title: const Text(
          FaradaysLawScreen.title,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: FaradaysLawScreen.accentColor,
        foregroundColor: Colors.white,
        toolbarHeight: 44,
      ),
      body: SafeArea(
        // Top already accounted by AppBar; keep left/right/bottom insets.
        top: false,
        child: FaradaysLawPlayArea(
          model: model,
          autoStartClock: widget.autoStartClock,
        ),
      ),
    );
  }
}
