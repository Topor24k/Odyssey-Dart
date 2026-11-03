import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/scene.dart';
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

class _Header extends StatelessWidget {
  const _Header({required this.post, this.place, this.badge});

  final Post post;
  final String? place;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final author = AppStore.instance.person(post.authorId);
    return Row(
      children: [
        GestureDetector(
          onTap: () => openProfile(context, author),
          child: Avatar(author, size: 40),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OdysseyType.sans(
                  14.5,
                  color: AppColors.ink,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                place == null ? post.ago : '${post.ago} · $place',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OdysseyType.sans(12, color: AppColors.muted),
              ),
            ],
          ),
        ),
        ?badge,
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
              tooltip: saved ? 'Unsave' : 'Save',
              onTap: () => store.toggleSave(post.id),
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
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final String? label;
  final Color color;

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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, a) =>
                    ScaleTransition(scale: a, child: child),
                child: Icon(icon, key: ValueKey(icon), size: 20, color: color),
              ),
              if (label != null) ...[
                const SizedBox(width: 5),
                Text(
                  label!,
                  style: OdysseyType.sans(13, color: AppColors.body),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: _Header(
              post: post,
              place: post.place,
              badge: const StatusPill(
                'Story',
                icon: Icons.auto_stories_outlined,
                background: AppColors.tile,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(height: 180, child: Scene(post.motif, post.seed)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: OdysseyType.display(
                    24,
                    color: AppColors.ink,
                    weight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.excerpt,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.sans(
                    14,
                    color: AppColors.body,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Read story · ${post.readMinutes} min',
                  style: OdysseyType.sans(
                    13,
                    color: AppColors.ink,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(post: post, place: post.place),
          const SizedBox(height: 10),
          Text(
            post.text,
            style: OdysseyType.sans(15, color: AppColors.ink, height: 1.5),
          ),
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
    final going = [
      store.person(event.hostId),
      for (final id in event.attendeeIds) store.person(id),
    ];
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            post: post,
            badge: StatusPill(
              'Invite',
              icon: Icons.mail_outline,
              background: AppColors.sage,
              foreground: AppColors.sageInk,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            post.note,
            style: OdysseyType.sans(15, color: AppColors.ink, height: 1.5),
          ),
          const SizedBox(height: 12),
          Material(
            color: AppColors.tile,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => openEvent(context, event),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 66,
                        height: 66,
                        child: Scene(event.motif, event.seed),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${event.kind.label.toUpperCase()} · '
                            '${dayLabel(event.start).toUpperCase()}',
                            style: OdysseyType.sans(
                              10.5,
                              color: AppColors.sageInk,
                              weight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: OdysseyType.sans(
                              14.5,
                              color: AppColors.ink,
                              weight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              AvatarStack(going, size: 22),
                              const SizedBox(width: 6),
                              ListenableBuilder(
                                listenable: store,
                                builder: (context, _) => Text(
                                  '${store.goingCount(event)} going',
                                  style: OdysseyType.sans(
                                    12,
                                    color: AppColors.muted,
                                  ),
                                ),
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
              ),
            ),
          ),
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
