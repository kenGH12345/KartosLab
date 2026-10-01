import 'dart:math' as math;

import 'pair_group.dart';
import 'vec3.dart';

/// Index permutation. Matches `dot/Permutation` for the attractor search.
class Permutation {
  Permutation(this.indices);

  final List<int> indices;

  int get size => indices.length;

  int apply(int i) => indices[i];

  /// Inverse map: if `apply(i) == j` then `inverted().apply(j) == i`.
  Permutation inverted() {
    final inv = List<int>.filled(size, 0);
    for (var i = 0; i < size; i++) {
      inv[apply(i)] = i;
    }
    return Permutation(inv);
  }

  static Permutation identity(int n) => Permutation(List.generate(n, (i) => i));

  static List<Permutation> all(int n) {
    final results = <Permutation>[];
    void go(List<int> prefix, List<int> remaining) {
      if (remaining.isEmpty) {
        results.add(Permutation(List.of(prefix)));
        return;
      }
      for (var i = 0; i < remaining.length; i++) {
        final next = List.of(remaining)..removeAt(i);
        go([...prefix, remaining[i]], next);
      }
    }

    go([], List.generate(n, (i) => i));
    return results;
  }

  /// `Permutation.withIndicesPermuted` over a subset of slots.
  List<Permutation> withIndicesPermuted(List<int> subset) {
    if (subset.length < 2) {
      return [this];
    }
    final results = <Permutation>[];
    for (final perm in all(subset.length)) {
      final next = List.of(indices);
      for (var i = 0; i < subset.length; i++) {
        next[subset[i]] = indices[subset[perm.apply(i)]];
      }
      results.add(Permutation(next));
    }
    return results;
  }

  @override
  bool operator ==(Object other) =>
      other is Permutation &&
      other.indices.length == indices.length &&
      ListEquality.equals(other.indices, indices);

  @override
  int get hashCode => Object.hashAll(indices);
}

class ListEquality {
  static bool equals(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}

/// Result of matching current orientations to ideal slots.
class AttractorMapping {
  AttractorMapping({
    required this.error,
    required this.targetOrientations,
    required this.permutation,
    required this.rotation,
  });

  final double error;
  final List<Vec3> targetOrientations;
  final Permutation permutation;
  final Mat3 rotation;

  Vec3 rotateVector(Vec3 v) => rotation.times(v);
}

/// `AttractorModel.js` — SVD (Kabsch) attraction toward VSEPR slots.
class AttractorModel {
  static List<Vec3> orientationsFromOrigin(List<PairGroup> groups) =>
      groups.map((group) => group.orientation).toList();

  /// Lone pairs permute among themselves; bonded atoms permute among themselves.
  /// Bond order is ignored (source explicitly rejected double/triple preference).
  static List<Permutation> vseprPermutations(List<PairGroup> neighbors) {
    var permutations = [Permutation.identity(neighbors.length)];
    final loneIndices = <int>[];
    final atomIndices = <int>[];
    for (var i = 0; i < neighbors.length; i++) {
      if (neighbors[i].isLonePair) {
        loneIndices.add(i);
      } else {
        atomIndices.add(i);
      }
    }
    permutations = _expand(permutations, loneIndices);
    permutations = _expand(permutations, atomIndices);
    return permutations;
  }

  static List<Permutation> _expand(
    List<Permutation> current,
    List<int> indices,
  ) {
    if (indices.length < 2) {
      return current;
    }
    final next = <Permutation>[];
    for (final perm in current) {
      next.addAll(perm.withIndicesPermuted(indices));
    }
    return next;
  }

  static AttractorMapping findClosestMatchingConfiguration({
    required List<Vec3> currentOrientations,
    required List<Vec3> idealOrientations,
    required List<Permutation> allowablePermutations,
    Permutation? lastPermutation,
  }) {
    assert(currentOrientations.length == idealOrientations.length);
    AttractorMapping? best;
    if (lastPermutation != null) {
      best = _score(currentOrientations, idealOrientations, lastPermutation);
    }
    for (final permutation in allowablePermutations) {
      if (best != null &&
          currentOrientations.length > 2 &&
          best.permutation != permutation) {
        final i0 = permutation.apply(0);
        final i1 = permutation.apply(1);
        final lowBound = 4 -
            4 *
                math.cos(
                  (math.acos(
                            currentOrientations[0]
                                .dot(idealOrientations[i0])
                                .clamp(-1.0, 1.0),
                          ) -
                          math.acos(
                            currentOrientations[1]
                                .dot(idealOrientations[i1])
                                .clamp(-1.0, 1.0),
                          ))
                      .abs(),
                );
        if (best.error < lowBound) {
          continue;
        }
      }
      final result = _score(currentOrientations, idealOrientations, permutation);
      if (best == null || result.error < best.error) {
        best = result;
      }
    }
    return best!;
  }

