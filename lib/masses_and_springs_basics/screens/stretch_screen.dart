import 'package:flutter/material.dart';

import '../controller/masb_controller.dart';
import '../model/masb_model.dart';
import '../widgets/bounce_right_panel.dart';
import '../widgets/simulation_workspace.dart';

/// Stretch screen — same physics stack as Bounce, damping fixed at 0.7.
class StretchScreen extends StatefulWidget {
  const StretchScreen({super.key});

  @override
  State<StretchScreen> createState() => _StretchScreenState();
}

class _StretchScreenState extends State<StretchScreen>
    with SingleTickerProviderStateMixin {
  late final MasbController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MasbController(model: MasbModel.stretch());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              SimulationWorkspace(controller: _controller),
              Positioned(
                top: 8,
                right: 8,
                width: 190,
                child: SingleChildScrollView(
                  child: BounceRightPanel(controller: _controller),
                ),
              ),
            ],
          ),
        ),
        _StretchHud(controller: _controller),
      ],
    );
  }
}

class _StretchHud extends StatelessWidget {
  const _StretchHud({required this.controller});
  final MasbController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final m = controller.model;
        final s = m.spring;
        return Material(
          color: const Color(0xFF111827),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: m.playing ? 'Pause' : 'Play',
                    onPressed: controller.togglePlayPause,
                    icon: Icon(
                      m.playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Reset',
                    onPressed: controller.reset,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Stretch  damping=${m.damping.toStringAsFixed(1)}  '
                      'k=${s.springConstant.toStringAsFixed(0)}  '
                      'g=${m.gravity.toStringAsFixed(1)}  '
                      'x=${s.displacement.toStringAsFixed(3)}',
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
