// Synthesises the Odyssey splash sound into assets/sounds/odyssey_intro.wav.
//
//   dart run tool/generate_intro_sound.dart
//
// Every cue below is timed to SplashTimeline in
// lib/splash/splash_timeline.dart — change both together.
//
// The score, in order:
//   1. an airy whoosh while the compass bezel draws itself,
//   2. three brass ticks as the needle swings past north and reverses,
//   3. a struck singing-bowl tone (with a soft thump) when the needle locks,
//   4. a quieter fifth above as the ODYSSEY wordmark settles,
//   5. a faint click as the coordinates lock,
//   6. a paper page-turn as the journal opens.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int sampleRate = 44100;
const double lengthSeconds = 5.6;

// Mirrors SplashTimeline.
const double bezelStart = 0.10;
const double needleStart = 0.65;
const double needleDamping = 6.0;
const double needleOmega = 13.1;
const double lockAt = 1.55;
const double wordmarkChimeAt = 2.45;
const double coordinatesLockAt = 3.10;
const double exitAt = 3.45;

void main() {
  final n = (sampleRate * lengthSeconds).round();
  final dry = Float64List(n);
  final rng = math.Random(1937);

  _whoosh(dry, rng,
      start: bezelStart, length: 0.95, fromHz: 320, toHz: 1500, gain: 0.11);

  final tickGains = [0.22, 0.15, 0.09];
  final ticks = _needleReversals(3);
  for (var i = 0; i < ticks.length; i++) {
    _tick(dry, rng, at: needleStart + ticks[i], gain: tickGains[i]);
  }

  _thump(dry, at: lockAt, gain: 0.32);
  _bowl(dry, rng, at: lockAt, fundamental: 392.0, gain: 0.55, decay: 2.6);
  _bowl(dry, rng,
      at: wordmarkChimeAt, fundamental: 587.33, gain: 0.20, decay: 1.7);
  _tick(dry, rng, at: coordinatesLockAt, gain: 0.07, freq: 3900);
  _whoosh(dry, rng,
      start: exitAt, length: 0.75, fromHz: 2600, toHz: 480, gain: 0.13);

  final wetL = _reverb(dry, spread: 0);
  final wetR = _reverb(dry, spread: 23);
  final dryPeak = _peak(dry);
  final wetScale = 0.42 * dryPeak / math.max(_peak(wetL), _peak(wetR));

  final left = Float64List(n);
  final right = Float64List(n);
  for (var i = 0; i < n; i++) {
    left[i] = dry[i] + wetL[i] * wetScale;
    right[i] = dry[i] + wetR[i] * wetScale;
  }

  final norm = 0.89 / math.max(_peak(left), _peak(right));
  final fadeIn = (0.005 * sampleRate).round();
  final fadeOut = (0.45 * sampleRate).round();
  for (var i = 0; i < n; i++) {
    var g = norm;
    if (i < fadeIn) g *= i / fadeIn;
    if (i > n - fadeOut) {
      g *= 0.5 + 0.5 * math.cos(math.pi * (i - (n - fadeOut)) / fadeOut);
    }
    left[i] *= g;
    right[i] *= g;
  }

  final out = File('assets/sounds/odyssey_intro.wav');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(_wav(left, right));
  stdout.writeln('Wrote ${out.path} (${out.lengthSync()} bytes)');
}

/// Times (seconds after the swing starts) at which the damped needle
/// reverses — the extremes of e^(-ζt)·cos(ωt).
List<double> _needleReversals(int count) {
  final shift = math.atan(needleDamping / needleOmega);
  return [
    for (var k = 1; k <= count; k++) (k * math.pi - shift) / needleOmega,
  ];
}

