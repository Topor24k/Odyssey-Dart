import 'package:flutter/material.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../data/sample.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/scene.dart';
import '../app_shell.dart';
import '../routes.dart';

/// Find wayfarers to travel with, add them, and see who's already in your
/// circle.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _store = AppStore.instance;
  final _search = TextEditingController();
  int _tab = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Person p) {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return '${p.name} ${p.base} ${p.style} ${p.handle}'.toLowerCase().contains(
      q,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final friends = Sample.people
            .where((p) => _store.statusOf(p.id) == FriendStatus.friends)
            .toList();
        final others = Sample.people
            .where((p) => _store.statusOf(p.id) != FriendStatus.friends)
            .toList();
        final suggested = [...others]
          ..sort((a, b) => b.mutuals.compareTo(a.mutuals));
        final listed = (_tab == 0 ? Sample.people : friends)
            .where(_matches)
            .toList();
        final searching = _search.text.trim().isNotEmpty;

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
                      ScreenHeader(
                        title: 'Community',
                        subtitle: 'Find your people on the road.',
                        trailing: GestureDetector(
                          onTap: () => openProfile(context, _store.me),
                          child: Avatar(_store.me, size: 44),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SoftField(
                        controller: _search,
                        hint: 'Search by name, place or travel style',
                        icon: Icons.search,
                        textCapitalization: TextCapitalization.none,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      Segmented(
                        options: ['Discover', 'Friends (${friends.length})'],
                        selected: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_tab == 0 && !searching && suggested.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: SectionHeader(
                    'Fellow wayfarers',
                    trailingText: 'Suggested',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 236,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: suggested.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) =>
                        _SuggestionCard(person: suggested[i]),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: SectionHeader(
                  searching
                      ? 'Results'
                      : (_tab == 0 ? 'All wayfarers' : 'Your friends'),
                  trailingText: '${listed.length}',
                ),
              ),
            ),
            if (listed.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Center(
                    child: Musing(
                      _tab == 1 && !searching
                          ? 'No companions yet —\nthe road is long, say hello.'
                          : 'Nobody by that name…\nyet.',
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: listed.length,
                  itemBuilder: (context, i) => _PersonRow(person: listed[i]),
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: navClearance(context))),
          ],
        );
      },
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => openProfile(context, person),
        child: Column(
          children: [
            SizedBox(
              height: 92,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Scene(person.cover, person.name.length),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -26,
                    child: Center(
                      child: Avatar(person, size: 56, border: AppColors.card),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Text(
                    person.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OdysseyType.sans(
                      14,
                      color: AppColors.ink,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    person.mutuals > 0
                        ? '${person.mutuals} mutual friends'
                        : person.style,
                    style: OdysseyType.sans(11.5, color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),
                  FriendButton(person, compact: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => openProfile(context, person),
      child: Row(
        children: [
          Avatar(person, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.sans(
                    14.5,
                    color: AppColors.ink,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${person.style} · ${person.base}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.sans(12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FriendButton(person, compact: true),
        ],
      ),
    );
  }
}
