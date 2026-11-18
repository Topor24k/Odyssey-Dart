import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_shell.dart';
import '../data/intro_prefs.dart';
import '../theme/odyssey_theme.dart';
import '../widgets/kit.dart';
import '../widgets/motion.dart';
import '../widgets/photo.dart';

class _Page {
  const _Page(this.photo, this.place, this.title, this.body);

  final Photo photo;
  final String place;
  final String title;
  final String body;
}

const _pages = [
  _Page(
    Photos.haGiangPeak,
    'Mã Pí Lèng, Vietnam',
    'Travel slower.\nRemember more.',
    'Odyssey is a field journal and a circle of wayfarers across '
        'Southeast Asia.',
  ),
  _Page(
    Photos.kayanganLake,
    'Coron, Philippines',
    'Share the road\nwith your circle.',
    'Stories, quick notes and invites from people travelling the same way.',
  ),
  _Page(
    Photos.batadTerraces,
    'Batad, Philippines',
    'Pin stories where\nthey happened.',
    'Drop yours on the map, and find the places others loved.',
  ),
  _Page(
    Photos.segaraAnak,
    'Rinjani, Indonesia',
    'Plan the days,\njoin the climb.',
    'Your schedule keeps your plans and every gathering or expedition you '
        'join.',
  ),
  _Page(
    Photos.trangAn,
    'Ninh Bình, Vietnam',
    'Keep it all in\nyour journal.',
    'Shared or private, everything you write stays with you.',
  ),
];

/// A short photo tour of what Odyssey does, played after signing up. Skip
/// it at any time; tick "Don't show this again" and it won't come back.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.name});

  /// Your first name, for the welcome on the first page.
  final String name;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  final _pager = PageController();

  /// A slow drift on the photo, so each page feels alive.
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat(reverse: true);

  int _index = 0;
  bool _dontShow = false;
  bool _leaving = false;

  bool get _last => _index == _pages.length - 1;

  /// Full screen and cropped tall, so the photos load at full size.
  static const _photoWidth = 4000.0;

  @override
  void initState() {
    super.initState();
    IntroPrefs.markSeen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load every page's photo now, so swiping never waits.
    for (final page in _pages) {
      precacheImage(
        PhotoImage.providerFor(context, page.photo, width: _photoWidth),
        context,
      );
    }
  }

  @override
  void dispose() {
    _pager.dispose();
    _drift.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_last) {
      _finish();
    } else {
      _pager.nextPage(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _finish() async {
    if (_leaving) return;
    _leaving = true;
    if (_dontShow) await IntroPrefs.hideForGood();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, _, _) => const AppShell(),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF102421),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF102421),
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pager,
              itemCount: _pages.length,
              onPageChanged: (i) {
                HapticFeedback.selectionClick();
                setState(() => _index = i);
              },
              itemBuilder: (context, i) => _Backdrop(
                photo: _pages[i].photo,
                index: i,
                pager: _pager,
                drift: _drift,
              ),
            ),
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x99102421),
                      Color(0x00102421),
                      Color(0x00102421),
                      Color(0xCC102421),
                      Color(0xF7102421),
                    ],
                    stops: [0, 0.22, 0.42, 0.72, 1],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Wordmark(size: 19, color: Colors.white),
                        const Spacer(),
                        TextButton(
                          onPressed: _finish,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Skip',
                            style: OdysseyType.sans(
                              14,
                              color: Colors.white,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 460),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder: (current, previous) => Stack(
                        alignment: Alignment.bottomLeft,
                        children: [...previous, ?current],
                      ),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: _Copy(
                        key: ValueKey(_index),
                        page: page,
                        body: _index == 0 && widget.name.isNotEmpty
                            ? 'Welcome, ${widget.name}. ${page.body}'
                            : page.body,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        _Progress(pager: _pager, count: _pages.length),
                        const Spacer(),
                        _NextButton(last: _last, onTap: _next),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _DontShow(
                      value: _dontShow,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _dontShow = v);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The page's photo, sliding a little slower than the page (parallax) and
/// drifting closer while it's on screen.
class _Backdrop extends StatelessWidget {
  const _Backdrop({
    required this.photo,
    required this.index,
    required this.pager,
    required this.drift,
  });

  final Photo photo;
  final int index;
  final PageController pager;
  final Animation<double> drift;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pager, drift]),
      builder: (context, child) {
        final page = pager.hasClients && pager.position.haveDimensions
            ? pager.page ?? 0
            : 0.0;
        final offset = (page - index).clamp(-1.0, 1.0);
        final scale = 1.08 + 0.06 * Curves.easeInOut.transform(drift.value);
        return ClipRect(
          child: Transform.scale(
            scale: scale,
            child: PhotoImage(
              photo,
              width: _IntroScreenState._photoWidth,
              alignment: Alignment(offset * 0.7, 0),
              background: const Color(0xFF102421),
            ),
          ),
        );
      },
    );
  }
}

class _Copy extends StatelessWidget {
  const _Copy({super.key, required this.page, required this.body});

  final _Page page;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(9, 5, 11, 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.place_outlined, size: 13, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                page.place.toUpperCase(),
                style: OdysseyType.caps(
                  9.5,
                  color: Colors.white,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          page.title,
          style: OdysseyType.display(
            38,
            color: Colors.white,
            weight: FontWeight.w500,
            height: 1.02,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          body,
          style: OdysseyType.sans(14.5, color: Colors.white70, height: 1.5),
        ),
      ],
    );
  }
}

/// One short bar per page; the current one stretches out as you swipe.
class _Progress extends StatelessWidget {
  const _Progress({required this.pager, required this.count});

  final PageController pager;
  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pager,
      builder: (context, _) {
        final page = pager.hasClients && pager.position.haveDimensions
            ? pager.page ?? 0
            : 0.0;
        return Row(
          children: [
            for (var i = 0; i < count; i++)
              Builder(
                builder: (context) {
                  final near = (1 - (page - i).abs()).clamp(0.0, 1.0);
                  return Container(
                    width: 8 + 22 * near,
                    height: 4,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: Color.lerp(Colors.white38, Colors.white, near),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

/// A round arrow that opens out into "Start exploring" on the last page.
class _NextButton extends StatelessWidget {
  const _NextButton({required this.last, required this.onTap});

  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: last ? 'Start exploring' : 'Next',
      child: Press(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutBack,
            width: last ? 172 : 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(29),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: last
                  ? Row(
                      key: const ValueKey('start'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Start exploring',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.clip,
                          style: OdysseyType.sans(
                            14.5,
                            color: AppColors.ink,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: AppColors.ink,
                        ),
                      ],
                    )
                  : const Icon(
                      Icons.arrow_forward,
                      key: ValueKey('next'),
                      color: AppColors.ink,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DontShow extends StatelessWidget {
  const _DontShow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      label: 'Don\'t show this again',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: value ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: value ? Colors.white : Colors.white70,
                    width: 1.4,
                  ),
                ),
                child: AnimatedScale(
                  scale: value ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: const Icon(
                    Icons.check,
                    size: 13,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Don\'t show this again',
                style: OdysseyType.sans(13, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
