import 'package:flutter/material.dart';

import '../../view/baa_phet_font.dart';
import '../charge_meter.dart';

/// PhET Game level selection icons (`*LevelIcon.ts`) — runtime geometry.
class GameLevelIcon extends StatelessWidget {
  const GameLevelIcon({
    super.key,
    required this.levelNumber,
    this.size = 72,
  });

  final int levelNumber;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (levelNumber) {
      case 1:
        return _Level1Icon(size: size);
      case 2:
        return _Level2Icon(size: size);
      case 3:
        return _Level3Icon(size: size);
      case 4:
        return _Level4Icon(size: size);
      default:
        return Text('$levelNumber', style: BaaPhetFont.of(38, fontWeight: FontWeight.bold));
    }
  }
}

class _Level1Icon extends StatelessWidget {
  const _Level1Icon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    // PeriodicTableLevelIcon: clipped PT image + "1"
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 0.55,
            child: Image.asset(
              'assets/build_an_atom/images/periodicTableIcon.png',
              width: size * 1.1,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (context, error, stackTrace) => SizedBox(
                width: size,
                height: size * 0.5,
                child: const ColoredBox(color: Color(0xFFFEFF99)),
              ),
            ),
          ),
        ),
        Text('1', style: BaaPhetFont.of(22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _Level2Icon extends StatelessWidget {
  const _Level2Icon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    // MassAndChargeLevelIcon: ChargeMeter + scale hint + "2"
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size * 0.7,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                child: Transform.scale(
                  scale: 0.7,
                  child: const ChargeMeter(
                    charge: 0,
                    width: 50,
                    showNumericalReadout: false,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Image.asset(
                  'assets/build_an_atom/images/scale.png',
                  width: size * 0.55,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(),
                ),
              ),
            ],
          ),
        ),
        Text('2', style: BaaPhetFont.of(22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _Level3Icon extends StatelessWidget {
  const _Level3Icon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    // SymbolLevelIcon: box with H / 1 / 1 / ?
    final box = size * 0.85;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: box,
          height: box * 1.05,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 4,
                top: 3,
                child: Text('1', style: BaaPhetFont.of(box * 0.22)),
              ),
              Positioned(
                right: 4,
                top: 3,
                child: Text('?', style: BaaPhetFont.of(box * 0.22)),
              ),
              Center(
                child: Text('H', style: BaaPhetFont.of(box * 0.45, fontWeight: FontWeight.w500)),
              ),
              Positioned(
                left: 4,
                bottom: 3,
                child: Text(
                  '1',
                  style: BaaPhetFont.of(box * 0.22, color: const Color(0xFFD14600)),
                ),
              ),
            ],
          ),
        ),
        Text('3', style: BaaPhetFont.of(22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _Level4Icon extends StatelessWidget {
  const _Level4Icon({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    final box = size * 0.85;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: box,
          height: box * 1.05,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Center(
            child: Text('?', style: BaaPhetFont.of(box * 0.7, fontWeight: FontWeight.w500)),
          ),
        ),
        Text('4', style: BaaPhetFont.of(22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
