import 'package:flutter/material.dart';

import '../model/abs_beaker.dart';
import '../model/particle_key.dart';
import '../model/solutions/aqueous_solution.dart';
import '../model/solutions/strong_acid.dart';
import '../model/solutions/strong_base.dart';
import '../model/solutions/water.dart';
import '../model/solutions/weak_acid.dart';
import '../model/solutions/weak_base.dart';
import 'abs_particle_painter.dart';

/// Reaction equation below beaker — PhET `ReactionEquationNode` / Factory.
///
/// Horizontal HBox (spacing 4, scale 1.5), centered under the beaker.
/// Species order matches graph bars left-to-right; do not force-fit into
/// bar slots (that overlaps formulas).
class AbsReactionEquation extends StatelessWidget {
  const AbsReactionEquation({
    super.key,
    required this.beaker,
    required this.solution,
  });

  final AbsBeaker beaker;
  final AqueousSolution solution;

  /// PhET `EQUATION_SCALE`
  static const double equationScale = 1.5;

  /// PhET HBox `spacing: 4` (pre-scale)
  static const double hSpacing = 4;

  @override
  Widget build(BuildContext context) {
    final children = _equationFor(solution);
    if (children.isEmpty) return const SizedBox.shrink();

    // PhET: centerX = beaker.position.x; top = beaker.position.y + 10
    return Positioned(
      left: beaker.position.dx,
      top: beaker.position.dy + 10,
      child: FractionalTranslation(
        translation: const Offset(-0.5, 0),
        child: Transform.scale(
          scale: equationScale,
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: hSpacing),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _equationFor(AqueousSolution s) {
    if (s is Water) {
      return [
        _water2Term(),
        _arrow(reversible: true),
        _term(ParticleKey.h3o, 'H₃O⁺'),
        _plus(),
        _term(ParticleKey.oh, 'OH⁻'),
      ];
    }
    if (s is StrongAcid) {
      return [
        _term(ParticleKey.ha, 'HA'),
        _plus(),
        _term(ParticleKey.h2o, 'H₂O'),
        _arrow(reversible: false),
        _term(ParticleKey.a, 'A⁻'),
        _plus(),
        _term(ParticleKey.h3o, 'H₃O⁺'),
      ];
    }
    if (s is WeakAcid) {
      return [
        _term(ParticleKey.ha, 'HA'),
        _plus(),
        _term(ParticleKey.h2o, 'H₂O'),
        _arrow(reversible: true),
        _term(ParticleKey.a, 'A⁻'),
        _plus(),
        _term(ParticleKey.h3o, 'H₃O⁺'),
      ];
    }
    if (s is StrongBase) {
      return [
        _term(ParticleKey.moh, 'MOH'),
        _arrow(reversible: false),
        _term(ParticleKey.m, 'M⁺'),
        _plus(),
        _term(ParticleKey.oh, 'OH⁻'),
      ];
    }
    if (s is WeakBase) {
      return [
        _term(ParticleKey.b, 'B'),
        _plus(),
        _term(ParticleKey.h2o, 'H₂O'),
        _arrow(reversible: true),
        _term(ParticleKey.bh, 'BH⁺'),
        _plus(),
        _term(ParticleKey.oh, 'OH⁻'),
      ];
    }
    return const [];
  }

  /// PhET `create2H2O` — two particle icons + "2 H₂O".
  Widget _water2Term() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AbsParticleIcon(ParticleKey.h2o, scale: 0.7),
            SizedBox(width: 4),
            AbsParticleIcon(ParticleKey.h2o, scale: 0.7),
          ],
        ),
        SizedBox(height: 2),
        Text(
          '2 H₂O',
          textAlign: TextAlign.center,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: TextStyle(fontFamily: 'Arial', fontSize: 13, height: 1),
        ),
      ],
    );
  }

  Widget _term(ParticleKey key, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AbsParticleIcon(key, scale: 0.7),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontFamily: 'Arial', fontSize: 13, height: 1),
        ),
      ],
    );
  }

  /// PhET plus sits on the formula baseline (VBox + VStrut).
  Widget _plus() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 1),
      child: Text(
        '+',
        softWrap: false,
        style: TextStyle(fontFamily: 'Arial', fontSize: 13, height: 1),
      ),
    );
  }

  Widget _arrow({required bool reversible}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Text(
        reversible ? '⇌' : '→',
        softWrap: false,
        style: const TextStyle(fontFamily: 'Arial', fontSize: 16, height: 1),
      ),
    );
  }
}
