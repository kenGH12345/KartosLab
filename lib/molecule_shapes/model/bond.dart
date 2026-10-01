import 'pair_group.dart';

/// Connection between two pair groups.
///
/// [order] is 0 for a lone pair, 1/2/3 for single/double/triple.
/// Order does not change how many electron domains the group counts as.
class Bond {
  Bond(this.a, this.b, this.order, this.length);

  final PairGroup a;
  final PairGroup b;
  final int order;
  final double length;

  bool contains(PairGroup group) => a == group || b == group;

  PairGroup other(PairGroup group) {
    assert(contains(group));
    return a == group ? b : a;
  }
}
