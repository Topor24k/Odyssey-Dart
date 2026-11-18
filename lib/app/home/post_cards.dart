import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/motion.dart';
import '../../widgets/photo.dart';
import '../../widgets/photo_tools.dart';
import '../routes.dart';

/// One feed entry, drawn for its kind.
class PostCard extends StatelessWidget {
  const PostCard(this.post, {super.key});

  final Post post;

  @override
  Widget build(BuildContext context) => switch (post) {
    StoryPost p => _StoryCard(p),
    TextPost p => _TextCard(p),
    InvitePost p => _InviteCard(p),
  };
}

class _Byline extends StatelessWidget {
  const _Byline({required this.post, this.place});

  final Post post;
  final String? place;

  @override
  Widget build(BuildContext context) {
    final author = AppStore.instance.person(post.authorId);
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            openProfile(context, author);
          },
          child: Avatar(author, size: 34),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OdysseyType.sans(
                  13.5,
                  color: AppColors.ink,
                  weight: FontWeight.w600,
                ),
              ),
              Text(
                (place == null ? post.ago : '${post.ago} · $place'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OdysseyType.sans(11.5, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions(this.post);

  final Post post;

  void _soon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what are coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final liked = store.isLiked(post.id);
        final saved = store.isSaved(post.id);
        return Row(
          children: [
            _Action(
              icon: liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? AppColors.alert : AppColors.body,
              label: '${store.likesOf(post)}',
              tooltip: liked ? 'Unlike' : 'Like',
              trigger: liked,
              onTap: () {
                HapticFeedback.lightImpact();
                store.toggleLike(post.id);
              },
            ),
            _Action(
              icon: Icons.chat_bubble_outline,
              label: '${post.comments}',
              tooltip: 'Comments',
              onTap: () => _soon(context, 'Comments'),
            ),
            const Spacer(),
            _Action(
              icon: saved ? Icons.bookmark : Icons.bookmark_border,
              color: saved ? AppColors.ink : AppColors.body,
              tooltip: saved ? 'Unsave' : 'Save',
              trigger: saved,
              onTap: () {
                HapticFeedback.selectionClick();
                store.toggleSave(post.id);
              },
            ),
            _Action(
              icon: Icons.ios_share,
              tooltip: 'Share',
              onTap: () => _soon(context, 'Shares'),
            ),
          ],
        );
      },
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.label,
    this.color = AppColors.body,
    this.trigger,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final String? label;
  final Color color;

  /// The icon bounces when this changes.
  final Object? trigger;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Pop(
                trigger: trigger,
                child: Icon(icon, size: 20, color: color),
              ),
              if (label != null) ...[
                const SizedBox(width: 5),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, a) => SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(a),
                    child: FadeTransition(opacity: a, child: child),
                  ),
                  child: Text(
                    label!,
                    key: ValueKey(label),
                    style: OdysseyType.sans(12.5, color: AppColors.body),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard(this.post);

  final StoryPost post;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => openStory(context, post),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 190,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(tag: 'story-${post.id}', child: PhotoImage(post.photo)),
                Positioned(
                  left: 12,
                  top: 12,
                  child: StatusPill(
                    'Story · ${post.readMinutes} min',
                    icon: Icons.auto_stories_outlined,
                  ),
                ),
                if (post.photos.length > 1)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: StatusPill(
                      '${post.photos.length} photos',
                      icon: Icons.photo_library_outlined,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.place.toUpperCase(), style: OdysseyType.caps(9.5)),
                const SizedBox(height: 6),
                Text(
                  post.title,
                  style: OdysseyType.display(
                    23,
                    color: AppColors.ink,
                    weight: FontWeight.w500,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.sans(
                    13.5,
                    color: AppColors.body,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                _Byline(post: post),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
            child: _Actions(post),
          ),
        ],
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard(this.post);

  final TextPost post;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Byline(post: post, place: post.place),
          const SizedBox(height: 12),
          Text(
            post.text,
            style: OdysseyType.display(19, color: AppColors.ink, height: 1.4),
          ),
          if (post.photo != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => showPhotoViewer(context, [post.photo!]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: PhotoImage(post.photo!),
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Transform.translate(
            offset: const Offset(-8, 0),
            child: _Actions(post),
          ),
        ],
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  const _InviteCard(this.post);

  final InvitePost post;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final event = store.event(post.eventId);
    final host = store.person(post.authorId);
    final going = [
      store.person(event.hostId),
      for (final id in event.attendeeIds) store.person(id),
    ];
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => openEvent(context, event),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'event-${event.id}-${post.id}',
                  child: PhotoImage(event.photo),
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: StatusPill(
                    '${event.kind.label} · ${stampLabel(event.start)}',
                    icon: event.kind.icon,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INVITE FROM ${host.firstName.toUpperCase()}',
                  style: OdysseyType.caps(9.5, color: AppColors.sageInk),
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  style: OdysseyType.display(
                    22,
                    color: AppColors.ink,
                    weight: FontWeight.w500,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.note,
                  style: OdysseyType.sans(
                    13.5,
                    color: AppColors.body,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    AvatarStack(going, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: store,
                        builder: (context, _) => Text(
                          '${store.goingCount(event)} going · ${event.place}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OdysseyType.sans(12, color: AppColors.muted),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    JoinButton(event),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
            child: _Actions(post),
          ),
        ],
      ),
    );
  }
}
