import 'dart:async';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../theme/odyssey_theme.dart';
import '../widgets/photo.dart';
import 'models.dart';
import 'sample.dart';

enum FriendStatus { none, requested, friends }

/// Everything you do in the app: likes, saves, joined events, friends, your
/// journal, and the posts, plans and map pins you add. Lives for the session
/// only.
class AppStore extends ChangeNotifier {
  AppStore._();

  static final instance = AppStore._();

  /// The selected bottom-bar tab: Home, Schedule, Map, Journal, Events.
  final tab = ValueNotifier<int>(0);

  /// Set to ask the map to enter pin-dropping mode.
  final pinRequest = ValueNotifier<int>(0);

  /// Set to a pin's id to ask the map to show it.
  final focusPin = ValueNotifier<String?>(null);

  /// The Events tab's filter: All, Gatherings, Expeditions, Joined.
  final eventsFilter = ValueNotifier<int>(0);

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
    stories: _journal.where((e) => e.kind == EntryKind.story).length,
    trips: attendedEvents.length,
    friends: friendCount,
    cover: Photos.lanHa,
  );

  Person person(String id) =>
      id == 'me' ? me : Sample.people.firstWhere((p) => p.id == id);

  TripEvent event(String id) => Sample.events.firstWhere((e) => e.id == id);

  // Feed ─────────────────────────────────────────────────────────────────

  final List<Post> _posts = [...Sample.posts];
  final Set<String> _liked = {};
  final Set<String> _saved = {};

  List<Post> get posts => List.unmodifiable(_posts);

  Post? post(String id) => _posts.where((p) => p.id == id).firstOrNull;

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

  /// Past events you took off your calendar. You still attended them.
  final Set<String> _offCalendar = {};

  bool isJoined(String eventId) => _joined.contains(eventId);

  bool hasEnded(TripEvent e) => e.end.isBefore(DateTime.now());

  /// Over, and you were there: the host marks everyone who joined.
  bool attended(TripEvent e) => hasEnded(e) && isJoined(e.id);

  /// Join or leave. An event that's over can't be joined or left.
  void toggleJoin(String eventId) {
    if (hasEnded(event(eventId))) return;
    _joined.contains(eventId) ? _joined.remove(eventId) : _joined.add(eventId);
    _offCalendar.remove(eventId);
    notifyListeners();
  }

  /// Takes a joined event off your schedule. For one still to come, that
  /// means leaving it; one that's over just leaves the calendar and stays
  /// in your joined events. Returns true if you left.
  bool removeEventFromSchedule(String eventId) {
    final e = event(eventId);
    if (hasEnded(e)) {
      _offCalendar.add(eventId);
      notifyListeners();
      return false;
    }
    _joined.remove(eventId);
    notifyListeners();
    return true;
  }

  /// Joined events still to come, soonest first.
  List<TripEvent> get upcomingJoined =>
      Sample.events.where((e) => isJoined(e.id) && !hasEnded(e)).toList()
        ..sort((a, b) => a.start.compareTo(b.start));

  /// Events you went to, most recent first, whether or not they are still
  /// on your calendar.
  List<TripEvent> get attendedEvents =>
      Sample.events.where(attended).toList()
        ..sort((a, b) => b.start.compareTo(a.start));

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

  PlanItem? plan(String id) => _plans.where((p) => p.id == id).firstOrNull;

  void addPlan(PlanItem plan) {
    _plans.add(plan);
    notifyListeners();
  }

  /// Takes a plan off your schedule. A journal entry written from it stays.
  void removePlan(String id) {
    _plans.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// You've been: you can write about a trip once its time has come. To-dos
  /// like packing are just reminders.
  bool canWriteUp(PlanItem plan) =>
      plan.eventId == null &&
      plan.kind != PlanKind.task &&
      plan.start.isBefore(DateTime.now());

  /// Your plans and joined events on [day], earliest first. A multi-day
  /// expedition appears on each of its days.
  List<PlanItem> itemsOn(DateTime day) {
    final date = DateUtils.dateOnly(day);
    final items = [
      for (final p in _plans)
        if (DateUtils.isSameDay(p.start, date)) p,
    ];
    for (final e in Sample.events.where(
      (e) => isJoined(e.id) && !_offCalendar.contains(e.id),
    )) {
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

  /// Puts your story on the map, and in your journal.
  void pinStory(MapStory story) {
    _mapStories.add(story);
    _journal.add(
      JournalEntry(
        id: newId('j'),
        kind: EntryKind.pin,
        title: story.title,
        paragraphs: [story.note],
        place: story.place,
        date: DateTime.now(),
        photos: [story.photo],
        shared: true,
        pinId: story.id,
      ),
    );
    notifyListeners();
  }

  /// Opens the map tab ready to drop a pin.
  void startPinning() {
    tab.value = 2;
    pinRequest.value++;
  }

  /// Opens the map tab on one of the pins.
  void showOnMap(String pinId) {
    tab.value = 2;
    focusPin.value = pinId;
  }

  // Journal ──────────────────────────────────────────────────────────────

  final List<JournalEntry> _journal = [...Sample.journal];

  /// Everything you have written, newest first.
  List<JournalEntry> get journal =>
      [..._journal]..sort((a, b) => b.date.compareTo(a.date));

  JournalEntry? entry(String id) =>
      _journal.where((e) => e.id == id).firstOrNull;

  /// Keeps what you wrote in your journal and, if [share], posts it to
  /// Moments as well. Written [from] a plan, it is dated to the plan and
  /// linked to it.
  JournalEntry write({
    required EntryKind kind,
    required List<String> paragraphs,
    required String place,
    String? title,
    List<Photo> photos = const [],
    bool share = true,
    PlanItem? from,
  }) {
    assert(
      kind != EntryKind.story || photos.isNotEmpty,
      'A story needs at least one photo.',
    );
    assert(kind != EntryKind.note || photos.length <= 1, 'One photo a note.');
    final entry = JournalEntry(
      id: newId('j'),
      kind: kind,
      title: title,
      paragraphs: paragraphs,
      place: place,
      date: from?.start ?? DateTime.now(),
      photos: photos,
    );
    _journal.add(entry);
    if (from != null) {
      final i = _plans.indexWhere((p) => p.id == from.id);
      if (i >= 0) _plans[i] = _plans[i].withJournal(entry.id);
    }
    if (share) return _share(entry);
    notifyListeners();
    return entry;
  }

  /// Deletes an entry for good: its post leaves Moments, its pin leaves the
  /// map, and a plan it was written from can be written up again.
  void deleteEntry(String id) {
    final e = entry(id);
    if (e == null) return;
    _journal.removeWhere((x) => x.id == id);
    if (e.postId != null) _posts.removeWhere((p) => p.id == e.postId);
    if (e.pinId != null) _mapStories.removeWhere((s) => s.id == e.pinId);
    for (var i = 0; i < _plans.length; i++) {
      if (_plans[i].journalId == id) _plans[i] = _plans[i].withJournal(null);
    }
    notifyListeners();
  }

  /// Posts a private entry to Moments.
  void shareEntry(String id) {
    final e = entry(id);
    if (e != null && !e.shared) _share(e);
  }

  JournalEntry _share(JournalEntry e) {
    final post = e.toPost(id: newId('post'), ago: 'Just now');
    _posts.insert(0, post);
    final shared = e.shareAs(post.id);
    _journal[_journal.indexWhere((x) => x.id == e.id)] = shared;
    notifyListeners();
    return shared;
  }

  LatLng get home => const LatLng(21.0285, 105.8542);
}
