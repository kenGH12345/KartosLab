import 'reaction.dart';

/// Base model for Sandwiches and Molecules screens — `RPALBaseModel.ts`.
class RpalBaseModel<R extends Reaction> {
  RpalBaseModel(this.reactions) : selectedReaction = reactions.first;

  final List<R> reactions;
  R selectedReaction;

  void selectReaction(R reaction) {
    assert(reactions.contains(reaction));
    selectedReaction = reaction;
  }

  void reset() {
    selectedReaction = reactions.first;
    for (final reaction in reactions) {
      reaction.reset();
    }
  }
}
