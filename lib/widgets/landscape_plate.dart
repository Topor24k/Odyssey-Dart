import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/odyssey_theme.dart';

/// An illustrated archival plate: a duotone, engraving-textured scene painted
/// from a motif and a seed, so every plate is distinct and works offline.
class LandscapePlate extends StatelessWidget {
  const LandscapePlate(this.plate, {super.key, this.framed = true});

  final Plate plate;

  /// Draws a hairline brass mount inside the edge.
  final bool framed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _PlatePainter(plate.motif, plate.seed, framed),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PlatePainter extends CustomPainter {
  _PlatePainter(this.motif, this.seed, this.framed);

  final PlateMotif motif;
  final int seed;
  final bool framed;

  static const _far = Color(0xFF6E6248);
  static const _near = Color(0xFF0E150F);
  static const _light = OdysseyColors.parchment;

  static Color _depth(double d) => Color.lerp(_far, _near, d.clamp(0, 1))!;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rng = math.Random(seed);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    switch (motif) {
      case PlateMotif.karst:
        _karst(canvas, size, rng);
      case PlateMotif.islands:
        _islands(canvas, size, rng);
      case PlateMotif.volcano:
        _volcano(canvas, size, rng);
      case PlateMotif.river:
        _river(canvas, size, rng);
      case PlateMotif.terraces:
        _terraces(canvas, size, rng);
      case PlateMotif.lanterns:
        _lanterns(canvas, size, rng);
      case PlateMotif.temple:
        _temple(canvas, size, rng);
    }
    _engrave(canvas, size, rng);
    if (framed) {
      canvas.drawRect(
        (Offset.zero & size).deflate(6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = OdysseyColors.brassLight.withValues(alpha: 0.45),
      );
    }
    canvas.restore();
  }

  // ── Shared elements ────────────────────────────────────────────────────

  void _sky(Canvas canvas, Size size, Color top, Color horizon, double hy) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          [top, horizon, horizon],
          [0, (hy / size.height).clamp(0.05, 1.0), 1],
        ),
    );
  }

  void _sun(Canvas canvas, Offset c, double radius, {double alpha = 0.85}) {
    canvas.drawCircle(
      c,
      radius * 3.4,
      Paint()
        ..shader = ui.Gradient.radial(c, radius * 3.4, [
          _light.withValues(alpha: 0.28 * alpha),
          _light.withValues(alpha: 0),
        ]),
    );
    canvas.drawCircle(c, radius, Paint()..color = _light.withValues(alpha: alpha));
  }

  void _mist(Canvas canvas, Size size, double y, double height, double alpha) {
    final rect = Rect.fromLTWH(0, y - height / 2, size.width, height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          rect.topCenter,
          rect.bottomCenter,
          [
            _light.withValues(alpha: 0),
            _light.withValues(alpha: alpha),
            _light.withValues(alpha: 0),
          ],
          [0, 0.5, 1],
        ),
    );
  }

  void _stars(Canvas canvas, Size size, math.Random rng, int count, double maxY) {
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * maxY),
        0.4 + rng.nextDouble() * 0.7,
        Paint()..color = _light.withValues(alpha: 0.2 + rng.nextDouble() * 0.5),
      );
    }
  }

  /// A steep rounded tower — the karst and islet silhouette.
  void _dome(Path path, double cx, double baseY, double width, double height) {
    path
      ..moveTo(cx - width / 2, baseY)
      ..cubicTo(cx - width * 0.5, baseY - height * 0.78, cx - width * 0.3,
          baseY - height, cx, baseY - height)
      ..cubicTo(cx + width * 0.3, baseY - height, cx + width * 0.5,
          baseY - height * 0.78, cx + width / 2, baseY)
      ..close();
  }

  /// Rolling hills filled down to the bottom edge.
  void _hills(Canvas canvas, Size size, math.Random rng, double baseY,
      double amp, Color color) {
    final p1 = rng.nextDouble() * 6, p2 = rng.nextDouble() * 6;
    final f1 = 2 + rng.nextDouble() * 2, f2 = 5 + rng.nextDouble() * 4;
    final path = Path()..moveTo(0, size.height);
    for (var x = 0.0; x <= size.width + 4; x += 4) {
      final u = x / size.width;
      final y = baseY -
          amp *
              (0.55 +
                  0.3 * math.sin(u * f1 * math.pi + p1) +
                  0.15 * math.sin(u * f2 * math.pi + p2));
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _reflectionColumn(
      Canvas canvas, Size size, math.Random rng, double x, double fromY) {
    final rows = 16;
    for (var k = 0; k < rows; k++) {
      final y = fromY + 3 + k * (size.height - fromY) / (rows + 2);
      final half = size.width * 0.045 * (1 + k * 0.12) * (0.6 + rng.nextDouble() * 0.4);
      final jitter = (rng.nextDouble() - 0.5) * size.width * 0.02;
      canvas.drawLine(
        Offset(x - half + jitter, y),
        Offset(x + half + jitter, y),
        Paint()
          ..strokeWidth = 1.1
          ..color = _light.withValues(alpha: 0.32 * (1 - k / rows)),
      );
    }
  }

  // ── Motifs ─────────────────────────────────────────────────────────────

  void _karst(Canvas canvas, Size size, math.Random rng) {
    final w = size.width, h = size.height;
    _sky(canvas, size, const Color(0xFF17211A), const Color(0xFF8A7048), h * 0.6);
    _sun(canvas, Offset(w * (0.55 + rng.nextDouble() * 0.3), h * (0.26 + rng.nextDouble() * 0.1)),
        h * 0.07);
    for (var layer = 0; layer < 4; layer++) {
      final baseY = h * (0.56 + layer * 0.12);
      final peaks = 4 + layer + rng.nextInt(2);
      final path = Path();
      for (var i = 0; i < peaks; i++) {
        final cx = w * ((i + rng.nextDouble() * 0.8 - 0.4) / (peaks - 1));
        _dome(
          path,
          cx,
          baseY + 2,
          w * (0.15 + rng.nextDouble() * 0.12),
          h * (0.14 + rng.nextDouble() * 0.2) * (1 - layer * 0.07),
        );
      }
      path.addRect(Rect.fromLTRB(0, baseY, w, h));
      canvas.drawPath(path, Paint()..color = _depth(0.18 + layer * 0.27));
      if (layer < 3) _mist(canvas, size, baseY - h * 0.01, h * 0.09, 0.1 + layer * 0.02);
    }
    // A switchback road scratched into the nearest slope.
    final road = Path()..moveTo(w * 0.06, h * 1.02);
    var x = w * 0.06, y = h * 1.02;
    for (var i = 0; i < 5; i++) {
      final nx = i.isEven ? x + w * 0.2 : x - w * 0.14;
      final ny = y - h * 0.045;
      road.quadraticBezierTo((x + nx) / 2 + (i.isEven ? 6 : -6), ny + h * 0.03, nx, ny);
      x = nx;
      y = ny;
    }
    canvas.drawPath(
      road,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = _light.withValues(alpha: 0.22),
    );
  }

  void _islands(Canvas canvas, Size size, math.Random rng) {
    final w = size.width, h = size.height;
    final hy = h * (0.56 + rng.nextDouble() * 0.06);
    _sky(canvas, size, const Color(0xFF1A2620), const Color(0xFF9A7E52), hy);
    final sunX = w * (0.25 + rng.nextDouble() * 0.5);
    _sun(canvas, Offset(sunX, hy - h * 0.1), h * 0.07);

    final sea = Rect.fromLTRB(0, hy, w, h);
    canvas.drawRect(
      sea,
      Paint()
        ..shader = ui.Gradient.linear(sea.topCenter, sea.bottomCenter, [
          const Color(0xFF5A4C34),
          const Color(0xFF1A231B),
          _near,
        ], [0, 0.55, 1]),
    );
    _reflectionColumn(canvas, size, rng, sunX, hy);
    for (var k = 1; k < 11; k++) {
      final y = hy + (h - hy) * math.pow(k / 11, 1.6);
      canvas.drawLine(
        Offset(0, y),
        Offset(w, y),
        Paint()
          ..strokeWidth = 0.7
          ..color = _light.withValues(alpha: 0.05),
      );
    }

    final islands = 3 + rng.nextInt(3);
    for (var i = 0; i < islands; i++) {
      final cx = w * rng.nextDouble();
      final iw = w * (0.06 + rng.nextDouble() * 0.16);
      final ih = h * (0.05 + rng.nextDouble() * 0.12);
      final color = _depth(0.35 + rng.nextDouble() * 0.3);
      final islet = Path();
      _dome(islet, cx, hy + 1, iw, ih);
      canvas.drawPath(islet, Paint()..color = color);
      final mirrored = Path();
      _dome(mirrored, cx, hy, iw, ih * 0.7);
      canvas.save();
      canvas.translate(0, hy * 2);
      canvas.scale(1, -1);
      canvas.drawPath(mirrored, Paint()..color = color.withValues(alpha: 0.22));
      canvas.restore();
    }

    // An outrigger banca crossing the foreground.
    final bx = w * (0.3 + rng.nextDouble() * 0.35);
    final by = hy + (h - hy) * 0.55;
    final s = w * 0.22;
    final boat = Paint()..color = _near;
    canvas.drawPath(
      Path()
        ..moveTo(bx + s * 0.5, by - s * 0.075)
        ..quadraticBezierTo(bx, by + s * 0.07, bx - s * 0.5, by - s * 0.05)
        ..lineTo(bx - s * 0.44, by - s * 0.03)
        ..lineTo(bx + s * 0.42, by - s * 0.04)
        ..close(),
      boat,
    );
    canvas.drawRect(
      Rect.fromLTRB(bx - s * 0.16, by - s * 0.12, bx + s * 0.12, by - s * 0.035),
      boat,
    );
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = _near;
    canvas.drawLine(
        Offset(bx - s * 0.62, by + s * 0.015), Offset(bx + s * 0.6, by + s * 0.005), line);
    for (final dx in [-0.26, 0.24]) {
      canvas.drawPath(
        Path()
          ..moveTo(bx + s * dx, by - s * 0.05)
          ..quadraticBezierTo(bx + s * (dx * 1.25), by - s * 0.13,
              bx + s * (dx * 1.45), by + s * 0.012),
        line,
      );
    }
    canvas.drawLine(Offset(bx - s * 0.02, by - s * 0.12),
        Offset(bx - s * 0.02, by - s * 0.3), line..strokeWidth = 1);
  }

  void _volcano(Canvas canvas, Size size, math.Random rng) {
    final w = size.width, h = size.height;
    final hy = h * 0.72;
    _sky(canvas, size, const Color(0xFF0D130F), const Color(0xFF7A5A36), hy);
    _stars(canvas, size, rng, 46, h * 0.45);
    final dawn = Offset(w * (0.65 + rng.nextDouble() * 0.25), hy);
    canvas.drawCircle(
      dawn,
      w * 0.5,
      Paint()
        ..shader = ui.Gradient.radial(dawn, w * 0.5, [
          OdysseyColors.brassLight.withValues(alpha: 0.35),
          OdysseyColors.brassLight.withValues(alpha: 0),
        ]),
    );

    final cx = w * (0.44 + rng.nextDouble() * 0.12);
    final topY = h * (0.24 + rng.nextDouble() * 0.06);
    final crater = w * 0.07;
    final baseL = w * (0.06 + rng.nextDouble() * 0.08);
    final baseR = w * (0.86 + rng.nextDouble() * 0.08);
    final rightFlank = Path()
      ..moveTo(cx + crater, topY)
      ..quadraticBezierTo(cx + crater * 2.4, hy - h * 0.1, baseR, hy + h * 0.02);
    canvas.drawPath(
      Path()
        ..moveTo(baseL, hy + h * 0.02)
        ..quadraticBezierTo(cx - crater * 2.2, hy - h * 0.12, cx - crater, topY)
        ..lineTo(cx - crater * 0.35, topY + h * 0.015)
        ..lineTo(cx + crater * 0.3, topY + h * 0.01)
        ..lineTo(cx + crater, topY)
        ..quadraticBezierTo(cx + crater * 2.4, hy - h * 0.1, baseR, hy + h * 0.02)
        ..lineTo(baseR, h)
        ..lineTo(baseL, h)
        ..close(),
      Paint()..color = _depth(0.5),
    );
    canvas.drawPath(
      rightFlank,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = OdysseyColors.brassLight.withValues(alpha: 0.22),
    );

    // Plume drifting off the crater.
    for (var k = 0; k < 7; k++) {
      final radius = w * (0.02 + k * 0.012);
      canvas.drawCircle(
        Offset(cx + k * w * 0.026 + k * k * 0.8, topY - k * h * 0.045 - radius * 0.4),
        radius,
        Paint()
          ..color = _light.withValues(alpha: 0.07)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.5),
      );
    }

    // Trekkers' headlamps zig-zagging up the ridge before dawn.
    for (var j = 0; j < 12; j++) {
      final f = j / 11;
      final p = Offset(
        ui.lerpDouble(cx - w * 0.17, cx - w * 0.045, f)! +
            math.sin(j * 1.9) * w * 0.025,
        ui.lerpDouble(hy - h * 0.03, topY + h * 0.05, f)!,
      );
      canvas.drawCircle(
        p,
        2.6,
        Paint()
          ..color = OdysseyColors.brassLight.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawCircle(p, 0.9, Paint()..color = _light.withValues(alpha: 0.95));
    }

    _hills(canvas, size, rng, hy + h * 0.08, h * 0.08, _depth(0.75));
    _hills(canvas, size, rng, h * 0.95, h * 0.07, _depth(1));
  }

  void _river(Canvas canvas, Size size, math.Random rng) {
    final w = size.width, h = size.height;
    final hy = h * 0.48;
    _sky(canvas, size, const Color(0xFF1A241D), const Color(0xFFA48A5C), hy);
    _sun(canvas, Offset(w * (0.35 + rng.nextDouble() * 0.3), hy - h * 0.06), h * 0.06,
        alpha: 0.7);
    _hills(canvas, size, rng, hy, h * 0.06, _depth(0.2));
    _hills(canvas, size, rng, hy + h * 0.045, h * 0.05, _depth(0.4));
    _mist(canvas, size, hy + h * 0.04, h * 0.08, 0.16);

    final vx = w * (0.45 + rng.nextDouble() * 0.1);
    final vy = hy + h * 0.07;
    final water = Path()
      ..moveTo(vx - w * 0.015, vy)
      ..cubicTo(vx - w * 0.08, vy + h * 0.15, w * 0.05, h * 0.75, -w * 0.1, h)
      ..lineTo(w * 1.1, h)
      ..cubicTo(w * 0.95, h * 0.8, vx + w * 0.12, vy + h * 0.18, vx + w * 0.015, vy)
      ..close();
    canvas.drawRect(
      Rect.fromLTRB(0, vy - 1, w, h),
      Paint()..color = _depth(0.7),
    );
    canvas.drawPath(
      water,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, vy), Offset(0, h), [
          const Color(0xFF9A8358),
          const Color(0xFF3A3A2A),
        ]),
    );

    // Jungle canopy rising toward the viewer on both banks.
    final canopy = Paint()..color = _depth(0.82);
    for (final side in [-1.0, 1.0]) {
      final bank = Path()
        ..moveTo(vx + side * w * 0.02, vy + 1)
        ..lineTo(side < 0 ? -2 : w + 2, vy - h * 0.2)
        ..lineTo(side < 0 ? -2 : w + 2, vy + h * 0.06)
        ..close();
      canvas.drawPath(bank, canopy);
      for (var k = 0; k <= 18; k++) {
        final f = k / 18;
        final x = ui.lerpDouble(vx + side * w * 0.03, side < 0 ? 0 : w, f)!;
        final y = ui.lerpDouble(vy, vy - h * 0.2, f)!;
        canvas.drawCircle(
          Offset(x, y),
          2 + f * w * 0.07 * (0.7 + rng.nextDouble() * 0.5),
          canopy,
        );
      }
    }

    for (var i = 0; i < 26; i++) {
      final f = rng.nextDouble();
      final y = vy + (h - vy) * f;
      final mid = ui.lerpDouble(vx, w * 0.5, f)!;
      final half = w * (0.01 + f * 0.06);
      final x = mid + (rng.nextDouble() - 0.5) * w * (0.05 + f * 0.5);
      canvas.drawLine(
        Offset(x - half, y),
        Offset(x + half, y),
        Paint()
          ..strokeWidth = 0.8
          ..color = _light.withValues(alpha: 0.18),
      );
    }

    // A long-tail slow boat with its roof.
    final by = vy + (h - vy) * 0.45;
    final bx = ui.lerpDouble(vx, w * 0.5, 0.45)! + w * 0.04;
    final s = w * 0.3;
    final boat = Paint()..color = _near;
    canvas.drawPath(
      Path()
        ..moveTo(bx - s / 2, by - s * 0.01)
        ..lineTo(bx + s / 2, by - s * 0.035)
        ..quadraticBezierTo(bx, by + s * 0.06, bx - s / 2, by - s * 0.01)
        ..close(),
      boat,
    );
    canvas.drawRect(
        Rect.fromLTRB(bx - s * 0.32, by - s * 0.09, bx + s * 0.24, by - s * 0.035), boat);
    canvas.drawRect(
        Rect.fromLTRB(bx - s * 0.36, by - s * 0.1, bx + s * 0.28, by - s * 0.085), boat);
    final wake = Paint()
      ..strokeWidth = 0.8
      ..color = _light.withValues(alpha: 0.25);
    canvas.drawLine(Offset(bx - s / 2, by), Offset(bx - s * 0.9, by + s * 0.05), wake);
    canvas.drawLine(Offset(bx - s / 2, by), Offset(bx - s * 0.85, by - s * 0.03), wake);
  }

  void _terraces(Canvas canvas, Size size, math.Random rng) {
    final w = size.width, h = size.height;
    final hy = h * 0.42;
    _sky(canvas, size, const Color(0xFF1B261E), const Color(0xFF8C7A55), hy);
    _sun(canvas, Offset(w * (0.2 + rng.nextDouble() * 0.6), hy - h * 0.16), h * 0.05,
        alpha: 0.6);
    _hills(canvas, size, rng, hy - h * 0.02, h * 0.12, _depth(0.15));
    _hills(canvas, size, rng, hy + h * 0.04, h * 0.09, _depth(0.3));
    _mist(canvas, size, hy + h * 0.06, h * 0.1, 0.18);

    final top = hy + h * 0.08;
    canvas.drawRect(Rect.fromLTRB(0, top, w, h), Paint()..color = _depth(0.58));
    // An amphitheatre of terraces: each wall dips toward the centre, and
    // the spacing opens up toward the viewer.
    const rows = 16;
    final tilt = (rng.nextDouble() - 0.5) * h * 0.05;
    for (var k = 0; k < rows; k++) {
      final f = math.pow(k / rows, 1.35).toDouble();
      final yl = top + f * (h - top) * 0.95 - tilt;
      final yr = top + f * (h - top) * 0.95 + tilt;
      final ym = top + h * 0.06 + f * (h - top) * 1.05;
      final control = 2 * ym - 0.5 * (yl + yr);
      final curve = Path()
        ..moveTo(-w * 0.05, yl)
        ..quadraticBezierTo(w * 0.5, control, w * 1.05, yr);
      canvas.drawPath(
        curve,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1 + k * 0.1
          ..color = _depth(0.88),
      );
      canvas.save();
      canvas.translate(0, 2 + k * 0.25);
      canvas.drawPath(
        curve,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7 + k * 0.08
          ..color = _light.withValues(alpha: 0.1 + k * 0.007),
      );
      canvas.restore();
    }

    // Two Ifugao huts on stilts.
    for (var i = 0; i < 2; i++) {
      final x = w * (0.2 + i * 0.5 + rng.nextDouble() * 0.15);
      final y = top + (h - top) * (0.28 + i * 0.22);
      final s = w * (0.035 + i * 0.015);
      final hut = Paint()..color = _near;
      canvas.drawPath(
        Path()
          ..moveTo(x - s, y - s * 0.6)
          ..lineTo(x, y - s * 1.8)
          ..lineTo(x + s, y - s * 0.6)
          ..close(),
        hut,
      );
      canvas.drawRect(Rect.fromLTRB(x - s * 0.6, y - s * 0.6, x + s * 0.6, y - s * 0.2), hut);
      canvas.drawRect(Rect.fromLTRB(x - s * 0.5, y - s * 0.2, x - s * 0.38, y + s * 0.2), hut);
      canvas.drawRect(Rect.fromLTRB(x + s * 0.38, y - s * 0.2, x + s * 0.5, y + s * 0.2), hut);
    }
  }

  void _lanterns(Canvas canvas, Size size, math.Random rng) {
    final w = size.width, h = size.height;
    final vx = w * 0.5;
    final vy = h * 0.56;
    _sky(canvas, size, const Color(0xFF0B100C), const Color(0xFF2B2A1F), vy);
    _stars(canvas, size, rng, 18, h * 0.3);
    _sun(canvas, Offset(w * (0.62 + rng.nextDouble() * 0.2), h * 0.14), h * 0.045,
        alpha: 0.8);

    final street = Path()
      ..moveTo(vx - w * 0.07, vy + h * 0.02)
      ..lineTo(vx + w * 0.07, vy + h * 0.02)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      street,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, vy), Offset(0, h), [
          const Color(0xFF2A2619),
          const Color(0xFF151A13),
        ]),
    );

    // Shophouse facades converging on the vanishing point.
    for (final side in [-1.0, 1.0]) {
      final edge = side < 0 ? 0.0 : w;
      final inner = vx + side * w * 0.07;
      final roof = Path()..moveTo(edge, h);
      const blocks = 6;
      for (var b = 0; b <= blocks; b++) {
        final f = b / blocks;
        final x = ui.lerpDouble(edge, inner, f)!;
        final y = ui.lerpDouble(h * 0.1, vy - h * 0.08, f)! +
            (rng.nextDouble() - 0.5) * h * 0.05 * (1 - f);
        roof.lineTo(x, y);
        if (b < blocks && rng.nextBool()) {
          final nx = ui.lerpDouble(edge, inner, (b + 0.5) / blocks)!;
          roof.lineTo(nx, y - h * 0.04 * (1 - f));
        }
      }
      roof
        ..lineTo(inner, vy + h * 0.02)
        ..close();
      canvas.drawPath(roof, Paint()..color = side < 0 ? _near : const Color(0xFF121A13));
      for (var i = 0; i < 9; i++) {
        final f = rng.nextDouble() * 0.85;
        final x = ui.lerpDouble(edge, inner, f)! + side * -4;
        final top = ui.lerpDouble(h * 0.16, vy - h * 0.04, f)!;
        final bottom = ui.lerpDouble(h * 0.9, vy, f)!;
        final y = top + (bottom - top) * rng.nextDouble();
        final s = ui.lerpDouble(9, 2, f)!;
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x + side * -s, y), width: s, height: s * 1.4),
          Paint()
            ..color = OdysseyColors.brassLight
                .withValues(alpha: 0.25 + rng.nextDouble() * 0.4),
        );
      }
    }

    // Strings of lanterns, nearer strings hung higher, wider and lower-slung.
    for (final f in [0.12, 0.38, 0.64, 0.9]) {
      final a = Offset(ui.lerpDouble(vx - w * 0.07, -w * 0.02, f)!,
          ui.lerpDouble(vy - h * 0.06, h * 0.2, f)!);
      final b = Offset(ui.lerpDouble(vx + w * 0.07, w * 1.02, f)!, a.dy - h * 0.01);
      final sag = ui.lerpDouble(h * 0.01, h * 0.09, f)!;
      final c = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 + sag * 2);
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..quadraticBezierTo(c.dx, c.dy, b.dx, b.dy),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6
          ..color = _light.withValues(alpha: 0.15),
      );
      final count = 5 + (f * 6).round();
      final radius = ui.lerpDouble(1.6, 6.5, f)! * (w / 360).clamp(0.6, 1.6);
      for (var i = 1; i < count; i++) {
        final t = i / count;
        final p = a * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + b * (t * t);
        final centre = p + Offset(0, radius * 1.3);
        canvas.drawCircle(
          centre,
          radius * 3.2,
          Paint()
            ..shader = ui.Gradient.radial(centre, radius * 3.2, [
              OdysseyColors.brassLight.withValues(alpha: 0.32),
              OdysseyColors.brassLight.withValues(alpha: 0),
            ]),
        );
        canvas.drawOval(
          Rect.fromCenter(center: centre, width: radius * 1.7, height: radius * 2.1),
          Paint()
            ..shader = ui.Gradient.radial(centre, radius * 1.1, [
              const Color(0xFFF0C878),
              OdysseyColors.ember,
            ]),
        );
        // Faint reflection on the wet street.
        if (f > 0.5) {
          final ry = h - (centre.dy - h * 0.6) * 0.25;
          canvas.drawLine(
            Offset(centre.dx, ry),
            Offset(centre.dx, ry + radius * 3),
            Paint()
              ..strokeWidth = radius * 0.6
              ..color = OdysseyColors.brassLight.withValues(alpha: 0.08),
          );
        }
      }
    }
  }

  void _temple(Canvas canvas, Size size, math.Random rng) {
    final w = size.width, h = size.height;
    final hy = h * 0.7;
    _sky(canvas, size, const Color(0xFF1E261C), const Color(0xFFB08C58), hy);
    final cx = w * (0.46 + rng.nextDouble() * 0.08);
    _sun(canvas, Offset(cx + w * (rng.nextDouble() - 0.5) * 0.2, hy - h * 0.2), h * 0.13,
        alpha: 0.7);
    _hills(canvas, size, rng, hy - h * 0.02, h * 0.03, _depth(0.35));

    Path temple(double baseY) {
      final path = Path()
        ..addRect(Rect.fromLTRB(cx - w * 0.3, baseY - h * 0.05, cx + w * 0.3, baseY + 1))
        ..addRect(Rect.fromLTRB(cx - w * 0.22, baseY - h * 0.09, cx + w * 0.22, baseY));
      void tower(double x, double bw, double th) {
        final base = baseY - h * 0.088;
        path
          ..moveTo(x - bw / 2, base)
          ..cubicTo(x - bw * 0.54, base - th * 0.45, x - bw * 0.38, base - th * 0.82,
              x, base - th)
          ..cubicTo(x + bw * 0.38, base - th * 0.82, x + bw * 0.54, base - th * 0.45,
              x + bw / 2, base)
          ..close();
      }

      tower(cx, w * 0.12, h * 0.36);
      tower(cx - w * 0.17, w * 0.08, h * 0.23);
      tower(cx + w * 0.17, w * 0.08, h * 0.23);
      tower(cx - w * 0.28, w * 0.05, h * 0.13);
      tower(cx + w * 0.28, w * 0.05, h * 0.13);
      return path;
    }

    final silhouette = temple(hy);
    canvas.drawPath(silhouette, Paint()..color = _depth(0.86));
    // Tier lines across the towers.
    for (var k = 1; k < 7; k++) {
      final y = hy - h * 0.088 - k * h * 0.045;
      canvas.drawLine(
        Offset(cx - w * 0.06, y),
        Offset(cx + w * 0.06, y),
        Paint()
          ..strokeWidth = 0.6
          ..color = OdysseyColors.brassLight.withValues(alpha: 0.12),
      );
    }

    final moat = Rect.fromLTRB(0, hy, w, h);
    canvas.drawRect(
      moat,
      Paint()
        ..shader = ui.Gradient.linear(moat.topCenter, moat.bottomCenter, [
          const Color(0xFF4A4030),
          _near,
        ]),
    );
    canvas.save();
    canvas.translate(0, hy * 2);
    canvas.scale(1, -1);
    canvas.drawPath(silhouette, Paint()..color = _depth(0.9).withValues(alpha: 0.35));
    canvas.restore();
    _reflectionColumn(canvas, size, rng, cx, hy);

    // Sugar palms framing the scene.
    final palm = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = _near;
    for (final x in [w * 0.1, w * 0.9]) {
      final lean = (x < w / 2 ? 1 : -1) * w * 0.04;
      final crown = Offset(x + lean, hy - h * 0.34);
      canvas.drawPath(
        Path()
          ..moveTo(x, h)
          ..quadraticBezierTo(x - lean * 0.5, hy - h * 0.1, crown.dx, crown.dy),
        palm..strokeWidth = 2.6,
      );
      for (var i = 0; i < 9; i++) {
        final angle = -math.pi + i * math.pi / 8;
        final len = w * (0.07 + rng.nextDouble() * 0.03);
        final end = crown + Offset.fromDirection(angle, len) + Offset(0, len * 0.4);
        final ctl = crown + Offset.fromDirection(angle, len * 0.6) - Offset(0, len * 0.15);
        canvas.drawPath(
          Path()
            ..moveTo(crown.dx, crown.dy)
            ..quadraticBezierTo(ctl.dx, ctl.dy, end.dx, end.dy),
          palm..strokeWidth = 1.8,
        );
      }
    }
  }

  /// Engraving lines, grain and a vignette over everything.
  void _engrave(Canvas canvas, Size size, math.Random rng) {
    final w = size.width, h = size.height;
    final lines = Paint()
      ..strokeWidth = 0.6
      ..color = _light.withValues(alpha: 0.035);
    for (var y = 1.5; y < h; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(w, y), lines);
    }
    final light = <Offset>[], dark = <Offset>[];
    for (var i = 0; i < (w * h / 260).clamp(60, 900); i++) {
      (i.isEven ? light : dark)
          .add(Offset(rng.nextDouble() * w, rng.nextDouble() * h));
    }
    canvas.drawPoints(
      ui.PointMode.points,
      light,
      Paint()
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round
        ..color = _light.withValues(alpha: 0.07),
    );
    canvas.drawPoints(
      ui.PointMode.points,
      dark,
      Paint()
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withValues(alpha: 0.12),
    );
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          rect.center,
          rect.longestSide * 0.75,
          [Colors.transparent, Colors.black.withValues(alpha: 0.38)],
          [0.55, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_PlatePainter old) =>
      old.motif != motif || old.seed != seed || old.framed != framed;
}
