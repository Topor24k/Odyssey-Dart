import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../splash/splash_painters.dart';
import '../theme/odyssey_theme.dart';

/// The auth palette: white type over a soft, blurred wash in Odyssey's
/// brass-taupe and forest-sage tones, with obsidian forest for the main
/// action and parchment for the alternative.
abstract final class Mist {
  static const white = Colors.white;

  /// Labels and secondary text.
  static const soft = Color(0xD9FFFFFF);

  /// Field underlines.
  static const line = Color(0x99FFFFFF);
  static const error = Color(0xFF7A2C27);

  /// The colour of the wash's lower edge, for the system navigation bar.
  static const base = Color(0xFF98A098);

  /// Lifts white type off the light parts of the wash.
  static const lift = [
    Shadow(color: Color(0x2B000000), blurRadius: 12, offset: Offset(0, 1)),
  ];
}

/// A soft, out-of-focus wash — warm brass-taupe at the top left, a
/// parchment glow in the middle, forest-sage below — with the intro's
/// topographic contour lines traced faintly across it.
class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(painter: _MistPainter(), child: SizedBox.expand()),
    );
  }
}

class _MistPainter extends CustomPainter {
  const _MistPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, h),
          const [Color(0xFFB39F86), Color(0xFFBDB6AB), Color(0xFF98A098)],
          const [0, 0.5, 1],
        ),
    );
    void glow(Offset c, double r, Color color) => canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(c, r, [
          color,
          color.withValues(alpha: 0),
        ]),
    );
    glow(Offset(w * 0.1, h * 0.08), w * 0.9, const Color(0xE6C2A585));
    glow(Offset(w * 0.66, h * 0.38), w * 0.7, const Color(0xB3DDD6CA));
    glow(Offset(w * 0.25, h * 0.7), w * 0.6, const Color(0x80CFC9C0));
    glow(Offset(w * 0.92, h * 0.96), w * 0.9, const Color(0xCC8B988D));
    // A shadow falling in from the right edge, like a blurred photograph.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(Offset(w * 0.7, 0), Offset(w, 0), const [
          Color(0x00000000),
          Color(0x22000000),
        ]),
    );

    // Odyssey's survey-sheet contours, barely there.
    for (final ring in ContourField.generate(size, seed: 23).rings) {
      canvas.drawPath(
        ring.metric.extractPath(0, ring.metric.length),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ring.isIndex ? 1.0 : 0.7
          ..color = Colors.white.withValues(alpha: ring.isIndex ? 0.13 : 0.07),
      );
    }

    // Fine photographic grain.
    final rng = math.Random(4);
    canvas.drawPoints(
      ui.PointMode.points,
      [
        for (var i = 0; i < (w * h / 90).clamp(400, 9000); i++)
          Offset(rng.nextDouble() * w, rng.nextDouble() * h),
      ],
      Paint()
        ..strokeWidth = 1
        ..color = const Color(0x0DFFFFFF),
    );
  }

  @override
  bool shouldRepaint(_MistPainter old) => false;
}

/// Fades and lifts a form element in, staggered by [index], as its form
/// opens.
class Entrance extends StatelessWidget {
  const Entrance({
    super.key,
    required this.animation,
    required this.index,
    required this.child,
  });

  final Animation<double> animation;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.07).clamp(0.0, 0.65);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(
        start,
        (start + 0.35).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) => Opacity(
        opacity: curved.value,
        child: Transform.translate(
          offset: Offset(0, (1 - curved.value) * 14),
          child: child,
        ),
      ),
    );
  }
}

/// A small field-journal label over a large serif heading, both centred,
/// e.g. "SIGN IN" over "Welcome back, wayfarer."
class AuthTitle extends StatelessWidget {
  const AuthTitle(this.text, {super.key, this.kicker});

  final String text;
  final String? kicker;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kicker != null) ...[
          Text(
            kicker!.toUpperCase(),
            textAlign: TextAlign.center,
            style: OdysseyType.mono(
              10.5,
              color: Mist.soft,
              letterSpacing: 2.6,
            ).copyWith(shadows: Mist.lift),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          text,
          textAlign: TextAlign.center,
          style: OdysseyType.display(
            42,
            color: Mist.white,
            weight: FontWeight.w700,
            height: 1.04,
          ).copyWith(shadows: Mist.lift),
        ),
      ],
    );
  }
}

/// An underline-only field whose label floats up once it has focus or
/// text.
class LineField extends StatefulWidget {
  const LineField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.obscure = false,
    this.trailing,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;

