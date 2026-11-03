import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/atlas.dart';
import '../../data/geo.dart';
import '../../data/models.dart';
import '../../data/odyssey_store.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/companion_widgets.dart';
import '../../widgets/elevation_profile.dart';
import '../../widgets/journal.dart';
import '../../widgets/landscape_plate.dart';
import '../navigation.dart';

/// A route plan: elevation profile, the itinerary day by day, logistics for
/// where connectivity ends, waypoints and GPX export.
class RouteScreen extends StatelessWidget {
  const RouteScreen({super.key, required this.route});

  final RoutePlan route;

  (String, IconData) get _supplyLabel => switch (route.mode) {
        TravelMode.motorbike => ('Fuel', Icons.local_gas_station_outlined),
        TravelMode.trek => ('Water', Icons.water_drop_outlined),
        _ => ('Supplies', Icons.inventory_2_outlined),
      };

  @override
  Widget build(BuildContext context) {
    final stops = Atlas.waypointsOf(route);
    final profile = elevationProfile(stops, seed: route.plate.seed);
    final peak = stops.map((w) => w.elevationM).reduce((a, b) => a > b ? a : b);
    final keeper = Atlas.companion(route.keeperId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 300,
            backgroundColor: OdysseyColors.forest,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            automaticallyImplyLeading: false,
            leading: PlateIconButton(
              icon: Icons.arrow_back,
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'route-${route.id}',
                    child: LandscapePlate(route.plate),
                  ),
                  Positioned(
                    left: 22,
                    bottom: 18,
                    child: PlateBadge(route.mode.label, icon: route.mode.icon),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker('${route.country} · ${route.region}'),
                  const SizedBox(height: 6),
                  Text(route.name,
                      style: OdysseyType.display(34,
                          weight: FontWeight.w600, height: 1.06)),
                  const SizedBox(height: 10),
                  Text(route.summary,
                      style: OdysseyType.prose(17.5,
                          italic: true, color: OdysseyColors.inkSoft)),
                  const SizedBox(height: 20),
                  _StatStrip(route: route, peak: peak),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SectionHeading(
              kicker: 'Topography',
              title: 'Elevation profile',
              trailing: 'Drag to scrub',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ElevationProfile(points: profile),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeading(
              kicker: 'Itinerary',
              title: 'Day by day',
              trailing: '${route.days.length} stages',
            ),
          ),
          SliverList.builder(
            itemCount: route.days.length,
            itemBuilder: (context, i) => _DayEntry(
              index: i,
              day: route.days[i],
              last: i == route.days.length - 1,
              supply: _supplyLabel,
            ),
          ),
          const SliverToBoxAdapter(
            child: SectionHeading(
              kicker: 'Reliability in the wild',
              title: 'Logistics',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  InfoLine(icon: route.mode.icon, label: 'Vehicle', value: route.vehicle),
                  InfoLine(icon: Icons.payments_outlined, label: 'Cash', value: route.cash),
                  InfoLine(
                      icon: Icons.signal_cellular_alt,
                      label: 'Signal',
                      value: route.connectivity),
                  InfoLine(
                      icon: Icons.wb_sunny_outlined,
                      label: 'Season',
                      value: route.season),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeading(
              kicker: 'GPX track',
              title: 'Waypoints',
              trailing: '${stops.length} points',
            ),
          ),
          SliverList.builder(
            itemCount: stops.length,
            itemBuilder: (context, i) => _WaypointRow(number: i + 1, waypoint: stops[i]),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
              child: _KeeperCard(keeper: keeper),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: OdysseyColors.parchment,
          border: Border(top: BorderSide(color: OdysseyColors.rule)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: JournalButton(
                    label: 'Open map',
                    icon: Icons.map_outlined,
                    filled: false,
                    onPressed: () =>
                        showOnMap(context, MapFocus.route(route.id)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: JournalButton(
                    label: 'Export GPX',
                    icon: Icons.file_download_outlined,
                    onPressed: () => _showGpx(context, stops),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGpx(BuildContext context, List<Waypoint> stops) {
    final gpx = buildGpx(route, stops);
    final fileName =
        '${route.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}.gpx';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Kicker('GPX 1.1 · offline navigation'),
              const SizedBox(height: 4),
              Text(fileName,
                  style: OdysseyType.display(24, weight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(
                'Verified coordinates for ${stops.length} waypoints. Paste into '
                'OsmAnd, Organic Maps or your GPS before you lose signal.',
                style: OdysseyType.prose(15, color: OdysseyColors.inkSoft),
              ),
              const SizedBox(height: 14),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.42,
                ),
                decoration: BoxDecoration(
                  color: OdysseyColors.forest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(14),
                  child: SelectableText(
                    gpx,
                    style: OdysseyType.mono(10,
                        color: OdysseyColors.parchment,
                        letterSpacing: 0,
                        height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              JournalButton(
                label: 'Copy GPX to clipboard',
                icon: Icons.copy_outlined,
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final sheet = Navigator.of(sheetContext);
                  await Clipboard.setData(ClipboardData(text: gpx));
                  sheet.pop();
                  messenger.showSnackBar(const SnackBar(
                    content: Text('GPX copied — paste it into your offline map.'),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatStrip extends StatelessWidget {
  const _StatStrip({required this.route, required this.peak});

  final RoutePlan route;
  final int peak;

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, Widget value) => Expanded(
          child: Column(
            children: [
              Text(label.toUpperCase(),
                  style: OdysseyType.mono(8.5, letterSpacing: 1.6)),
              const SizedBox(height: 6),
              SizedBox(height: 26, child: Center(child: value)),
            ],
          ),
        );
    Widget big(String s) =>
        Text(s, style: OdysseyType.display(22, weight: FontWeight.w600));
    const divider = SizedBox(
      height: 40,
      child: VerticalDivider(color: OdysseyColors.rule, width: 1),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: OdysseyColors.rule),
        ),
      ),
      child: Row(
        children: [
          cell('Days', big('${route.days.length}')),
          divider,
          cell('Distance', big('${route.distanceKm} km')),
          divider,
          cell('Max elev.', big(groupThousands(peak))),
          divider,
          cell(route.difficultyLabel, DifficultyMeter(route.difficulty, size: 6)),
        ],
      ),
    );
  }
}

class _DayEntry extends StatelessWidget {
  const _DayEntry({
    required this.index,
    required this.day,
    required this.last,
    required this.supply,
  });

  final int index;
  final RouteDay day;
  final bool last;
  final (String, IconData) supply;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: OdysseyColors.forest,
                      shape: BoxShape.circle,
                      border: Border.all(color: OdysseyColors.brass),
                    ),
                    child: Text('D${index + 1}',
                        style: OdysseyType.mono(10,
                            color: OdysseyColors.brassLight,
                            weight: FontWeight.w500,
                            letterSpacing: 0.5)),
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: OdysseyColors.brass.withValues(alpha: 0.45),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 26, top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Kicker('${day.from} → ${day.to}'),
                    const SizedBox(height: 3),
                    Text(day.title,
                        style: OdysseyType.display(22,
                            weight: FontWeight.w600, height: 1.1)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        _Mini(Icons.straighten, '${day.distanceKm} km'),
                        if (day.gainM > 0)
                          _Mini(Icons.trending_up,
                              '+${groupThousands(day.gainM)} m'),
                        _Mini(day.surface.icon, day.surface.label),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(day.notes, style: OdysseyType.prose(16)),
                    const SizedBox(height: 4),
                    InfoLine(icon: supply.$2, label: supply.$1, value: day.fuel),
                    InfoLine(
                        icon: Icons.cottage_outlined,
                        label: 'Rest',
                        value: day.rest),
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

class _Mini extends StatelessWidget {
  const _Mini(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: OdysseyColors.brass),
        const SizedBox(width: 4),
        Text(text,
            style: OdysseyType.mono(10,
                color: OdysseyColors.ink, letterSpacing: 0.6)),
      ],
    );
  }
}

class _WaypointRow extends StatelessWidget {
  const _WaypointRow({required this.number, required this.waypoint});

  final int number;
  final Waypoint waypoint;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showOnMap(context, MapFocus.waypoint(waypoint.id)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        child: Row(
          children: [
            MonogramSeal(initials: '$number', size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(waypoint.name,
                      style: OdysseyType.display(17.5, weight: FontWeight.w600)),
                  Text(
                    formatLatLng(waypoint.point),
                    style: OdysseyType.mono(9.5, letterSpacing: 0.6),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(waypoint.kind.icon, size: 16, color: OdysseyColors.brass),
                Text(formatElevation(waypoint.elevationM),
                    style: OdysseyType.mono(9.5, color: OdysseyColors.ink)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KeeperCard extends StatelessWidget {
  const _KeeperCard({required this.keeper});

  final Companion keeper;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OdysseyColors.parchmentDeep,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OdysseyColors.rule),
      ),
      child: Row(
        children: [
          Monogram(keeper, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => showCompanionSheet(context, keeper),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Route keeper'),
                  const SizedBox(height: 2),
                  Text(keeper.name,
                      style: OdysseyType.display(19, weight: FontWeight.w600)),
                  Text('${keeper.routesLogged} routes verified',
                      style: OdysseyType.mono(9.5)),
                ],
              ),
            ),
          ),
          ConnectButton(keeper),
        ],
      ),
    );
  }
}
