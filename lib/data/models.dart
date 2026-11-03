import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/scene.dart';

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
    this.cover = SceneMotif.karst,
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
  final SceneMotif cover;

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
    required this.motif,
    required this.seed,
    required this.readMinutes,
  });

  final String title;
  final String excerpt;
  final List<String> paragraphs;
  final String place;
  final SceneMotif motif;
  final int seed;
  final int readMinutes;
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
  });

  final String text;
  final String? place;
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
    required this.motif,
    required this.seed,
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
  final SceneMotif motif;
  final int seed;
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
    required this.motif,
    required this.seed,
    required this.likes,
    required this.ago,
  });

  final String id;
  final String authorId;
  final String title;
  final String note;
  final String place;
  final LatLng point;
  final SceneMotif motif;
  final int seed;
  final int likes;
  final String ago;
}
