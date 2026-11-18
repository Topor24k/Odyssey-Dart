import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../data/sample.dart';
import '../theme/odyssey_theme.dart';
import '../widgets/kit.dart';
import '../widgets/photo.dart';
import '../widgets/photo_tools.dart';

/// The create menu behind the "+" button.
Future<void> showCreateSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) {
      void then(void Function() action) {
        Navigator.of(sheet).pop();
        action();
      }

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create',
                style: OdysseyType.sans(
                  22,
                  color: AppColors.ink,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Everything you write is kept in your journal.',
                style: OdysseyType.sans(13.5, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              _CreateOption(
                icon: Icons.auto_stories_outlined,
                title: 'Story',
                subtitle: 'A journey with a title and photos',
                onTap: () => then(() => showWriteSheet(context)),
              ),
              _CreateOption(
                icon: Icons.notes_rounded,
                title: 'Note',
                subtitle: 'A quick thought or tip, with one photo if you like',
                onTap: () =>
                    then(() => showWriteSheet(context, kind: EntryKind.note)),
              ),
              _CreateOption(
                icon: Icons.mail_outline_rounded,
                title: 'Invite post',
                subtitle: 'Invite friends to a gathering or expedition',
                onTap: () => then(() => showInviteComposer(context)),
              ),
              _CreateOption(
                icon: Icons.add_location_alt_outlined,
                title: 'Pin on the map',
                subtitle: 'Drop your story where it happened',
                onTap: () => then(AppStore.instance.startPinning),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CreateOption extends StatelessWidget {
  const _CreateOption({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            IconTile(icon, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: OdysseyType.sans(
                      15,
                      color: AppColors.ink,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: OdysseyType.sans(12.5, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

/// After posting: a little bump, then to Moments if it was shared, or to
/// the journal if it was kept private.
void _posted(BuildContext context, String message, {bool shared = true}) {
  HapticFeedback.mediumImpact();
  AppStore.instance.tab.value = shared ? 0 : 3;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

List<String> _paragraphs(String text) => text
    .split(RegExp(r'\n\s*\n'))
    .map((p) => p.trim())
    .where((p) => p.isNotEmpty)
    .toList();

typedef _Fields = List<TextEditingController>;

/// Frame shared by the composers: a title, fields and a Post button that
/// wakes up once there is something to post. It owns the fields'
/// controllers, so they live exactly as long as the sheet.
Future<void> _showComposer(
  BuildContext context, {
  required String title,
  required int fieldCount,
  required List<Widget> Function(_Fields fields, VoidCallback refresh) build,
  required bool Function(_Fields fields) ready,
  required void Function(_Fields fields) onPost,
  String Function()? action,
  List<String> initial = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ComposerSheet(
      title: title,
      fieldCount: fieldCount,
      build: build,
      ready: ready,
      onPost: onPost,
      action: action ?? () => 'Post',
      initial: initial,
    ),
  );
}

class _ComposerSheet extends StatefulWidget {
  const _ComposerSheet({
    required this.title,
    required this.fieldCount,
    required this.build,
    required this.ready,
    required this.onPost,
    required this.action,
    required this.initial,
  });

  final String title;
  final int fieldCount;
  final List<Widget> Function(_Fields fields, VoidCallback refresh) build;
  final bool Function(_Fields fields) ready;
  final void Function(_Fields fields) onPost;

  /// The label on the button: "Post", or "Save" for a private entry.
  final String Function() action;

  /// Text the fields start with, in order.
  final List<String> initial;

  @override
  State<_ComposerSheet> createState() => _ComposerSheetState();
}

class _ComposerSheetState extends State<_ComposerSheet> {
  late final _Fields _fields = List.generate(
    widget.fieldCount,
    (i) => TextEditingController(
      text: i < widget.initial.length ? widget.initial[i] : null,
    ),
  );

  void _refresh() {
    // Photo picking finishes after a pause; the sheet may be gone by then.
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = widget.ready(_fields);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: OdysseyType.sans(
                        20,
                        color: AppColors.ink,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      disabledBackgroundColor: AppColors.line,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: ready
                        ? () {
                            // Read the fields before the sheet goes.
                            widget.onPost(_fields);
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.action(),
                        key: ValueKey(widget.action()),
                        style: OdysseyType.sans(
                          14,
                          color: ready ? Colors.white : AppColors.muted,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...widget.build(_fields, _refresh),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Share to Moments" on or off. Off keeps it in your journal only.
class _ShareSwitch extends StatelessWidget {
  const _ShareSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      color: value ? AppColors.sage : AppColors.card,
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              value ? Icons.public : Icons.lock_outline,
              key: ValueKey(value),
              size: 20,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share to Moments',
                  style: OdysseyType.sans(
                    14.5,
                    color: AppColors.ink,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  value
                      ? 'Your circle sees it. It stays in your journal too.'
                      : 'Only you can see it, in your journal.',
                  style: OdysseyType.sans(12, color: AppColors.body),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: AppColors.ink,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Write a story or a note. Both are kept in your journal, and posted to
/// Moments too unless you keep them as a private draft.
///
/// A story needs a title and at least one photo, and can have several. A
/// note can have one photo, or none. Written [from] a plan you've been on,
/// the title and place start filled in and the entry is linked to the plan.
Future<void> showWriteSheet(
  BuildContext context, {
  EntryKind kind = EntryKind.story,
  bool share = true,
  bool chooseKind = false,
  PlanItem? from,
}) {
  final store = AppStore.instance;
  var current = kind;
  var shared = share;
  var storyPhotos = <Photo>[];
  Photo? notePhoto;
  bool isStory() => current == EntryKind.story;

  return _showComposer(
    context,
    title: from != null
        ? 'Write about it'
        : (chooseKind ? 'Journal entry' : (isStory() ? 'Story' : 'Note')),
    fieldCount: 3,
    initial: [from?.title ?? '', from?.place ?? '', ''],
    action: () => shared ? 'Post' : 'Save draft',
    ready: (f) =>
        f[2].text.trim().isNotEmpty &&
        (!isStory() || (f[0].text.trim().isNotEmpty && storyPhotos.isNotEmpty)),
    build: (f, refresh) => [
      if (chooseKind) ...[
        _KindToggle(
          value: current,
          onChanged: (k) {
            current = k;
            refresh();
          },
        ),
        const SizedBox(height: 16),
      ],
      if (isStory()) ...[
        Row(
          children: [
            Text('PHOTOS', style: OdysseyType.caps(10)),
            const SizedBox(width: 8),
            Text(
              storyPhotos.isEmpty
                  ? 'At least one'
                  : '${storyPhotos.length} added',
              style: OdysseyType.sans(
                11.5,
                color: storyPhotos.isEmpty ? AppColors.alert : AppColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        PhotoStrip(
          photos: storyPhotos,
          onChanged: (photos) {
            storyPhotos = photos;
            refresh();
          },
        ),
      ] else ...[
        Row(
          children: [
            Text('PHOTO', style: OdysseyType.caps(10)),
            const SizedBox(width: 8),
            Text(
              'Optional · one only',
              style: OdysseyType.sans(11.5, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        PhotoSlot(
          photo: notePhoto,
          onChanged: (photo) {
            notePhoto = photo;
            refresh();
          },
        ),
      ],
      const SizedBox(height: 16),
      if (isStory()) ...[
        SoftField(
          controller: f[0],
          label: 'Title',
          hint: 'The Fog Does Not Lift at Mã Pí Lèng',
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => refresh(),
        ),
        const SizedBox(height: 12),
      ],
      SoftField(
        controller: f[1],
        label: 'Where',
        hint: 'Hà Giang, Vietnam',
        icon: Icons.place_outlined,
        textCapitalization: TextCapitalization.words,
      ),
      const SizedBox(height: 12),
      SoftField(
        controller: f[2],
        label: isStory() ? 'Your story' : 'Your note',
        hint: isStory()
            ? 'Start with the moment you remember first…'
            : "What's happening on the road?",
        minLines: isStory() ? 6 : 4,
        maxLines: 12,
        onChanged: (_) => refresh(),
      ),
      const SizedBox(height: 12),
      _ShareSwitch(
        value: shared,
        onChanged: (v) {
          shared = v;
          refresh();
        },
      ),
    ],
    onPost: (f) {
      final title = f[0].text.trim();
      final place = f[1].text.trim();
      store.write(
        kind: current,
        title: isStory() && title.isNotEmpty ? title : null,
        paragraphs: _paragraphs(f[2].text),
        place: place.isEmpty
            ? (isStory() ? 'Southeast Asia' : 'On the road')
            : place,
        photos: isStory() ? storyPhotos : [?notePhoto],
        share: shared,
        from: from,
      );
      _posted(
        context,
        shared
            ? (isStory() ? 'Your story is live.' : 'Posted to Moments.')
            : 'Saved to your journal as a private draft.',
        shared: shared,
      );
    },
  );
}

/// Story or Note, for a journal entry.
class _KindToggle extends StatelessWidget {
  const _KindToggle({required this.value, required this.onChanged});

  final EntryKind value;
  final ValueChanged<EntryKind> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option(EntryKind kind, String hint) {
      final on = kind == value;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (on) return;
            HapticFeedback.selectionClick();
            onChanged(kind);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: on ? AppColors.ink : AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: on ? AppColors.ink : AppColors.line),
            ),
            child: Row(
              children: [
                Icon(
                  kind.icon,
                  size: 18,
                  color: on ? Colors.white : AppColors.ink,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kind.label,
                        style: OdysseyType.sans(
                          14,
                          color: on ? Colors.white : AppColors.ink,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        hint,
                        style: OdysseyType.sans(
                          11,
                          color: on ? Colors.white70 : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        option(EntryKind.story, 'Title + photos'),
        const SizedBox(width: 8),
        option(EntryKind.note, 'Text, one photo'),
      ],
    );
  }
}

Future<void> showInviteComposer(BuildContext context, {String? eventId}) {
  final store = AppStore.instance;
  final upcoming = Sample.events
      .where((e) => !e.start.isBefore(Sample.today))
      .toList();
  var selected = eventId ?? upcoming.first.id;
  return _showComposer(
    context,
    title: 'Invite post',
    fieldCount: 1,
    ready: (_) => true,
    build: (f, refresh) => [
      Text(
        'Which event?',
        style: OdysseyType.sans(
          12.5,
          color: AppColors.muted,
          weight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      for (final e in upcoming)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            padding: const EdgeInsets.all(10),
            color: e.id == selected ? AppColors.sage : AppColors.card,
            onTap: () {
              selected = e.id;
              refresh();
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: PhotoImage(e.photo, width: 44),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        style: OdysseyType.sans(
                          14,
                          color: AppColors.ink,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${dayLabel(e.start)} · ${e.place}',
                        style: OdysseyType.sans(12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Icon(
                  e.id == selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: e.id == selected ? AppColors.ink : AppColors.muted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 6),
      SoftField(
        controller: f[0],
        hint: 'Add a note — why should they come?',
        minLines: 2,
        maxLines: 4,
      ),
    ],
    onPost: (f) {
      final event = store.event(selected);
      final note = f[0].text.trim();
      store.addPost(
        InvitePost(
          id: store.newId('post'),
          authorId: 'me',
          ago: 'Just now',
          eventId: selected,
          note: note.isEmpty ? 'Come along to ${event.title}!' : note,
        ),
      );
      _posted(context, 'Invite posted to your feed.');
    },
  );
}
