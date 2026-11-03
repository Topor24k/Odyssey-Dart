import 'package:flutter/material.dart';

import '../theme/odyssey_theme.dart';
import 'auth_widgets.dart';
import 'validators.dart';

/// Log in with email and password, or with Gmail.
///
/// For now Log In opens the app straight away, details or not — there is no
/// account backend yet. An empty email signs in as "Wayfarer".
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.onSignUp,
    required this.onSignedIn,
    this.entranceDelay = Duration.zero,
  });

  final VoidCallback onSignUp;

  /// Called with the wayfarer's display name.
  final ValueChanged<String> onSignedIn;
  final Duration entranceDelay;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  bool _remember = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.entranceDelay, () {
      if (mounted) _entrance.forward();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onSignedIn(nameFromEmail(_email.text));
  }

  void _gmail() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Gmail login isn\'t connected yet.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    var i = 0;
    Widget step(Widget child) =>
        Entrance(animation: _entrance, index: i++, child: child);

    return Form(
      key: _form,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 2),
            const SizedBox(height: 28),
            step(
              const AuthTitle('Welcome back,\nwayfarer.', kicker: 'Sign in'),
            ),
            const SizedBox(height: 36),
            step(
              LineField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
              ),
            ),
            const SizedBox(height: 8),
            step(
              LineField(
                label: 'Password',
                controller: _password,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
                trailing: FieldAction(
                  'Forgot?',
                  onTap: () => showResetSheet(context, _email.text),
                ),
              ),
            ),
            const SizedBox(height: 16),
            step(
              TickBox(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v),
                label: 'Remember me',
              ),
            ),
            const SizedBox(height: 26),
            step(PillButton(label: 'Log In', busy: _busy, onPressed: _submit)),
            const SizedBox(height: 18),
            step(
              PillButton(
                label: 'Log in with Gmail',
                icon: Icons.mail_outline,
                dark: false,
                onPressed: _gmail,
              ),
            ),
            const Spacer(flex: 3),
            const SizedBox(height: 32),
            step(
              FooterPrompt(
                question: 'Don\'t have an account?',
                action: 'Sign Up',
                onTap: widget.onSignUp,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// Asks for an email and "sends" a reset link.
Future<void> showResetSheet(BuildContext context, String email) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: OdysseyColors.forest,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: _ResetSheet(initialEmail: email),
    ),
  );
}

class _ResetSheet extends StatefulWidget {
  const _ResetSheet({required this.initialEmail});

  final String initialEmail;

  @override
  State<_ResetSheet> createState() => _ResetSheetState();
}

class _ResetSheetState extends State<_ResetSheet> {
  final _form = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'If an account exists for ${_email.text.trim()}, a reset link is '
          'on its way.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reset password',
                style: OdysseyType.sans(
                  24,
                  color: Mist.white,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the email you signed up with and we\'ll send you a '
                'link to set a new password.',
                style: OdysseyType.sans(14, color: Mist.soft, height: 1.45),
              ),
              const SizedBox(height: 12),
              LineField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.send,
                autofillHints: const [AutofillHints.email],
                validator: validateEmail,
                onSubmitted: (_) => _send(),
              ),
              const SizedBox(height: 28),
              PillButton(
                label: 'Send reset link',
                dark: false,
                busy: _busy,
                onPressed: _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
