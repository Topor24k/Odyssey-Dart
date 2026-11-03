import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/scene.dart';
import '../app_shell.dart';
import '../routes.dart';

/// Travel stories pinned where they happened. Browse other wayfarers' pins
/// for inspiration, or drop your own.
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

  /// OpenStreetMap's standard tiles. For a public release, use a tile
  /// provider with an API key: OSM's servers are not meant for app traffic.
  static const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Softens the tiles towards the app's warm off-white while keeping a
  /// hint of their colour, so water and parks still read.
  static const _softTiles = ColorFilter.matrix([
    0.4776, 0.2609, 0.0263, 0, 54, //
    0.0755, 0.6540, 0.0256, 0, 55,
    0.0740, 0.2489, 0.4251, 0, 53,
    0, 0, 0, 1, 0,
  ]);

  final _store = AppStore.instance;
  final _map = MapController();
  final _cards = PageController(viewportFraction: 0.86);
  int _index = 0;
  bool _pinning = false;

  @override
  void initState() {
    super.initState();
    _store.pinRequest.addListener(_startPinning);
  }

  @override
  void dispose() {
    _store.pinRequest.removeListener(_startPinning);
    _map.dispose();
    _cards.dispose();
    super.dispose();
  }

  List<MapStory> get _stories => _store.mapStories;

  void _startPinning() => setState(() => _pinning = true);

  void _focus(int index, {bool fromMap = false}) {
    final stories = _stories;
    if (index < 0 || index >= stories.length) return;
    setState(() => _index = index);
    _map.move(stories[index].point, math.max(_map.camera.zoom, 6));
    if (fromMap && _cards.hasClients) {
      _cards.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _dropPin(LatLng point) async {
    HapticFeedback.mediumImpact();
    final pinned = await showModalBottomSheet<MapStory>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PinSheet(point: point),
    );
    if (pinned == null || !mounted) return;
    _store.pinStory(pinned);
    setState(() => _pinning = false);
    final index = _stories.indexWhere((s) => s.id == pinned.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_cards.hasClients) _cards.jumpToPage(index);
      _focus(index);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Pinned! Other wayfarers can now find your story.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final carouselBottom = navClearance(context) - 6;
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final stories = _stories;
        final selected = stories.isEmpty
            ? null
            : stories[_index.clamp(0, stories.length - 1)];
        return Stack(
          children: [
            FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: _region,
                  padding: const EdgeInsets.fromLTRB(24, 70, 72, 250),
                ),
                minZoom: 3,
                maxZoom: 16,
                backgroundColor: AppColors.canvas,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onTap: (_, point) {
                  if (_pinning) _dropPin(point);
                },
              ),
              children: [
                ColorFiltered(
                  colorFilter: _softTiles,
                  child: TileLayer(
                    urlTemplate: _tileUrl,
                    userAgentPackageName: 'com.example.odyssey',
                    // The map tab is built while hidden; faded-in tiles
                    // that load then never finish fading, so show them
                    // as soon as they arrive.
                    tileDisplay: const TileDisplay.instantaneous(),
                  ),
                ),
                MarkerLayer(
                  markers: [
                    for (var i = 0; i < stories.length; i++)
                      Marker(
                        point: stories[i].point,
                        width: 56,
                        height: 64,
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () => _focus(i, fromMap: true),
                          child: _StoryPin(
                            story: stories[i],
                            selected: stories[i] == selected,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (_pinning)
              const IgnorePointer(
                child: Center(
                  child: Icon(
                    Icons.add_location_alt,
                    size: 34,
                    color: AppColors.ink,
                  ),
                ),
              ),
            if (_pinning)
              Positioned(
                top: top + 12,
                left: 16,
                right: 16,
                child: _PinningBanner(
                  onCancel: () => setState(() => _pinning = false),
                ),
              ),
            Positioned(
              right: 16,
              top: top + (_pinning ? 84 : 14),
              child: Column(
                children: [
                  RoundIconButton(
                    icon: Icons.add_location_alt_outlined,
                    tooltip: 'Pin a story',
                    dark: true,
                    onTap: _startPinning,
                  ),
                  const SizedBox(height: 14),
                  RoundIconButton(
                    icon: Icons.add,
                    tooltip: 'Zoom in',
                    onTap: () => _map.move(
                      _map.camera.center,
                      math.min(_map.camera.zoom + 1, 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RoundIconButton(
                    icon: Icons.remove,
                    tooltip: 'Zoom out',
                    onTap: () => _map.move(
                      _map.camera.center,
                      math.max(_map.camera.zoom - 1, 3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RoundIconButton(
                    icon: Icons.public,
                    tooltip: 'All of Southeast Asia',
                    onTap: () => _map.fitCamera(
                      CameraFit.bounds(
                        bounds: _region,
                        padding: const EdgeInsets.fromLTRB(24, 70, 72, 250),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 14,
              bottom: carouselBottom + 122,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.card.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: OdysseyType.sans(9.5, color: AppColors.muted),
                ),
              ),
            ),
            if (!_pinning)
              Positioned(
                left: 0,
                right: 0,
                bottom: carouselBottom,
                height: 112,
                child: stories.isEmpty
                    ? _NoPins(onPin: _startPinning)
                    : PageView.builder(
                        controller: _cards,
                        itemCount: stories.length,
                        onPageChanged: _focus,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _StoryCard(story: stories[i]),
                        ),
                      ),
              ),
          ],
        );
      },
    );
  }
}

class _PinningBanner extends StatelessWidget {
  const _PinningBanner({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tap the map where your story happened',
              style: OdysseyType.sans(
                14,
                color: Colors.white,
                weight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(
              'Cancel',
              style: OdysseyType.sans(
                13.5,
                color: AppColors.sage,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryPin extends StatelessWidget {
  const _StoryPin({required this.story, required this.selected});

  final MapStory story;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final mine = story.authorId == 'me';
    return AnimatedScale(
      scale: selected ? 1.15 : 1,
      alignment: Alignment.bottomCenter,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: selected || mine ? AppColors.ink : Colors.white,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(child: Scene(story.motif, story.seed)),
          ),
          CustomPaint(
            size: const Size(12, 9),
            painter: _PinTip(selected || mine ? AppColors.ink : Colors.white),
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

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final MapStory story;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final author = store.person(story.authorId);
    return AppCard(
      padding: const EdgeInsets.all(10),
      onTap: () => _showStory(context, story),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 88,
              height: 90,
              child: Scene(story.motif, story.seed),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  story.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.sans(
                    15,
                    color: AppColors.ink,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Avatar(author, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${author.firstName} · ${story.ago}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OdysseyType.sans(12, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        story.place,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OdysseyType.sans(12, color: AppColors.body),
                      ),
                    ),
                    const Icon(
                      Icons.favorite_border,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${story.likes}',
                      style: OdysseyType.sans(12, color: AppColors.body),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoPins extends StatelessWidget {
  const _NoPins({required this.onPin});

  final VoidCallback onPin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: AppCard(
        onTap: onPin,
        child: Row(
          children: [
            const IconTile(Icons.add_location_alt_outlined, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'No pins here yet. Drop the first story.',
                style: OdysseyType.sans(14, color: AppColors.body),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showStory(BuildContext context, MapStory story) {
  final store = AppStore.instance;
  final author = store.person(story.authorId);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheet) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 170,
                width: double.infinity,
                child: Scene(story.motif, story.seed),
              ),
            ),
            const SizedBox(height: 14),
            StatusPill(
              story.place,
              icon: Icons.place_outlined,
              background: AppColors.tile,
            ),
            const SizedBox(height: 10),
            Text(
              story.title,
              style: OdysseyType.display(
                26,
                color: AppColors.ink,
                weight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              story.note,
              style: OdysseyType.sans(14.5, color: AppColors.body, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(sheet).pop();
                    openProfile(context, author);
                  },
                  child: Avatar(author, size: 38),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author.name,
                        style: OdysseyType.sans(
                          14,
                          color: AppColors.ink,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${story.ago} · ${story.likes} likes',
                        style: OdysseyType.sans(12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                if (author.id != 'me') FriendButton(author, compact: true),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Title, place and a few lines about the moment — then it's on the map.
class _PinSheet extends StatefulWidget {
  const _PinSheet({required this.point});

  final LatLng point;

  @override
  State<_PinSheet> createState() => _PinSheetState();
}

class _PinSheetState extends State<_PinSheet> {
  final _title = TextEditingController();
  final _place = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _note.dispose();
    super.dispose();
  }

  void _post() {
    final store = AppStore.instance;
    final title = _title.text.trim();
    final (motif, seed) = store.sceneFor(title);
    Navigator.of(context).pop(
      MapStory(
        id: store.newId('m'),
        authorId: 'me',
        title: title,
        note: _note.text.trim().isEmpty ? 'I was here.' : _note.text.trim(),
        place: _place.text.trim().isEmpty ? 'Pinned spot' : _place.text.trim(),
        point: widget.point,
        motif: motif,
        seed: seed,
        likes: 0,
        ago: 'Just now',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _title.text.trim().isNotEmpty;
    final p = widget.point;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pin your story',
                style: OdysseyType.sans(
                  20,
                  color: AppColors.ink,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${p.latitude.abs().toStringAsFixed(3)}° '
                '${p.latitude >= 0 ? 'N' : 'S'}, '
                '${p.longitude.abs().toStringAsFixed(3)}° '
                '${p.longitude >= 0 ? 'E' : 'W'}',
                style: OdysseyType.sans(12.5, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              SoftField(
                controller: _title,
                label: 'Title',
                hint: 'Sunrise over the rice terraces',
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              SoftField(
                controller: _place,
                label: 'Place name',
                hint: 'Batad, Ifugao',
                icon: Icons.place_outlined,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              SoftField(
                controller: _note,
                label: 'What happened here?',
                hint: 'A line or two to inspire the next wayfarer…',
                minLines: 3,
                maxLines: 6,
              ),
              const SizedBox(height: 18),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  disabledBackgroundColor: AppColors.line,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: ready ? _post : null,
                child: Text(
                  'Post to the map',
                  style: OdysseyType.sans(
                    14.5,
                    color: ready ? Colors.white : AppColors.muted,
                    weight: FontWeight.w600,
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
