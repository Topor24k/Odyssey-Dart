import 'package:flutter/material.dart';

import '../../data/atlas.dart';
import '../../data/models.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/cover_flow.dart';
import '../../widgets/journal.dart';
import '../../widgets/landscape_plate.dart';
import '../navigation.dart';

/// Pillar one: long-form memoirs from independent explorers.
class ChroniclesScreen extends StatefulWidget {
  const ChroniclesScreen({super.key});

  @override
  State<ChroniclesScreen> createState() => _ChroniclesScreenState();
}

class _ChroniclesScreenState extends State<ChroniclesScreen> {
  int _featured = 0;
  int _country = 0;

  @override
  Widget build(BuildContext context) {
    const stories = Atlas.stories;
    final countries = ['All', ...{for (final s in stories) s.country}];
    final listed = _country == 0
        ? stories
        : stories.where((s) => s.country == countries[_country]).toList();

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _Masthead()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 22),
            child: CoverFlow(
              height: 330,
              itemCount: stories.length,
              onPageChanged: (i) => setState(() => _featured = i),
              onTap: (i) =>
                  openStory(context, stories[i], heroTag: 'cover-${stories[i].id}'),
              itemBuilder: (context, i, isReflection) =>
                  _CoverCard(story: stories[i], hero: !isReflection),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _FeatureCaption(
              key: ValueKey(_featured),
              story: stories[_featured],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SectionHeading(
            kicker: 'Field dispatches',
            title: 'Latest Chronicles',
            trailing: '${listed.length} entries',
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: FilterRow(
              options: countries,
              selected: _country,
              onSelected: (i) => setState(() => _country = i),
            ),
          ),
        ),
        SliverList.separated(
          itemCount: listed.length,
          itemBuilder: (context, i) => _StoryRow(story: listed[i]),
          separatorBuilder: (_, _) =>
              const Divider(indent: 22, endIndent: 22),
        ),
        const SliverToBoxAdapter(child: _Colophon()),
      ],
    );
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Kicker('Vol. I · No. 11 · November 2026'),
                Spacer(),
                Icon(Icons.explore_outlined,
                    size: 18, color: OdysseyColors.brass),
              ],
            ),
            const SizedBox(height: 10),
            Text('Odyssey', style: OdysseyType.display(54, height: 1.1)),
            const SizedBox(height: 6),
            Text(
              'THE CHRONICLES',
              style: OdysseyType.subtitle(13,
                  color: OdysseyColors.brass, letterSpacing: 5),
            ),
            const SizedBox(height: 14),
            Text(
              'Trace Southeast Asia one journey at a time — from misty '
              'highland passes and forgotten island passages to heritage '
              'riverways and midnight street alleys.',
              style: OdysseyType.prose(16.5,
                  italic: true, color: OdysseyColors.inkSoft),
            ),
            const SizedBox(height: 16),
            const OrnamentRule(),
          ],
        ),
      ),
    );
  }
}

class _CoverCard extends StatelessWidget {
  const _CoverCard({required this.story, required this.hero});

  final Story story;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final plate = LandscapePlate(story.cover);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        fit: StackFit.expand,
        children: [
          hero ? Hero(tag: 'cover-${story.id}', child: plate) : plate,
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xE6141D15)],
                stops: [0.45, 1],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Kicker('${story.country} · ${story.region}',
                    color: OdysseyColors.brassLight),
                const SizedBox(height: 5),
                Text(
                  story.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.display(21,
                      color: OdysseyColors.parchment,
                      weight: FontWeight.w600,
                      height: 1.1),
                ),
              ],
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Text(
              'PLATE I',
              style: OdysseyType.mono(8.5,
                  color: OdysseyColors.parchment.withValues(alpha: 0.75),
                  letterSpacing: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCaption extends StatelessWidget {
  const _FeatureCaption({super.key, required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final author = Atlas.companion(story.authorId);
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 2, 40, 0),
      child: Column(
        children: [
          Text(
            story.dek,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: OdysseyType.prose(15.5,
                italic: true, color: OdysseyColors.inkSoft),
          ),
          const SizedBox(height: 8),
          Text(
            'BY ${author.name.toUpperCase()} · ${story.readMinutes} MIN READ',
            textAlign: TextAlign.center,
            style: OdysseyType.mono(9, letterSpacing: 1.4),
          ),
        ],
      ),
    );
  }
}

class _StoryRow extends StatelessWidget {
  const _StoryRow({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final author = Atlas.companion(story.authorId);
    final tag = 'list-${story.id}';
    return InkWell(
      onTap: () => openStory(context, story, heroTag: tag),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 88,
              height: 112,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Hero(
                  tag: tag,
                  child: LandscapePlate(story.cover, framed: false),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker('${story.country} · ${story.region}'),
                  const SizedBox(height: 5),
                  Text(story.title,
                      style: OdysseyType.display(21,
                          weight: FontWeight.w600, height: 1.12)),
                  const SizedBox(height: 5),
                  Text(
                    story.dek,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: OdysseyType.display(15,
                        italic: true, color: OdysseyColors.inkSoft),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      MonogramSeal(initials: author.initials, size: 20),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          author.name,
                          overflow: TextOverflow.ellipsis,
                          style: OdysseyType.mono(9.5,
                              color: OdysseyColors.ink, letterSpacing: 0.6),
                        ),
                      ),
                      Text('${story.readMinutes} MIN',
                          style: OdysseyType.mono(9.5)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Colophon extends StatelessWidget {
  const _Colophon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 30, 40, 36),
      child: Column(
        children: [
          const OrnamentRule(),
          const SizedBox(height: 16),
          Text(
            'ODYSSEY · SOUTHEAST ASIA EXPEDITION NETWORK',
            textAlign: TextAlign.center,
            style: OdysseyType.subtitle(11,
                color: OdysseyColors.brass, letterSpacing: 2.4),
          ),
          const SizedBox(height: 6),
          Text(
            'For those who seek the journey as much as the destination.',
            textAlign: TextAlign.center,
            style: OdysseyType.prose(15,
                italic: true, color: OdysseyColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
