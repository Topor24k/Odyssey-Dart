import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home/home_placeholder.dart';
import 'auth_widgets.dart';
import 'login_form.dart';
import 'signup_form.dart';

enum AuthMode { signIn, signUp }

/// Log in and sign up, in a minimalist style: white type over a soft
/// blurred wash, underline fields and pill buttons. The two forms
/// cross-fade over the same backdrop.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.signIn});

  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode _mode = widget.initialMode;
  final _scroll = ScrollController();

  /// The first form waits for the intro's reveal before it staggers in.
  bool _firstForm = true;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _switchTo(AuthMode mode) {
    FocusScope.of(context).unfocus();
    setState(() {
      _mode = mode;
      _firstForm = false;
    });
    // Each form starts from its title, wherever the last one was scrolled.
    if (_scroll.hasClients && _scroll.offset > 0) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _enterJournal(String name) {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, _, _) => HomePlaceholder(name: name),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signUp = _mode == AuthMode.signUp;
    final entranceDelay = Duration(milliseconds: _firstForm ? 550 : 60);

    return PopScope(
      canPop: !signUp,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _switchTo(AuthMode.signIn);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Mist.base,
        ),
        child: Scaffold(
          backgroundColor: Mist.base,
          body: Stack(
            children: [
              const Positioned.fill(child: AuthBackdrop()),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, viewport) => SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ConstrainedBox(
                      // At least a screen tall, so the footer rests at the
                      // bottom; taller (and scrollable) when the keyboard
                      // takes the room.
                      constraints: BoxConstraints(
                        minHeight: viewport.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 360),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          layoutBuilder: (current, previous) => Stack(
                            fit: StackFit.expand,
                            children: [...previous, ?current],
                          ),
                          child: signUp
                              ? SignUpForm(
                                  key: const ValueKey(AuthMode.signUp),
                                  entranceDelay: entranceDelay,
                                  onLogIn: () => _switchTo(AuthMode.signIn),
                                  onCreated: _enterJournal,
                                )
                              : LoginForm(
                                  key: const ValueKey(AuthMode.signIn),
                                  entranceDelay: entranceDelay,
                                  onSignUp: () => _switchTo(AuthMode.signUp),
                                  onSignedIn: _enterJournal,
                                ),
                        ),
                      ),
                    ),
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
