import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../data/sample.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/scene.dart';
import '../app_shell.dart';
import '../routes.dart';

/// Gatherings (an evening, a morning) and expeditions (several days),
/// hosted by the community.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _store = AppStore.instance;
  int _filter = 0;

  bool _passes(TripEvent e) => switch (_filter) {
    1 => e.kind == EventKind.gathering,
    2 => e.kind == EventKind.expedition,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final events = Sample.events.where(_passes).toList()
          ..sort((a, b) => a.start.compareTo(b.start));
        final featured = events
            .where((e) => e.kind == EventKind.expedition)
            .firstOrNull;
        final rest = [
          for (final e in events)
            if (e != featured) e,
        ];
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScreenHeader(
                        title: 'Events',
                        subtitle: 'Small groups, hosted by the circle.',
                      ),
                      const SizedBox(height: 18),
                      Segmented(
                        options: const ['All', 'Gatherings', 'Expeditions'],
                        selected: _filter,
                        onChanged: (i) => setState(() => _filter = i),
                      ),
                      const SizedBox(height: 16),
                      if (featured != null) _Featured(event: featured),
                      const SizedBox(height: 24),
                      SectionHeader(
                        'Upcoming',
                        trailingText: '${rest.length} events',
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: rest.length,
                itemBuilder: (context, i) => _EventRow(event: rest[i]),
                separatorBuilder: (_, _) => const SizedBox(height: 10),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: navClearance(context))),
          ],
        );
      },
    );
  }
}

class _Featured extends StatelessWidget {
  const _Featured({required this.event});

  final TripEvent event;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final going = [
      store.person(event.hostId),
      for (final id in event.attendeeIds) store.person(id),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 220,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Scene(event.motif, event.seed),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00141D15), Color(0xE6141D15)],
                  stops: [0.3, 1],
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => openEvent(context, event),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusPill(
                        '${event.kind.label} · ${relativeDay(event.start)}',
                        icon: event.kind.icon,
                      ),
                      const Spacer(),
                      Text(
                        event.title,
                        style: OdysseyType.sans(
                          22,
                          color: Colors.white,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${dayLabel(event.start)} · ${event.dayCount} days · '
                        '${event.place}',
                        style: OdysseyType.sans(13, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          AvatarStack(going, size: 26),
                          const SizedBox(width: 8),
                          Text(
                            '${store.goingCount(event)} going',
                            style: OdysseyType.sans(13, color: Colors.white),
                          ),
                          const Spacer(),
                          JoinButton(event),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final TripEvent event;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final going = [
      store.person(event.hostId),
      for (final id in event.attendeeIds) store.person(id),
    ];
    final when = event.kind == EventKind.expedition
        ? '${event.dayCount} days'
        : timeLabel(event.start);
    return AppCard(
      onTap: () => openEvent(context, event),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: store.isJoined(event.id) ? AppColors.sage : AppColors.tile,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  '${event.start.day}',
                  style: OdysseyType.sans(
                    20,
                    color: AppColors.ink,
                    weight: FontWeight.w700,
                  ),
                ),
                Text(
                  shortMonth(event.start.month).toUpperCase(),
                  style: OdysseyType.sans(
                    11,
                    color: AppColors.muted,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${event.kind.label} · ${relativeDay(event.start)}',
                  style: OdysseyType.sans(
                    11.5,
                    color: AppColors.sageInk,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.sans(
                    15,
                    color: AppColors.ink,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$when · ${event.place}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.sans(12, color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    AvatarStack(going, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${store.goingCount(event)}/${event.capacity} going',
                      style: OdysseyType.sans(11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          JoinButton(event),
        ],
      ),
    );
  }
}
