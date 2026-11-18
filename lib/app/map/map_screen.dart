import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/motion.dart';
import '../../widgets/photo.dart';
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
  static const _fitPadding = EdgeInsets.fromLTRB(24, 24, 64, 150);

  /// OpenStreetMap's standard tiles. For a public release, use a tile
  /// provider with an API key: OSM's servers are not meant for app traffic.
  static const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Turns the tiles into a travel-poster map: turquoise water, warm beige
  /// land, soft greens, dark labels.
  static const _posterTiles = ColorFilter.matrix([
    1.72, 0, 0, 0, -182, //
    0, 1.46, 0, 0, -123,
    0, 0, 1.6, 0, -167,
    0, 0, 0, 1, 0,
  ]);

  final _store = AppStore.instance;
  final _map = MapController();
  final _cards = PageController(viewportFraction: 0.88);
  int _index = 0;
  bool _pinning = false;

  /// The pin that has just been dropped, so it can fall into place.
  String? _landing;

  @override
  void initState() {
    super.initState();
    _store.pinRequest.addListener(_startPinning);
    _store.focusPin.addListener(_showRequestedPin);
  }

  @override
  void dispose() {
    _store.pinRequest.removeListener(_startPinning);
    _store.focusPin.removeListener(_showRequestedPin);
    _map.dispose();
    _cards.dispose();
    super.dispose();
  }

  List<MapStory> get _stories => _store.mapStories;

  void _startPinning() {
    HapticFeedback.selectionClick();
    setState(() => _pinning = true);
  }

  /// Flies to a pin asked for elsewhere, e.g. from your journal.
  void _showRequestedPin() {
    final id = _store.focusPin.value;
    if (id == null) return;
    _store.focusPin.value = null;
    final index = _stories.indexWhere((s) => s.id == id);
    if (index < 0) return;
    setState(() => _pinning = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _index = index);
      if (_cards.hasClients) _cards.jumpToPage(index);
      _map.move(_stories[index].point, 8);
    });
  }

  void _focus(int index, {bool fromMap = false}) {
    final stories = _stories;
    if (index < 0 || index >= stories.length) return;
    setState(() => _index = index);
    _map.move(stories[index].point, math.max(_map.camera.zoom, 6));
    if (fromMap && _cards.hasClients) {
      _cards.animateToPage(
        index,
        duration: const Duration(milliseconds: 380),
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
    HapticFeedback.heavyImpact();
    setState(() {
      _pinning = false;
      _landing = pinned.id;
    });
    final index = _stories.indexWhere((s) => s.id == pinned.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_cards.hasClients) _cards.jumpToPage(index);
      _focus(index);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Pinned, and saved in your journal.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final stories = _stories;
        final selected = stories.isEmpty
            ? null
            : stories[_index.clamp(0, stories.length - 1)];
        return Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
                child: ScreenHeader(
                  title: 'Map',
                  subtitle: 'Stories pinned by the circle',
                  trailing: RoundIconButton(
                    icon: Icons.add_location_alt_outlined,
                    tooltip: 'Pin a story',
                    dark: true,
                    onTap: _startPinning,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _map,
                    options: MapOptions(
                      initialCameraFit: CameraFit.bounds(
                        bounds: _region,
                        padding: _fitPadding,
                      ),
                      minZoom: 3,
                      maxZoom: 16,
                      backgroundColor: const Color(0xFF6EB9BE),
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                      onTap: (_, point) {
                        if (_pinning) _dropPin(point);
                      },
                    ),
                    children: [
                      ColorFiltered(
                        colorFilter: _posterTiles,
                        child: TileLayer(
                          urlTemplate: _tileUrl,
                          userAgentPackageName: 'com.example.odyssey',
                          // The map tab is built while hidden; faded-in
                          // tiles that load then never finish fading, so
                          // show them as soon as they arrive.
                          tileDisplay: const TileDisplay.instantaneous(),
                        ),
                      ),
                      MarkerLayer(
                        markers: [
                          for (var i = 0; i < stories.length; i++)
                            Marker(
                              point: stories[i].point,
                              width: 130,
                              height: 62,
                              // Puts the teal dot, not the photo, on the spot.
                              alignment: const Alignment(0.65, -0.73),
                              child: GestureDetector(
                                onTap: () => _focus(i, fromMap: true),
                                child: _StoryPin(
                                  story: stories[i],
                                  selected: stories[i] == selected,
                                  landing: stories[i].id == _landing,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (_pinning) ...[
                    const IgnorePointer(
                      child: Center(
                        child: Icon(
                          Icons.add_location_alt,
                          size: 34,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: Reveal(
                        child: _PinningBanner(
                          onCancel: () {
                            setState(() => _pinning = false);
                          },
                        ),
                      ),
                    ),
                  ],
                  Positioned(
                    right: 14,
                    top: _pinning ? 84 : 14,
                    child: Column(
                      children: [
                        RoundIconButton(
                          icon: Icons.add,
                          tooltip: 'Zoom in',
                          size: 40,
                          onTap: () => _map.move(
                            _map.camera.center,
                            math.min(_map.camera.zoom + 1, 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        RoundIconButton(
                          icon: Icons.remove,
                          tooltip: 'Zoom out',
                          size: 40,
                          onTap: () => _map.move(
                            _map.camera.center,
                            math.max(_map.camera.zoom - 1, 3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        RoundIconButton(
                          icon: Icons.public,
                          tooltip: 'All of Southeast Asia',
                          size: 40,
                          onTap: () => _map.fitCamera(
                            CameraFit.bounds(
                              bounds: _region,
                              padding: _fitPadding,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: navClearance(context) + 44 + 92,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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
                      // Above the create button, which floats over the bar.
                      bottom: navClearance(context) + 44,
                      height: 84,
                      child: stories.isEmpty
                          ? _NoPins(onPin: _startPinning)
                          : PageView.builder(
                              controller: _cards,
                              itemCount: stories.length,
                              onPageChanged: _focus,
                              itemBuilder: (context, i) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: _StoryCard(story: stories[i]),
                              ),
                            ),
                    ),
                ],
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
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
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

/// A round photo pin with a teal dot on the spot and the place's name
/// beside it. A freshly dropped pin falls in and bounces.
class _StoryPin extends StatelessWidget {
  const _StoryPin({
    required this.story,
    required this.selected,
    required this.landing,
  });

  final MapStory story;
  final bool selected;
  final bool landing;

  @override
  Widget build(BuildContext context) {
    final mine = story.authorId == 'me';
    final label = story.place.split(',').first;
    Widget pin = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedScale(
              scale: selected ? 1.12 : 1,
              alignment: Alignment.bottomCenter,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Container(
                width: 46,
                height: 46,
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
                child: ClipOval(child: PhotoImage(story.photo, width: 46)),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.ink,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 46),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style:
                OdysseyType.sans(
                  11.5,
                  color: AppColors.ink,
                  weight: FontWeight.w600,
                ).copyWith(
                  shadows: const [
                    Shadow(color: Colors.white, blurRadius: 4),
                    Shadow(color: Colors.white, blurRadius: 8),
                  ],
                ),
          ),
        ),
      ],
    );
    if (landing) {
      pin = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.bounceOut,
        builder: (context, t, child) => Transform.translate(
          offset: Offset(0, (1 - t) * -70),
          child: Opacity(opacity: t.clamp(0, 1), child: child),
        ),
        child: pin,
      );
    }
    return pin;
  }
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
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
              child: PhotoImage(story.photo, width: 64),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  story.place.split(',').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.display(
                    20,
                    color: AppColors.ink,
                    weight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${author.id == 'me' ? 'You' : author.firstName} · '
                  '${story.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.sans(12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.ink),
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
                child: PhotoImage(story.photo),
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
  Photo _photo = Photos.coverFor(DateTime.now().toIso8601String());
  Photo? _picked;

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
    Navigator.of(context).pop(
      MapStory(
        id: store.newId('m'),
        authorId: 'me',
        title: title,
        note: _note.text.trim().isEmpty ? 'I was here.' : _note.text.trim(),
        place: _place.text.trim().isEmpty ? 'Pinned spot' : _place.text.trim(),
        point: widget.point,
        photo: _photo,
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
              Text('PHOTO', style: OdysseyType.caps(10)),
              const SizedBox(height: 8),
              CoverPicker(
                selected: _photo,
                picked: _picked,
                onChanged: (photo) {
                  if (!mounted) return;
                  setState(() {
                    if (photo.isPicked) _picked = photo;
                    _photo = photo;
                  });
                },
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
