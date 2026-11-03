import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../theme/odyssey_theme.dart';
import '../widgets/scene.dart';
import 'models.dart';
import 'sample.dart';

enum FriendStatus { none, requested, friends }

/// Everything you do in the app: likes, saves, joined events, friends, and
/// the posts, plans and map pins you add. Lives for the session only.
class AppStore extends ChangeNotifier {
  AppStore._();

  static final instance = AppStore._();

  /// The selected bottom-bar tab: Home, Schedule, Map, Community, Events.
  final tab = ValueNotifier<int>(0);

  /// Set to ask the map to enter pin-dropping mode.
  final pinRequest = ValueNotifier<int>(0);

  String _userName = 'Wayfarer';

  String get userName => _userName;

  void signIn(String name) {
    _userName = name;
    tab.value = 0;
    notifyListeners();
  }

  Person get me => Person(
    id: 'me',
    name: _userName,
    handle: '@${_userName.toLowerCase().replaceAll(' ', '')}',
    base: 'Hà Nội, Vietnam',
    bio: 'Tracing Southeast Asia one journey at a time.',
    tint: AppColors.ink,
    style: 'Wayfarer',
    stories: _myMapStories,
    trips: 3,
    friends: friendCount,
    cover: SceneMotif.river,
  );

  Person person(String id) =>
      id == 'me' ? me : Sample.people.firstWhere((p) => p.id == id);

  TripEvent event(String id) => Sample.events.firstWhere((e) => e.id == id);

  // Feed ─────────────────────────────────────────────────────────────────

  final List<Post> _posts = [...Sample.posts];
  final Set<String> _liked = {};
  final Set<String> _saved = {};

  List<Post> get posts => List.unmodifiable(_posts);

  bool isLiked(String postId) => _liked.contains(postId);
  bool isSaved(String postId) => _saved.contains(postId);

  int likesOf(Post post) => post.likes + (isLiked(post.id) ? 1 : 0);

  void toggleLike(String postId) {
    _liked.contains(postId) ? _liked.remove(postId) : _liked.add(postId);
    notifyListeners();
  }

  void toggleSave(String postId) {
    _saved.contains(postId) ? _saved.remove(postId) : _saved.add(postId);
    notifyListeners();
  }

  void addPost(Post post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  String newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  // Events ───────────────────────────────────────────────────────────────

  final Set<String> _joined = {...Sample.joinedEventIds};

  bool isJoined(String eventId) => _joined.contains(eventId);

  void toggleJoin(String eventId) {
    _joined.contains(eventId) ? _joined.remove(eventId) : _joined.add(eventId);
    notifyListeners();
  }

  /// Everyone going, counting you once you join.
  int goingCount(TripEvent e) =>
      1 + e.attendeeIds.length + (isJoined(e.id) ? 1 : 0);

  // Friends ──────────────────────────────────────────────────────────────

  final Map<String, FriendStatus> _friends = {
    for (final id in Sample.friendIds) id: FriendStatus.friends,
  };

  FriendStatus statusOf(String personId) =>
      _friends[personId] ?? FriendStatus.none;

  int get friendCount =>
      _friends.values.where((s) => s == FriendStatus.friends).length;

  /// Sends a request; the other wayfarer accepts a moment later.
  void addFriend(String personId) {
    _friends[personId] = FriendStatus.requested;
    notifyListeners();
    Timer(const Duration(milliseconds: 1500), () {
      if (_friends[personId] == FriendStatus.requested) {
        _friends[personId] = FriendStatus.friends;
        notifyListeners();
      }
    });
  }

  void removeFriend(String personId) {
    _friends.remove(personId);
    notifyListeners();
  }

  // Schedule ─────────────────────────────────────────────────────────────

  final List<PlanItem> _plans = [...Sample.plans];

  void addPlan(PlanItem plan) {
    _plans.add(plan);
    notifyListeners();
  }

  /// Your plans and joined events on [day], earliest first. A multi-day
  /// expedition appears on each of its days.
  List<PlanItem> itemsOn(DateTime day) {
    final date = DateUtils.dateOnly(day);
    final items = [
      for (final p in _plans)
        if (DateUtils.isSameDay(p.start, date)) p,
    ];
    for (final e in Sample.events.where((e) => isJoined(e.id))) {
      final first = DateUtils.dateOnly(e.start);
      final dayIndex = date.difference(first).inDays;
      if (dayIndex < 0 || dayIndex >= e.dayCount) continue;
      items.add(
        PlanItem(
          id: '${e.id}-$dayIndex',
          title: e.dayCount > 1 ? '${e.title} · Day ${dayIndex + 1}' : e.title,
          kind: PlanKind.event,
          start: dayIndex == 0
              ? e.start
              : date.add(Duration(hours: e.start.hour)),
          length: e.dayCount > 1 ? const Duration(hours: 8) : e.length,
          place: e.place,
          peopleIds: [e.hostId, ...e.attendeeIds],
          eventId: e.id,
        ),
      );
    }
    items.sort((a, b) => a.start.compareTo(b.start));
    return items;
  }

  bool hasItemsOn(DateTime day) => itemsOn(day).isNotEmpty;

  // Map ──────────────────────────────────────────────────────────────────

  final List<MapStory> _mapStories = [...Sample.mapStories];

  List<MapStory> get mapStories => List.unmodifiable(_mapStories);

  int get _myMapStories => _mapStories.where((s) => s.authorId == 'me').length;

  void pinStory(MapStory story) {
    _mapStories.add(story);
    notifyListeners();
  }

  /// Opens the map tab ready to drop a pin.
  void startPinning() {
    tab.value = 2;
    pinRequest.value++;
  }

  /// A fresh scene for something you post.
  (SceneMotif, int) sceneFor(String text) {
    final hash = text.hashCode.abs();
    return (SceneMotif.values[hash % SceneMotif.values.length], hash % 97);
  }

  LatLng get home => const LatLng(21.0285, 105.8542);
}
