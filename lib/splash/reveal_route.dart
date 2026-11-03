import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../theme/odyssey_theme.dart';

/// Opens the next page as a widening circle from [center], edged with a
/// brass ring — the journal unfolding out of the compass.
class CircularRevealRoute<T> extends PageRouteBuilder<T> {
  CircularRevealRoute({required WidgetBuilder builder, required Offset center})
    : super(
        transitionDuration: const Duration(milliseconds: 950),
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: (context, animation, _, child) {
          final eased = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return AnimatedBuilder(
            animation: eased,
            child: child,
            builder: (context, child) {
              final f = eased.value;
              if (f >= 1) return child!;
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipPath(
                    clipper: _CircleClipper(center, f),
                    child: Transform.scale(
                      scale: lerpDouble(1.06, 1, f),
                      child: child,
                    ),
                  ),
                  IgnorePointer(
                    child: CustomPaint(painter: _RingPainter(center, f)),
                  ),
                ],
              );
            },
          );
        },
      );
}

double _coverRadius(Size size, Offset center) => [
  Offset.zero,
  Offset(size.width, 0),
  Offset(0, size.height),
  Offset(size.width, size.height),
].map((corner) => (corner - center).distance).reduce(math.max);

class _CircleClipper extends CustomClipper<Path> {
  _CircleClipper(this.center, this.fraction);

  final Offset center;
  final double fraction;

  @override
  Path getClip(Size size) => Path()
    ..addOval(
      Rect.fromCircle(
        center: center,
        radius: _coverRadius(size, center) * fraction,
      ),
    );

  @override
  bool shouldReclip(_CircleClipper old) =>
      old.fraction != fraction || old.center != center;
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.center, this.fraction);

  final Offset center;
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    if (fraction <= 0) return;
    final radius = _coverRadius(size, center) * fraction;
    final fade = 1 - fraction;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = OdysseyColors.brassLight.withValues(alpha: 0.9 * fade),
    );
    canvas.drawCircle(
      center,
      radius - 7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = OdysseyColors.brass.withValues(alpha: 0.5 * fade),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.center != center;
}
