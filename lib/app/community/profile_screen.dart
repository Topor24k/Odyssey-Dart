import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../auth/auth_screen.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/scene.dart';
import '../routes.dart';

/// A wayfarer's profile — or yours, with Edit profile and Sign out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.person});

  final Person person;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _store = AppStore.instance;
  int _tab = 0;

  bool get _isMe => widget.person.id == 'me';

  void _soon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what is coming soon.')));
  }

  void _signOut() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: ListenableBuilder(
          listenable: _store,
          builder: (context, _) {
            final person = _isMe ? _store.me : widget.person;
            final stories = _store.posts
                .whereType<StoryPost>()
                .where((p) => p.authorId == person.id)
                .toList();
            final pins = _store.mapStories
                .where((s) => s.authorId == person.id)
                .toList();
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Cover(person: person)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.name,
                          style: OdysseyType.sans(
                            25,
                            color: AppColors.ink,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${person.handle} · ${person.base}',
                          style: OdysseyType.sans(13, color: AppColors.muted),
                        ),
                        const SizedBox(height: 10),
                        StatusPill(
                          person.style,
                          icon: Icons.explore_outlined,
                          background: AppColors.sage,
                          foreground: AppColors.sageInk,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          person.bio,
                          style: OdysseyType.sans(
                            14.5,
                            color: AppColors.body,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        AppCard(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              _Stat('${person.stories}', 'Stories'),
                              _Stat('${person.trips}', 'Trips'),
                              _Stat('${person.friends}', 'Friends'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: _isMe
                              ? [
                                  Expanded(
                                    child: _Button(
                                      label: 'Edit profile',
                                      icon: Icons.edit_outlined,
                                      onTap: () => _soon('Editing profiles'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _Button(
                                      label: 'Sign out',
                                      icon: Icons.logout,
                                      dark: true,
                                      onTap: _signOut,
                                    ),
                                  ),
                                ]
                              : [
                                  FriendButton(person),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _Button(
                                      label: 'Message',
                                      icon: Icons.chat_bubble_outline,
                                      onTap: () => _soon('Messaging'),
                                    ),
                                  ),
                                ],
                        ),
                        const SizedBox(height: 24),
                        Segmented(
                          options: [
                            'Stories (${stories.length})',
                            'Pins (${pins.length})',
                          ],
                          selected: _tab,
                          onChanged: (i) => setState(() => _tab = i),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                if ((_tab == 0 ? stories.length : pins.length) == 0)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Center(
                        child: Musing(
                          _isMe
                              ? 'Your first story\nis out there.'
                              : 'Nothing here yet.',
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: _tab == 0 ? stories.length : pins.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _tab == 0
                          ? _WorkTile(
                              motif: stories[i].motif,
                              seed: stories[i].seed,
                              title: stories[i].title,
                              subtitle:
                                  '${stories[i].place} · '
                                  '${stories[i].readMinutes} min read',
                              onTap: () => openStory(context, stories[i]),
                            )
                          : _WorkTile(
                              motif: pins[i].motif,
                              seed: pins[i].seed,
                              title: pins[i].title,
                              subtitle: '${pins[i].place} · ${pins[i].ago}',
                            ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 200 + top + 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 200 + top,
            child: Scene(person.cover, person.name.length + 7),
          ),
          Positioned(
            left: 12,
            top: top + 8,
            child: RoundIconButton(
              icon: Icons.arrow_back,
              tooltip: 'Back',
              size: 42,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 0,
            child: Avatar(person, size: 96, border: AppColors.canvas),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: OdysseyType.sans(
              20,
              color: AppColors.ink,
              weight: FontWeight.w700,
            ),
          ),
          Text(label, style: OdysseyType.sans(12, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.icon,
    required this.onTap,
    this.dark = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.ink;
    return Material(
      color: dark ? AppColors.ink : AppColors.card,
      shape: StadiumBorder(
        side: dark ? BorderSide.none : const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: OdysseyType.sans(14, color: fg, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkTile extends StatelessWidget {
  const _WorkTile({
    required this.motif,
    required this.seed,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final SceneMotif motif;
  final int seed;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(width: 64, height: 64, child: Scene(motif, seed)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.sans(
                    14.5,
                    color: AppColors.ink,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.sans(12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}
