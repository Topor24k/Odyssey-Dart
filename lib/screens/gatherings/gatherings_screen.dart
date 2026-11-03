import 'package:flutter/material.dart';

import '../../data/atlas.dart';
import '../../data/models.dart';
import '../../data/odyssey_store.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/journal.dart';
import '../navigation.dart';

/// Pillar five: community-hosted expeditions, grouped by month.
class GatheringsScreen extends StatelessWidget {
  const GatheringsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = OdysseyStore.instance;
    final byMonth = <(int, int), List<Expedition>>{};
    for (final e in [...Atlas.expeditions]
      ..sort((a, b) => a.start.compareTo(b.start))) {
      byMonth.putIfAbsent((e.start.year, e.start.month), () => []).add(e);
    }

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: PageHeader(
              kicker: 'Expeditions & gatherings',
              title: 'Field Gatherings',
              subtitle:
                  'Small-group journeys hosted by the circle. Meet your roster '
                  'before you meet the road.',
            ),
          ),
          for (final MapEntry(key: (year, month), value: list)
              in byMonth.entries) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(longMonth(month),
                        style: OdysseyType.display(26, weight: FontWeight.w600)),
                    const SizedBox(width: 10),
                    Text('$year', style: OdysseyType.mono(11)),
                    const SizedBox(width: 12),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),
            ),
            SliverList.builder(
              itemCount: list.length,
              itemBuilder: (context, i) =>
                  _ExpeditionCard(expedition: list[i], store: store),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

class _ExpeditionCard extends StatelessWidget {
  const _ExpeditionCard({required this.expedition, required this.store});

  final Expedition expedition;
  final OdysseyStore store;

  @override
  Widget build(BuildContext context) {
    final e = expedition;
    final host = Atlas.companion(e.hostId);
    final going = store.isGoing(e.id);
    final filled = e.rosterIds.length + 1 + (going ? 1 : 0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
      child: Material(
        color: OdysseyColors.parchment,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: going ? OdysseyColors.brass : OdysseyColors.rule),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openExpedition(context, e),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 80,
                  color: OdysseyColors.forest,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(e.start.day.toString().padLeft(2, '0'),
                          style: OdysseyType.display(36,
                              color: OdysseyColors.parchment, height: 1)),
                      Text(shortMonth(e.start.month).toUpperCase(),
                          style: OdysseyType.mono(10,
                              color: OdysseyColors.brassLight,
                              letterSpacing: 2)),
                      Container(
                        width: 22,
                        height: 0.8,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: OdysseyColors.brass,
                      ),
                      Text('${e.nights} NIGHTS',
                          style: OdysseyType.mono(8,
                              color: OdysseyColors.parchment
                                  .withValues(alpha: 0.7),
                              letterSpacing: 1)),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Kicker(e.kind),
                        const SizedBox(height: 3),
                        Text(e.title,
                            style: OdysseyType.display(20,
                                weight: FontWeight.w600, height: 1.1)),
                        const SizedBox(height: 2),
                        Text(e.region, style: OdysseyType.mono(9.5)),
                        const SizedBox(height: 12),
                        RosterBar(filled: filled, capacity: e.capacity),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            MonogramSeal(initials: host.initials, size: 20),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                'Hosted by ${host.name}',
                                overflow: TextOverflow.ellipsis,
                                style: OdysseyType.mono(9.5,
                                    color: OdysseyColors.ink,
                                    letterSpacing: 0.5),
                              ),
                            ),
                            if (going)
                              const Icon(Icons.verified,
                                  size: 16, color: OdysseyColors.brass),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Seats taken out of seats available.
class RosterBar extends StatelessWidget {
  const RosterBar({super.key, required this.filled, required this.capacity});

  final int filled;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final f = (filled / capacity).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$filled / $capacity WAYFARERS',
                style: OdysseyType.mono(9,
                    color: OdysseyColors.ink, letterSpacing: 1.2)),
            const Spacer(),
            Text(
              filled >= capacity
                  ? 'ROSTER FULL'
                  : '${capacity - filled} PLACES LEFT',
              style: OdysseyType.mono(9,
                  color: filled >= capacity
                      ? OdysseyColors.ember
                      : OdysseyColors.brass,
                  letterSpacing: 1.2),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Stack(
            children: [
              Container(height: 4, color: OdysseyColors.vellum),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                widthFactor: f,
                child: Container(height: 4, color: OdysseyColors.brass),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
