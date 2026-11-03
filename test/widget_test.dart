import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:odyssey/data/atlas.dart';
import 'package:odyssey/data/geo.dart';
import 'package:odyssey/data/odyssey_store.dart';
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
        for (var t = SplashTimeline.needleStart;
            t < SplashTimeline.lock;
            t += 0.01)
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

  group('Atlas', () {
    test('every reference resolves', () {
      for (final r in Atlas.routes) {
        expect(Atlas.waypointsOf(r), isNotEmpty);
        Atlas.companion(r.keeperId);
      }
      for (final s in Atlas.stories) {
        Atlas.companion(s.authorId);
        expect(s.paragraphs.length, greaterThanOrEqualTo(3));
      }
      for (final e in Atlas.expeditions) {
        Atlas.companion(e.hostId);
        e.rosterIds.forEach(Atlas.companion);
        if (e.routeId != null) Atlas.route(e.routeId!);
        expect(e.rosterIds.length + 1, lessThan(e.capacity));
      }
    });

    test('ids are unique', () {
      Set<String> ids(Iterable<String> xs) => xs.toSet();
      expect(ids(Atlas.waypoints.map((w) => w.id)).length,
          Atlas.waypoints.length);
      expect(ids(Atlas.routes.map((r) => r.id)).length, Atlas.routes.length);
      expect(ids(Atlas.stories.map((s) => s.id)).length, Atlas.stories.length);
    });

    test('waypoints sit within Southeast Asia', () {
      for (final w in Atlas.waypoints) {
        expect(w.point.latitude, inInclusiveRange(-11, 29), reason: w.name);
        expect(w.point.longitude, inInclusiveRange(92, 141), reason: w.name);
      }
    });
  });

  group('Geo', () {
    test('formats coordinates by hemisphere', () {
      expect(formatLat(23.2315), 'N 23.2315°');
      expect(formatLat(-8.4115), 'S 8.4115°');
      expect(formatLng(105.4078), 'E 105.4078°');
      expect(formatElevation(3726), '3,726 m');
      expect(formatElevation(0), 'Sea level');
    });

    test('elevation profile passes through every waypoint', () {
      final route = Atlas.route('r-rinjani');
      final stops = Atlas.waypointsOf(route);
      final profile = elevationProfile(stops);
      final marked = profile.where((p) => p.waypoint != null).toList();
      expect(marked.length, stops.length);
      expect(marked.map((p) => p.elevationM),
          stops.map((w) => w.elevationM.toDouble()));
      for (var i = 1; i < profile.length; i++) {
        expect(profile[i].km, greaterThanOrEqualTo(profile[i - 1].km));
      }
    });

    test('GPX lists each waypoint once and the full route in order', () {
      final route = Atlas.route('r-hagiang');
      final stops = Atlas.waypointsOf(route);
      final gpx = buildGpx(route, stops);
      expect(gpx, startsWith('<?xml'));
      expect('<wpt '.allMatches(gpx).length, stops.toSet().length);
      expect('<rtept '.allMatches(gpx).length, stops.length);
      expect(gpx, contains("Quản Bạ Heaven's Gate"));
      expect(gpx.trim(), endsWith('</gpx>'));
    });
  });

  group('Store', () {
    test('RSVP, checklist and pledge toggle', () {
      final store = OdysseyStore.instance;
      expect(store.isGoing('x-mekong'), isFalse);
      store.toggleRsvp('x-mekong');
      expect(store.isGoing('x-mekong'), isTrue);
      store.togglePacked('x-mekong', 2);
      expect(store.isPacked('x-mekong', 2), isTrue);
      expect(store.packedCount('x-mekong'), 1);
      store.togglePledge();
      expect(store.pledgedOn, isNotNull);
    });

    test('showOnMap switches to the map tab', () {
      final store = OdysseyStore.instance;
      store.showOnMap(const MapFocus.route('r-mekong'));
      expect(store.tab.value, 2);
      expect(store.mapFocus.value?.routeId, 'r-mekong');
    });
  });
}
