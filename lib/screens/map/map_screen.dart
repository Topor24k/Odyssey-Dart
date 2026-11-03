import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../data/atlas.dart';
import '../../data/geo.dart';
import '../../data/models.dart';
import '../../data/odyssey_store.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/journal.dart';
import '../navigation.dart';

/// Pillar three: the cartography. Verified waypoint pins, route tracks and a
/// live coordinates HUD over a parchment-toned map.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static final _region = LatLngBounds(
    const LatLng(-10.5, 94.0),
    const LatLng(24.5, 125.0),
  );

  /// Keeps every pin clear of the HUD and filters above and the legend below.
  static final _regionFit = CameraFit.bounds(
    bounds: _region,
    padding: const EdgeInsets.fromLTRB(16, 160, 16, 90),
  );

  /// OpenStreetMap's standard tiles. For a public release, swap in a
  /// commercial tile provider: OSM's servers are not meant for app traffic.
  static const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Turns basemap tiles into a sepia survey sheet: luminance mapped from
  /// brown ink (dark) to the parchment page tone (light).
  static const _parchmentTiles = ColorFilter.matrix([
    0.1735, 0.5836, 0.0589, 0, 40, //
    0.1759, 0.5918, 0.0597, 0, 34,
    0.1717, 0.5777, 0.0583, 0, 26,
    0, 0, 0, 1, 0,
  ]);

  final _store = OdysseyStore.instance;
  final _map = MapController();
  bool _ready = false;
  int _kindFilter = 0;
  Waypoint? _selected;
  String? _routeId;
  (LatLng, String)? _pin;

  @override
  void initState() {
    super.initState();
    _store.mapFocus.addListener(_applyFocus);
  }

  @override
  void dispose() {
    _store.mapFocus.removeListener(_applyFocus);
    _map.dispose();
    super.dispose();
  }

  void _applyFocus() {
    final focus = _store.mapFocus.value;
    if (focus == null || !_ready) return;
    _store.mapFocus.value = null;
    if (focus.routeId case final id?) {
      _showRoute(Atlas.route(id));
    } else if (focus.waypointId case final id?) {
      _select(Atlas.waypoint(id), zoom: 10);
    } else if (focus.point case final point?) {
      setState(() {
        _pin = (point, focus.label ?? '');
        _selected = null;
        _routeId = null;
      });
      _map.move(point, 9);
    }
  }

  void _showRoute(RoutePlan route) {
    setState(() {
      _routeId = route.id;
      _selected = null;
      _pin = null;
      _kindFilter = 0;
    });
    _map.fitCamera(CameraFit.bounds(
      bounds: LatLngBounds.fromPoints(
          [for (final w in Atlas.waypointsOf(route)) w.point]),
      padding: const EdgeInsets.fromLTRB(50, 200, 50, 120),
      maxZoom: 11,
    ));
  }

  void _select(Waypoint w, {double? zoom}) {
    setState(() {
      _selected = w;
      _pin = null;
    });
    _map.move(w.point, zoom ?? _map.camera.zoom);
  }

  void _zoom(double by) =>
      _map.move(_map.camera.center, (_map.camera.zoom + by).clamp(3.5, 16));

  void _reset() {
    setState(() {
      _selected = null;
      _routeId = null;
      _pin = null;
    });
    _map.fitCamera(_regionFit);
  }

  @override
  Widget build(BuildContext context) {
    final kinds = WaypointKind.values;
    final kind = _kindFilter == 0 ? null : kinds[_kindFilter - 1];
    final visible = [
      for (final w in Atlas.waypoints)
        if (kind == null || w.kind == kind) w,
    ];
    final top = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCameraFit: _regionFit,
            minZoom: 3.5,
            maxZoom: 16,
            backgroundColor: OdysseyColors.parchmentDeep,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onMapReady: () {
              _ready = true;
              _applyFocus();
            },
            onTap: (_, _) => setState(() {
              _selected = null;
              _pin = null;
            }),
          ),
          children: [
            ColorFiltered(
              colorFilter: _parchmentTiles,
              child: TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: 'com.example.odyssey',
              ),
            ),
            PolylineLayer(
              polylines: [
                for (final r in Atlas.routes)
                  Polyline(
                    points: [for (final w in Atlas.waypointsOf(r)) w.point],
                    strokeWidth: r.id == _routeId ? 4 : 2.2,
                    color: (r.id == _routeId
                            ? OdysseyColors.forest
                            : OdysseyColors.brass)
                        .withValues(alpha: r.id == _routeId ? 0.9 : 0.6),
                    pattern: r.mode.onWater
                        ? StrokePattern.dashed(segments: const [9, 6])
                        : const StrokePattern.solid(),
                  ),
              ],
            ),
            MarkerLayer(
              markers: [
                for (final w in visible)
                  Marker(
                    point: w.point,
                    width: 40,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => _select(w),
                      child: _WaypointPin(
                        icon: w.kind.icon,
                        selected: _selected?.id == w.id,
                      ),
                    ),
                  ),
                if (_pin case (final point, _))
                  Marker(
                    point: point,
                    width: 40,
                    height: 48,
                    alignment: Alignment.topCenter,
                    child: const _WaypointPin(
                      icon: Icons.auto_stories_outlined,
                      selected: true,
                    ),
                  ),
              ],
            ),
            _CoordinatesHud(top: top + 12),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
              backgroundColor: Color(0xCCF8F5EE),
            ),
          ],
        ),
        const IgnorePointer(child: Center(child: _Crosshair())),
        Positioned(
          top: top + 86,
          left: 0,
          right: 0,
          child: FilterRow(
            options: ['All', for (final k in kinds) k.label],
            icons: [null, for (final k in kinds) k.icon],
            selected: _kindFilter,
            onSelected: (i) => setState(() => _kindFilter = i),
          ),
        ),
        Positioned(
          right: 14,
          top: top + 140,
          child: Column(
            children: [
              _MapButton(icon: Icons.add, tooltip: 'Zoom in', onTap: () => _zoom(1)),
              const SizedBox(height: 8),
              _MapButton(icon: Icons.remove, tooltip: 'Zoom out', onTap: () => _zoom(-1)),
              const SizedBox(height: 8),
              _MapButton(
                  icon: Icons.public, tooltip: 'All of Southeast Asia', onTap: _reset),
            ],
          ),
        ),
        // Sits above the attribution line, which must stay visible.
        Positioned(
          left: 14,
          right: 14,
          bottom: 30,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.15), end: Offset.zero)
                    .animate(animation),
                child: child,
              ),
            ),
            child: _bottomCard(),
          ),
        ),
      ],
    );
  }

  Widget _bottomCard() {
    if (_selected case final w?) {
      return _WaypointCard(
        key: ValueKey(w.id),
        waypoint: w,
        onClose: () => setState(() => _selected = null),
        onRoute: _showRoute,
      );
    }
    if (_pin case (final point, final label)) {
      return _HudCard(
        key: ValueKey('pin-$label'),
        kicker: 'Chronicle filed here',
        title: label,
        lines: [formatLatLng(point)],
        onClose: () => setState(() => _pin = null),
      );
    }
    if (_routeId case final id?) {
      final route = Atlas.route(id);
      return _HudCard(
        key: ValueKey('route-$id'),
        kicker: '${route.mode.label} · ${route.days.length} days',
        title: route.name,
        lines: [
          '${route.distanceKm} km · ${Atlas.waypointsOf(route).length} waypoints',
        ],
        onClose: () => setState(() => _routeId = null),
        action: ('View route plan', () => openRoute(context, route)),
      );
    }
    return const _Legend(key: ValueKey('legend'));
  }
}

