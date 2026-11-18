import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../data/sample.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/motion.dart';
import '../../widgets/photo.dart';
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

  int get _filter => _store.eventsFilter.value;

  bool _passes(TripEvent e) =>
      !_store.hasEnded(e) &&
      switch (_filter) {
        1 => e.kind == EventKind.gathering,
        2 => e.kind == EventKind.expedition,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_store, _store.eventsFilter]),
      builder: (context, _) {
        final joinedView = _filter == 3;
        final events = Sample.events.where(_passes).toList()
          ..sort((a, b) => a.start.compareTo(b.start));
        final featured = joinedView
            ? null
            : events.where((e) => e.kind == EventKind.expedition).firstOrNull;
        final rest = [
          for (final e in events)
            if (e != featured) e,
        ];
        final upcoming = _store.upcomingJoined;
        final attended = _store.attendedEvents;

        Widget list(List<TripEvent> items) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: items.length,
            itemBuilder: (context, i) => Reveal(
              key: ValueKey('${items[i].id}-$_filter'),
              index: i,
              child: _EventRow(event: items[i]),
            ),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
          ),
        );

        Widget header(String title, String trailing) => SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: SectionHeader(title, trailingText: trailing),
          ),
        );

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
                        options: const [
                          'All',
                          'Gatherings',
                          'Expeditions',
                          'Joined',
                        ],
                        selected: _filter,
                        onChanged: (i) => _store.eventsFilter.value = i,
                      ),
                      if (!joinedView) ...[
                        const SizedBox(height: 16),
                        if (featured != null) _Featured(event: featured),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (joinedView) ...[
              header('Coming up', '${upcoming.length} joined'),
              if (upcoming.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Musing('Nothing joined yet.'),
                  ),
                )
              else
                list(upcoming),
              header('Attended', '${attended.length} events'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Text(
                    'Events you went to, marked by their hosts. They stay '
                    'here even if you take them off your calendar.',
                    style: OdysseyType.sans(
                      12.5,
                      color: AppColors.muted,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
              list(attended),
            ] else ...[
              header('Upcoming', '${rest.length} events'),
              list(rest),
            ],
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
            Hero(tag: 'event-${event.id}', child: PhotoImage(event.photo)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00102421), Color(0xD9102421)],
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
                        style: OdysseyType.display(
                          28,
                          color: Colors.white,
                          weight: FontWeight.w500,
                          height: 1.05,
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
                  store.hasEnded(event)
                      ? '${event.kind.label} · Past'
                      : '${event.kind.label} · ${relativeDay(event.start)}',
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
                  style: OdysseyType.display(
                    19,
                    color: AppColors.ink,
                    weight: FontWeight.w500,
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
                      store.hasEnded(event)
                          ? '${store.goingCount(event)} went'
                          : '${store.goingCount(event)}/${event.capacity} going',
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
