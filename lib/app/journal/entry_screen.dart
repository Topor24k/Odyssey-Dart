import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/photo.dart';
import '../../widgets/photo_tools.dart';

/// One journal entry, read in full. A private draft can be shared to
/// Moments from here, a pin can be found on the map, and any entry can be
/// deleted — the Journal is the only place entries are deleted from.
class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return Scaffold(
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final entry = store.entry(entryId);
          if (entry == null) return const SizedBox.shrink();
          final photo = entry.photo;
          return CustomScrollView(
            slivers: [
              if (photo != null)
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  expandedHeight: 320,
                  backgroundColor: AppColors.canvas,
                  surfaceTintColor: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  automaticallyImplyLeading: false,
                  leading: const _Back(),
                  actions: [_Delete(entry: entry)],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [StretchMode.zoomBackground],
                    background: GestureDetector(
                      onTap: () => showPhotoViewer(context, entry.photos),
                      child: Hero(
                        tag: 'journal-${entry.id}',
                        child: PhotoImage(photo),
                      ),
                    ),
                  ),
                )
              else
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.canvas,
                  surfaceTintColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  leading: const _Back(),
                  actions: [_Delete(entry: entry)],
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    photo == null ? 4 : 22,
                    22,
                    MediaQuery.paddingOf(context).bottom + 32,
                  ),
                  child: _Body(entry: entry),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Back extends StatelessWidget {
  const _Back();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: RoundIconButton(
        icon: Icons.arrow_back,
        tooltip: 'Back',
        size: 42,
        onTap: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

/// Deletes the entry, after asking. Its post and pin go with it.
class _Delete extends StatelessWidget {
  const _Delete({required this.entry});

  final JournalEntry entry;

  Future<void> _confirm(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final also = switch (entry) {
      JournalEntry(kind: EntryKind.pin) => ' Its pin comes off the map too.',
      JournalEntry(shared: true) => ' It will also be removed from Moments.',
      _ => '',
    };
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: AppColors.canvas,
        title: Text(
          'Delete this entry?',
          style: OdysseyType.display(
            24,
            color: AppColors.ink,
            weight: FontWeight.w500,
          ),
        ),
        content: Text(
          '“${entry.heading}” will be deleted from your journal.$also '
          "This can't be undone.",
          style: OdysseyType.sans(14, color: AppColors.body, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(
              'Keep',
              style: OdysseyType.sans(14, color: AppColors.ink),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(
              'Delete',
              style: OdysseyType.sans(
                14,
                color: AppColors.alert,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    HapticFeedback.mediumImpact();
    navigator.pop();
    AppStore.instance.deleteEntry(entry.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Entry deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: RoundIconButton(
        icon: Icons.delete_outline,
        tooltip: 'Delete entry',
        size: 42,
        onTap: () => _confirm(context),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.entry});

  final JournalEntry entry;

  void _share(BuildContext context) {
    HapticFeedback.mediumImpact();
    AppStore.instance.shareEntry(entry.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Shared to Moments.')));
  }

  void _showOnMap(BuildContext context) {
    AppStore.instance.showOnMap(entry.pinId!);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final post = entry.postId == null ? null : store.post(entry.postId!);
    final d = entry.date;
    final note = entry.kind == EntryKind.note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${weekdayShort(d)} · ${d.day} ${monthName(d.month)} ${d.year} · '
                  '${timeLabel(d)}'
              .toUpperCase(),
          style: OdysseyType.caps(9.5),
        ),
        const SizedBox(height: 12),
        if (entry.title != null && entry.title!.isNotEmpty) ...[
          Text(
            entry.title!,
            style: OdysseyType.display(
              34,
              color: AppColors.ink,
              weight: FontWeight.w500,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusPill(
              entry.place,
              icon: Icons.place_outlined,
              background: AppColors.tile,
            ),
            StatusPill(
              entry.kind.label,
              icon: entry.kind.icon,
              background: AppColors.tile,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: StatusPill(
                entry.shared ? 'Shared' : 'Private draft',
                key: ValueKey(entry.shared),
                icon: entry.shared ? Icons.public : Icons.lock_outline,
                background: entry.shared ? AppColors.sage : AppColors.tile,
                foreground: entry.shared ? AppColors.sageInk : AppColors.body,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 18),
        for (final p in entry.paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              p,
              style: OdysseyType.display(
                note ? 21 : 19.5,
                color: AppColors.ink,
                italic: note,
                height: 1.55,
              ),
            ),
          ),
        if (entry.photos.length > 1) ...[
          const SizedBox(height: 4),
          PhotoGallery(entry.photos),
          const SizedBox(height: 20),
        ],
        const SizedBox(height: 8),
        if (entry.kind == EntryKind.pin && entry.pinId != null)
          _Action(
            icon: Icons.map_outlined,
            label: 'See it on the map',
            onTap: () => _showOnMap(context),
          )
        else if (!entry.shared)
          _Action(
            icon: Icons.public,
            label: 'Share to Moments',
            dark: true,
            onTap: () => _share(context),
          )
        else
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 18,
                color: AppColors.sageInk,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  post == null
                      ? 'Shared to Moments'
                      : 'Shared to Moments · ${store.likesOf(post)} likes · '
                            '${post.comments} comments',
                  style: OdysseyType.sans(13.5, color: AppColors.sageInk),
                ),
              ),
            ],
          ),
        const SizedBox(height: 28),
        const Center(child: OrnamentRule()),
        const SizedBox(height: 14),
        const Center(child: Musing('Written down, so it stays.')),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.dark = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.ink;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: dark ? AppColors.ink : AppColors.card,
        shape: StadiumBorder(
          side: dark
              ? BorderSide.none
              : const BorderSide(color: AppColors.line),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: OdysseyType.sans(
                    14.5,
                    color: fg,
                    weight: FontWeight.w600,
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
