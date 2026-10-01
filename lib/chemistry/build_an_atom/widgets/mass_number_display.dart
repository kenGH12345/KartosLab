import 'package:flutter/material.dart';

/// PhET `MassNumberDisplay` — scale.png + numerical readout.
class MassNumberDisplay extends StatelessWidget {
  const MassNumberDisplay({
    super.key,
    required this.massNumber,
    this.width = 122,
  });

  final int massNumber;
  final double width;

  static const _asset = 'assets/build_an_atom/images/scale.png';

  @override
  Widget build(BuildContext context) {
    final readoutW = width * 0.25;
    final readoutH = width * 0.165;
    return SizedBox(
      width: width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            _asset,
            width: width,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) => Container(
              width: width,
              height: width * 0.55,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              child: const Text('scale'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              width: readoutW,
              height: readoutH,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                '$massNumber',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