  static AttractorMapping _score(
    List<Vec3> current,
    List<Vec3> ideal,
    Permutation permutation,
  ) {
    final n = current.length;
    final permuted = List<Vec3>.generate(n, (i) => ideal[permutation.apply(i)]);
    final rotation = _kabsch(permuted, current);
    final targets = List<Vec3>.generate(n, (i) => rotation.times(permuted[i]).normalized());
    var error = 0.0;
    for (var i = 0; i < n; i++) {
      final d = current[i].minus(targets[i]);
      error += d.dot(d);
    }
    return AttractorMapping(
      error: error,
      targetOrientations: targets,
      permutation: permutation,
      rotation: rotation,
    );
  }

  /// Rotation minimizing ‖R·x_i − y_i‖ (columns of X mapped to Y).
  static Mat3 _kabsch(List<Vec3> x, List<Vec3> y) {
    // S = X * Y^T
    final s = List<double>.filled(9, 0);
    for (var i = 0; i < x.length; i++) {
      s[0] += x[i].x * y[i].x;
      s[1] += x[i].x * y[i].y;
      s[2] += x[i].x * y[i].z;
      s[3] += x[i].y * y[i].x;
      s[4] += x[i].y * y[i].y;
      s[5] += x[i].y * y[i].z;
      s[6] += x[i].z * y[i].x;
      s[7] += x[i].z * y[i].y;
      s[8] += x[i].z * y[i].z;
    }
    final svd = _svd3(s);
    // R = V * U^T
    return svd.v.timesMat(svd.u.transposed());
  }

  static ({Mat3 u, Mat3 v}) _svd3(List<double> a) {
    // Jacobi SVD for 3×3. Enough for the attractor's constant-size matrices.
    var ata = Mat3(a).transposed().timesMat(Mat3(a));
    var v = Mat3.identity;
    for (var iter = 0; iter < 12; iter++) {
      var converged = true;
      for (final pair in const [
        [0, 1],
        [0, 2],
        [1, 2],
      ]) {
        final p = pair[0];
        final q = pair[1];
        final app = ata.m[p * 3 + p];
        final aqq = ata.m[q * 3 + q];
        final apq = ata.m[p * 3 + q];
        if (apq.abs() < 1e-12) {
          continue;
        }
        converged = false;
        final tau = (aqq - app) / (2 * apq);
        final t = tau >= 0
            ? 1 / (tau + math.sqrt(1 + tau * tau))
            : -1 / (-tau + math.sqrt(1 + tau * tau));
        final c = 1 / math.sqrt(1 + t * t);
        final s = t * c;
        final j = Mat3.identity;
        final jm = List<double>.from(j.m);
        jm[p * 3 + p] = c;
        jm[q * 3 + q] = c;
        jm[p * 3 + q] = s;
        jm[q * 3 + p] = -s;
        final jacobi = Mat3(jm);
        ata = jacobi.transposed().timesMat(ata).timesMat(jacobi);
        v = v.timesMat(jacobi);
      }
      if (converged) {
        break;
      }
    }
    final av = Mat3(a).timesMat(v);
    final uCols = <Vec3>[];
    final vCols = <Vec3>[];
    for (var i = 0; i < 3; i++) {
      final col = Vec3(av.m[i], av.m[3 + i], av.m[6 + i]);
      final sigma = col.magnitude;
      uCols.add(sigma > 1e-12 ? col.times(1 / sigma) : _fallbackAxis(uCols));
      vCols.add(Vec3(v.m[i], v.m[3 + i], v.m[6 + i]));
    }
    // Ensure right-handed (det >= 0) so we do not introduce a reflection.
    final u = Mat3.columns(uCols[0], uCols[1], uCols[2]);
    final vv = Mat3.columns(vCols[0], vCols[1], vCols[2]);
    if (u.determinant * vv.determinant < 0) {
      final flipped = Mat3.columns(uCols[0], uCols[1], uCols[2].negated());
      return (u: flipped, v: vv);
    }
    return (u: u, v: vv);
  }

