import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_shell.dart';
import '../data/app_store.dart';
import '../data/intro_prefs.dart';
import '../intro/intro_screen.dart';
import 'auth_widgets.dart';
import 'login_form.dart';
import 'signup_form.dart';

enum AuthMode { signIn, signUp }

/// Log in and sign up, in a minimalist style: serif titles on the cream
/// page, underline fields and pill buttons. The two forms cross-fade.
///
/// After signing up, the intro tour plays; after logging in it plays again
/// until "Don't show this again" is ticked.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.signIn});

  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode _mode = widget.initialMode;
  final _scroll = ScrollController();

  /// The first form waits a beat after launch before it staggers in.
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

  /// Into the app, by way of the intro tour when it's due.
  Future<void> _enterJournal(String name, {required bool signedUp}) async {
    HapticFeedback.mediumImpact();
    AppStore.instance.signIn(name);
    final intro = await IntroPrefs.shouldShow(afterSignUp: signedUp);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, _, _) =>
            intro ? IntroScreen(name: name) : const AppShell(),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signUp = _mode == AuthMode.signUp;
    final entranceDelay = Duration(milliseconds: _firstForm ? 150 : 60);

    return PopScope(
      canPop: !signUp,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _switchTo(AuthMode.signIn);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Mist.base,
        ),
        child: Scaffold(
          backgroundColor: Mist.base,
          body: LayoutBuilder(
            builder: (context, viewport) => SingleChildScrollView(
              controller: _scroll,
              child: ConstrainedBox(
                // At least a screen tall, so the footer rests at the
                // bottom; taller (and scrollable) when the keyboard takes
                // the room.
                constraints: BoxConstraints(minHeight: viewport.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            32,
                            MediaQuery.paddingOf(context).top,
                            32,
                            MediaQuery.paddingOf(context).bottom,
                          ),
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
                                    onCreated: (name) =>
                                        _enterJournal(name, signedUp: true),
                                  )
                                : LoginForm(
                                    key: const ValueKey(AuthMode.signIn),
                                    entranceDelay: entranceDelay,
                                    onSignUp: () => _switchTo(AuthMode.signUp),
                                    onSignedIn: (name) =>
                                        _enterJournal(name, signedUp: false),
                                  ),
                          ),
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
