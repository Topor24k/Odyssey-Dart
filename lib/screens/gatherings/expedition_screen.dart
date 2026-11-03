import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/atlas.dart';
import '../../data/models.dart';
import '../../data/odyssey_store.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/companion_widgets.dart';
import '../../widgets/journal.dart';
import '../../widgets/landscape_plate.dart';
import '../navigation.dart';
import 'gatherings_screen.dart';

/// An expedition: logistics, the roster, the host and a checklist you tick
/// off before departure — with an RSVP to join the roster.
class ExpeditionScreen extends StatelessWidget {
  const ExpeditionScreen({super.key, required this.expedition});

  final Expedition expedition;

  @override
  Widget build(BuildContext context) {
    final store = OdysseyStore.instance;
    final e = expedition;
    final host = Atlas.companion(e.hostId);
    final route = e.routeId == null ? null : Atlas.route(e.routeId!);
    final categories = <String>{for (final c in e.checklist) c.category};

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final going = store.isGoing(e.id);
        // The host plus confirmed wayfarers, plus you once you RSVP.
        final filled = e.rosterIds.length + 1 + (going ? 1 : 0);
        final full = filled >= e.capacity && !going;
        final packed = store.packedCount(e.id);
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                expandedHeight: 280,
                backgroundColor: OdysseyColors.forest,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                automaticallyImplyLeading: false,
                leading: PlateIconButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      LandscapePlate(e.plate),
                      Positioned(
                        left: 22,
                        bottom: 18,
                        child: PlateBadge(
                          '${formatDateRange(e.start, e.end)} · ${e.nights} nights',
                          icon: Icons.event_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Kicker(e.kind),
                      const SizedBox(height: 6),
                      Text(e.title,
                          style: OdysseyType.display(32,
                              weight: FontWeight.w600, height: 1.08)),
                      const SizedBox(height: 10),
                      Text(e.summary,
                          style: OdysseyType.prose(17.5,
                              italic: true, color: OdysseyColors.inkSoft)),
                      const SizedBox(height: 12),
                      InfoLine(
                          icon: Icons.place_outlined,
                          label: 'Meet',
                          value: e.meetingPoint),
                      InfoLine(
                          icon: Icons.payments_outlined,
                          label: 'Share',
                          value: e.costShare),
                      InfoLine(
                          icon: Icons.public,
                          label: 'Region',
                          value: e.region),
                      if (route != null) ...[
                        const SizedBox(height: 14),
                        JournalButton(
                          label: 'Route plan · ${route.name}',
                          icon: Icons.route_outlined,
                          filled: false,
                          onPressed: () => openRoute(context, route),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SectionHeading(
                  kicker: 'Wayfarers',
                  title: 'The roster',
                  trailing: '$filled / ${e.capacity}',
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: _Roster(expedition: e, going: going),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                  child: Row(
                    children: [
                      Monogram(host, size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => showCompanionSheet(context, host),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Kicker('Trip leader'),
                              Text(host.name,
                                  style: OdysseyType.display(19,
                                      weight: FontWeight.w600)),
                              Text(host.role.toUpperCase(),
                                  style: OdysseyType.mono(9)),
                            ],
                          ),
                        ),
                      ),
                      ConnectButton(host),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SectionHeading(
                  kicker: 'Prerequisites',
                  title: 'Expedition checklist',
                  trailing: '$packed / ${e.checklist.length} ready',
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: packed / e.checklist.length),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 4,
                        backgroundColor: OdysseyColors.vellum,
                        color: OdysseyColors.moss,
                      ),
                    ),
                  ),
                ),
              ),
              for (final category in categories) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
                    child: Kicker(category, color: OdysseyColors.inkSoft),
                  ),
                ),
                SliverList.list(
                  children: [
                    for (var i = 0; i < e.checklist.length; i++)
                      if (e.checklist[i].category == category)
                        _CheckRow(
                          label: e.checklist[i].label,
                          checked: store.isPacked(e.id, i),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            store.togglePacked(e.id, i);
                          },
                        ),
                  ],
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              color: OdysseyColors.parchment,
              border: Border(top: BorderSide(color: OdysseyColors.rule)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: JournalButton(
                  label: going
                      ? 'On the roster · Withdraw'
                      : (full ? 'Roster full' : 'Request a place on the roster'),
                  icon: going ? Icons.verified : Icons.how_to_reg_outlined,
                  filled: !going,
                  onPressed: full
                      ? null
                      : () {
                          store.toggleRsvp(e.id);
                          final first = host.name.split(' ').first;
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: Text(store.isGoing(e.id)
                                  ? 'You\'re on the roster. $first will be in touch.'
                                  : 'You\'ve withdrawn from ${e.title}.'),
                            ));
                        },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Roster extends StatelessWidget {
  const _Roster({required this.expedition, required this.going});

  final Expedition expedition;
  final bool going;

  @override
  Widget build(BuildContext context) {
    final e = expedition;
    final members = [
      Atlas.companion(e.hostId),
      for (final id in e.rosterIds) Atlas.companion(id),
    ];
    final open = e.capacity - members.length - (going ? 1 : 0);
    Widget seat(Widget avatar, String name) => SizedBox(
          width: 64,
          child: Column(
            children: [
              avatar,
              const SizedBox(height: 5),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: OdysseyType.mono(8.5,
                    color: OdysseyColors.ink, letterSpacing: 0.4),
              ),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 14,
          children: [
            for (final m in members)
              GestureDetector(
                onTap: () => showCompanionSheet(context, m),
                child: seat(Monogram(m, size: 44), m.name.split(' ').first),
              ),
            if (going)
              seat(
                const MonogramSeal(
                  initials: 'YOU',
                  size: 44,
                  background: OdysseyColors.moss,
                ),
                'You',
              ),
            for (var i = 0; i < open.clamp(0, 4); i++)
              seat(
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: OdysseyColors.rule, width: 1.2),
                  ),
                  child: const Icon(Icons.add,
                      size: 16, color: OdysseyColors.rule),
                ),
                'Open',
              ),
          ],
        ),
        const SizedBox(height: 14),
        RosterBar(
          filled: members.length + (going ? 1 : 0),
          capacity: e.capacity,
        ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked ? OdysseyColors.moss : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: checked ? OdysseyColors.moss : OdysseyColors.brass,
                  width: 1.2,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check,
                      size: 15, color: OdysseyColors.parchment)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: OdysseyType.prose(16.5,
                    color: checked ? OdysseyColors.inkSoft : OdysseyColors.ink),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
