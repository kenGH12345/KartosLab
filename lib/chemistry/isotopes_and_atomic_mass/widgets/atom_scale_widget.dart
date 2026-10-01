/// AtomScaleNode — scale.png + massNumber / atomicMass readout.
library;

import 'package:flutter/material.dart';

import '../controller/make_isotopes_controller.dart';
import '../iaam_constants.dart';
import '../model/data/phet_number_utils.dart';

class AtomScaleWidget extends StatelessWidget {
  const AtomScaleWidget({
    super.key,
    required this.controller,
  });

  final MakeIsotopesController controller;

  @override
  Widget build(BuildContext context) {
    final m = controller.model;
    final mode = controller.displayMode;
    final String readout;
    if (mode == ScaleDisplayMode.massNumber) {
      readout = '${m.massNumber}';
    } else {
      final am = m.atomicMass;
      readout = am > 0 ? toFixed(am, 5) : '--';
    }

    return SizedBox(
      width: IaamConstants.scaleImageWidth,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            IaamConstants.scaleAsset,
            width: IaamConstants.scaleImageWidth,
            fit: BoxFit.fitWidth,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(width: 2, color: Colors.black87),
                  ),
                  child: Text(
                    readout,
                    style: const TextStyle(fontSize: 19, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RadioRow(
                      label: 'Mass Number',
                      selected: mode == ScaleDisplayMode.massNumber,
                      onTap: () => controller
                          .setDisplayMode(ScaleDisplayMode.massNumber),
                    ),
                    const SizedBox(height: 8),
                    _RadioRow(
                      label: 'Atomic Mass',
                      selected: mode == ScaleDisplayMode.atomicMass,
                      onTap: () => controller
                          .setDisplayMode(ScaleDisplayMode.atomicMass),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: selected ? Colors.white : Colors.transparent,
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
