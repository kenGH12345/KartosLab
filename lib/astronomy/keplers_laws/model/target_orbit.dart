/// [已确认] `js/common/model/TargetOrbit.ts`
library;

class TargetOrbit {
  const TargetOrbit({
    required this.id,
    required this.name,
    required this.eccentricity,
    required this.semiMajorAxis,
  });

  final String id;
  final String name;
  final double eccentricity;
  final double semiMajorAxis;

  static const none = TargetOrbit(
    id: 'none',
    name: 'None',
    eccentricity: 0,
    semiMajorAxis: 0,
  );

  static const mercury = TargetOrbit(
    id: 'mercury',
    name: 'Mercury',
    eccentricity: 0.2056,
    semiMajorAxis: 0.4,
  );
  static const venus = TargetOrbit(
    id: 'venus',
    name: 'Venus',
    eccentricity: 0.0068,
    semiMajorAxis: 0.7,
  );
  static const earth = TargetOrbit(
    id: 'earth',
    name: 'Earth',
    eccentricity: 0.0167,
    semiMajorAxis: 1.0,
  );
  static const mars = TargetOrbit(
    id: 'mars',
    name: 'Mars',
    eccentricity: 0.0934,
    semiMajorAxis: 1.5,
  );
  static const jupiter = TargetOrbit(
    id: 'jupiter',
    name: 'Jupiter',
    eccentricity: 0.0484,
    semiMajorAxis: 5.2,
  );

  /// Eccentricity panel comparison orbits (not combo defaults).
  static const eris = TargetOrbit(
    id: 'eris',
    name: 'Eris',
    eccentricity: 0.44,
    semiMajorAxis: 67.6,
  );
  static const nereid = TargetOrbit(
    id: 'nereid',
    name: 'Nereid',
    eccentricity: 0.75,
    semiMajorAxis: 30.11,
  );
  static const halley = TargetOrbit(
    id: 'halley',
    name: 'Halley',
    eccentricity: 0.967,
    semiMajorAxis: 18.5,
  );

  static const comboItems = [none, mercury, venus, earth, mars, jupiter];
}
