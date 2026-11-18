import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../data/sample.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/motion.dart';
import '../../widgets/photo.dart';
import '../app_shell.dart';
import '../routes.dart';
import 'post_cards.dart';

/// Home: your next trip with its numbers and highlights, then the moments
/// your circle is sharing.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _highlights = [
    ('Quản Bạ', Photos.quanBaValley),
    ('Sủng Là', Photos.dongVanPeaks),
    ('Mã Pí Lèng', Photos.maPiLengRidge),
    ('Nho Quế', Photos.nhoQueGorge),
    ('Du Già', Photos.duGiaFields),
  ];

  final _store = AppStore.instance;
  int _feed = 0;

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
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Wordmark(),
                          const Spacer(),
                          RoundIconButton(
                            icon: Icons.people_outline_rounded,
                            tooltip: 'Community',
                            filled: false,
                            onTap: () => openCommunity(context),
                          ),
                          RoundIconButton(
                            icon: Icons.notifications_none_rounded,
                            tooltip: 'Notifications',
                            badge: true,
                            filled: false,
                            onTap: () => _showNotifications(context),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => openProfile(context, _store.me),
                            child: Avatar(_store.me, size: 40),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Reveal(child: _TripHero()),
                      const SizedBox(height: 12),
                      Reveal(
                        index: 1,
                        child: StatsStrip([
                          (Icons.calendar_today_outlined, '4', 'Days'),
                          (Icons.place_outlined, '7', 'Places'),
                          (
                            Icons.photo_library_outlined,
                            '${_store.posts.length + _store.mapStories.length}',
                            'Moments',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 22),
                      Reveal(
                        index: 2,
                        child: SectionHeader(
                          'Trip Highlights',
                          onAction: () => _store.tab.value = 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Reveal(
                index: 3,
                child: SizedBox(
                  height: 132,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    itemCount: _highlights.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final (name, photo) = _highlights[i];
                      return _Highlight(
                        name: name,
                        photo: photo,
                        onTap: () => _store.tab.value = 2,
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      'Moments',
                      trailingText: '${posts.length} posts',
                    ),
                    const SizedBox(height: 6),
                    Segmented(
                      options: const ['For you', 'Friends'],
                      selected: _feed,
                      onChanged: (i) => setState(() => _feed = i),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: posts.length,
                itemBuilder: (context, i) => Reveal(
                  key: ValueKey(posts[i].id),
                  index: i,
                  child: PostCard(posts[i]),
                ),
                separatorBuilder: (_, _) => const SizedBox(height: 14),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 28, 24, navClearance(context)),
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
                style: OdysseyType.display(
                  26,
                  color: AppColors.ink,
                  weight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < items.length; i++)
                Reveal(
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Avatar(items[i].$1, size: 38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${items[i].$1.firstName} ',
                                  style: OdysseyType.sans(
                                    14,
                                    color: AppColors.ink,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: items[i].$2,
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
                          items[i].$3,
                          style: OdysseyType.sans(12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The big scenic card: where you're going next, and when.
class _TripHero extends StatelessWidget {
  const _TripHero();

  @override
  Widget build(BuildContext context) {
    final start = Sample.at(2, 8);
    final end = start.add(const Duration(days: 3));
    return Press(
      child: GestureDetector(
        onTap: () => AppStore.instance.tab.value = 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 210,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const PhotoImage(Photos.haGiangPeak),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00102421), Color(0xCC102421)],
                      stops: [0.35, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: StatusPill(
                    'Next adventure · ${relativeDay(start)}',
                    icon: Icons.near_me_outlined,
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hà Giang Loop',
                        style: OdysseyType.display(
                          34,
                          color: Colors.white,
                          weight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stampLabel(start)} — ${stampLabel(end)}, '
                        '${end.year}',
                        style: OdysseyType.caps(10.5, color: Colors.white70),
                      ),
                    ],
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

class _Highlight extends StatelessWidget {
  const _Highlight({
    required this.name,
    required this.photo,
    required this.onTap,
  });

  final String name;
  final Photo photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Press(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 104,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 92,
                  width: 104,
                  child: PhotoImage(photo, width: 104),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OdysseyType.sans(12.5, color: AppColors.body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
