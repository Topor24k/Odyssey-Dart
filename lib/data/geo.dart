import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import 'models.dart';

String formatLat(double lat, {int digits = 4}) =>
    '${lat >= 0 ? 'N' : 'S'} ${lat.abs().toStringAsFixed(digits)}°';

String formatLng(double lng, {int digits = 4}) =>
    '${lng >= 0 ? 'E' : 'W'} ${lng.abs().toStringAsFixed(digits)}°';

String formatLatLng(LatLng p, {int digits = 4}) =>
    '${formatLat(p.latitude, digits: digits)} · '
    '${formatLng(p.longitude, digits: digits)}';

/// 1200 → "1,200".
String groupThousands(int n) {
  final s = n.abs().toString();
  final out = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
    out.write(s[i]);
  }
  return out.toString();
}

String formatElevation(int metres) =>
    metres <= 0 ? 'Sea level' : '${groupThousands(metres)} m';

/// One sample of a route's elevation profile.
class ProfilePoint {
  const ProfilePoint(this.km, this.elevationM, [this.waypoint]);

  final double km;
  final double elevationM;

  /// Set when the sample sits exactly on a waypoint.
  final Waypoint? waypoint;
}

/// Interpolates an elevation profile through [stops], with a little
/// deterministic relief between them so it reads like real terrain.
List<ProfilePoint> elevationProfile(List<Waypoint> stops, {int seed = 7}) {
  const distance = Distance();
  final rng = math.Random(seed);
  final points = <ProfilePoint>[];
  var km = 0.0;
  for (var i = 0; i < stops.length; i++) {
    final w = stops[i];
    if (i > 0) {
      final prev = stops[i - 1];
      final legKm = distance.as(LengthUnit.Kilometer, prev.point, w.point);
      final phase = rng.nextDouble() * math.pi * 2;
      final relief = (prev.elevationM + w.elevationM) * 0.08;
      const steps = 14;
      for (var s = 1; s < steps; s++) {
        final f = s / steps;
        final eased = f * f * (3 - 2 * f);
        final base = prev.elevationM + (w.elevationM - prev.elevationM) * eased;
        final bump = math.sin(f * math.pi) *
            (math.sin(f * math.pi * 3 + phase) * relief);
        points.add(ProfilePoint(km + legKm * f, math.max(0, base + bump)));
      }
      km += legKm;
    }
    points.add(ProfilePoint(km, w.elevationM.toDouble(), w));
  }
  return points;
}

String _xml(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

/// A GPX 1.1 document with the route's waypoints and the route itself.
String buildGpx(RoutePlan route, List<Waypoint> stops) {
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<gpx version="1.1" creator="Odyssey Field Journal" '
        'xmlns="http://www.topografix.com/GPX/1/1">')
    ..writeln('  <metadata><name>${_xml(route.name)}</name></metadata>');
  final seen = <String>{};
  for (final w in stops) {
    if (!seen.add(w.id)) continue;
    b
      ..writeln('  <wpt lat="${w.point.latitude}" lon="${w.point.longitude}">')
      ..writeln('    <ele>${w.elevationM}</ele>')
      ..writeln('    <name>${_xml(w.name)}</name>')
      ..writeln('    <desc>${_xml(w.note)}</desc>')
      ..writeln('    <type>${_xml(w.kind.label)}</type>')
      ..writeln('  </wpt>');
  }
  b
    ..writeln('  <rte>')
    ..writeln('    <name>${_xml(route.name)}</name>');
  for (final w in stops) {
    b.writeln('    <rtept lat="${w.point.latitude}" '
        'lon="${w.point.longitude}"><name>${_xml(w.name)}</name></rtept>');
  }
  b
    ..writeln('  </rte>')
    ..write('</gpx>');
  return b.toString();
}
