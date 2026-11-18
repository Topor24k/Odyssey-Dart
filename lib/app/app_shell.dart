import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../theme/odyssey_theme.dart';
import '../widgets/motion.dart';
import 'compose_sheet.dart';
import 'events/events_screen.dart';
import 'home/home_screen.dart';
import 'journal/journal_screen.dart';
import 'map/map_screen.dart';
import 'schedule/schedule_screen.dart';

const _barHeight = 64.0;

/// Space to leave at the bottom of a tab so content clears the navigation
/// bar and the create button.
double navClearance(BuildContext context) =>
    _barHeight + 40 + MediaQuery.paddingOf(context).bottom;

/// The signed-in app: Home, Schedule, Map, Journal and Events behind a
/// labelled navigation bar, with a create button floating above it.
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
    ('Map', Icons.place_outlined, Icons.place_rounded),
    ('Journal', Icons.menu_book_outlined, Icons.menu_book_rounded),
    ('Events', Icons.festival_outlined, Icons.festival_rounded),
  ];

  final _store = AppStore.instance;
  late final AnimationController _switch = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: 1,
  );
  late int _index = _store.tab.value;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _store.tab.addListener(_onTab);
  }

  void _onTab() {
    if (_store.tab.value == _index) return;
    setState(() => _index = _store.tab.value);
    _switch.forward(from: 0);
  }

  Future<void> _create() async {
    HapticFeedback.lightImpact();
    setState(() => _creating = true);
    await showCreateSheet(context);
    if (mounted) setState(() => _creating = false);
  }

  @override
  void dispose() {
    _store.tab.removeListener(_onTab);
    _switch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final curve = CurvedAnimation(parent: _switch, curve: Curves.easeOutCubic);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.card,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: curve,
              builder: (context, child) => Opacity(
                opacity: curve.value,
                child: Transform.translate(
                  offset: Offset(0, (1 - curve.value) * 12),
                  child: child,
                ),
              ),
              child: IndexedStack(
                index: _index,
                children: const [
                  HomeScreen(),
                  ScheduleScreen(),
                  MapScreen(),
                  JournalScreen(),
                  EventsScreen(),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _NavBar(
                tabs: _tabs,
                index: _index,
                bottomInset: bottom,
                onSelect: (i) {
                  if (i == _index) return;
                  HapticFeedback.selectionClick();
                  _store.tab.value = i;
                },
              ),
            ),
            Positioned(
              right: 18,
              bottom: _barHeight + bottom + 14,
              child: _CreateButton(open: _creating, onTap: _create),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.tabs,
    required this.index,
    required this.bottomInset,
    required this.onSelect,
  });

  final List<(String, IconData, IconData)> tabs;
  final int index;
  final double bottomInset;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _barHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D1D3C37),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: Semantics(
                label: tabs[i].$1,
                selected: i == index,
                button: true,
                child: InkResponse(
                  onTap: () => onSelect(i),
                  radius: 32,
                  child: _NavItem(
                    label: tabs[i].$1,
                    icon: i == index ? tabs[i].$3 : tabs[i].$2,
                    active: i == index,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.ink : AppColors.muted;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSlide(
          offset: Offset(0, active ? -0.08 : 0),
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutBack,
          child: AnimatedScale(
            scale: active ? 1.12 : 1,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            child: Icon(icon, size: 23, color: color),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: OdysseyType.sans(
            10.5,
            color: color,
            weight: active ? FontWeight.w600 : FontWeight.w400,
          ),
          child: Text(label, maxLines: 1, overflow: TextOverflow.fade),
        ),
      ],
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Create',
      child: Press(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x401D3C37),
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
              onTap: onTap,
              child: SizedBox(
                width: 58,
                height: 58,
                child: AnimatedRotation(
                  turns: open ? 0.125 : 0,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  child: const Icon(Icons.add, size: 28, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
