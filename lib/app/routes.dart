import 'package:flutter/material.dart';

import '../data/models.dart';
import '../widgets/motion.dart';
import 'community/community_screen.dart';
import 'community/profile_screen.dart';
import 'credits_screen.dart';
import 'events/event_screen.dart';
import 'home/story_screen.dart';
import 'journal/entry_screen.dart';

Future<void> openStory(BuildContext context, StoryPost story) =>
    Navigator.of(context).push(softRoute((_) => StoryScreen(story: story)));

Future<void> openProfile(BuildContext context, Person person) =>
    Navigator.of(context).push(softRoute((_) => ProfileScreen(person: person)));

Future<void> openEvent(BuildContext context, TripEvent event) =>
    Navigator.of(context).push(softRoute((_) => EventScreen(event: event)));

Future<void> openCommunity(BuildContext context) =>
    Navigator.of(context).push(softRoute((_) => const CommunityScreen()));

Future<void> openEntry(BuildContext context, JournalEntry entry) =>
    Navigator.of(context)
        .push(softRoute((_) => EntryScreen(entryId: entry.id)));

Future<void> openPhotoCredits(BuildContext context) =>
    Navigator.of(context).push(softRoute((_) => const CreditsScreen()));
