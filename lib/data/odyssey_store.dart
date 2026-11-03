import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'models.dart';

enum CompanionLink { none, requested, connected }

/// Where the map tab should fly to next.
class MapFocus {
  const MapFocus.route(String this.routeId)
      : waypointId = null,
        point = null,
        label = null;

  const MapFocus.waypoint(String this.waypointId)
      : routeId = null,
        point = null,
        label = null;

  /// An arbitrary spot, such as where a story was written.
  const MapFocus.point(LatLng this.point, String this.label)
      : routeId = null,
        waypointId = null;

  final String? routeId;
  final String? waypointId;
  final LatLng? point;
  final String? label;
}

/// The traveller's own state: companions, RSVPs, checklists, saved stories
/// and the inquiries they have posted.
class OdysseyStore extends ChangeNotifier {
  OdysseyStore._();

  static final instance = OdysseyStore._();

  /// Selected tab in the home shell.
  final tab = ValueNotifier<int>(0);
  final mapFocus = ValueNotifier<MapFocus?>(null);

  void showOnMap(MapFocus focus) {
    mapFocus.value = focus;
    tab.value = 2;
  }

  final Map<String, CompanionLink> _links = {};

  CompanionLink linkWith(String companionId) =>
      _links[companionId] ?? CompanionLink.none;

  int get companionCount =>
      _links.values.where((l) => l == CompanionLink.connected).length;

  /// Sends a request; the companion "accepts" a moment later.
  void requestCompanion(String companionId) {
    _links[companionId] = CompanionLink.requested;
    notifyListeners();
    Timer(const Duration(milliseconds: 1600), () {
      if (_links[companionId] == CompanionLink.requested) {
        _links[companionId] = CompanionLink.connected;
        notifyListeners();
      }
    });
  }

  void releaseCompanion(String companionId) {
    _links.remove(companionId);
    notifyListeners();
  }

  final Set<String> _rsvps = {};

  bool isGoing(String expeditionId) => _rsvps.contains(expeditionId);

  void toggleRsvp(String expeditionId) {
    _rsvps.contains(expeditionId)
        ? _rsvps.remove(expeditionId)
        : _rsvps.add(expeditionId);
    notifyListeners();
  }

  final Map<String, Set<int>> _packed = {};

  bool isPacked(String expeditionId, int item) =>
      _packed[expeditionId]?.contains(item) ?? false;

  int packedCount(String expeditionId) => _packed[expeditionId]?.length ?? 0;

  void togglePacked(String expeditionId, int item) {
    final set = _packed.putIfAbsent(expeditionId, () => {});
    set.contains(item) ? set.remove(item) : set.add(item);
    notifyListeners();
  }

  final Set<String> _saved = {};

  bool isSaved(String storyId) => _saved.contains(storyId);

  void toggleSaved(String storyId) {
    _saved.contains(storyId) ? _saved.remove(storyId) : _saved.add(storyId);
    notifyListeners();
  }

  final Map<String, List<Inquiry>> _posted = {};

  List<Inquiry> inquiriesFor(Story story) =>
      [...story.inquiries, ...?_posted[story.id]];

  void postInquiry(String storyId, String message) {
    _posted.putIfAbsent(storyId, () => []).add(
          Inquiry(author: 'You', message: message, when: 'just now'),
        );
    notifyListeners();
  }

  DateTime? _pledgedOn;

  DateTime? get pledgedOn => _pledgedOn;

  void togglePledge() {
    _pledgedOn = _pledgedOn == null ? DateTime.now() : null;
    notifyListeners();
  }
}
