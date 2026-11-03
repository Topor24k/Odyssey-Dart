import 'package:flutter/material.dart';

import '../data/models.dart';
import 'community/profile_screen.dart';
import 'events/event_screen.dart';
import 'home/story_screen.dart';

Future<void> openStory(BuildContext context, StoryPost story) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => StoryScreen(story: story)));

Future<void> openProfile(BuildContext context, Person person) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => ProfileScreen(person: person)));

Future<void> openEvent(BuildContext context, TripEvent event) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(builder: (_) => EventScreen(event: event)));
