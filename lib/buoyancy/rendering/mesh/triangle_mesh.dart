/// Indexed triangle mesh in local model meters.
class TriangleMesh {
  const TriangleMesh({
    required this.positions,
    required this.indices,
  });

  final List<double> positions;
  final List<int> indices;

  int get vertexCount => positions.length ~/ 3;
  int get triangleCount => indices.length ~/ 3;

  ({double minX, double maxX, double minY, double maxY, double minZ, double maxZ})
      bounds() {
    var minX = positions[0], maxX = positions[0];
    var minY = positions[1], maxY = positions[1];
    var minZ = positions[2], maxZ = positions[2];
    for (var i = 0; i < positions.length; i += 3) {
      final x = positions[i], y = positions[i + 1], z = positions[i + 2];
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
      if (z < minZ) minZ = z;
      if (z > maxZ) maxZ = z;
    }
    return (
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      minZ: minZ,
      maxZ: maxZ,
    );
  }
}
