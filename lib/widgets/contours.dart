import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// One topographic contour line.
typedef Contour = ({Path path, bool isIndex});

/// Nested contour rings scattered across [size], as on a survey sheet.
/// Every fourth ring is an index contour, meant to be drawn heavier.
List<Contour> contourRings(Size size, {int seed = 11}) {
  final rng = math.Random(seed);
  final unit = size.shortestSide / 400;
  const anchors = [
    Offset(0.14, 0.16),
    Offset(0.92, 0.58),
    Offset(0.26, 0.96),
    Offset(1.02, 0.02),
  ];
  final rings = <Contour>[];
  for (final anchor in anchors) {
    final origin = Offset(anchor.dx * size.width, anchor.dy * size.height);
    final phases = List.generate(4, (_) => rng.nextDouble() * math.pi * 2);
    final drift = rng.nextDouble() * math.pi * 2;
    final count = 7 + rng.nextInt(3);
    for (var k = 0; k < count; k++) {
      final centre = origin + Offset.fromDirection(drift, k * 3.2 * unit);
      rings.add((
        path: _ring(centre, (16 + k * 24) * unit, phases, 0.55 + k * 0.07),
        isIndex: k % 4 == 3,
      ));
    }
  }
  return rings;
}

Path _ring(Offset centre, double radius, List<double> phases, double wobble) {
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
  final start = mid(pts.last, pts.first);
  final path = Path()..moveTo(start.dx, start.dy);
  for (var i = 0; i < n; i++) {
    final p = pts[i];
    final m = mid(p, pts[(i + 1) % n]);
    path.quadraticBezierTo(p.dx, p.dy, m.dx, m.dy);
  }
  return path..close();
}
