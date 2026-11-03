import 'package:flutter/material.dart';

/// Builds one cover. [isReflection] is true for the mirrored copy beneath
/// it, which must not contain Heroes or anything interactive.
typedef CoverBuilder = Widget Function(
    BuildContext context, int index, bool isReflection);

/// A 3D cover-flow carousel: the centred cover faces you, its neighbours turn
/// away in perspective, and each stands on a faint reflection.
class CoverFlow extends StatefulWidget {
  const CoverFlow({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height = 320,
    this.viewportFraction = 0.64,
    this.onTap,
    this.onPageChanged,
  });

  final int itemCount;
  final CoverBuilder itemBuilder;
  final double height;
  final double viewportFraction;
  final ValueChanged<int>? onTap;
  final ValueChanged<int>? onPageChanged;

  @override
  State<CoverFlow> createState() => _CoverFlowState();
}

class _CoverFlowState extends State<CoverFlow> {
  static const _reflection = 0.2;
  static const _gap = 6.0;

  late final PageController _controller =
      PageController(viewportFraction: widget.viewportFraction);
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.hasClients && _controller.page != null) {
        setState(() => _page = _controller.page!);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tap(int index) {
    if (index == _page.round()) {
      widget.onTap?.call(index);
    } else {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverHeight = (widget.height - _gap) / (1 + _reflection);
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.itemCount,
        onPageChanged: widget.onPageChanged,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final delta = (index - _page).clamp(-1.5, 1.5);
          final near = delta.abs().clamp(0.0, 1.0);
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(-delta.clamp(-1.0, 1.0) * 0.85);
          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Transform.scale(
              scale: 1 - 0.14 * near,
              child: Opacity(
                opacity: 1 - 0.45 * ((delta.abs() - 0.6) / 0.9).clamp(0, 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      SizedBox(
                        height: coverHeight,
                        child: GestureDetector(
                          onTap: () => _tap(index),
                          child: widget.itemBuilder(context, index, false),
                        ),
                      ),
                      const SizedBox(height: _gap),
                      _Reflection(
                        height: coverHeight,
                        fraction: _reflection,
                        child: widget.itemBuilder(context, index, true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Reflection extends StatelessWidget {
  const _Reflection({
    required this.height,
    required this.fraction,
    required this.child,
  });

  final double height;
  final double fraction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: height * fraction,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minHeight: height,
            maxHeight: height,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.24),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: [0, fraction],
              ).createShader(rect),
              child: Transform.flip(flipY: true, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
