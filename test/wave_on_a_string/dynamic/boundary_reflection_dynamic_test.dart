import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kratos/wave_on_a_string/model/woas_end_type.dart';
import 'package:kratos/wave_on_a_string/model/woas_model.dart';
import 'package:kratos/wave_on_a_string/woas_constants.dart';

/// Inject a right-going pulse via left-end drive, then free left end at 0.
void _launchPulse(WoasModel m, {double amp = 40, int hold = 6}) {
  m.setManualDisplacement(amp);
  for (var i = 0; i < hold; i++) {
    m.manualStep(frameDuration);
    m.nextLeftY = amp;
  }
  m.setManualDisplacement(0);
  for (var i = 0; i < hold; i++) {
    m.manualStep(frameDuration);
    m.nextLeftY = 0;
  }
}

void main() {
  group('Fixed End dynamic', () {
    test('endpoint stays 0; wave reaches boundary region', () {
      final m = WoasModel()
        ..setDamping(0)
        ..setTension(0.8)
        ..setStringEndType(WoasEndType.fixedEnd);
      _launchPulse(m);

      var nearEndEnergy = 0.0;
      for (var t = 0; t < 250; t++) {
        m.manualStep(frameDuration);
        m.nextLeftY = 0;
        expect(m.yNowAt(lastIndex), 0);
        for (var i = lastIndex - 8; i < lastIndex; i++) {
          nearEndEnergy = nearEndEnergy < m.yNowAt(i).abs()
              ? m.yNowAt(i).abs()
              : nearEndEnergy;
        }
      }
      expect(nearEndEnergy, greaterThan(0.5));
    });

    test('Fixed reflection returns energy toward mid-string (source evolve)', () {
      final m = WoasModel()
        ..setDamping(0)
        ..setTension(0.8);
      _launchPulse(m, amp: 50, hold: 8);

      var peakMid = 0.0;
      var peakNearEnd = 0.0;
      for (var t = 0; t < 220; t++) {
        m.manualStep(frameDuration);
        m.nextLeftY = 0;
        expect(m.yNowAt(lastIndex), 0);
        peakMid = math.max(peakMid, m.yNowAt(20).abs() + m.yNowAt(30).abs());
        peakNearEnd =
            math.max(peakNearEnd, m.yNowAt(nextToLastIndex).abs());
      }
      expect(peakNearEnd, greaterThan(0.5));
      expect(peakMid, greaterThan(0.5));
    });
  });

  group('Loose End dynamic', () {
    test('LAST tracks NEXT_TO_LAST (Neumann) during propagation', () {
      final m = WoasModel()
        ..setDamping(0)
        ..setTension(0.8)
        ..setStringEndType(WoasEndType.looseEnd);
      _launchPulse(m);

      var sawNonzeroEnd = false;
      for (var t = 0; t < 220; t++) {
        m.manualStep(frameDuration);
        m.nextLeftY = 0;
        if (m.yNowAt(lastIndex).abs() > 0.5) {
          sawNonzeroEnd = true;
          expect(
            m.yNowAt(lastIndex),
            closeTo(m.yNowAt(nextToLastIndex), 1e-9),
          );
        }
      }
      expect(sawNonzeroEnd, isTrue);
    });
  });

  group('No End dynamic', () {
    test('wave can leave; LAST not forced to 0', () {
      final m = WoasModel()
        ..setDamping(0)
        ..setTension(0.8)
        ..setStringEndType(WoasEndType.noEnd);
      _launchPulse(m, amp: 50, hold: 8);

      var peakEnd = 0.0;
      for (var t = 0; t < 250; t++) {
        m.manualStep(frameDuration);
        m.nextLeftY = 0;
        peakEnd = peakEnd < m.yNowAt(lastIndex).abs()
            ? m.yNowAt(lastIndex).abs()
            : peakEnd;
      }
      expect(peakEnd, greaterThan(0));
    });

    test('No End vs Fixed: endpoint peak differs (source boundary)', () {
      double peakEnd(WoasEndType end) {
        final m = WoasModel()
          ..setDamping(0)
          ..setTension(0.8)
          ..setStringEndType(end);
        _launchPulse(m, amp: 45, hold: 8);
        var peak = 0.0;
        for (var t = 0; t < 220; t++) {
          m.manualStep(frameDuration);
          m.nextLeftY = 0;
          peak = math.max(peak, m.yNowAt(lastIndex).abs());
        }
        return peak;
      }

      expect(peakEnd(WoasEndType.fixedEnd), 0);
      expect(peakEnd(WoasEndType.noEnd), greaterThan(0.5));
    });
  });

  group('boundary switching', () {
    test('Loose→No End keeps wave; Fixed zeros endpoint only', () {
      final m = WoasModel()
        ..setDamping(0)
        ..setStringEndType(WoasEndType.looseEnd);
      m.debugSeedBead(index: 12, yNow: 7, yLast: 7, yDraw: 7);
      m.debugSeedBead(index: lastIndex, yNow: 4, yDraw: 4);

      m.setStringEndType(WoasEndType.noEnd);
      expect(m.yNowAt(12), 7);
      expect(m.damping, 0);

      m.setStringEndType(WoasEndType.fixedEnd);
      expect(m.yNowAt(12), 7);
      expect(m.yNowAt(lastIndex), 0);
      expect(m.damping, 0); // not ResetAll
    });

    test('switch during active wave: Fixed zeroOutEndPoint, parameters kept', () {
      final m = WoasModel()
        ..setDamping(0.3)
        ..setAmplitudeCm(1.0)
        ..setStringEndType(WoasEndType.looseEnd);
      _launchPulse(m);
      for (var t = 0; t < 100; t++) {
        m.manualStep(frameDuration);
        m.nextLeftY = 0;
      }
      final mid = m.yNowAt(25);
      m.setStringEndType(WoasEndType.fixedEnd);
      expect(m.yNowAt(lastIndex), 0);
      expect(m.yNowAt(25), mid);
      expect(m.damping, 0.3);
      expect(m.amplitudeCm, 1.0);
    });
  });
}