class _WaypointPin extends StatelessWidget {
  const _WaypointPin({required this.icon, required this.selected});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.15 : 1,
      alignment: Alignment.bottomCenter,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: selected ? OdysseyColors.brass : OdysseyColors.forest,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? OdysseyColors.parchment
                    : OdysseyColors.brassLight,
                width: 1.4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 16, color: OdysseyColors.parchment),
          ),
          CustomPaint(
            size: const Size(10, 9),
            painter: _PinTip(
                selected ? OdysseyColors.brass : OdysseyColors.forest),
          ),
        ],
      ),
    );
  }
}

class _PinTip extends CustomPainter {
  _PinTip(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_PinTip old) => old.color != color;
}

/// Live map-centre readout. It lives inside the map so it rebuilds with
/// every camera move.
class _CoordinatesHud extends StatelessWidget {
  const _CoordinatesHud({required this.top});

  final double top;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final c = camera.center;
    // Columns here must size to their content: the map hands its overlays
    // loose constraints as tall as the map itself.
    Widget cell(String label, String value) => Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: OdysseyType.mono(8,
                      color: OdysseyColors.brass, letterSpacing: 1.6)),
              const SizedBox(height: 2),
              Text(value,
                  maxLines: 1,
                  style: OdysseyType.mono(11.5,
                      color: OdysseyColors.parchment, letterSpacing: 0.3)),
            ],
          ),
        );
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, top, 14, 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: OdysseyColors.forest.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: OdysseyColors.brass.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              const Icon(Icons.my_location,
                  size: 18, color: OdysseyColors.brassLight),
              const SizedBox(width: 12),
              cell('LATITUDE', formatLat(c.latitude)),
              cell('LONGITUDE', formatLng(c.longitude)),
              SizedBox(
                width: 44,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('ZOOM',
                        style: OdysseyType.mono(8,
                            color: OdysseyColors.brass, letterSpacing: 1.6)),
                    const SizedBox(height: 2),
                    Text(camera.zoom.toStringAsFixed(1),
                        style: OdysseyType.mono(11.5,
                            color: OdysseyColors.parchment)),
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

class _Crosshair extends StatelessWidget {
  const _Crosshair();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(28, 28), painter: _CrosshairPainter());
  }
}

