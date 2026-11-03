import 'package:flutter/material.dart';

import 'auth_widgets.dart';
import 'validators.dart';

/// Create an account with a name, email and password, or with Gmail.
///
/// UI only: a valid form "creates" the account after a short pause.
class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.onLogIn,
    required this.onCreated,
    this.entranceDelay = Duration.zero,
  });

  final VoidCallback onLogIn;

  /// Called with the new wayfarer's first name.
  final ValueChanged<String> onCreated;
  final Duration entranceDelay;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  bool _agreed = false;
  bool _agreementMissing = false;
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
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _form.currentState!.validate();
    setState(() => _agreementMissing = !_agreed);
    if (!valid || !_agreed) return;
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onCreated(_name.text.trim().split(RegExp(r'\s+')).first);
  }

  void _gmail() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Gmail sign-up isn\'t connected yet.')),
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
              const AuthTitle(
                'Begin your\nodyssey.',
                kicker: 'Create your account',
              ),
            ),
            const SizedBox(height: 36),
            step(
              LineField(
                label: 'Your Name',
                controller: _name,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                validator: validateName,
              ),
            ),
            const SizedBox(height: 8),
            step(
              LineField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: validateEmail,
              ),
            ),
            const SizedBox(height: 8),
            step(
              LineField(
                label: 'Password',
                controller: _password,
                obscure: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: validateNewPassword,
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 16),
            step(
              TickBox(
                value: _agreed,
                error: _agreementMissing,
                onChanged: (v) => setState(() {
                  _agreed = v;
                  if (v) _agreementMissing = false;
                }),
                label: _agreementMissing
                    ? 'Please agree to the terms of service and privacy policy '
                          'to sign up'
                    : 'By signing up you agree to the terms of service and '
                          'privacy policy',
              ),
            ),
            const SizedBox(height: 26),
            step(PillButton(label: 'Sign Up', busy: _busy, onPressed: _submit)),
            const SizedBox(height: 18),
            step(
              PillButton(
                label: 'Sign up with Gmail',
                icon: Icons.mail_outline,
                dark: false,
                onPressed: _gmail,
              ),
            ),
            const Spacer(flex: 3),
            const SizedBox(height: 32),
            step(
              FooterPrompt(
                question: 'Already have an account?',
                action: 'Log In',
                onTap: widget.onLogIn,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
