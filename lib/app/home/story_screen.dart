import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/scene.dart';
import '../routes.dart';

/// A story post, read in full like a newsletter piece.
class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key, required this.story});

  final StoryPost story;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final author = store.person(story.authorId);
    return Scaffold(
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: 320,
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
              actions: [
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: RoundIconButton(
                    icon: store.isSaved(story.id)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    tooltip: 'Save',
                    size: 42,
                    onTap: () => store.toggleSave(story.id),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Scene(story.motif, story.seed),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusPill(
                      story.place,
                      icon: Icons.place_outlined,
                      background: AppColors.tile,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      story.title,
                      style: OdysseyType.display(
                        34,
                        color: AppColors.ink,
                        weight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      story.excerpt,
                      style: OdysseyType.display(
                        19,
                        color: AppColors.body,
                        italic: true,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => openProfile(context, author),
                          child: Avatar(author, size: 42),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                author.name,
                                style: OdysseyType.sans(
                                  14.5,
                                  color: AppColors.ink,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${story.ago} · ${story.readMinutes} min read',
                                style: OdysseyType.sans(
                                  12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (author.id != 'me') FriendButton(author),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 18),
                    for (final p in story.paragraphs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          p,
                          style: OdysseyType.display(
                            19.5,
                            color: AppColors.ink,
                            height: 1.55,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Reaction(
                          icon: store.isLiked(story.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: store.isLiked(story.id)
                              ? AppColors.alert
                              : AppColors.body,
                          label: '${store.likesOf(story)} likes',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            store.toggleLike(story.id);
                          },
                        ),
                        const SizedBox(width: 10),
                        _Reaction(
                          icon: Icons.chat_bubble_outline,
                          label: '${story.comments} comments',
                          onTap: () => ScaffoldMessenger.of(context)
                              .showSnackBar(
                                const SnackBar(
                                  content: Text('Comments are coming soon.'),
                                ),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const OrnamentRule(),
                    const SizedBox(height: 14),
                    const Musing('Go and see it for yourself.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Reaction extends StatelessWidget {
  const _Reaction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.body,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 7),
              Text(label, style: OdysseyType.sans(13, color: AppColors.body)),
            ],
          ),
        ),
      ),
    );
  }
}
