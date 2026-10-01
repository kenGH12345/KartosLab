import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../layout/membrane_transport_layout.dart';
import '../membrane_transport_feature_set.dart';
import '../model/membrane_transport_model.dart';
import '../model/transport_protein_type.dart';

/// Right-side transport protein toolbox — PhET `TransportProteinPanel.ts`.
class TransportProteinPanel extends StatelessWidget {
  const TransportProteinPanel({
    super.key,
    required this.model,
    this.onDragStart,
  });

  final MembraneTransportModel model;

  /// Global pointer position when drag starts from toolbox.
  final void Function(TransportProteinType type, Offset globalPosition)?
      onDragStart;

  static const double panelWidth = MembraneTransportLayoutPrimitives.proteinPanelWidth;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[];
    final fs = model.featureSet;

    if (fs == MembraneTransportFeatureSet.facilitatedDiffusion ||
        fs == MembraneTransportFeatureSet.playground) {
      sections.add(
        _ChannelSection(
          title: 'Leakage Channels',
          types: const [
            TransportProteinType.sodiumIonLeakageChannel,
            TransportProteinType.potassiumIonLeakageChannel,
          ],
          labels: const ['Sodium Ion', 'Potassium Ion'],
          model: model,
          onDragStart: onDragStart,
        ),
      );
      sections.add(const Divider(height: 1, color: Colors.black));
      sections.add(
        _ChannelSection(
          title: 'Voltage-Gated Channels',
          types: const [
            TransportProteinType.sodiumIonVoltageGatedChannel,
            TransportProteinType.potassiumIonVoltageGatedChannel,
          ],
          labels: const ['Sodium Ion', 'Potassium Ion'],
          model: model,
          onDragStart: onDragStart,
          footer: _MembranePotentialControls(model: model),
        ),
      );
      sections.add(const Divider(height: 1, color: Colors.black));
      sections.add(
        _ChannelSection(
          title: 'Ligand-Gated Channels',
          types: const [
            TransportProteinType.sodiumIonLigandGatedChannel,
            TransportProteinType.potassiumIonLigandGatedChannel,
          ],
          labels: const ['Sodium Ion', 'Potassium Ion'],
          model: model,
          onDragStart: onDragStart,
          footer: _LigandToggle(model: model),
        ),
      );
    }

    if (fs == MembraneTransportFeatureSet.activeTransport ||
        fs == MembraneTransportFeatureSet.playground) {
      if (sections.isNotEmpty) {
        sections.add(const Divider(height: 1, color: Colors.black));
      }
      sections.add(
        _ChannelSection(
          title: 'Active Transporters',
          types: const [
            TransportProteinType.sodiumPotassiumPump,
            TransportProteinType.sodiumGlucoseCotransporter,
          ],
          labels: const ['Na⁺/K⁺ Pump', 'Na⁺/Glucose'],
          model: model,
          onDragStart: onDragStart,
        ),
      );
    }

    return Container(
      width: panelWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black45),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: sections,
      ),
    );
  }
}

class _ChannelSection extends StatelessWidget {
  const _ChannelSection({
    required this.title,
    required this.types,
    required this.labels,
    required this.model,
    this.onDragStart,
    this.footer,
  });

  final String title;
  final List<TransportProteinType> types;
  final List<String> labels;
  final MembraneTransportModel model;
  final void Function(TransportProteinType type, Offset globalPosition)?
      onDragStart;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < types.length; i++)
                _ProteinTool(
                  type: types[i],
                  label: labels[i],
                  model: model,
                  onDragStart: onDragStart,
                ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 6),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _ProteinTool extends StatelessWidget {
  const _ProteinTool({
    required this.type,
    required this.label,
    required this.model,
    this.onDragStart,
  });

  final TransportProteinType type;
  final String label;
  final MembraneTransportModel model;
  final void Function(TransportProteinType type, Offset globalPosition)?
      onDragStart;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => model.placeProtein(type),
      onPanStart: onDragStart == null
          ? null
          : (d) => onDragStart!(type, d.globalPosition),
      child: SizedBox(
        width: 88,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 52,
              child: SvgPicture.asset(
                MembraneTransportAssets.forProteinToolbox(type),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _MembranePotentialControls extends StatelessWidget {
  const _MembranePotentialControls({required this.model});
  final MembraneTransportModel model;

  static const potentials = [-70, -50, 30];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Membrane Potential (mV)', style: TextStyle(fontSize: 11)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final v in potentials)
              _PotentialRadio(
                value: v,
                selected: model.membranePotential == v,
                onTap: () => model.setMembranePotential(v),
              ),
          ],
        ),
        const SizedBox(height: 2),
        // Potential axis cue (double-headed arrow stand-in)
        SizedBox(
          height: 10,
          width: 160,
          child: CustomPaint(painter: _PotentialAxisPainter()),
        ),
        InkWell(
          onTap: () => model.setChargesVisible(!model.chargesVisible),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: Checkbox(
                  value: model.chargesVisible,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onChanged: (v) => model.setChargesVisible(v ?? false),
                ),
              ),
              const SizedBox(width: 4),
              const Text('Charges', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PotentialRadio extends StatelessWidget {
  const _PotentialRadio({
    required this.value,
    required this.selected,
    required this.onTap,
  });
  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = value > 0 ? '+$value' : '$value';
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFBBDEFB) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? const Color(0xFF1565C0) : Colors.black38,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _PotentialAxisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(4, y), Offset(size.width - 4, y), paint);
    // arrow heads
    canvas.drawLine(Offset(4, y), const Offset(10, 1), paint);
    canvas.drawLine(Offset(4, y), Offset(10, size.height - 1), paint);
    canvas.drawLine(
      Offset(size.width - 4, y),
      Offset(size.width - 10, 1),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - 4, y),
      Offset(size.width - 10, size.height - 1),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LigandToggle extends StatelessWidget {
  const _LigandToggle({required this.model});
  final MembraneTransportModel model;

  @override
  Widget build(BuildContext context) {
    final added = model.areLigandsAdded;
    return Material(
      color: MembraneTransportColors.ligandButton,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => model.setAreLigandsAdded(!added),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            added ? 'Remove Ligands' : 'Add Ligands',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
