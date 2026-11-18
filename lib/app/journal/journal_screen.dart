import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/motion.dart';
import '../../widgets/photo.dart';
import '../app_shell.dart';
import '../compose_sheet.dart';
import '../routes.dart';

/// Everything you have written — stories, notes and map pins — month by
/// month, whether you shared it or kept it to yourself.
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _store = AppStore.instance;
  final _scroll = ScrollController();
  late int _count = _store.journal.length;
  int _filter = 0;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStore);
  }

  @override
  void dispose() {
    _store.removeListener(_onStore);
    _scroll.dispose();
    super.dispose();
  }

  /// A new entry lands at the top, so go and show it.
  void _onStore() {
    final count = _store.journal.length;
    if (count > _count && _scroll.hasClients && _scroll.offset > 0) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
    _count = count;
  }

  bool _passes(JournalEntry e) => switch (_filter) {
    1 => e.shared,
    2 => !e.shared,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final entries = _store.journal.where(_passes).toList();

        // Newest month first, entries newest first within it.
        final months = <(int, int), List<JournalEntry>>{};
        for (final e in entries) {
          months.putIfAbsent((e.date.year, e.date.month), () => []).add(e);
        }

        return CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScreenHeader(
                        title: 'Journal',
                        subtitle: 'Everything you\'ve written',
                        trailing: RoundIconButton(
                          icon: Icons.edit_outlined,
                          tooltip: 'Write an entry',
                          dark: true,
                          onTap: () => showWriteSheet(
                            context,
                            chooseKind: true,
                            share: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Segmented(
                        options: const ['All', 'Shared', 'Private'],
                        selected: _filter,
                        onChanged: (i) => setState(() => _filter = i),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (entries.isEmpty)
              SliverToBoxAdapter(child: _Empty(filter: _filter))
            else
              for (final MapEntry(key: (year, month), value: list)
                  in months.entries) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${monthName(month)} $year',
                          style: OdysseyType.display(
                            23,
                            color: AppColors.ink,
                            weight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${list.length} '
                                  '${list.length == 1 ? 'entry' : 'entries'}'
                              .toUpperCase(),
                          style: OdysseyType.caps(9.5),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) => Reveal(
                      key: ValueKey('${list[i].id}-$_filter'),
                      index: i,
                      child: _EntryRow(
                        entry: list[i],
                        last: i == list.length - 1,
                      ),
                    ),
                  ),
                ),
              ],
            SliverToBoxAdapter(child: SizedBox(height: navClearance(context))),
          ],
        );
      },
    );
  }
}

/// The date on the left, a hairline down to the next entry, and the entry.
class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.last});

  final JournalEntry entry;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  '${entry.date.day}',
                  style: OdysseyType.display(
                    26,
                    color: AppColors.ink,
                    weight: FontWeight.w500,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  weekdayShort(entry.date).toUpperCase(),
                  style: OdysseyType.caps(8.5, letterSpacing: 1.6),
                ),
                const SizedBox(height: 8),
                if (!last)
                  Expanded(child: Container(width: 1, color: AppColors.line)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _EntryCard(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final post = entry.postId == null ? null : store.post(entry.postId!);
    final pin = entry.pinId == null
        ? null
        : store.mapStories.where((s) => s.id == entry.pinId).firstOrNull;
    final likes = post != null ? store.likesOf(post) : (pin?.likes ?? 0);
    final note = entry.kind == EntryKind.note;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => openEntry(context, entry),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.photo != null)
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'journal-${entry.id}',
                    child: PhotoImage(entry.photo!),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: StatusPill(entry.kind.label, icon: entry.kind.icon),
                  ),
                  if (entry.photos.length > 1)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: StatusPill(
                        '${entry.photos.length}',
                        icon: Icons.photo_library_outlined,
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    if (entry.photo == null) entry.kind.label,
                    entry.place.split(',').first,
                    timeLabel(entry.date),
                  ].join(' · ').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.caps(9),
                ),
                const SizedBox(height: 6),
                if (note)
                  Text(
                    entry.text,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: OdysseyType.display(
                      17.5,
                      color: AppColors.ink,
                      italic: true,
                      height: 1.35,
                    ),
                  )
                else ...[
                  Text(
                    entry.heading,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: OdysseyType.display(
                      20,
                      color: AppColors.ink,
                      weight: FontWeight.w500,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.paragraphs.isEmpty ? '' : entry.paragraphs.first,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: OdysseyType.sans(
                      13,
                      color: AppColors.body,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      entry.shared ? Icons.public : Icons.lock_outline,
                      size: 14,
                      color: entry.shared ? AppColors.sageInk : AppColors.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry.shared
                            ? (entry.kind == EntryKind.pin
                                  ? 'On the map · $likes likes'
                                  : 'Shared · $likes likes')
                            : 'Private draft',
                        style: OdysseyType.sans(
                          12,
                          color: entry.shared
                              ? AppColors.sageInk
                              : AppColors.muted,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.filter});

  final int filter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
      child: Column(
        children: [
          Musing(switch (filter) {
            1 => 'Nothing shared yet.\nThe road is patient.',
            2 => 'No private entries.\nSome stories are just for you.',
            _ => 'Your first entry\nis waiting.',
          }),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              shape: const StadiumBorder(),
            ),
            onPressed: () =>
                showWriteSheet(context, chooseKind: true, share: false),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(
              'Write an entry',
              style: OdysseyType.sans(
                14,
                color: Colors.white,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
