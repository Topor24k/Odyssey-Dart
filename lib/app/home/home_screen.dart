import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../data/sample.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/scene.dart';
import '../app_shell.dart';
import '../compose_sheet.dart';
import '../routes.dart';
import 'post_cards.dart';

/// The social home: a greeting, your next adventure, and a feed of story,
/// text and invite posts from your circle.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = AppStore.instance;
  int _feed = 0;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 18) return 'Good afternoon,';
    return 'Good evening,';
  }

  bool _inFeed(Post post) =>
      _feed == 0 ||
      post.authorId == 'me' ||
      _store.statusOf(post.authorId) == FriendStatus.friends;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final posts = _store.posts.where(_inFeed).toList();
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          RoundIconButton(
                            icon: Icons.notifications_none_rounded,
                            tooltip: 'Notifications',
                            badge: true,
                            filled: false,
                            onTap: () => _showNotifications(context),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => openProfile(context, _store.me),
                            child: Avatar(_store.me, size: 44),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        _greeting.toUpperCase(),
                        style: OdysseyType.subtitle(
                          14,
                          color: AppColors.brass,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_store.userName}.',
                        style: OdysseyType.display(
                          46,
                          color: AppColors.ink,
                          weight: FontWeight.w600,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Trace Southeast Asia one journey at a time.',
                        style: OdysseyType.display(
                          17,
                          italic: true,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _NextAdventure(),
                      const SizedBox(height: 18),
                      _ShareBox(me: _store.me),
                      const SizedBox(height: 26),
                      SectionHeader(
                        'Dispatches',
                        trailingText: '${posts.length} posts',
                      ),
                      const SizedBox(height: 10),
                      Segmented(
                        options: const ['For you', 'Friends'],
                        selected: _feed,
                        onChanged: (i) => setState(() => _feed = i),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: posts.length,
                itemBuilder: (context, i) => PostCard(posts[i]),
                separatorBuilder: (_, _) => const SizedBox(height: 14),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 26, 24, navClearance(context)),
                child: const Column(
                  children: [
                    OrnamentRule(),
                    SizedBox(height: 14),
                    Musing(
                      'For those who seek the journey\n'
                      'as much as the destination.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNotifications(BuildContext context) {
    final people = Sample.people;
    final items = [
      (people[0], 'invited you to Hà Giang High Pass Ride', '1h'),
      (people[6], 'liked your story', '3h'),
      (people[5], 'accepted your friend request', 'Yesterday'),
      (people[4], 'is going to Angkor Dawn Photo Walk', '2d'),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: OdysseyType.sans(
                  20,
                  color: AppColors.ink,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final (person, what, ago) in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Avatar(person, size: 38),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${person.firstName} ',
                                style: OdysseyType.sans(
                                  14,
                                  color: AppColors.ink,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: what,
                                style: OdysseyType.sans(
                                  14,
                                  color: AppColors.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        ago,
                        style: OdysseyType.sans(12, color: AppColors.muted),
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
}

/// Your next trip as a field-journal entry: the route over its scene, with
/// telemetry and how ready you are.
class _NextAdventure extends StatelessWidget {
  const _NextAdventure();

  @override
  Widget build(BuildContext context) {
    final start = Sample.at(2, 8);
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 172,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Scene(SceneMotif.karst, 41),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xEB141D15), Color(0x40141D15)],
                  stops: [0.2, 1],
                ),
              ),
            ),
            const ContourPatch(seed: 9, color: Colors.white, opacity: 0.12),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => AppStore.instance.tab.value = 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const FieldTag(
                            'Next expedition',
                            color: AppColors.brassLight,
                          ),
                          const Spacer(),
                          Text(
                            relativeDay(start).toUpperCase(),
                            style: OdysseyType.mono(
                              10,
                              color: Colors.white70,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hà Giang Loop',
                        style: OdysseyType.display(
                          32,
                          color: Colors.white,
                          weight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '4 DAYS · 350 KM · ▲ 1,600 M',
                        style: OdysseyType.mono(
                          10.5,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Expanded(
                            child: ThinProgress(
                              0.6,
                              color: AppColors.brassLight,
                              track: Colors.white24,
                              height: 3,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'PREP 60%',
                            style: OdysseyType.mono(
                              10,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Share a journey…" with quick buttons for each kind of post.
class _ShareBox extends StatelessWidget {
  const _ShareBox({required this.me});

  final Person me;

  @override
  Widget build(BuildContext context) {
    Widget chip(IconData icon, String label, VoidCallback onTap) => Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.body),
              const SizedBox(width: 6),
              Text(
                label,
                style: OdysseyType.sans(
                  13,
                  color: AppColors.body,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Column(
        children: [
          InkWell(
            onTap: () => showCreateSheet(context),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Avatar(me, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Share a journey, a thought or an invite…',
                    style: OdysseyType.sans(14, color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Row(
            children: [
              chip(
                Icons.auto_stories_outlined,
                'Story',
                () => showStoryComposer(context),
              ),
              chip(
                Icons.notes_rounded,
                'Text',
                () => showTextComposer(context),
              ),
              chip(
                Icons.mail_outline_rounded,
                'Invite',
                () => showInviteComposer(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
