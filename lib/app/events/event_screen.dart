import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/scene.dart';
import '../compose_sheet.dart';
import '../routes.dart';

/// One event: when and where, the host, what to expect, who's going, and a
/// button to join.
class EventScreen extends StatelessWidget {
  const EventScreen({super.key, required this.event});

  final TripEvent event;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final host = store.person(event.hostId);
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final joined = store.isJoined(event.id);
        final going = [
          host,
          for (final id in event.attendeeIds) store.person(id),
          if (joined) store.me,
        ];
        final full = store.goingCount(event) >= event.capacity && !joined;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                expandedHeight: 290,
                backgroundColor: AppColors.canvas,
                surfaceTintColor: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                automaticallyImplyLeading: false,
                leading: Padding(
                  padding: const EdgeInsets.all(6),
                  child: RoundIconButton(
                    icon: Icons.arrow_back,
                    tooltip: 'Back',
                    size: 42,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Scene(event.motif, event.seed),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusPill(
                        '${event.kind.label} · ${relativeDay(event.start)}',
                        icon: event.kind.icon,
                        background: AppColors.sage,
                        foreground: AppColors.sageInk,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.title,
                        style: OdysseyType.sans(
                          27,
                          color: AppColors.ink,
                          weight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _Info(
                        Icons.calendar_today_outlined,
                        event.kind == EventKind.expedition
                            ? '${dayLabel(event.start)} – '
                                  '${dayLabel(event.end)} · '
                                  '${event.dayCount} days'
                            : '${dayLabel(event.start)} · '
                                  '${timeLabel(event.start)} – '
                                  '${timeLabel(event.end)}',
                      ),
                      _Info(Icons.place_outlined, event.place),
                      _Info(
                        Icons.group_outlined,
                        '${store.goingCount(event)} of ${event.capacity} '
                        'places taken',
                      ),
                      const SizedBox(height: 6),
                      ThinProgress(
                        store.goingCount(event) / event.capacity,
                        color: AppColors.sageInk,
                      ),
                      const SizedBox(height: 18),
                      AppCard(
                        onTap: host.id == 'me'
                            ? null
                            : () => openProfile(context, host),
                        child: Row(
                          children: [
                            Avatar(host, size: 46),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hosted by',
                                    style: OdysseyType.sans(
                                      12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  Text(
                                    host.name,
                                    style: OdysseyType.sans(
                                      15,
                                      color: AppColors.ink,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FriendButton(host, compact: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader('About'),
                      const SizedBox(height: 8),
                      Text(
                        event.summary,
                        style: OdysseyType.sans(
                          14.5,
                          color: AppColors.body,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const SectionHeader('Highlights'),
                      const SizedBox(height: 8),
                      for (final h in event.highlights)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: AppColors.sageInk,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  h,
                                  style: OdysseyType.sans(
                                    14,
                                    color: AppColors.body,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),
                      SectionHeader(
                        'Who\'s going',
                        trailingText: '${going.length}',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 14,
                        runSpacing: 12,
                        children: [
                          for (final p in going)
                            GestureDetector(
                              onTap: p.id == 'me'
                                  ? null
                                  : () => openProfile(context, p),
                              child: SizedBox(
                                width: 56,
                                child: Column(
                                  children: [
                                    Avatar(p, size: 46),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.id == 'me' ? 'You' : p.firstName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: OdysseyType.sans(
                                        11.5,
                                        color: AppColors.body,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const OrnamentRule(),
                      const SizedBox(height: 14),
                      const Musing('See you on the road.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.canvas,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: joined
                              ? AppColors.sage
                              : AppColors.ink,
                          disabledBackgroundColor: AppColors.line,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: full
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                store.toggleJoin(event.id);
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        store.isJoined(event.id)
                                            ? 'You\'re going — it\'s on your '
                                                  'schedule.'
                                            : 'You left ${event.title}.',
                                      ),
                                    ),
                                  );
                              },
                        child: Text(
                          full
                              ? 'Event full'
                              : (joined
                                    ? 'You\'re going · Leave'
                                    : 'Join this ${event.kind.label.toLowerCase()}'),
                          style: OdysseyType.sans(
                            15,
                            color: joined ? AppColors.sageInk : Colors.white,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    RoundIconButton(
                      icon: Icons.mail_outline,
                      tooltip: 'Invite friends',
                      size: 50,
                      onTap: () =>
                          showInviteComposer(context, eventId: event.id),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          IconTile(icon, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: OdysseyType.sans(14, color: AppColors.body),
            ),
          ),
        ],
      ),
    );
  }
}
