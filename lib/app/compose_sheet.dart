import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../data/sample.dart';
import '../theme/odyssey_theme.dart';
import '../widgets/kit.dart';
import '../widgets/scene.dart';

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
                'Share the road with your circle.',
                style: OdysseyType.sans(13.5, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              _CreateOption(
                icon: Icons.auto_stories_outlined,
                title: 'Story post',
                subtitle: 'Write about a journey, with a title and cover',
                onTap: () => then(() => showStoryComposer(context)),
              ),
              _CreateOption(
                icon: Icons.notes_rounded,
                title: 'Text post',
                subtitle: 'A quick thought, tip or road update',
                onTap: () => then(() => showTextComposer(context)),
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

void _posted(BuildContext context, String message) {
  AppStore.instance.tab.value = 0;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

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
  });

  final String title;
  final int fieldCount;
  final List<Widget> Function(_Fields fields, VoidCallback refresh) build;
  final bool Function(_Fields fields) ready;
  final void Function(_Fields fields) onPost;

  @override
  State<_ComposerSheet> createState() => _ComposerSheetState();
}

class _ComposerSheetState extends State<_ComposerSheet> {
  late final _Fields _fields = List.generate(
    widget.fieldCount,
    (_) => TextEditingController(),
  );

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
                    child: Text(
                      'Post',
                      style: OdysseyType.sans(
                        14,
                        color: ready ? Colors.white : AppColors.muted,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...widget.build(_fields, () => setState(() {})),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showTextComposer(BuildContext context) {
  final store = AppStore.instance;
  return _showComposer(
    context,
    title: 'Text post',
    fieldCount: 2,
    ready: (f) => f[0].text.trim().isNotEmpty,
    build: (f, refresh) => [
      SoftField(
        controller: f[0],
        hint: 'What\'s happening on the road?',
        minLines: 4,
        maxLines: 8,
        onChanged: (_) => refresh(),
      ),
      const SizedBox(height: 12),
      SoftField(
        controller: f[1],
        hint: 'Where are you? (optional)',
        icon: Icons.place_outlined,
        textCapitalization: TextCapitalization.words,
      ),
    ],
    onPost: (f) {
      final place = f[1].text.trim();
      store.addPost(
        TextPost(
          id: store.newId('post'),
          authorId: 'me',
          ago: 'Just now',
          text: f[0].text.trim(),
          place: place.isEmpty ? null : place,
        ),
      );
      _posted(context, 'Posted to your feed.');
    },
  );
}

Future<void> showStoryComposer(BuildContext context) {
  final store = AppStore.instance;
  return _showComposer(
    context,
    title: 'Story post',
    fieldCount: 3,
    ready: (f) => f[0].text.trim().isNotEmpty && f[2].text.trim().isNotEmpty,
    build: (f, refresh) => [
      SoftField(
        controller: f[0],
        label: 'Title',
        hint: 'The Fog Does Not Lift at Mã Pí Lèng',
        textCapitalization: TextCapitalization.words,
        onChanged: (_) => refresh(),
      ),
      const SizedBox(height: 12),
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
        label: 'Your story',
        hint: 'Start with the moment you remember first…',
        minLines: 6,
        maxLines: 12,
        onChanged: (_) => refresh(),
      ),
    ],
    onPost: (f) {
      final title = f[0].text.trim();
      final place = f[1].text.trim();
      final text = f[2].text.trim();
      final paragraphs = text
          .split(RegExp(r'\n\s*\n'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      final (motif, seed) = store.sceneFor(title);
      final words = text.split(RegExp(r'\s+')).length;
      store.addPost(
        StoryPost(
          id: store.newId('post'),
          authorId: 'me',
          ago: 'Just now',
          title: title,
          excerpt: text.length > 140 ? '${text.substring(0, 140)}…' : text,
          paragraphs: paragraphs,
          place: place.isEmpty ? 'Southeast Asia' : place,
          motif: motif,
          seed: seed,
          readMinutes: math.max(1, (words / 200).ceil()),
        ),
      );
      _posted(context, 'Your story is live.');
    },
  );
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
                    child: Scene(e.motif, e.seed),
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
