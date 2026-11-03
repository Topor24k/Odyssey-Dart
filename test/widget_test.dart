import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssey/auth/validators.dart';
import 'package:odyssey/splash/splash_timeline.dart';

void main() {
  group('Splash timeline', () {
    test('needle starts away from north and locks exactly on it', () {
      expect(SplashTimeline.needleAngle(0), SplashTimeline.needleFrom);
      expect(SplashTimeline.needleAngle(SplashTimeline.lock), 0);
      expect(SplashTimeline.needleAngle(SplashTimeline.length), 0);
    });

    test('needle overshoots north before it settles', () {
      final swing = [
        for (
          var t = SplashTimeline.needleStart;
          t < SplashTimeline.lock;
          t += 0.01
        )
          SplashTimeline.needleAngle(t),
      ];
      expect(swing.any((a) => a > 0), isTrue, reason: 'swings past north');
      expect(swing.last.abs(), lessThan(math.pi / 180));
    });

    test('beats are in order', () {
      expect(SplashTimeline.bezel.$1, lessThan(SplashTimeline.lock));
      expect(SplashTimeline.lock, lessThan(SplashTimeline.wordmarkStart));
      expect(SplashTimeline.coordinates.$2, lessThan(SplashTimeline.length));
      expect(
        SplashTimeline.duration.inMilliseconds,
        (SplashTimeline.length * 1000).round(),
      );
    });
  });

  group('Email', () {
    test('accepts well-formed addresses', () {
      expect(validateEmail('kayeen@example.com'), isNull);
      expect(validateEmail('  mai.thao+trips@mail.co.vn '), isNull);
    });

    test('rejects empty or malformed addresses', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail(null), isNotNull);
      expect(validateEmail('kayeen'), isNotNull);
      expect(validateEmail('kayeen@example'), isNotNull);
      expect(validateEmail('kay een@example.com'), isNotNull);
    });
  });

  group('Passwords', () {
    test('sign-in only needs something typed', () {
      expect(validateSignInPassword(''), isNotNull);
      expect(validateSignInPassword('x'), isNull);
    });

    test('new passwords need eight characters', () {
      expect(validateNewPassword('short'), isNotNull);
      expect(validateNewPassword('longenough'), isNull);
    });
  });

  group('Names', () {
    test('a name is required', () {
      expect(validateName('  '), isNotNull);
      expect(validateName('Kayeen'), isNull);
    });

    test('display name comes from the email', () {
      expect(nameFromEmail('kayeen.campana@example.com'), 'Kayeen');
      expect(nameFromEmail('MAI_thao@x.vn'), 'Mai');
      expect(nameFromEmail('@x.com'), 'Wayfarer');
    });
  });
}
