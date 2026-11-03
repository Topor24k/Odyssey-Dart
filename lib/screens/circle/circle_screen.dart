import 'package:flutter/material.dart';

import '../../data/atlas.dart';
import '../../data/models.dart';
import '../../data/odyssey_store.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/companion_widgets.dart';
import '../../widgets/journal.dart';

const _numerals = ['I', 'II', 'III', 'IV', 'V'];

/// Pillar four: the companion circle and its shared travel ethos.
class CircleScreen extends StatefulWidget {
  const CircleScreen({super.key});

  @override
  State<CircleScreen> createState() => _CircleScreenState();
}

class _CircleScreenState extends State<CircleScreen> {
  final _store = OdysseyStore.instance;
  int _country = 0;

  static String _countryOf(Companion c) => c.base.split(', ').last;

  @override
  Widget build(BuildContext context) {
    const people = Atlas.companions;
    final countries = ['All', ...{for (final c in people) _countryOf(c)}];
    final listed = _country == 0
        ? people
        : people.where((c) => _countryOf(c) == countries[_country]).toList();

    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) => CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: PageHeader(
              kicker: 'Explorer network',
              title: 'Companion Circle',
              subtitle:
                  'A trust-based circle of mindful wayfarers who share route '
                  'intel and travel across borders together.',
            ),
          ),
          SliverToBoxAdapter(child: _YourCircle(store: _store)),
          SliverToBoxAdapter(
            child: SectionHeading(
              kicker: 'Wayfarer profiles',
              title: 'Keepers & guides',
              trailing: '${listed.length} verified',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilterRow(
                options: countries,
                selected: _country,
                onSelected: (i) => setState(() => _country = i),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: listed.length,
            itemBuilder: (context, i) => _CompanionCard(companion: listed[i]),
          ),
          const SliverToBoxAdapter(
            child: SectionHeading(
              kicker: 'Mutual travel ethos',
              title: 'Five tenets of the road',
            ),
          ),
          SliverList.builder(
            itemCount: Atlas.ethos.length,
            itemBuilder: (context, i) => _Tenet(index: i),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 36),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _store.pledgedOn == null
                    ? JournalButton(
                        key: const ValueKey('pledge'),
                        label: 'Take the wayfarer\'s pledge',
                        icon: Icons.handshake_outlined,
                        onPressed: _store.togglePledge,
                      )
                    : JournalButton(
                        key: const ValueKey('pledged'),
                        label: 'Pledged · ${_store.pledgedOn!.day} '
                            '${shortMonth(_store.pledgedOn!.month)} '
                            '${_store.pledgedOn!.year}',
                        icon: Icons.verified_outlined,
                        filled: false,
                        onPressed: _store.togglePledge,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YourCircle extends StatelessWidget {
  const _YourCircle({required this.store});

  final OdysseyStore store;

  @override
  Widget build(BuildContext context) {
    final pending = Atlas.companions
        .where((c) => store.linkWith(c.id) == CompanionLink.requested)
        .length;
    Widget figure(String value, String label) => Expanded(
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Text(
                  value,
                  key: ValueKey(value),
                  style: OdysseyType.display(34,
                      color: OdysseyColors.parchment, height: 1),
                ),
              ),
              const SizedBox(height: 4),
              Text(label.toUpperCase(),
                  style: OdysseyType.mono(8.5,
                      color: OdysseyColors.brassLight, letterSpacing: 1.6)),
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: OdysseyColors.forest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OdysseyColors.brass.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MonogramSeal(
                initials: 'YOU',
                size: 40,
                background: OdysseyColors.forestMist,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your circle',
                        style: OdysseyType.display(21,
                            color: OdysseyColors.parchment,
                            weight: FontWeight.w600)),
                    Text('WAYFARER · SINCE NOV 2026',
                        style: OdysseyType.mono(8.5,
                            color: OdysseyColors.brassLight,
                            letterSpacing: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              figure('${store.companionCount}', 'Companions'),
              figure('$pending', 'Pending'),
              figure(store.pledgedOn == null ? '—' : '✓', 'Pledged'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanionCard extends StatelessWidget {
  const _CompanionCard({required this.companion});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    final c = companion;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
      child: Material(
        color: OdysseyColors.parchment,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: OdysseyColors.rule),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showCompanionSheet(context, c),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Monogram(c, size: 50),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: OdysseyType.display(20,
                                  weight: FontWeight.w600, height: 1.1)),
                          const SizedBox(height: 2),
                          Text(c.role.toUpperCase(),
                              style: OdysseyType.subtitle(11.5,
                                  color: OdysseyColors.brass,
                                  letterSpacing: 2)),
                          Text(c.base,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: OdysseyType.mono(9.5)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConnectButton(c),
                  ],
                ),
                const SizedBox(height: 12),
                Text(c.bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: OdysseyType.prose(15.5,
                        color: OdysseyColors.inkSoft)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [for (final s in c.specialties) Tag(s)],
                ),
                const SizedBox(height: 12),
                Text(
                  '${c.routesLogged} ROUTES · ${c.storiesWritten} STORIES · '
                  '${c.yearsOnRoad} YEARS ON THE ROAD',
                  style: OdysseyType.mono(9, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tenet extends StatelessWidget {
  const _Tenet({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final (title, body) = Atlas.ethos[index];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              _numerals[index],
              style: OdysseyType.display(26,
                  color: OdysseyColors.brass, weight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: OdysseyType.display(20, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(body,
                    style: OdysseyType.prose(15.5,
                        color: OdysseyColors.inkSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
