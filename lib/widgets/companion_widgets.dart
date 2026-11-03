import 'package:flutter/material.dart';

import '../data/atlas.dart';
import '../data/models.dart';
import '../data/odyssey_store.dart';
import '../screens/navigation.dart';
import '../theme/odyssey_theme.dart';
import 'journal.dart';

/// "+ Connect" → "Requested" → "Companion". Tapping a companion releases the
/// bond, with an undo.
class ConnectButton extends StatelessWidget {
  const ConnectButton(this.companion, {super.key});

  final Companion companion;

  @override
  Widget build(BuildContext context) {
    final store = OdysseyStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final link = store.linkWith(companion.id);
        final (label, icon, filled) = switch (link) {
          CompanionLink.none => ('Connect', Icons.add, false),
          CompanionLink.requested => ('Requested', Icons.schedule, false),
          CompanionLink.connected => ('Companion', Icons.check, true),
        };
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.0).animate(animation),
              child: child,
            ),
          ),
          child: Material(
            key: ValueKey(link),
            color: filled ? OdysseyColors.forest : Colors.transparent,
            shape: StadiumBorder(
              side: BorderSide(
                color: link == CompanionLink.requested
                    ? OdysseyColors.rule
                    : OdysseyColors.brass,
              ),
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () => _onTap(context, link),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon,
                        size: 14,
                        color: filled
                            ? OdysseyColors.brassLight
                            : OdysseyColors.brass),
                    const SizedBox(width: 5),
                    Text(
                      label.toUpperCase(),
                      style: OdysseyType.mono(
                        9.5,
                        color: filled
                            ? OdysseyColors.parchment
                            : (link == CompanionLink.requested
                                ? OdysseyColors.inkSoft
                                : OdysseyColors.forest),
                        weight: FontWeight.w500,
                        letterSpacing: 1.3,
                      ),
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

  void _onTap(BuildContext context, CompanionLink link) {
    final store = OdysseyStore.instance;
    final messenger = ScaffoldMessenger.of(context);
    final first = companion.name.split(' ').first;
    switch (link) {
      case CompanionLink.none:
        store.requestCompanion(companion.id);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('Companion request sent to $first.'),
          ));
      case CompanionLink.requested:
        break;
      case CompanionLink.connected:
        store.releaseCompanion(companion.id);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('Companion bond with $first released.'),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: OdysseyColors.brassLight,
              onPressed: () => store.requestCompanion(companion.id),
            ),
          ));
    }
  }
}

/// A wayfarer profile: bio, languages, specialties and their own work.
Future<void> showCompanionSheet(BuildContext context, Companion companion) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.74,
      maxChildSize: 0.94,
      minChildSize: 0.4,
      // Navigate with the caller's context: the sheet's own is gone once
      // it pops.
      builder: (_, scroll) {
        final stories =
            Atlas.stories.where((s) => s.authorId == companion.id).toList();
        final routes =
            Atlas.routes.where((r) => r.keeperId == companion.id).toList();
        return ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
          children: [
            Row(
              children: [
                Monogram(companion, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(companion.name,
                          style: OdysseyType.display(25,
                              weight: FontWeight.w600, height: 1.1)),
                      const SizedBox(height: 2),
                      Text(companion.role.toUpperCase(),
                          style: OdysseyType.subtitle(12.5,
                              color: OdysseyColors.brass, letterSpacing: 2.4)),
                      const SizedBox(height: 4),
                      Text(companion.base, style: OdysseyType.mono(10)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ConnectButton(companion),
                const Spacer(),
                _Count('Routes', companion.routesLogged),
                _Count('Stories', companion.storiesWritten),
                _Count('Years', companion.yearsOnRoad),
              ],
            ),
            const SizedBox(height: 18),
            const OrnamentRule(),
            const SizedBox(height: 16),
            Text(companion.bio, style: OdysseyType.prose(18)),
            const SizedBox(height: 20),
            const Kicker('Specialties'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final s in companion.specialties) Tag(s)],
            ),
            const SizedBox(height: 18),
            const Kicker('Languages'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final l in companion.languages)
                  Tag(l, icon: Icons.translate),
              ],
            ),
            if (stories.isNotEmpty) ...[
              const SizedBox(height: 22),
              const Kicker('Chronicles'),
              for (final s in stories)
                _WorkTile(
                  icon: Icons.auto_stories_outlined,
                  title: s.title,
                  subtitle: '${s.country} · ${s.readMinutes} min read',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    openStory(context, s);
                  },
                ),
            ],
            if (routes.isNotEmpty) ...[
              const SizedBox(height: 22),
              const Kicker('Routes kept'),
              for (final r in routes)
                _WorkTile(
                  icon: r.mode.icon,
                  title: r.name,
                  subtitle: '${r.days.length} days · ${r.distanceKm} km',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    openRoute(context, r);
                  },
                ),
            ],
          ],
        );
      },
    ),
  );
}

class _Count extends StatelessWidget {
  const _Count(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Column(
        children: [
          Text('$value',
              style: OdysseyType.display(22, weight: FontWeight.w600, height: 1)),
          Text(label.toUpperCase(),
              style: OdysseyType.mono(8, letterSpacing: 1.2)),
        ],
      ),
    );
  }
}

class _WorkTile extends StatelessWidget {
  const _WorkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: OdysseyColors.brass),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: OdysseyType.display(18, weight: FontWeight.w600)),
                  Text(subtitle, style: OdysseyType.mono(9.5)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: OdysseyColors.inkSoft),
          ],
        ),
      ),
    );
  }
}
