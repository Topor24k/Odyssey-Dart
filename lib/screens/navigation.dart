import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/odyssey_store.dart';
import 'gatherings/expedition_screen.dart';
import 'routes/route_screen.dart';
import 'stories/story_screen.dart';

Future<void> openStory(BuildContext context, Story story, {String? heroTag}) =>
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => StoryScreen(story: story, heroTag: heroTag),
    ));

Future<void> openRoute(BuildContext context, RoutePlan route) =>
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RouteScreen(route: route),
    ));

Future<void> openExpedition(BuildContext context, Expedition expedition) =>
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ExpeditionScreen(expedition: expedition),
    ));

/// Closes any detail pages and flies the map tab to [focus].
void showOnMap(BuildContext context, MapFocus focus) {
  Navigator.of(context).popUntil((route) => route.isFirst);
  OdysseyStore.instance.showOnMap(focus);
}
