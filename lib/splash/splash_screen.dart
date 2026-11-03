import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/atlas.dart';
import '../data/geo.dart';
import '../data/models.dart';
import '../theme/odyssey_theme.dart';
import 'reveal_route.dart';
import 'splash_painters.dart';
import 'splash_sound.dart';
import 'splash_timeline.dart';

/// The opening sequence: contour lines survey themselves in, a compass draws
/// its bezel, the needle swings onto north and locks with a bowl strike, the
/// wordmark resolves, and coordinates scramble until they lock onto a
/// different field waypoint each launch. Tap anywhere to skip.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.next});

  final WidgetBuilder next;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: SplashTimeline.duration,
  );
  final SplashSound _sound = SplashSound();
  final Waypoint _bearing =
      Atlas.waypoints[math.Random().nextInt(Atlas.waypoints.length)];

  ContourField? _field;
  Size? _fieldSize;
  Offset _revealCenter = Offset.zero;
  bool _locked = false;
  bool _leaving = false;

  double get _t => _clock.value * SplashTimeline.length;

  @override
  void initState() {
    super.initState();
    _clock
      ..addListener(_onTick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _leave();
      });
    _start();
  }

  Future<void> _start() async {
    OdysseyType.warmUp().ignore();
    await _sound.prepare().timeout(
          const Duration(milliseconds: 800),
          onTimeout: () {},
        );
    if (!mounted) return;
    _clock.forward();
    _sound.play();
  }

  void _onTick() {
    if (!_locked && _t >= SplashTimeline.lock) {
      _locked = true;
      HapticFeedback.lightImpact();
    }
  }

  void _leave() {
    if (_leaving || !mounted) return;
    _leaving = true;
    if (!_clock.isCompleted) {
      _sound.fadeOut();
      _clock.stop();
    }
    Navigator.of(context).pushReplacement(
      CircularRevealRoute(builder: widget.next, center: _revealCenter),
    );
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: OdysseyColors.forest,
      ),
      child: Scaffold(
        backgroundColor: OdysseyColors.forest,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _leave,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              if (_fieldSize != size) {
                _field = ContourField.generate(size);
                _fieldSize = size;
              }
              return AnimatedBuilder(
                animation: _clock,
                builder: (context, _) => _frame(context, size),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _frame(BuildContext context, Size size) {
    final t = _t;
    final diameter = math.min(size.width * 0.48, 200.0);
    const block = 150.0;
    final rise = SplashTimeline.progress(
        t, SplashTimeline.rise, Curves.easeInOutCubic);
    final center = size.center(Offset.zero);
    final compass = Offset(center.dx, center.dy - rise * block / 2);
    _revealCenter = compass;
    final textTop = center.dy - block / 2 + diameter * 0.29 + 30;
    final tagline = SplashTimeline.progress(
        t, SplashTimeline.tagline, Curves.easeOut);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: SplashBackdropPainter(t: t, field: _field!),
          ),
        ),
        Positioned(
          left: compass.dx - diameter / 2,
          top: compass.dy - diameter / 2,
          width: diameter,
          height: diameter,
          child: Transform.scale(
            scale: lerpDouble(1, 0.58, rise),
            child: CustomPaint(painter: CompassPainter(t: t)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: textTop,
          child: _TitleBlock(t: t, bearing: _bearing),
        ),
        Positioned(
          left: 32,
          right: 32,
          bottom: 40 + MediaQuery.paddingOf(context).bottom,
          child: Opacity(
            opacity: tagline,
            child: Transform.translate(
              offset: Offset(0, (1 - tagline) * 8),
              child: Text(
                'For those who seek the journey\nas much as the destination.',
                textAlign: TextAlign.center,
                style: OdysseyType.display(
                  15,
                  italic: true,
                  height: 1.4,
                  color: OdysseyColors.parchment.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.t, required this.bearing});

  final double t;
  final Waypoint bearing;

  @override
  Widget build(BuildContext context) {
    final rule = SplashTimeline.progress(
        t, SplashTimeline.rule, Curves.easeOutCubic);
    final subtitle = SplashTimeline.progress(
        t, SplashTimeline.subtitle, Curves.easeOut);
    final coords = SplashTimeline.progress(t, SplashTimeline.coordinates);
    final name = SplashTimeline.progress(
        t, SplashTimeline.bearingName, Curves.easeOut);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Wordmark(t: t),
        const SizedBox(height: 12),
        CustomPaint(size: const Size(190, 10), painter: RulePainter(rule)),
        const SizedBox(height: 14),
        Opacity(
          opacity: subtitle,
          child: Text(
            'SOUTHEAST ASIA EXPEDITION NETWORK',
            textAlign: TextAlign.center,
            style: OdysseyType.subtitle(
              12,
              color: OdysseyColors.brassLight,
              letterSpacing: lerpDouble(7, 3.2, subtitle)!,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Opacity(
          opacity: (coords * 4).clamp(0, 1),
          child: Text(
            _scramble(formatLatLng(bearing.point), coords),
            style: OdysseyType.mono(
              11,
              color: OdysseyColors.parchment.withValues(alpha: 0.78),
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Opacity(
          opacity: name,
          child: Text(
            '◆  ${bearing.name.toUpperCase()}',
            style: OdysseyType.mono(
              9,
              color: OdysseyColors.brass,
              letterSpacing: 2.2,
            ),
          ),
        ),
      ],
    );
  }

  /// Rolls the digits of [target] like a GPS hunting for a fix, locking
  /// them left to right as [progress] runs to 1.
  String _scramble(String target, double progress) {
    if (progress >= 1) return target;
    final locked = (progress * target.length).floor();
    final roll = math.Random((t * 24).floor());
    final out = StringBuffer();
    for (var i = 0; i < target.length; i++) {
      final ch = target[i];
      final isDigit = ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
      out.write(i < locked || !isDigit ? ch : roll.nextInt(10));
    }
    return out.toString();
  }
}

/// ODYSSEY, resolving letter by letter from the centre outward while the
/// tracking tightens.
class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.t});

  final double t;

  static const _letters = 'ODYSSEY';

  @override
  Widget build(BuildContext context) {
    final start = SplashTimeline.wordmarkStart;
    final tracking = lerpDouble(
      15,
      4.5,
      SplashTimeline.progress(t, (start, start + 1.0), Curves.easeOutQuart),
    )!;
    final style = OdysseyType.display(
      46,
      color: OdysseyColors.parchment,
      height: 1,
    );
    // Early on, the widest tracking can exceed a narrow phone; only the
    // still-invisible outer letters spill, so let the row overflow freely.
    return SizedBox(
      height: 54,
      child: OverflowBox(
        maxWidth: double.infinity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _letters.length; i++)
              _letter(_letters[i], i, start, tracking, style),
          ],
        ),
      ),
    );
  }

  Widget _letter(
    String letter,
    int index,
    double start,
    double tracking,
    TextStyle style,
  ) {
    final delay = (index - 3).abs() * 0.07;
    final p = SplashTimeline.progress(
      t,
      (start + delay, start + delay + 0.55),
      Curves.easeOutCubic,
    );
    Widget glyph = Text(letter, style: style);
    if (p < 0.98) {
      final sigma = (1 - p) * 6;
      glyph = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: glyph,
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tracking),
      child: Opacity(
        opacity: p,
        child: Transform.translate(
          offset: Offset(0, (1 - p) * 14),
          child: glyph,
        ),
      ),
    );
  }
}
