/// Particle-backed atom — shred `ParticleAtom` domain subset for BAA.
library;

import 'dart:math' as math;

import '../constants/baa_constants.dart';
import 'atom_stability.dart';
import 'baa_particle.dart';
import 'nucleus_packing.dart';
import 'number_atom.dart';

/// Open shell slot for an electron.
class ElectronShellSlot {
  ElectronShellSlot({required this.index, required this.x, required this.y});

  final int index;
  final double x;
  final double y;
  BaaParticle? electron;
}

/// Atom composed of owned [BaaParticle] instances.
class ParticleAtom {
  ParticleAtom({
    this.innerElectronShellRadius = BAAConstants.innerElectronShellRadius,
    this.outerElectronShellRadius = BAAConstants.outerElectronShellRadius,
    this.nucleonRadius = BAAConstants.nucleonRadius,
  }) {
    _initShellSlots();
  }

  final double innerElectronShellRadius;
  final double outerElectronShellRadius;
  final double nucleonRadius;

  double atomX = 0;
  double atomY = 0;

  /// Unstable-nucleus visual offset (View reads; Model `step` may update).
  double nucleusOffsetX = 0;
  double nucleusOffsetY = 0;

  final List<BaaParticle> protons = <BaaParticle>[];
  final List<BaaParticle> neutrons = <BaaParticle>[];
  final List<BaaParticle> electrons = <BaaParticle>[];

  late final List<ElectronShellSlot> electronShellSlots;

  void _initShellSlots() {
    final slots = <ElectronShellSlot>[
      ElectronShellSlot(index: 0, x: innerElectronShellRadius, y: 0),
      ElectronShellSlot(index: 1, x: -innerElectronShellRadius, y: 0),
    ];
    const numOuter = BAAConstants.outerShellCapacity;
    var angle = math.pi / numOuter * 1.2;
    for (var i = 0; i < numOuter; i++) {
      slots.add(
        ElectronShellSlot(
          index: i + 2,
          x: math.cos(angle) * outerElectronShellRadius,
          y: math.sin(angle) * outerElectronShellRadius,
        ),
      );
      angle += 2 * math.pi / numOuter;
    }
    electronShellSlots = slots;
  }

  int get protonCount => protons.length;
  int get neutronCount => neutrons.length;
  int get electronCount => electrons.length;
  int get atomicNumber => protonCount;
  int get massNumber => protonCount + neutronCount;
  int get charge => protonCount - electronCount;

  bool get nucleusStable =>
      AtomStability.isNucleusStable(protonCount, neutronCount);

  bool get isUnstable => !nucleusStable;

  NumberAtom toNumberAtom() => NumberAtom(protonCount, neutronCount, electronCount);

  bool contains(BaaParticle p) =>
      protons.contains(p) || neutrons.contains(p) || electrons.contains(p);

  /// Add particle; updates shell / nucleus packing.
  void addParticle(BaaParticle particle) {
    if (contains(particle)) return;

    if (particle.isProton) {
      protons.add(particle);
      particle.container = BaaParticleContainer.atom;
      particle.electronShellIndex = null;
      reconfigureNucleus();
    } else if (particle.isNeutron) {
      neutrons.add(particle);
      particle.container = BaaParticleContainer.atom;
      particle.electronShellIndex = null;
      reconfigureNucleus();
    } else if (particle.isElectron) {
      electrons.add(particle);
      particle.container = BaaParticleContainer.atom;
      _placeElectronInShell(particle);
    }
  }

