import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/odyssey_store.dart';
import '../theme/odyssey_theme.dart';
import 'circle/circle_screen.dart';
import 'gatherings/gatherings_screen.dart';
import 'map/map_screen.dart';
import 'routes/routes_screen.dart';
import 'stories/chronicles_screen.dart';

/// The five pillars — Chronicles, Routes, Map, Circle, Gatherings — behind a
/// field-journal tab bar. Tabs keep their state and fade as you switch.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  static const _tabs = [
    ('Chronicles', Icons.auto_stories_outlined),
    ('Routes', Icons.route_outlined),
    ('Map', Icons.explore_outlined),
    ('Circle', Icons.diversity_3_outlined),
    ('Gatherings', Icons.festival_outlined),
  ];

  final _store = OdysseyStore.instance;
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
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
        systemNavigationBarColor: OdysseyColors.parchment,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: FadeTransition(
          opacity: CurvedAnimation(parent: _fade, curve: Curves.easeOut),
          child: IndexedStack(
            index: _index,
            children: const [
              ChroniclesScreen(),
              RoutesScreen(),
              MapScreen(),
              CircleScreen(),
              GatheringsScreen(),
            ],
          ),
        ),
        bottomNavigationBar: _JournalTabBar(
          tabs: _tabs,
          index: _index,
          onSelect: (i) {
            HapticFeedback.selectionClick();
            _store.tab.value = i;
          },
        ),
      ),
    );
  }
}

class _JournalTabBar extends StatelessWidget {
  const _JournalTabBar({
    required this.tabs,
    required this.index,
    required this.onSelect,
  });

  final List<(String, IconData)> tabs;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: OdysseyColors.parchment,
        border: Border(top: BorderSide(color: OdysseyColors.rule, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < tabs.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == index,
                    button: true,
                    label: tabs[i].$1,
                    child: InkResponse(
                      onTap: () => onSelect(i),
                      radius: 36,
                      child: _TabItem(
                        label: tabs[i].$1,
                        icon: tabs[i].$2,
                        active: i == index,
                      ),
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

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.active,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: active ? 1 : 0,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(width: 5, height: 5, color: OdysseyColors.brass),
          ),
        ),
        const SizedBox(height: 5),
        AnimatedSlide(
          offset: Offset(0, active ? -0.06 : 0),
          duration: const Duration(milliseconds: 220),
          child: Icon(
            icon,
            size: 22,
            color: active ? OdysseyColors.forest : OdysseyColors.inkSoft,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: OdysseyType.mono(
            8,
            color: active ? OdysseyColors.brass : OdysseyColors.inkSoft,
            letterSpacing: 1.1,
            weight: active ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
