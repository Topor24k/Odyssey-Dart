import 'package:flutter/material.dart';

import '../theme/odyssey_theme.dart';

/// The sign-in palette: deep teal type and hairlines on the cream page.
abstract final class Mist {
  /// Titles, field text and links.
  static const strong = AppColors.ink;

  /// Labels and secondary text.
  static const soft = AppColors.muted;

  /// Field underlines.
  static const line = Color(0xFFCFC6B5);
  static const error = Color(0xFFA2412F);

  /// The page colour, also used for the system navigation bar.
  static const base = AppColors.canvas;
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

/// Small tracked capitals over a large serif heading, both centred, e.g.
/// "SIGN IN" over "Welcome back, wayfarer."
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
            style: OdysseyType.caps(10, color: Mist.soft, letterSpacing: 2.6),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          text,
          textAlign: TextAlign.center,
          style: OdysseyType.display(
            38,
            color: Mist.strong,
            weight: FontWeight.w500,
            height: 1.05,
          ),
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
      cursorColor: Mist.strong,
      style: OdysseyType.sans(17, color: Mist.strong, weight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: OdysseyType.sans(16.5, color: Mist.soft),
        floatingLabelStyle: OdysseyType.sans(13, color: Mist.soft),
        errorStyle: OdysseyType.sans(
          12.5,
          color: Mist.error,
          weight: FontWeight.w500,
        ),
        errorMaxLines: 2,
        filled: false,
        contentPadding: const EdgeInsets.only(top: 16, bottom: 12),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(),
        enabledBorder: _line(Mist.line, 1),
        focusedBorder: _line(Mist.strong, 1.5),
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
        child: Text(label, style: OdysseyType.sans(13.5, color: Mist.strong)),
      ),
    );
  }
}

/// A full-width pill: deep teal for the main action, warm white for the
/// alternative. Shows a spinner while [busy].
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
    final bg = dark ? AppColors.ink : AppColors.card;
    final fg = dark ? Colors.white : AppColors.ink;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: dark ? 0.25 : 0.06),
              blurRadius: dark ? 18 : 10,
              offset: Offset(0, dark ? 8 : 3),
            ),
          ],
        ),
        child: Material(
          color: bg,
          shape: StadiumBorder(
            side: dark
                ? BorderSide.none
                : const BorderSide(color: AppColors.line),
          ),
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
                            color: fg,
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

/// A small rounded checkbox: teal with a white tick when on, an outline
/// when off.
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
                  color: value ? AppColors.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: value
                      ? null
                      : Border.all(
                          color: error ? Mist.error : Mist.line,
                          width: 1.4,
                        ),
                ),
                child: value
                    ? const Icon(Icons.check, size: 15, color: Colors.white)
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
                  ),
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
        Text('$question  ', style: OdysseyType.sans(13.5, color: Mist.soft)),
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
                    color: Mist.strong,
                    weight: FontWeight.w600,
                  ).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: Mist.strong,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