  void _placeElectronInShell(BaaParticle particle) {
    final open = electronShellSlots.where((s) => s.electron == null).toList();
    // Proximal sort by distance to particle, then force inner shell first
    // (shred: sort by distance to particle, then by distance to atom center).
    open.sort((a, b) {
      final da = particle.distanceTo(atomX + a.x, atomY + a.y);
      final db = particle.distanceTo(atomX + b.x, atomY + b.y);
      final cmp = da.compareTo(db);
      if (cmp != 0) return cmp;
      final ra = math.sqrt(a.x * a.x + a.y * a.y);
      final rb = math.sqrt(b.x * b.x + b.y * b.y);
      return ra.compareTo(rb);
    });
    // Put inner shell positions in front (distance to atom center).
    open.sort((a, b) {
      final ra = math.sqrt(a.x * a.x + a.y * a.y);
      final rb = math.sqrt(b.x * b.x + b.y * b.y);
      return ra.compareTo(rb);
    });
    assert(open.isNotEmpty, 'No open electron shell positions');
    final slot = open.first;
    slot.electron = particle;
    particle.electronShellIndex = slot.index;
    particle.setDestination(atomX + slot.x, atomY + slot.y);
  }

  void removeParticle(BaaParticle particle) {
    if (protons.remove(particle)) {
      particle.container = null;
      reconfigureNucleus();
      return;
    }
    if (neutrons.remove(particle)) {
      particle.container = null;
      reconfigureNucleus();
      return;
    }
    if (electrons.remove(particle)) {
      _clearElectronSlot(particle);
      particle.container = null;
      particle.electronShellIndex = null;
      return;
    }
    throw StateError('Particle not in this atom');
  }

  void _clearElectronSlot(BaaParticle removed) {
    ElectronShellSlot? freed;
    for (final slot in electronShellSlots) {
      if (slot.electron == removed) {
        slot.electron = null;
        freed = slot;
        break;
      }
    }
    if (freed == null) return;
    final freedSlot = freed;

    // If inner shell emptied, move nearest outer electron inward.
    final freedR =
        math.sqrt(freedSlot.x * freedSlot.x + freedSlot.y * freedSlot.y);
    if ((freedR - innerElectronShellRadius).abs() < 1e-5) {
      final outerOccupied = electronShellSlots.where((s) {
        if (s.electron == null) return false;
        final r = math.sqrt(s.x * s.x + s.y * s.y);
        return (r - outerElectronShellRadius).abs() < 1e-5;
      }).toList()
        ..sort((a, b) {
          final da = math.sqrt(math.pow(a.x - freedSlot.x, 2) +
              math.pow(a.y - freedSlot.y, 2));
          final db = math.sqrt(math.pow(b.x - freedSlot.x, 2) +
              math.pow(b.y - freedSlot.y, 2));
          return da.compareTo(db);
        });
      if (outerOccupied.isNotEmpty) {
        final donor = outerOccupied.first;
        freedSlot.electron = donor.electron;
        donor.electron = null;
        final moved = freedSlot.electron!;
        moved.electronShellIndex = freedSlot.index;
        moved.setDestination(atomX + freedSlot.x, atomY + freedSlot.y);
      }
    }
  }

  /// Extract last particle of [type] (shred `extractParticle`).
  BaaParticle? extractParticle(BaaParticleType type) {
    BaaParticle? p;
    switch (type) {
      case BaaParticleType.proton:
        if (protons.isNotEmpty) p = protons.last;
      case BaaParticleType.neutron:
        if (neutrons.isNotEmpty) p = neutrons.last;
      case BaaParticleType.electron:
        if (electrons.isNotEmpty) p = electrons.last;
    }
    if (p != null) removeParticle(p);
    return p;
  }

  void reconfigureNucleus() {
    NucleusPacking.reconfigure(
      protons: protons,
      neutrons: neutrons,
      nucleonRadius: nucleonRadius,
      centerX: atomX + nucleusOffsetX,
      centerY: atomY + nucleusOffsetY,
    );
  }

  void clear() {
    for (final p in [...protons, ...neutrons, ...electrons]) {
      p.container = null;
      p.electronShellIndex = null;
    }
    protons.clear();
    neutrons.clear();
    electrons.clear();
    for (final s in electronShellSlots) {
      s.electron = null;
    }
    nucleusOffsetX = 0;
    nucleusOffsetY = 0;
  }

  void snapAllToDestination() {
    for (final p in [...protons, ...neutrons, ...electrons]) {
      p.moveImmediatelyToDestination();
    }
  }
}