  static Vec3 _fallbackAxis(List<Vec3> existing) {
    const candidates = [Vec3.xUnit, Vec3.yUnit, Vec3.zUnit];
    for (final candidate in candidates) {
      var ok = true;
      for (final e in existing) {
        if (e.dot(candidate).abs() > 0.9) {
          ok = false;
          break;
        }
      }
      if (ok) {
        return candidate;
      }
    }
    return const Vec3(0, 0, 1);
  }

  /// Returns least-squares error after applying forces for [dt].
  static double applyAttractorForces({
    required List<PairGroup> groups,
    required double dt,
    required List<Vec3> idealOrientations,
    required List<Permutation> allowablePermutations,
    required Vec3 center,
    bool angleRepulsion = false,
    Permutation? lastPermutation,
  }) {
    final live = <Vec3>[];
    for (final group in groups) {
      final offset = group.position.minus(center);
      live.add(offset.magnitude > 0 ? offset.normalized() : Vec3.zero);
    }
    final mapping = findClosestMatchingConfiguration(
      currentOrientations: live,
      idealOrientations: idealOrientations,
      allowablePermutations: allowablePermutations,
      lastPermutation: lastPermutation,
    );
    final aroundCenter = center.almostEquals(Vec3.zero);
    var totalDelta = 0.0;
    for (var i = 0; i < groups.length; i++) {
      final pair = groups[i];
      final currentMagnitude = pair.position.minus(center).magnitude;
      final targetPosition =
          mapping.targetOrientations[i].times(currentMagnitude).plus(center);
      final delta = targetPosition.minus(pair.position);
      totalDelta += delta.dot(delta);
      final strength = dt * 3 * delta.magnitude;
      if (pair.isLonePair || !pair.isCentralAtom) {
        if (aroundCenter) {
          pair.addVelocity(delta.times(strength));
        }
      }
      if (!pair.isCentralAtom && aroundCenter) {
        pair.addPosition(delta.times(2.0 * dt));
      }
      if (!pair.isCentralAtom && !aroundCenter) {
        pair.addPosition(delta.times(math.min(20.0 * dt, 1)));
      }
    }
    if (angleRepulsion && aroundCenter) {
      for (var aIndex = 0; aIndex < groups.length; aIndex++) {
        for (var bIndex = aIndex + 1; bIndex < groups.length; bIndex++) {
          final a = groups[aIndex];
          final b = groups[bIndex];
          final aOrientation = a.position.minus(center).normalized();
          final bOrientation = b.position.minus(center).normalized();
          final aTarget = mapping.targetOrientations[aIndex];
          final bTarget = mapping.targetOrientations[bIndex];
          final targetAngle = math.acos(aTarget.dot(bTarget).clamp(-1.0, 1.0));
          final currentAngle =
              math.acos(aOrientation.dot(bOrientation).clamp(-1.0, 1.0));
          final angleDifference = targetAngle - currentAngle;
          final dirTowardsA = a.position.minus(b.position).normalized();
          final timeFactor = PairGroup.timescaleImpulseFactor(dt);
          final oscillationPrevention = (lastPermutation != null &&
                  lastPermutation != mapping.permutation)
              ? 0.5
              : 1.0;
          final extraClose = (3 *
                  math.pow(math.pi - currentAngle, 2) /
                  (math.pi * math.pi))
              .clamp(1.0, 3.0);
          final push = dirTowardsA.times(
            oscillationPrevention *
                timeFactor *
                angleDifference *
                PairGroup.angleRepulsionScale *
                (currentAngle < targetAngle ? 2.0 : 0.5) *
                extraClose,
          );
          a.addVelocity(push);
          b.addVelocity(push.negated());
        }
      }
    }
    return math.sqrt(totalDelta);
  }
}

extension on Mat3 {
  double get determinant {
    final a = m;
    return a[0] * (a[4] * a[8] - a[5] * a[7]) -
        a[1] * (a[3] * a[8] - a[5] * a[6]) +
        a[2] * (a[3] * a[7] - a[4] * a[6]);
  }
}