void _whoosh(
  Float64List out,
  math.Random rng, {
  required double start,
  required double length,
  required double fromHz,
  required double toHz,
  required double gain,
}) {
  final s0 = (start * sampleRate).round();
  final len = (length * sampleRate).round();
  final bp = _Biquad();
  for (var i = 0; i < len && s0 + i < out.length; i++) {
    final x = i / len;
    if (i % 16 == 0) {
      bp.bandpass(fromHz * math.pow(toHz / fromHz, x), 0.7);
    }
    // Rises over the first 60%, falls away over the last 40%.
    final env = x < 0.6
        ? math.pow(math.sin(math.pi * x / 1.2), 2)
        : math.pow(math.cos(math.pi * (x - 0.6) / 0.8), 2);
    out[s0 + i] += bp.process(rng.nextDouble() * 2 - 1) * 3.0 * env * gain;
  }
}

void _tick(
  Float64List out,
  math.Random rng, {
  required double at,
  required double gain,
  double freq = 2600,
}) {
  final s0 = (at * sampleRate).round();
  final len = (0.07 * sampleRate).round();
  final hp = _Biquad()..highpass(1800, 0.8);
  for (var i = 0; i < len && s0 + i < out.length; i++) {
    final t = i / sampleRate;
    final ring = math.sin(2 * math.pi * freq * t) * math.exp(-t / 0.011);
    final body =
        math.sin(2 * math.pi * freq * 0.46 * t) * math.exp(-t / 0.02) * 0.35;
    final click =
        hp.process(rng.nextDouble() * 2 - 1) * math.exp(-t / 0.0018) * 0.6;
    out[s0 + i] += (ring * 0.8 + body + click) * gain;
  }
}

void _thump(Float64List out, {required double at, required double gain}) {
  final s0 = (at * sampleRate).round();
  final len = (0.5 * sampleRate).round();
  var phase = 0.0;
  for (var i = 0; i < len && s0 + i < out.length; i++) {
    final t = i / sampleRate;
    final f = 55 + 34 * math.exp(-t / 0.03);
    phase += 2 * math.pi * f / sampleRate;
    final env = (1 - math.exp(-t / 0.002)) * math.exp(-t / 0.11);
    out[s0 + i] += math.sin(phase) * env * gain;
  }
}

/// A struck singing bowl: a sub hum, a slowly beating fundamental pair and
/// the bowl's inharmonic upper partials, each fading at its own rate.
void _bowl(
  Float64List out,
  math.Random rng, {
  required double at,
  required double fundamental,
  required double gain,
  required double decay,
}) {
  const partials = <(double ratio, double amp, double decayMul)>[
    (0.5, 0.16, 1.4),
    (1.0, 1.0, 1.0),
    (1.0042, 0.45, 1.05),
    (2.76, 0.28, 0.45),
    (2.765, 0.12, 0.45),
    (5.40, 0.10, 0.22),
    (8.93, 0.04, 0.12),
  ];
  final s0 = (at * sampleRate).round();
  final len = (decay * 1.4 * 6 * sampleRate).round();
  final strike = _Biquad()..bandpass(2200, 1.2);
  for (var i = 0; i < len && s0 + i < out.length; i++) {
    final t = i / sampleRate;
    final attack = math.min(1.0, t / 0.004);
    var v = 0.0;
    for (final (ratio, amp, decayMul) in partials) {
      v += math.sin(2 * math.pi * fundamental * ratio * t) *
          amp *
          math.exp(-t / (decay * decayMul));
    }
    v *= attack / 2.0;
    v += strike.process(rng.nextDouble() * 2 - 1) * math.exp(-t / 0.015) * 0.5;
    out[s0 + i] += v * gain;
  }
}

/// A small Freeverb-style room: eight damped combs into four allpasses.
Float64List _reverb(Float64List input, {required int spread}) {
  const combTunings = [1116, 1188, 1277, 1356, 1422, 1491, 1557, 1617];
  const allpassTunings = [556, 441, 341, 225];
  final combs = [for (final t in combTunings) _Comb(t + spread)];
  final allpasses = [for (final t in allpassTunings) _Allpass(t + spread)];
  final out = Float64List(input.length);
  for (var i = 0; i < input.length; i++) {
    final x = input[i] * 0.015;
    var y = 0.0;
    for (final c in combs) {
      y += c.process(x);
    }
    for (final a in allpasses) {
      y = a.process(y);
    }
    out[i] = y;
  }
  return out;
}