class _CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final p = Paint()
      ..strokeWidth = 1
      ..color = OdysseyColors.forest.withValues(alpha: 0.55);
    canvas.drawLine(c - const Offset(14, 0), c - const Offset(5, 0), p);
    canvas.drawLine(c + const Offset(5, 0), c + const Offset(14, 0), p);
    canvas.drawLine(c - const Offset(0, 14), c - const Offset(0, 5), p);
    canvas.drawLine(c + const Offset(0, 5), c + const Offset(0, 14), p);
    canvas.drawCircle(c, 1.5, p);
  }

  @override
  bool shouldRepaint(_CrosshairPainter old) => false;
}

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: OdysseyColors.forest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 20, color: OdysseyColors.parchment),
          ),
        ),
      ),
    );
  }
}

class _HudCard extends StatelessWidget {
  const _HudCard({
    super.key,
    required this.kicker,
    required this.title,
    required this.lines,
    required this.onClose,
    this.action,
    this.children = const [],
  });

  final String kicker;
  final String title;
  final List<String> lines;
  final VoidCallback onClose;
  final (String, VoidCallback)? action;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
      decoration: BoxDecoration(
        color: OdysseyColors.forest.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OdysseyColors.brass.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Kicker(kicker, color: OdysseyColors.brassLight)),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Close',
                icon: const Icon(Icons.close,
                    size: 18, color: OdysseyColors.parchment),
                onPressed: onClose,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: OdysseyType.display(23,
                        color: OdysseyColors.parchment,
                        weight: FontWeight.w600,
                        height: 1.1)),
                const SizedBox(height: 6),
                for (final line in lines)
                  Text(line,
                      style: OdysseyType.mono(10.5,
                          color: OdysseyColors.parchment
                              .withValues(alpha: 0.8))),
                ...children,
                if (action case (final label, final onTap)) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: onTap,
                    child: Row(
                      children: [
                        Text(label.toUpperCase(),
                            style: OdysseyType.mono(10,
                                color: OdysseyColors.brassLight,
                                letterSpacing: 1.8)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward,
                            size: 14, color: OdysseyColors.brassLight),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaypointCard extends StatelessWidget {
  const _WaypointCard({
    super.key,
    required this.waypoint,
    required this.onClose,
    required this.onRoute,
  });

  final Waypoint waypoint;
  final VoidCallback onClose;
  final ValueChanged<RoutePlan> onRoute;

  @override
  Widget build(BuildContext context) {
    final w = waypoint;
    final routes = Atlas.routesThrough(w.id);
    return _HudCard(
      kicker: '${w.kind.label} · ${w.place}',
      title: w.name,
      lines: [
        '${formatLatLng(w.point)} · ${formatElevation(w.elevationM).toUpperCase()}',
      ],
      onClose: onClose,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(w.surface.icon, size: 14, color: OdysseyColors.brassLight),
            const SizedBox(width: 6),
            Text('TRAIL SURFACE · ${w.surface.label.toUpperCase()}',
                style: OdysseyType.mono(9.5,
                    color: OdysseyColors.brassLight, letterSpacing: 1.2)),
          ],
        ),
        const SizedBox(height: 8),
        Text(w.note,
            style: OdysseyType.prose(15.5,
                italic: true,
                color: OdysseyColors.parchment.withValues(alpha: 0.85))),
        if (routes.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in routes)
                GestureDetector(
                  onTap: () => onRoute(r),
                  child: PlateBadge('On route · ${r.name}', icon: r.mode.icon),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({super.key});

  @override
  Widget build(BuildContext context) {
    Widget line({required bool dashed}) => SizedBox(
          width: 26,
          child: Row(
            children: [
              for (var i = 0; i < (dashed ? 3 : 1); i++) ...[
                Expanded(
                  child: Container(height: 2.2, color: OdysseyColors.brass),
                ),
                if (dashed && i < 2) const SizedBox(width: 3),
              ],
            ],
          ),
        );
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: OdysseyColors.parchment.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: OdysseyColors.rule),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            line(dashed: false),
            const SizedBox(width: 6),
            Text('OVERLAND', style: OdysseyType.mono(8.5, letterSpacing: 1.2)),
            const SizedBox(width: 14),
            line(dashed: true),
            const SizedBox(width: 6),
            Text('WATERWAY', style: OdysseyType.mono(8.5, letterSpacing: 1.2)),
          ],
        ),
      ),
    );
  }
}
