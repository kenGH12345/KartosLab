import 'package:flutter/material.dart';

import '../concentration_assets.dart';
import '../model/concentration_model.dart';
import '../model/solute.dart';
import '../model/solute_form.dart';
import 'concentration_layout.dart';

/// Right-top solute combo + Solid/Solution radios — `SolutePanel.ts`.
class SolutePanel extends StatefulWidget {
  const SolutePanel({super.key, required this.model});

  final ConcentrationModel model;

  @override
  State<SolutePanel> createState() => _SolutePanelState();
}

class _SolutePanelState extends State<SolutePanel> {
  bool _listOpen = false;

  @override
  Widget build(BuildContext context) {
    const width = 280.0;
    return Positioned(
      right: ConcentrationLayout.layoutBounds.width -
          ConcentrationLayout.solutePanelRight,
      top: ConcentrationLayout.solutePanelTop,
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: ConcentrationLayout.panelFill,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SoluteComboButton(
                  solute: widget.model.solute,
                  open: _listOpen,
                  onTap: () => setState(() => _listOpen = !_listOpen),
                ),
                const SizedBox(height: 15),
                _SoluteFormRadios(model: widget.model),
              ],
            ),
          ),
          if (_listOpen)
            Container(
              margin: const EdgeInsets.only(top: 2),
              constraints: const BoxConstraints(maxHeight: 320),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade600),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  for (final s in widget.model.solutes)
                    _SoluteListTile(
                      solute: s,
                      selected: s.id == widget.model.solute.id,
                      onTap: () {
                        widget.model.setSolute(s);
                        setState(() => _listOpen = false);
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SoluteComboButton extends StatelessWidget {
  const _SoluteComboButton({
    required this.solute,
    required this.open,
    required this.onTap,
  });

  final Solute solute;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: solute.colorScheme.maxColor,
                border: Border.all(color: Colors.black54),
              ),
            ),
            Expanded(
              child: Text(
                solute.displayName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Text(
              open ? '▲' : '▼',
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoluteListTile extends StatelessWidget {
  const _SoluteListTile({
    required this.solute,
    required this.selected,
    required this.onTap,
  });

  final Solute solute;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color.fromARGB(255, 218, 255, 255)
          : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: solute.colorScheme.maxColor,
                  border: Border.all(color: Colors.black54),
                ),
              ),
              Expanded(
                child: Text(
                  solute.displayName,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoluteFormRadios extends StatelessWidget {
  const _SoluteFormRadios({required this.model});

  final ConcentrationModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FormOption(
            selected: model.soluteForm == SoluteForm.solid,
            label: 'Solid',
            iconAsset: ConcentrationAssets.shakerIcon,
            onTap: () => model.setSoluteForm(SoluteForm.solid),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FormOption(
            selected: model.soluteForm == SoluteForm.solution,
            label: 'Solution',
            iconAsset: ConcentrationAssets.dropperIcon,
            onTap: () => model.setSoluteForm(SoluteForm.solution),
          ),
        ),
      ],
    );
  }
}

class _FormOption extends StatelessWidget {
  const _FormOption({
    required this.selected,
    required this.label,
    required this.iconAsset,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? const Color(0xFF1565C0) : Colors.grey,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Image.asset(iconAsset, width: 28, height: 28),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Evaporation panel — `EvaporationPanel.ts` / `EvaporationSlider.ts`.
///
/// Pointer end / cancel / focus loss snaps rate to 0 (source endDrag + blur).
class EvaporationPanel extends StatelessWidget {
  const EvaporationPanel({super.key, required this.model});

  final ConcentrationModel model;

  @override
  Widget build(BuildContext context) {
    final ev = model.evaporator;
    return Positioned(
      left: ConcentrationLayout.evaporationLeft,
      top: ConcentrationLayout.evaporationTop,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: ConcentrationLayout.panelFill,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Evaporation:', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            SizedBox(
              // Source EvaporationSlider trackSize.width = 150 (+ thumb overhang)
              width: 150 + _EvaporationThumbShape.size.width,
              child: Column(
                children: [
                  Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) model.releaseEvaporation();
                    },
                    child: Listener(
                      onPointerCancel: (_) => model.releaseEvaporation(),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          // Source EvaporationSlider: trackSize 150×6, thumbSize 22×45
                          trackHeight: 6,
                          activeTrackColor: const Color(0xFF42A5F5),
                          inactiveTrackColor: Colors.grey.shade400,
                          thumbColor: const Color(0xFF1591B8),
                          thumbShape: const _EvaporationThumbShape(),
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: ev.evaporationRate,
                          min: 0,
                          max: ev.maxEvaporationRate,
                          onChanged: ev.enabled
                              ? (v) => model.setEvaporationRate(v)
                              : null,
                          onChangeEnd: (_) => model.releaseEvaporation(),
                        ),
                      ),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('none', style: TextStyle(fontSize: 16)),
                      Text('lots', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// PhET sun HSlider thumb — `EvaporationSlider.ts` thumbSize (22, 45).
class _EvaporationThumbShape extends SliderComponentShape {
  const _EvaporationThumbShape();

  static const Size size = Size(22, 45);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => size;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final rect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    final fill = sliderTheme.thumbColor ?? const Color(0xFF1591B8);
    final canvas = context.canvas;
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.55),
            fill,
            fill.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(rect),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(center.dx, rect.top + 8),
      Offset(center.dx, rect.bottom - 8),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 1.5,
    );
  }
}

/// Saturated! banner — `SaturatedIndicator.ts`.
///
/// Visible when [ConcentrationModel.isSaturated] (source `isSaturatedProperty`).
/// Centered on beaker; `bottom = beaker.bottom - 30`.
class SaturatedIndicator extends StatelessWidget {
  const SaturatedIndicator({super.key, required this.model});

  final ConcentrationModel model;

  static const String label = 'Saturated!';
  static const double fontSize = 20;
  static const EdgeInsets padding =
      EdgeInsets.symmetric(horizontal: 10, vertical: 5);

  @override
  Widget build(BuildContext context) {
    if (!model.isSaturated) return const SizedBox.shrink();

    final painter = TextPainter(
      text: const TextSpan(
        text: label,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 400);

    final boxW = painter.width + padding.horizontal;
    final boxH = painter.height + padding.vertical;
    final left = model.beaker.position.dx - boxW / 2;
    final top = ConcentrationLayout.beakerBottom - 30 - boxH;

    return Positioned(
      left: left,
      top: top,
      width: boxW,
      height: boxH,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Color.grayColor(240) @ opacity 0.6
            color: const Color.fromARGB(153, 240, 240, 240),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: padding,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: fontSize,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Remove Solute button — `RemoveSoluteButton.ts`.
class RemoveSoluteButton extends StatelessWidget {
  const RemoveSoluteButton({super.key, required this.model});

  final ConcentrationModel model;

  @override
  Widget build(BuildContext context) {
    final enabled = model.removeSoluteEnabled;
    return Positioned(
      left: ConcentrationLayout.evaporationLeft + 340,
      top: ConcentrationLayout.evaporationTop + 18,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: GestureDetector(
          onTap: enabled ? model.removeSolute : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ConcentrationLayout.removeSoluteBase,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black26),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: const Text(
              'Remove Solute',
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
