import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/odyssey_theme.dart';
import 'splash_timeline.dart';

/// Nested topographic contour rings scattered behind the compass. Every
/// fourth ring is an index contour, drawn heavier, as on a survey sheet.
class ContourField {
  ContourField.generate(Size size, {int seed = 11})
    : rings = _generate(size, seed);

  final List<ContourRing> rings;

  static List<ContourRing> _generate(Size size, int seed) {
    final rng = math.Random(seed);
    final unit = size.shortestSide / 400;
    const anchors = [
      Offset(0.14, 0.16),
      Offset(0.92, 0.58),
      Offset(0.26, 0.96),
      Offset(1.02, 0.02),
    ];
    final rings = <ContourRing>[];
    for (var a = 0; a < anchors.length; a++) {
      final origin = Offset(
        anchors[a].dx * size.width,
        anchors[a].dy * size.height,
      );
      final phases = List.generate(4, (_) => rng.nextDouble() * math.pi * 2);
      final drift = rng.nextDouble() * math.pi * 2;
      final count = 7 + rng.nextInt(3);
      for (var k = 0; k < count; k++) {
        final radius = (16 + k * 24) * unit;
        final centre = origin + Offset.fromDirection(drift, k * 3.2 * unit);
        final path = _ring(centre, radius, phases, 0.55 + k * 0.07);
        rings.add(
          ContourRing(
            metric: path.computeMetrics().first,
            isIndex: k % 4 == 3,
            delay: a * 0.12 + k * 0.07,
          ),
        );
      }
    }
    return rings;
  }

  static Path _ring(
    Offset centre,
    double radius,
    List<double> phases,
    double wobble,
  ) {
    const n = 96;
    final pts = <Offset>[];
    for (var i = 0; i < n; i++) {
      final th = i / n * math.pi * 2;
      var r = 1.0;
      for (var m = 0; m < phases.length; m++) {
        r += wobble * 0.11 / (m + 2) * math.sin((m + 2) * th + phases[m]);
      }
      pts.add(centre + Offset.fromDirection(th, radius * r));
    }
    // Quadratic segments through the midpoints give a smooth closed curve.
    Offset mid(Offset a, Offset b) => Offset.lerp(a, b, 0.5)!;
    final path = Path()
      ..moveTo(mid(pts.last, pts.first).dx, mid(pts.last, pts.first).dy);
    for (var i = 0; i < n; i++) {
      final p = pts[i];
      final m = mid(p, pts[(i + 1) % n]);
      path.quadraticBezierTo(p.dx, p.dy, m.dx, m.dy);
    }
    return path..close();
  }
}

class ContourRing {
  const ContourRing({
    required this.metric,
    required this.isIndex,
    required this.delay,
  });

  final ui.PathMetric metric;
  final bool isIndex;
  final double delay;
}

/// Obsidian forest vignette with contour lines surveying themselves in.
class SplashBackdropPainter extends CustomPainter {
  SplashBackdropPainter({required this.t, required this.field});