double _peak(Float64List xs) {
  var p = 1e-9;
  for (final x in xs) {
    p = math.max(p, x.abs());
  }
  return p;
}

Uint8List _wav(Float64List left, Float64List right) {
  const channels = 2;
  const bytesPerSample = 2;
  final dataBytes = left.length * channels * bytesPerSample;
  final b = ByteData(44 + dataBytes);
  void ascii(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      b.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  b.setUint32(4, 36 + dataBytes, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  b.setUint32(16, 16, Endian.little);
  b.setUint16(20, 1, Endian.little);
  b.setUint16(22, channels, Endian.little);
  b.setUint32(24, sampleRate, Endian.little);
  b.setUint32(28, sampleRate * channels * bytesPerSample, Endian.little);
  b.setUint16(32, channels * bytesPerSample, Endian.little);
  b.setUint16(34, bytesPerSample * 8, Endian.little);
  ascii(36, 'data');
  b.setUint32(40, dataBytes, Endian.little);
  var o = 44;
  for (var i = 0; i < left.length; i++) {
    b.setInt16(o, (left[i].clamp(-1.0, 1.0) * 32767).round(), Endian.little);
    b.setInt16(o + 2, (right[i].clamp(-1.0, 1.0) * 32767).round(),
        Endian.little);
    o += 4;
  }
  return b.buffer.asUint8List();
}

/// RBJ-cookbook biquad filter.
class _Biquad {
  double _b0 = 1, _b1 = 0, _b2 = 0, _a1 = 0, _a2 = 0;
  double _x1 = 0, _x2 = 0, _y1 = 0, _y2 = 0;

  void bandpass(double f, double q) {
    final w = 2 * math.pi * f / sampleRate;
    final alpha = math.sin(w) / (2 * q);
    _set(alpha, 0, -alpha, 1 + alpha, -2 * math.cos(w), 1 - alpha);
  }

  void highpass(double f, double q) {
    final w = 2 * math.pi * f / sampleRate;
    final alpha = math.sin(w) / (2 * q);
    final c = math.cos(w);
    _set((1 + c) / 2, -(1 + c), (1 + c) / 2, 1 + alpha, -2 * c, 1 - alpha);
  }

  void _set(double b0, double b1, double b2, double a0, double a1, double a2) {
    _b0 = b0 / a0;
    _b1 = b1 / a0;
    _b2 = b2 / a0;
    _a1 = a1 / a0;
    _a2 = a2 / a0;
  }

  double process(double x) {
    final y = _b0 * x + _b1 * _x1 + _b2 * _x2 - _a1 * _y1 - _a2 * _y2;
    _x2 = _x1;
    _x1 = x;
    _y2 = _y1;
    _y1 = y;
    return y;
  }
}

class _Comb {
  _Comb(int size) : _buffer = Float64List(size);

  static const _feedback = 0.82;
  static const _damp = 0.28;
  final Float64List _buffer;
  int _index = 0;
  double _store = 0;

  double process(double x) {
    final out = _buffer[_index];
    _store = out * (1 - _damp) + _store * _damp;
    _buffer[_index] = x + _store * _feedback;
    _index = (_index + 1) % _buffer.length;
    return out;
  }
}

class _Allpass {
  _Allpass(int size) : _buffer = Float64List(size);

  final Float64List _buffer;
  int _index = 0;

  double process(double x) {
    final buffered = _buffer[_index];
    _buffer[_index] = x + buffered * 0.5;
    _index = (_index + 1) % _buffer.length;
    return buffered - x;
  }
}
