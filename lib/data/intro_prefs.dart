import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers, on this phone, whether the intro tour has played and whether
/// you asked not to see it again.
abstract final class IntroPrefs {
  static const _seenKey = 'intro.seen';
  static const _hiddenKey = 'intro.hidden';

  /// The tour plays after you sign up, and after later log ins until you
  /// tick "Don't show this again".
  static Future<bool> shouldShow({required bool afterSignUp}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_hiddenKey) ?? false) return false;
      return afterSignUp || (prefs.getBool(_seenKey) ?? false);
    } on Exception catch (e) {
      debugPrint('Intro preferences unavailable: $e');
      return afterSignUp;
    }
  }

  static Future<void> markSeen() => _set(_seenKey);

  static Future<void> hideForGood() => _set(_hiddenKey);

  static Future<void> _set(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, true);
    } on Exception catch (e) {
      debugPrint('Could not save intro preference: $e');
    }
  }
}
