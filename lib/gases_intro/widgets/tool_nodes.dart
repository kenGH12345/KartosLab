import 'package:flutter/material.dart';

import '../view/tools_controller.dart';

/// Port of scenery-phet StopwatchNode + GasPropertiesStopwatchNode.
///
/// Digital readout (ps, 1 decimal) + reset + play/pause. Whole chrome is
/// draggable (buttons absorb taps). Positions via [ToolsController].
class GasPropertiesStopwatchTool extends StatelessWidget {
  const GasPropertiesStopwatchTool({
    super.key,
    required this.tools,
    required this.logicalBounds,
    required this.layoutScale,
  });

  final ToolsController tools;
  final Rect logicalBounds;
  final double layoutScale;

  static const Color _bg = Color(0xFF5082E6); // rgb(80,130,230)
  static const Color _btn = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final t = tools.stopwatchTimePs;
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(8),
      color: _bg,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => tools.bringToFront(ToolKind.stopwatch),
        onPanUpdate: (d) =>
            tools.dragStopwatch(d.delta, logicalBounds, layoutScale),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 148,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black87),
                ),
                child: Text(
                  '${t.toStringAsFixed(1)} ps',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ToolIconButton(
                    enabled: t > 0,
                    color: _btn,
                    onPressed: tools.resetStopwatchTime,
                    child: const Icon(Icons.u_turn_left,
                        size: 18, color: Color(0xFFE5002B)),
                  ),
                  const SizedBox(width: 8),
                  _ToolIconButton(
                    enabled: t < ToolsController.maxTimePs,
                    color: _btn,
                    onPressed: () =>
                        tools.setStopwatchRunning(!tools.stopwatchRunning),
                    child: Icon(
                      tools.stopwatchRunning ? Icons.pause : Icons.play_arrow,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Port of CollisionCounterNode (bezel + content + PlayReset + sample ComboBox).
class CollisionCounterTool extends StatelessWidget {
  const CollisionCounterTool({
    super.key,
    required this.tools,
    required this.logicalBounds,
    required this.layoutScale,
  });

  final ToolsController tools;
  final Rect logicalBounds;
  final double layoutScale;

  static const Color _panel = Color(0xFFFED483); // rgb(254,212,131)
  static const Color _bezel = Color(0xFF5A5A5A); // rgb(90,90,90)

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(10),
      color: _bezel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => tools.bringToFront(ToolKind.collision),
        onPanUpdate: (d) =>
            tools.dragCollision(d.delta, logicalBounds, layoutScale),
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Wall Collisions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 72),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Text(
                      '${tools.numberOfCollisions}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // PlayResetButton: false→play icon, true→reset icon
                  _ToolIconButton(
                    enabled: true,
                    color: const Color(0xFFDFE0E1),
                    onPressed: () =>
                        tools.setCollisionRunning(!tools.collisionRunning),
                    child: Icon(
                      tools.collisionRunning
                          ? Icons.u_turn_left
                          : Icons.play_arrow,
                      size: 18,
                      color: tools.collisionRunning
                          ? const Color(0xFFE5002B)
                          : const Color(0xFF00B300),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Sample Period',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: tools.samplePeriodPs,
                  isDense: true,
                  dropdownColor: Colors.white,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  items: [
                    for (final p in ToolsController.samplePeriods)
                      DropdownMenuItem(
                        value: p,
                        child: Text('$p ps'),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) tools.setSamplePeriod(v);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolIconButton extends StatelessWidget {
  const _ToolIconButton({
    required this.enabled,
    required this.color,
    required this.onPressed,
    required this.child,
  });

  final bool enabled;
  final Color color;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(4),
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: SizedBox(width: 36, height: 32, child: Center(child: child)),
        ),
      ),
    );
  }
}