  /// Hides the text. Without a [trailing] widget, an eye toggle reveals it.
  final bool obscure;

  /// Sits at the right end of the underline, e.g. "Forgot?".
  final Widget? trailing;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;

  @override
  State<LineField> createState() => _LineFieldState();
}

class _LineFieldState extends State<LineField> {
  late bool _hidden = widget.obscure;

  UnderlineInputBorder _line(Color color, double width) => UnderlineInputBorder(
    borderSide: BorderSide(color: color, width: width),
  );

  @override
  Widget build(BuildContext context) {
    Widget? suffix = widget.trailing;
    if (suffix == null && widget.obscure) {
      suffix = IconButton(
        tooltip: _hidden ? 'Show password' : 'Hide password',
        visualDensity: VisualDensity.compact,
        icon: Icon(
          _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: Mist.soft,
        ),
        onPressed: () => setState(() => _hidden = !_hidden),
      );
    }

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      // Per field, so typing in one never flags the untouched ones;
      // submitting validates them all.
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      obscureText: _hidden,
      enableSuggestions: !widget.obscure,
      autocorrect: false,
      textCapitalization: widget.textCapitalization,
      onFieldSubmitted: widget.onSubmitted,
      cursorColor: Mist.white,
      style: OdysseyType.sans(17, color: Mist.white, weight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: OdysseyType.sans(
          17,
          color: Mist.soft,
        ).copyWith(shadows: Mist.lift),
        floatingLabelStyle: OdysseyType.sans(13, color: Mist.soft),
        errorStyle: OdysseyType.sans(
          12.5,
          color: Mist.error,
          weight: FontWeight.w500,
        ),
        errorMaxLines: 2,
        filled: false,
        contentPadding: const EdgeInsets.only(top: 18, bottom: 14),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(),
        enabledBorder: _line(Mist.line, 1),
        focusedBorder: _line(Mist.white, 1.5),
        errorBorder: _line(Mist.error, 1),
        focusedErrorBorder: _line(Mist.error, 1.5),
      ),
    );
  }
}

/// Small text button inside a field, e.g. "Forgot?".
class FieldAction extends StatelessWidget {
  const FieldAction(this.label, {super.key, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 2, 8),
        child: Text(
          label,
          style: OdysseyType.sans(
            13.5,
            color: Mist.soft,
          ).copyWith(shadows: Mist.lift),
        ),
      ),
    );
  }
}

/// A full-width pill: obsidian forest for the main action, parchment for
/// the alternative. Shows a spinner while [busy].
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.dark = true,
    this.icon,
    this.busy = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool dark;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? OdysseyColors.forest : OdysseyColors.parchment;
    final fg = dark ? OdysseyColors.parchment : OdysseyColors.forest;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.25 : 0.07),
              blurRadius: dark ? 20 : 10,
              offset: Offset(0, dark ? 9 : 4),
            ),
          ],
        ),
        child: Material(
          color: bg,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: busy ? null : onPressed,
            child: SizedBox(
              height: 54,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: busy
                      ? SizedBox(
                          key: const ValueKey('busy'),
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: dark ? OdysseyColors.brassLight : fg,
                          ),
                        )
                      : Row(
                          key: const ValueKey('label'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, size: 20, color: fg),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              label,
                              style: OdysseyType.sans(
                                16,
                                color: fg,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The small rounded checkbox: parchment with a brass tick when on, a white
/// outline when off.
class TickBox extends StatelessWidget {
  const TickBox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.error = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  /// Outlines the box in the error colour.
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: value ? OdysseyColors.parchment : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: value
                      ? null
                      : Border.all(
                          color: error ? Mist.error : Mist.line,
                          width: 1.4,
                        ),
                ),
                child: value
                    ? const Icon(
                        Icons.check,
                        size: 15,
                        color: OdysseyColors.brass,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: OdysseyType.sans(
                    12,
                    color: error ? Mist.error : Mist.soft,
                    height: 1.35,
                  ).copyWith(shadows: error ? null : Mist.lift),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Don't have an account?  Sign Up", centred at the foot of the form.
class FooterPrompt extends StatelessWidget {
  const FooterPrompt({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$question  ',
          style: OdysseyType.sans(
            13.5,
            color: Mist.soft,
          ).copyWith(shadows: Mist.lift),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Text(
              action,
              style:
                  OdysseyType.sans(
                    13.5,
                    color: Mist.white,
                    weight: FontWeight.w600,
                  ).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: Mist.white,
                    shadows: Mist.lift,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
