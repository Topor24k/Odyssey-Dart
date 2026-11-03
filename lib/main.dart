import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'auth/auth_screen.dart';
import 'splash/splash_screen.dart';
import 'theme/odyssey_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const OdysseyApp());
}

class OdysseyApp extends StatelessWidget {
  const OdysseyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odyssey',
      debugShowCheckedModeBanner: false,
      theme: buildOdysseyTheme(),
      home: SplashScreen(next: (_) => const AuthScreen()),
    );
  }
}
