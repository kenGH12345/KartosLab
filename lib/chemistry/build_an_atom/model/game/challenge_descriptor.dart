/// Challenge descriptor — PhET `ChallengeDescriptor`.
library;

import '../number_atom.dart';
import 'challenge_type.dart';

/// Type + correct atom value used to configure a challenge instance.
class ChallengeDescriptor {
  const ChallengeDescriptor({
    required this.type,
    required this.atomValue,
  });

  final ChallengeType type;
  final NumberAtom atomValue;
}
