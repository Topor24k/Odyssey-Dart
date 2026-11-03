import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../theme/odyssey_theme.dart';
import '../widgets/kit.dart';
import 'community/community_screen.dart';
import 'compose_sheet.dart';
import 'events/events_screen.dart';
import 'home/home_screen.dart';
import 'map/map_screen.dart';
import 'schedule/schedule_screen.dart';

/// Space to leave at the bottom of a tab so content clears the floating
/// navigation bar.
double navClearance(BuildContext context) =>
    104 + MediaQuery.paddingOf(context).bottom;

/// The signed-in app: Home, Schedule, Map, Community and Events behind a
/// floating pill navigation bar, with a create button beside it.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    ('Home', Icons.home_outlined, Icons.home_rounded),
    ('Schedule', Icons.calendar_today_outlined, Icons.calendar_today_rounded),
    ('Map', Icons.map_outlined, Icons.map_rounded),
    ('Community', Icons.people_outline_rounded, Icons.people_rounded),
    ('Events', Icons.event_note_outlined, Icons.event_note_rounded),
  ];

  final _store = AppStore.instance;
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 1,
  );
  late int _index = _store.tab.value;

  @override
  void initState() {
    super.initState();
    _store.tab.addListener(_onTab);
  }

  void _onTab() {
    if (_store.tab.value == _index) return;
    setState(() => _index = _store.tab.value);
    _fade.forward(from: 0);
  }

  @override
  void dispose() {
    _store.tab.removeListener(_onTab);
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.canvas,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            FadeTransition(
              opacity: CurvedAnimation(parent: _fade, curve: Curves.easeOut),
              child: IndexedStack(
                index: _index,
                children: const [
                  HomeScreen(),
                  ScheduleScreen(),
                  MapScreen(),
                  CommunityScreen(),
                  EventsScreen(),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14 + MediaQuery.paddingOf(context).bottom,
              child: Row(
                children: [
                  Expanded(
                    child: _NavPill(
                      tabs: _tabs,
                      index: _index,
                      onSelect: (i) {
                        HapticFeedback.selectionClick();
                        _store.tab.value = i;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CreateButton(onTap: () => showCreateSheet(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.tabs,
    required this.index,
    required this.onSelect,
  });

  final List<(String, IconData, IconData)> tabs;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(31),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < tabs.length; i++)
            Semantics(
              label: tabs[i].$1,
              selected: i == index,
              button: true,
              child: Tooltip(
                message: tabs[i].$1,
                child: InkResponse(
                  onTap: () => onSelect(i),
                  radius: 28,
                  child: SizedBox(
                    width: 48,
                    height: 62,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == index ? tabs[i].$3 : tabs[i].$2,
                          size: 23,
                          color: i == index ? AppColors.ink : AppColors.muted,
                        ),
                        const SizedBox(height: 5),
                        AnimatedScale(
                          scale: i == index ? 1 : 0,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutBack,
                          child: const Diamond(size: 5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Create',
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: AppColors.ink,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            // A fine brass ring inside the disc, like a compass bezel.
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brassLight.withValues(alpha: 0.55),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
