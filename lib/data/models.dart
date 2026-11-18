import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/photo.dart';

/// A wayfarer: a friend, a host, or you.
class Person {
  const Person({
    required this.id,
    required this.name,
    required this.handle,
    required this.base,
    required this.bio,
    required this.tint,
    required this.style,
    this.stories = 0,
    this.trips = 0,
    this.friends = 0,
    this.mutuals = 0,
    this.cover = Photos.haGiangPeak,
  });

  final String id;
  final String name;
  final String handle;
  final String base;
  final String bio;

  /// Background colour of their initials avatar.
  final Color tint;

  /// How they travel, e.g. "Highland rider".
  final String style;
  final int stories;
  final int trips;
  final int friends;
  final int mutuals;

  /// The photo across the top of their profile.
  final Photo cover;

  String get firstName => name.split(' ').first;

  String get initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

/// Anything in the home feed.
sealed class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.ago,
    this.likes = 0,
    this.comments = 0,
  });

  final String id;
  final String authorId;

  /// "2h", "Yesterday" …
  final String ago;
  final int likes;
  final int comments;
}

/// A long-form travel story, read like a newsletter post.
class StoryPost extends Post {
  const StoryPost({
    required super.id,
    required super.authorId,
    required super.ago,
    super.likes,
    super.comments,
    required this.title,
    required this.excerpt,
    required this.paragraphs,
    required this.place,
    required this.photos,
    required this.readMinutes,
  });

  final String title;
  final String excerpt;
  final List<String> paragraphs;
  final String place;

  /// One or more; the first is the cover.
  final List<Photo> photos;
  final int readMinutes;

  Photo get photo => photos.first;
}

/// A short status update.
class TextPost extends Post {
  const TextPost({
    required super.id,
    required super.authorId,
    required super.ago,
    super.likes,
    super.comments,
    required this.text,
    this.place,
    this.photo,
  });

  final String text;
  final String? place;

  /// A note can carry one photo.
  final Photo? photo;
}

/// An invitation to join an event.
class InvitePost extends Post {
  const InvitePost({
    required super.id,
    required super.authorId,
    required super.ago,
    super.likes,
    super.comments,
    required this.eventId,
    required this.note,
  });

  final String eventId;
  final String note;
}

enum EventKind {
  gathering('Gathering', Icons.local_cafe_outlined),
  expedition('Expedition', Icons.hiking);

  const EventKind(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// A gathering (an evening, a morning) or an expedition (several days).
class TripEvent {
  const TripEvent({
    required this.id,
    required this.title,
    required this.kind,
    required this.place,
    required this.start,
    required this.length,
    required this.hostId,
    required this.attendeeIds,
    required this.capacity,
    required this.photo,
    required this.summary,
    required this.highlights,
  });

  final String id;
  final String title;
  final EventKind kind;
  final String place;
  final DateTime start;
  final Duration length;
  final String hostId;
  final List<String> attendeeIds;
  final int capacity;
  final Photo photo;
  final String summary;
  final List<String> highlights;

  DateTime get end => start.add(length);

  /// Whole days an expedition spans; 1 for a gathering.
  int get dayCount => kind == EventKind.expedition ? length.inDays : 1;
}

enum PlanKind {
  travel('Travel', Icons.route_outlined),
  ride('Ride', Icons.two_wheeler),
  stay('Stay', Icons.bed_outlined),
  task('To do', Icons.checklist_rounded),
  food('Food', Icons.ramen_dining_outlined),
  event('Event', Icons.event_outlined);

  const PlanKind(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// One entry in your schedule — your own plan, or a day of a joined event.
class PlanItem {
  const PlanItem({
    required this.id,
    required this.title,
    required this.kind,
    required this.start,
    required this.length,
    required this.place,
    this.note,
    this.peopleIds = const [],
    this.eventId,
    this.photo,
    this.journalId,
  });

  final String id;
  final String title;
  final PlanKind kind;
  final DateTime start;
  final Duration length;
  final String place;
  final String? note;
  final List<String> peopleIds;

  /// Set when the entry comes from a joined event.
  final String? eventId;

  /// A picture of where you're going, if there is one.
  final Photo? photo;

  /// The journal entry you wrote about it, once you'd been.
  final String? journalId;

  DateTime get end => start.add(length);

  PlanItem withJournal(String? entryId) => PlanItem(
    id: id,
    title: title,
    kind: kind,
    start: start,
    length: length,
    place: place,
    note: note,
    peopleIds: peopleIds,
    eventId: eventId,
    photo: photo,
    journalId: entryId,
  );
}

/// A travel story pinned to the map.
class MapStory {
  const MapStory({
    required this.id,
    required this.authorId,
    required this.title,
    required this.note,
    required this.place,
    required this.point,
    required this.photo,
    required this.likes,
    required this.ago,
  });

  final String id;
  final String authorId;
  final String title;
  final String note;
  final String place;
  final LatLng point;
  final Photo photo;
  final int likes;
  final String ago;
}

enum EntryKind {
  story('Story', Icons.auto_stories_outlined),
  note('Note', Icons.notes_rounded),
  pin('Map pin', Icons.place_outlined);

  const EntryKind(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Something you wrote: a story, a short note or a pin on the map. Kept in
/// your journal whether or not you share it.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.kind,
    required this.paragraphs,
    required this.place,
    required this.date,
    this.title,
    this.photos = const [],
    this.shared = false,
    this.postId,
    this.pinId,
  });

  final String id;
  final EntryKind kind;

  /// Notes often have none.
  final String? title;
  final List<String> paragraphs;
  final String place;
  final DateTime date;

  /// A story has one or more; a note has none or one; a pin has one.
  final List<Photo> photos;

  /// The cover: the first photo, if there is one.
  Photo? get photo => photos.isEmpty ? null : photos.first;

  /// Shared to Moments (or, for a pin, on the map for everyone).
  final bool shared;

  /// The feed post made when it was shared.
  final String? postId;

  /// The map pin, for a [EntryKind.pin].
  final String? pinId;

  String get text => paragraphs.join('\n\n');

  /// The title, or the opening words of a note.
  String get heading {
    if (title != null && title!.isNotEmpty) return title!;
    final first = paragraphs.isEmpty ? '' : paragraphs.first;
    return first.length > 60 ? '${first.substring(0, 60).trimRight()}…' : first;
  }

  int get readMinutes {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    return (words / 200).ceil().clamp(1, 60);
  }

  /// The feed post for this entry: a story with its photos, or a text post
  /// with its one photo, if any.
  Post toPost({
    required String id,
    required String ago,
    int likes = 0,
    int comments = 0,
  }) {
    if (kind == EntryKind.story && photos.isNotEmpty) {
      final excerpt = paragraphs.isEmpty ? '' : paragraphs.first;
      return StoryPost(
        id: id,
        authorId: 'me',
        ago: ago,
        likes: likes,
        comments: comments,
        title: heading,
        excerpt: excerpt.length > 140
            ? '${excerpt.substring(0, 140).trimRight()}…'
            : excerpt,
        paragraphs: paragraphs,
        place: place,
        photos: photos,
        readMinutes: readMinutes,
      );
    }
    return TextPost(
      id: id,
      authorId: 'me',
      ago: ago,
      likes: likes,
      comments: comments,
      text: text,
      place: place,
      photo: photo,
    );
  }

  JournalEntry shareAs(String postId) => JournalEntry(
    id: id,
    kind: kind,
    paragraphs: paragraphs,
    place: place,
    date: date,
    title: title,
    photos: photos,
    shared: true,
    postId: postId,
    pinId: pinId,
  );
}
