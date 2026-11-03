import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// The scene an illustrated archival plate depicts.
enum PlateMotif { karst, islands, volcano, river, terraces, lanterns, temple }

class Plate {
  const Plate(this.motif, this.seed, this.caption);

  final PlateMotif motif;
  final int seed;
  final String caption;
}

class Companion {
  const Companion({
    required this.id,
    required this.name,
    required this.role,
    required this.base,
    required this.bio,
    required this.specialties,
    required this.languages,
    required this.routesLogged,
    required this.storiesWritten,
    required this.yearsOnRoad,
    this.verified = true,
  });

  final String id;
  final String name;
  final String role;
  final String base;
  final String bio;
  final List<String> specialties;
  final List<String> languages;
  final int routesLogged;
  final int storiesWritten;
  final int yearsOnRoad;
  final bool verified;

  String get initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class Inquiry {
  const Inquiry({
    required this.author,
    required this.message,
    required this.when,
    this.fromAuthor = false,
  });

  final String author;
  final String message;
  final String when;

  /// A reply from the story's author rather than a reader.
  final bool fromAuthor;
}

class Story {
  const Story({
    required this.id,
    required this.title,
    required this.dek,
    required this.authorId,
    required this.region,
    required this.country,
    required this.published,
    required this.readMinutes,
    required this.location,
    required this.elevationM,
    required this.climate,
    required this.season,
    required this.cover,
    required this.plates,
    required this.paragraphs,
    required this.inquiries,
  });

  final String id;
  final String title;
  final String dek;
  final String authorId;
  final String region;
  final String country;
  final String published;
  final int readMinutes;
  final LatLng location;
  final int elevationM;
  final String climate;
  final String season;
  final Plate cover;
  final List<Plate> plates;
  final List<String> paragraphs;
  final List<Inquiry> inquiries;
}

enum TravelMode {
  motorbike('Motorbike', Icons.two_wheeler),
  banca('Outrigger banca', Icons.sailing),
  slowBoat('Slow boat', Icons.directions_boat_outlined),
  phinisi('Phinisi schooner', Icons.sailing_outlined),
  trek('On foot', Icons.hiking);

  const TravelMode(this.label, this.icon);
  final String label;
  final IconData icon;

  bool get onWater =>
      this == TravelMode.banca ||
      this == TravelMode.slowBoat ||
      this == TravelMode.phinisi;
}

enum Surface {
  switchbackAsphalt('Switchback asphalt', Icons.turn_sharp_right),
  gravel('Unpaved gravel', Icons.grain),
  forestDirt('Forest dirt', Icons.forest_outlined),
  scree('Volcanic scree', Icons.landslide_outlined),
  waterway('Waterway', Icons.waves);

  const Surface(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum WaypointKind {
  town('Town', Icons.location_city_outlined),
  pass('Mountain pass', Icons.terrain_outlined),
  summit('Summit', Icons.filter_hdr_outlined),
  viewpoint('Viewpoint', Icons.visibility_outlined),
  mooring('River mooring', Icons.anchor),
  campsite('Wild campsite', Icons.local_fire_department_outlined),
  homestay('Stilt homestay', Icons.cottage_outlined),
  temple('Sacred temple', Icons.temple_buddhist_outlined);

  const WaypointKind(this.label, this.icon);
  final String label;
  final IconData icon;
}

class Waypoint {
  const Waypoint({
    required this.id,
    required this.name,
    required this.kind,
    required this.point,
    required this.elevationM,
    required this.surface,
    required this.place,
    required this.note,
  });

  final String id;
  final String name;
  final WaypointKind kind;
  final LatLng point;
  final int elevationM;
  final Surface surface;

  /// Province or island and country, e.g. "Hà Giang, Vietnam".
  final String place;
  final String note;
}

class RouteDay {
  const RouteDay({
    required this.title,
    required this.from,
    required this.to,
    required this.distanceKm,
    required this.gainM,
    required this.surface,
    required this.fuel,
    required this.rest,
    required this.notes,
  });

  final String title;
  final String from;
  final String to;
  final int distanceKm;
  final int gainM;
  final Surface surface;

  /// Where to refuel (or resupply water on foot).
  final String fuel;

  /// Where to sleep — usually a family homestay.
  final String rest;
  final String notes;
}

class RoutePlan {
  const RoutePlan({
    required this.id,
    required this.name,
    required this.region,
    required this.country,
    required this.mode,
    required this.difficulty,
    required this.season,
    required this.vehicle,
    required this.cash,
    required this.connectivity,
    required this.summary,
    required this.plate,
    required this.keeperId,
    required this.days,
    required this.waypointIds,
  });

  final String id;
  final String name;
  final String region;
  final String country;
  final TravelMode mode;

  /// 1 (gentle) to 5 (expedition grade).
  final int difficulty;
  final String season;
  final String vehicle;
  final String cash;
  final String connectivity;
  final String summary;
  final Plate plate;
  final String keeperId;
  final List<RouteDay> days;

  /// Waypoints in travel order.
  final List<String> waypointIds;

  int get distanceKm => days.fold(0, (sum, d) => sum + d.distanceKm);

  String get difficultyLabel => const [
        'Gentle',
        'Steady',
        'Demanding',
        'Arduous',
        'Expedition',
      ][difficulty - 1];
}

class ChecklistItem {
  const ChecklistItem(this.category, this.label);

  final String category;
  final String label;
}

class Expedition {
  const Expedition({
    required this.id,
    required this.title,
    required this.kind,
    required this.region,
    required this.start,
    required this.end,
    required this.hostId,
    required this.capacity,
    required this.rosterIds,
    required this.costShare,
    required this.meetingPoint,
    required this.summary,
    required this.plate,
    required this.checklist,
    this.routeId,
  });

  final String id;
  final String title;
  final String kind;
  final String region;
  final DateTime start;
  final DateTime end;
  final String hostId;
  final int capacity;
  final List<String> rosterIds;
  final String costShare;
  final String meetingPoint;
  final String summary;
  final Plate plate;
  final List<ChecklistItem> checklist;
  final String? routeId;

  int get nights => end.difference(start).inDays;
}
