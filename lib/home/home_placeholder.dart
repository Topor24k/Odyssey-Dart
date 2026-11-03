import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/auth_screen.dart';
import '../auth/auth_widgets.dart';
import '../theme/odyssey_theme.dart';

/// Where a signed-in wayfarer lands until the rest of the app is built.
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Mist.base,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: AuthBackdrop()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),
                    AuthTitle('Welcome,\n$name.', kicker: 'You\'re in'),
                    const SizedBox(height: 14),
                    Text(
                      'Your field journal is ready. The rest of Odyssey '
                      'comes next.',
                      textAlign: TextAlign.center,
                      style: OdysseyType.sans(
                        15,
                        color: Mist.soft,
                        height: 1.5,
                      ).copyWith(shadows: Mist.lift),
                    ),
                    const Spacer(flex: 3),
                    PillButton(
                      label: 'Sign Out',
                      icon: Icons.logout,
                      dark: false,
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => const AuthScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
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
