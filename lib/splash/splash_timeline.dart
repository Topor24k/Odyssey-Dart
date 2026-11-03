import 'dart:math' as math;

import 'package:flutter/animation.dart';

typedef Span = (double start, double end);

/// Every beat of the opening sequence, in seconds from the first frame.
///
/// tool/generate_intro_sound.dart scores its cues to these same times —
/// change both together.
abstract final class SplashTimeline {
  /// When the journal opens (the sound's page-turn cue).
  static const double length = 3.45;

  static const Duration duration = Duration(milliseconds: 3450);

  static const Span contours = (0.0, 1.9);
  static const Span bezel = (0.10, 0.85);
  static const Span ticks = (0.30, 1.05);
  static const Span needleFade = (0.55, 0.75);
  static const double needleStart = 0.65;
  static const double lock = 1.55;
  static const Span north = (1.45, 1.90);
  static const Span rise = (1.70, 2.35);
  static const double wordmarkStart = 1.85;
  static const Span rule = (2.25, 2.75);
  static const Span subtitle = (2.40, 2.95);
  static const Span coordinates = (2.50, 3.10);
  static const Span bearingName = (3.05, 3.40);
  static const Span tagline = (2.85, 3.40);

  // The needle is a damped oscillator, e^(-ζt)·cos(ωt), released from
  // [needleFrom] at [needleStart] and locked on north at [lock].
  static const double needleFrom = -150 * math.pi / 180;
  static const double needleDamping = 6.0;
  static const double needleOmega = 13.1;

  /// Needle bearing in radians clockwise from north at [t] seconds.
  static double needleAngle(double t) {
    final s = t - needleStart;
    if (s <= 0) return needleFrom;
    const swing = lock - needleStart;
    if (s >= swing) return 0;
    final free = needleFrom *
        math.exp(-needleDamping * s) *
        math.cos(needleOmega * s);
    // Ease the last fraction of a degree into an exact lock.
    final settle = ((s - swing * 0.8) / (swing * 0.2)).clamp(0.0, 1.0);
    return free * (1 - Curves.easeIn.transform(settle));
  }

  /// Progress through [span] at [t] seconds, shaped by [curve].
  static double progress(double t, Span span, [Curve curve = Curves.linear]) {
    final (start, end) = span;
    return curve.transform(((t - start) / (end - start)).clamp(0.0, 1.0));
  }
}
