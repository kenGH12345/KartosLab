import 'package:flutter/material.dart';

import '../mp_colors.dart';
import '../mp_constants.dart';

class MpSimulationShell extends StatelessWidget {
  const MpSimulationShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MpColors.screenBackground,
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'Arial',
          fontSize: 18,
          color: Colors.black,
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            width: MpConstants.layoutWidth,
            height: MpConstants.layoutHeight,
            child: ColoredBox(
              color: MpColors.screenBackground,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
