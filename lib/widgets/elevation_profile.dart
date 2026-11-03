import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/geo.dart';
import '../theme/odyssey_theme.dart';

/// Elevation against distance, with numbered waypoints. Drag across it to
/// read the elevation at any kilometre.
class ElevationProfile extends StatefulWidget {
  const ElevationProfile({super.key, required this.points, this.height = 180});

  final List<ProfilePoint> points;
  final double height;

  @override
  State<ElevationProfile> createState() => _ElevationProfileState();
}

class _ElevationProfileState extends State<ElevationProfile> {
  double? _scrubKm;

  double get _totalKm => widget.points.last.km;

  void _scrub(Offset local, double width) {
    final plot = width - _ProfilePainter.left - _ProfilePainter.right;
    final f = ((local.dx - _ProfilePainter.left) / plot).clamp(0.0, 1.0);
    setState(() => _scrubKm = f * _totalKm);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragStart: (d) => _scrub(d.localPosition, width),
          onHorizontalDragUpdate: (d) => _scrub(d.localPosition, width),
          onHorizontalDragEnd: (_) => setState(() => _scrubKm = null),
          onTapDown: (d) => _scrub(d.localPosition, width),
          onTapUp: (_) => setState(() => _scrubKm = null),
          child: CustomPaint(
            size: Size(width, widget.height),
            painter: _ProfilePainter(widget.points, _scrubKm),
          ),
        );
      },
    );
  }
}

class _ProfilePainter extends CustomPainter {
  _ProfilePainter(this.points, this.scrubKm);

  static const left = 40.0;
  static const right = 10.0;
  static const top = 30.0;
  static const bottom = 22.0;

  final List<ProfilePoint> points;
  final double? scrubKm;

  TextPainter _text(String s, {Color color = OdysseyColors.inkSoft, double size = 9}) =>
      TextPainter(
        text: TextSpan(text: s, style: OdysseyType.mono(size, color: color, letterSpacing: 0.8)),
        textDirection: TextDirection.ltr,
      )..layout();

  double _elevationAt(double km) {
    for (var i = 1; i < points.length; i++) {
      if (points[i].km >= km) {
        final a = points[i - 1], b = points[i];
        final span = b.km - a.km;
        final f = span == 0 ? 0.0 : (km - a.km) / span;
        return ui.lerpDouble(a.elevationM, b.elevationM, f)!;
      }
    }
    return points.last.elevationM;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final totalKm = math.max(points.last.km, 1.0);
    final peak = points.map((p) => p.elevationM).reduce(math.max);
    final step = peak > 2000 ? 1000.0 : (peak > 800 ? 500.0 : 100.0);
    final maxE = math.max(step, (peak / step).ceil() * step);
    final plotW = size.width - left - right;
    final plotH = size.height - top - bottom;
    Offset at(double km, double e) =>
        Offset(left + km / totalKm * plotW, top + (1 - e / maxE) * plotH);

    // Grid and elevation labels.
    final grid = Paint()
      ..strokeWidth = 0.6
      ..color = OdysseyColors.rule;
    for (var e = 0.0; e <= maxE; e += maxE / 2) {
      final y = at(0, e).dy;
      for (var x = left; x < size.width - right; x += 6) {
        canvas.drawLine(Offset(x, y), Offset(x + 3, y), grid);
      }
      final label = _text(e == 0 ? '0' : groupThousands(e.round()));
      label.paint(canvas, Offset(left - label.width - 8, y - label.height / 2));
    }

    // Area and line.
    final line = Path()..moveTo(at(0, points.first.elevationM).dx, at(0, points.first.elevationM).dy);
    for (final p in points.skip(1)) {
      final o = at(p.km, p.elevationM);
      line.lineTo(o.dx, o.dy);
    }
    final area = Path.from(line)
      ..lineTo(at(totalKm, 0).dx, at(totalKm, 0).dy)
      ..lineTo(at(0, 0).dx, at(0, 0).dy)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, top), Offset(0, top + plotH), [
          OdysseyColors.brass.withValues(alpha: 0.38),
          OdysseyColors.brass.withValues(alpha: 0.03),
        ]),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeJoin = StrokeJoin.round
        ..color = OdysseyColors.brass,
    );

    // Numbered waypoint markers.
    var n = 0;
    for (final p in points) {
      if (p.waypoint == null) continue;
      n++;
      final o = at(p.km, p.elevationM);
      canvas.drawLine(
        o,
        Offset(o.dx, top + plotH),
        Paint()
          ..strokeWidth = 0.6
          ..color = OdysseyColors.forest.withValues(alpha: 0.18),
      );
      canvas.drawCircle(o, 7.5, Paint()..color = OdysseyColors.forest);
      canvas.drawCircle(
        o,
        7.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = OdysseyColors.brassLight,
      );
      final label = _text('$n', color: OdysseyColors.parchment, size: 8);
      label.paint(canvas, o - Offset(label.width / 2, label.height / 2));
    }

    // Distance axis.
    for (final f in [0.0, 0.5, 1.0]) {
      final label = _text('${(totalKm * f).round()} km');
      final x = left + plotW * f - label.width * f;
      label.paint(canvas, Offset(x, size.height - label.height));
    }

    // Scrub readout.
    final km = scrubKm;
    if (km != null) {
      final e = _elevationAt(km);
      final o = at(km, e);
      canvas.drawLine(
        Offset(o.dx, top - 4),
        Offset(o.dx, top + plotH),
        Paint()
          ..strokeWidth = 1
          ..color = OdysseyColors.forest,
      );
      canvas.drawCircle(o, 4.5, Paint()..color = OdysseyColors.brassLight);
      canvas.drawCircle(
        o,
        4.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = OdysseyColors.forest,
      );
      final readout = _text(
        'KM ${km.toStringAsFixed(0)} · ${groupThousands(e.round())} M',
        color: OdysseyColors.parchment,
        size: 9.5,
      );
      final w = readout.width + 16;
      final x = (o.dx - w / 2).clamp(0.0, size.width - w);
      final box = RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, w, 22), const Radius.circular(5));
      canvas.drawRRect(box, Paint()..color = OdysseyColors.forest);
      readout.paint(canvas, Offset(x + 8, 11 - readout.height / 2));
    }
  }

  @override
  bool shouldRepaint(_ProfilePainter old) =>
      old.points != points || old.scrubKm != scrubKm;
}
