import 'package:flutter/material.dart';

import 'package:kratos/under_pressure/controller/under_pressure_controller.dart';
import 'package:kratos/under_pressure/model/under_pressure_model.dart';

/// Source: `SceneChoiceNode.js` — vertical radio icons.
class UpSceneChoiceNode extends StatelessWidget {
  const UpSceneChoiceNode({super.key, required this.controller});

  final UnderPressureController controller;

  static const _icons = <UnderPressureScene, String>{
    UnderPressureScene.square:
        'assets/simulations/under_pressure/images/squarePoolIcon.png',
    UnderPressureScene.trapezoid:
        'assets/simulations/under_pressure/images/trapezoidPoolIcon.png',
    UnderPressureScene.chamber:
        'assets/simulations/under_pressure/images/chamberPoolIcon.png',
    UnderPressureScene.mystery:
        'assets/simulations/under_pressure/images/mysteryPoolIcon.png',
  };

  @override
  Widget build(BuildContext context) {
    // Source: SceneChoiceNode { x: 10, y: 260 }
    return Positioned(
      left: 10,
      top: 260,
      child: Column(
        children: UnderPressureScene.values.map((scene) {
          final selected = controller.model.currentScene == scene;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => controller.setScene(scene),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? Colors.white : Colors.black26,
                    width: selected ? 3 : 1,
                  ),
                  boxShadow: selected
                      ? const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(_icons[scene]!, fit: BoxFit.contain),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
