import 'package:flutter/material.dart';

import '../../data/atlas.dart';
import '../../data/geo.dart';
import '../../data/models.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/journal.dart';
import '../../widgets/landscape_plate.dart';
import '../navigation.dart';

/// Pillar two: field-verified route plans.
class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  static const _filters = ['All', 'Overland', 'Water', 'On foot'];
  int _filter = 0;

  bool _matches(RoutePlan r) => switch (_filter) {
        1 => r.mode == TravelMode.motorbike,
        2 => r.mode.onWater,
        3 => r.mode == TravelMode.trek,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final routes = Atlas.routes.where(_matches).toList();
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: PageHeader(
            kicker: 'Verified tracks',
            title: 'Route Plans',
            subtitle:
                'Turn-by-turn blueprints for slow and overland exploration — '
                'every waypoint ridden, sailed or walked by its keeper.',
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FilterRow(
              options: _filters,
              selected: _filter,
              icons: const [
                null,
                Icons.two_wheeler,
                Icons.sailing,
                Icons.hiking,
              ],
              onSelected: (i) => setState(() => _filter = i),
            ),
          ),
        ),
        SliverList.builder(
          itemCount: routes.length,
          itemBuilder: (context, i) => _RouteCard(route: routes[i]),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.route});

  final RoutePlan route;

  @override
  Widget build(BuildContext context) {
    final stops = Atlas.waypointsOf(route);
    final peak = stops.map((w) => w.elevationM).reduce((a, b) => a > b ? a : b);
    final surfaces = {for (final d in route.days) d.surface};
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
      child: Material(
        color: OdysseyColors.parchment,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: OdysseyColors.rule),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openRoute(context, route),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 170,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'route-${route.id}',
                      child: LandscapePlate(route.plate),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child:
                          PlateBadge(route.mode.label, icon: route.mode.icon),
                    ),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: PlateBadge(
                        '${route.days.length} ${route.days.length == 1 ? 'day' : 'days'}',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Kicker('${route.country} · ${route.region}'),
                    const SizedBox(height: 4),
                    Text(route.name,
                        style: OdysseyType.display(25,
                            weight: FontWeight.w600, height: 1.1)),
                    const SizedBox(height: 6),
                    Text(
                      route.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: OdysseyType.prose(15.5,
                          color: OdysseyColors.inkSoft),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _Stat('Distance', '${route.distanceKm} km'),
                        _Stat('Max elev.', formatElevation(peak)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GRADE',
                                  style: OdysseyType.mono(8.5,
                                      letterSpacing: 1.6)),
                              const SizedBox(height: 6),
                              DifficultyMeter(route.difficulty),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final s in surfaces) Tag(s.label, icon: s.icon),
                      ],
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

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: OdysseyType.mono(8.5, letterSpacing: 1.6)),
          const SizedBox(height: 2),
          Text(value,
              style: OdysseyType.display(19, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}