  final double t;
  final ContourField field;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          radius: 0.95,
          colors: [Color(0xFF1D2A1E), OdysseyColors.forest, Color(0xFF0B110C)],
          stops: [0, 0.55, 1],
        ).createShader(rect),
    );

    // A slow drift keeps the survey sheet alive.
    canvas.save();
    canvas.translate(math.sin(t * 0.7) * 3, -t * 4);
    final (start, end) = SplashTimeline.contours;
    for (final ring in field.rings) {
      final p = SplashTimeline.progress(t, (
        start + ring.delay,
        end + ring.delay * 0.5,
      ), Curves.easeInOutCubic);
      if (p <= 0) continue;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.isIndex ? 1.0 : 0.6
        ..color = OdysseyColors.brassLight.withValues(
          alpha: (ring.isIndex ? 0.17 : 0.09) * p.clamp(0, 1),
        );
      canvas.drawPath(
        ring.metric.extractPath(0, ring.metric.length * p),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(SplashBackdropPainter old) =>
      old.t != t || old.field != field;
}

/// The compass rose: a self-drawing bezel, calibration ticks, a needle that
/// swings onto north and a ripple when it locks.
class CompassPainter extends CustomPainter {
  CompassPainter({required this.t, this.showNorth = true});

  final double t;

  /// Draws the "N" above the bezel; small emblems leave it out.
  final bool showNorth;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final lock = SplashTimeline.lock;
    final settled = (t - lock).clamp(0.0, 10.0);

    // Warm glow that blooms on lock and then rests.
    final glow = t < lock
        ? SplashTimeline.progress(t, (0.6, lock)) * 0.08
        : 0.08 + 0.16 * math.exp(-settled * 2.4);
    canvas.drawCircle(
      c,
      r * 1.6,
      Paint()
        ..shader = RadialGradient(
          colors: [
            OdysseyColors.brassLight.withValues(alpha: glow),
            OdysseyColors.brassLight.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r * 1.6)),
    );

    // Lock ripples.
    for (var i = 0; i < 2; i++) {
      final p = SplashTimeline.progress(t, (
        lock + i * 0.18,
        lock + i * 0.18 + 0.85,
      ), Curves.easeOutCubic);
      if (p <= 0 || p >= 1) continue;
      canvas.drawCircle(
        c,
        r * (1 + 0.8 * p),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.4 + 1.2 * (1 - p)
          ..color = OdysseyColors.brassLight.withValues(alpha: 0.5 * (1 - p)),
      );
    }

    // Bezel, drawn clockwise from north with a spark at its head.
    final bezel = SplashTimeline.progress(
      t,
      SplashTimeline.bezel,
      Curves.easeInOutCubic,
    );
    if (bezel > 0) {
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * bezel,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = OdysseyColors.brass,
      );
      if (bezel < 1) {
        final head =
            c + Offset.fromDirection(-math.pi / 2 + math.pi * 2 * bezel, r);
        canvas.drawCircle(
          head,
          5,
          Paint()
            ..color = OdysseyColors.brassLight.withValues(alpha: 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawCircle(head, 1.6, Paint()..color = OdysseyColors.parchment);
      }
    }

    final inner = SplashTimeline.progress(t, (0.6, 1.15));
    if (inner > 0) {
      canvas.drawCircle(
        c,
        r * 0.8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = OdysseyColors.brass.withValues(alpha: 0.4 * inner),
      );
    }

    // 72 calibration ticks, one every five degrees, sweeping in.
    final ticks = SplashTimeline.progress(
      t,
      SplashTimeline.ticks,
      Curves.easeOutCubic,
    );
    for (var i = 0; i < 72; i++) {
      final local = (ticks * 72 - i).clamp(0.0, 1.0);
      if (local <= 0) break;
      final cardinal = i % 18 == 0;
      final ordinal = i % 9 == 0;
      final length = cardinal ? 0.15 : (ordinal ? 0.09 : 0.045);
      final angle = -math.pi / 2 + i * math.pi * 2 / 72;
      canvas.drawLine(
        c + Offset.fromDirection(angle, r * 0.96),
        c + Offset.fromDirection(angle, r * (0.96 - length)),
        Paint()
          ..strokeWidth = cardinal ? 1.4 : 0.8
          ..color = (cardinal ? OdysseyColors.brassLight : OdysseyColors.brass)
              .withValues(alpha: local * (cardinal ? 0.95 : 0.6)),
      );
    }

    // North letter, revealed as the needle finds it.
    final north = SplashTimeline.progress(
      t,
      SplashTimeline.north,
      Curves.easeOutCubic,
    );
    if (showNorth && north > 0) {
      final label = TextPainter(
        text: TextSpan(
          text: 'N',
          style: OdysseyType.display(
            r * 0.24,
            color: OdysseyColors.brassLight.withValues(alpha: north),
            weight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(
        canvas,
        c - Offset(label.width / 2, r + label.height + 6 - (1 - north) * 6),
      );
      label.dispose();
    }

    // Needle.
    final needle = SplashTimeline.progress(t, SplashTimeline.needleFade);
    if (needle > 0) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(SplashTimeline.needleAngle(t));
      final tip = r * 0.66;
      final half = r * 0.075;
      final northHalf = Path()
        ..moveTo(0, -tip)
        ..lineTo(half, 0)
        ..lineTo(-half, 0)
        ..close();
      final southHalf = Path()
        ..moveTo(0, tip)
        ..lineTo(half, 0)
        ..lineTo(-half, 0)
        ..close();
      canvas.drawPath(
        northHalf,
        Paint()
          ..shader = ui.Gradient.linear(Offset(0, -tip), Offset.zero, [
            OdysseyColors.brassLight.withValues(alpha: needle),
            OdysseyColors.brass.withValues(alpha: needle),
          ]),
      );
      canvas.drawLine(
        Offset(0, -tip),
        Offset.zero,
        Paint()
          ..strokeWidth = 0.6
          ..color = OdysseyColors.forest.withValues(alpha: 0.35 * needle),
      );
      canvas.drawPath(
        southHalf,
        Paint()..color = OdysseyColors.forest.withValues(alpha: needle),
      );
      canvas.drawPath(
        southHalf,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..strokeJoin = StrokeJoin.round
          ..color = OdysseyColors.brass.withValues(alpha: 0.75 * needle),
      );
      canvas.restore();

      canvas.drawCircle(
        c,
        r * 0.05,
        Paint()..color = OdysseyColors.forest.withValues(alpha: needle),
      );
      canvas.drawCircle(
        c,
        r * 0.05,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = OdysseyColors.brassLight.withValues(alpha: needle),
      );
    }
  }

  @override
  bool shouldRepaint(CompassPainter old) =>
      old.t != t || old.showNorth != showNorth;
}

/// A hairline brass rule that draws outward from a small central diamond.
class RulePainter extends CustomPainter {
  RulePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final c = size.center(Offset.zero);
    final half = size.width / 2 * progress;
    final line = Paint()
      ..strokeWidth = 0.8
      ..shader = ui.Gradient.linear(
        Offset(c.dx - half, c.dy),
        Offset(c.dx + half, c.dy),
        [
          OdysseyColors.brass.withValues(alpha: 0),
          OdysseyColors.brassLight,
          OdysseyColors.brass.withValues(alpha: 0),
        ],
        [0, 0.5, 1],
      );
    canvas.drawLine(Offset(c.dx - half, c.dy), Offset(c.dx + half, c.dy), line);
    final d = 3.6 * Curves.easeOutBack.transform(progress.clamp(0, 1));
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - d)
        ..lineTo(c.dx + d, c.dy)
        ..lineTo(c.dx, c.dy + d)
        ..lineTo(c.dx - d, c.dy)
        ..close(),
      Paint()..color = OdysseyColors.brassLight,
    );
  }

  @override
  bool shouldRepaint(RulePainter old) => old.progress != progress;
}
