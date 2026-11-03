import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays the opening score.
///
/// It deliberately outlives the splash screen: the bowl's tail and the
/// page-turn keep ringing under the journal, and the player disposes itself
/// once the sound ends.
class SplashSound {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _completion;
  bool _ready = false;
  bool _done = false;

  /// Loads the asset so playback can start in sync with the first frame.
  Future<void> prepare() async {
    try {
      // Mix with whatever the traveller is already listening to.
      await _player.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers)
            .build(),
      );
      await _player.setReleaseMode(ReleaseMode.release);
      await _player.setSource(AssetSource('sounds/odyssey_intro.wav'));
      _ready = true;
    } catch (error) {
      debugPrint('Odyssey intro sound unavailable: $error');
    }
  }

  void play() {
    if (!_ready || _done) {
      _release();
      return;
    }
    _completion = _player.onPlayerComplete.listen((_) => _release());
    _player.resume().catchError((Object error) {
      debugPrint('Odyssey intro sound failed: $error');
      _release();
    });
  }

  /// A quick fade, for when the splash is skipped.
  Future<void> fadeOut() async {
    if (_done) return;
    try {
      for (var volume = 0.75; volume > 0; volume -= 0.25) {
        await _player.setVolume(volume);
        await Future<void>.delayed(const Duration(milliseconds: 45));
      }
    } catch (_) {
      // Fading is best-effort; release regardless.
    }
    _release();
  }

  void _release() {
    if (_done) return;
    _done = true;
    _completion?.cancel();
    _player.dispose().catchError((Object _) {});
  }
}
