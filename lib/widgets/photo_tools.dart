import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/odyssey_theme.dart';
import 'photo.dart';

/// Opens the phone's gallery for several photos. Empty if none were picked
/// or the gallery could not be opened.
Future<List<Photo>> pickPhotos(BuildContext context) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final files = await ImagePicker().pickMultiImage(
      maxWidth: 1600,
      imageQuality: 85,
    );
    return [for (final f in files) Photo.picked(await f.readAsBytes())];
  } on PlatformException catch (e) {
    debugPrint('Photo picker failed: $e');
    messenger?.showSnackBar(
      const SnackBar(content: Text('Couldn\'t open your photos.')),
    );
    return const [];
  }
}

/// A sheet to choose photos: from the phone, or from Odyssey's own. With
/// [multiple], photos can be ticked on and off; otherwise one tap chooses.
/// Null if dismissed.
Future<List<Photo>?> showPhotoChooser(
  BuildContext context, {
  required bool multiple,
  List<Photo> selected = const [],
}) {
  return showModalBottomSheet<List<Photo>>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ChooserSheet(multiple: multiple, initial: selected),
  );
}

class _ChooserSheet extends StatefulWidget {
  const _ChooserSheet({required this.multiple, required this.initial});

  final bool multiple;
  final List<Photo> initial;

  @override
  State<_ChooserSheet> createState() => _ChooserSheetState();
}

class _ChooserSheetState extends State<_ChooserSheet> {
  late final List<Photo> _chosen = [...widget.initial];

  Future<void> _fromPhone() async {
    final navigator = Navigator.of(context);
    final picked = widget.multiple
        ? await pickPhotos(context)
        : [?await pickPhoto(context)];
    if (picked.isEmpty || !mounted) return;
    navigator.pop(widget.multiple ? [..._chosen, ...picked] : picked);
  }

  void _tap(Photo photo) {
    HapticFeedback.selectionClick();
    if (!widget.multiple) {
      Navigator.of(context).pop([photo]);
      return;
    }
    setState(() {
      _chosen.contains(photo) ? _chosen.remove(photo) : _chosen.add(photo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = _chosen.length;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.multiple ? 'Add photos' : 'Add a photo',
                      style: OdysseyType.display(
                        26,
                        color: AppColors.ink,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.multiple)
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        disabledBackgroundColor: AppColors.line,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.of(context).pop(_chosen),
                      child: Text(
                        n == 0 ? 'Done' : 'Done · $n',
                        style: OdysseyType.sans(
                          14,
                          color: Colors.white,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: AppColors.ink,
                shape: const StadiumBorder(),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: _fromPhone,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 19,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Choose from your phone',
                          style: OdysseyType.sans(
                            14.5,
                            color: Colors.white,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Text(
                'OR PICK FROM ODYSSEY\'S PHOTOS',
                style: OdysseyType.caps(9.5),
              ),
            ),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: Photos.covers.length,
                itemBuilder: (context, i) {
                  final photo = Photos.covers[i];
                  final order = _chosen.indexOf(photo);
                  return GestureDetector(
                    onTap: () => _tap(photo),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PhotoImage(photo, width: 120),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: order >= 0
                                    ? AppColors.ink
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          if (order >= 0)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: CircleAvatar(
                                radius: 11,
                                backgroundColor: AppColors.ink,
                                child: Text(
                                  '${order + 1}',
                                  style: OdysseyType.sans(
                                    11,
                                    color: Colors.white,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The photos of a story being written: each with a remove button, led by
/// an "Add" tile. The first one is the cover.
class PhotoStrip extends StatelessWidget {
  const PhotoStrip({super.key, required this.photos, required this.onChanged});

  final List<Photo> photos;
  final ValueChanged<List<Photo>> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == 0) {
            return _AddTile(
              label: photos.isEmpty ? 'Add photos' : 'Add more',
              onTap: () async {
                final chosen = await showPhotoChooser(
                  context,
                  multiple: true,
                  selected: photos,
                );
                if (chosen != null) onChanged(chosen);
              },
            );
          }
          final photo = photos[i - 1];
          return SizedBox(
            width: 84,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: PhotoImage(photo, width: 84),
                  ),
                ),
                if (i == 1)
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'COVER',
                        style: OdysseyType.caps(
                          7.5,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: _RemoveBadge(
                    onTap: () => onChanged([...photos]..removeAt(i - 1)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// One optional photo, for a note: add it, change it or take it away.
class PhotoSlot extends StatelessWidget {
  const PhotoSlot({super.key, required this.photo, required this.onChanged});

  final Photo? photo;
  final ValueChanged<Photo?> onChanged;

  Future<void> _choose(BuildContext context) async {
    final chosen = await showPhotoChooser(context, multiple: false);
    if (chosen != null && chosen.isNotEmpty) onChanged(chosen.first);
  }

  @override
  Widget build(BuildContext context) {
    final current = photo;
    if (current == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 84,
          child: _AddTile(label: 'Add a photo', onTap: () => _choose(context)),
        ),
      );
    }
    return Row(
      children: [
        SizedBox(
          width: 84,
          height: 84,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: PhotoImage(current, width: 84),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: _RemoveBadge(onTap: () => onChanged(null)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: () => _choose(context),
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: const Text('Change'),
          style: TextButton.styleFrom(foregroundColor: AppColors.ink),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        onTap: onTap,
        child: SizedBox(
          width: 84,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.ink,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: OdysseyType.sans(
                  10.5,
                  color: AppColors.ink,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RemoveBadge extends StatelessWidget {
  const _RemoveBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Remove photo',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xCC102421),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

/// A row of a post's photos; tap one to see them full screen.
class PhotoGallery extends StatelessWidget {
  const PhotoGallery(this.photos, {super.key, this.height = 120});

  final List<Photo> photos;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => showPhotoViewer(context, photos, initial: i),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: height * 1.3,
              child: PhotoImage(photos[i], width: height * 1.3),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen photos to swipe through and pinch to zoom.
Future<void> showPhotoViewer(
  BuildContext context,
  List<Photo> photos, {
  int initial = 0,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, _, _) => _Viewer(photos: photos, initial: initial),
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _Viewer extends StatefulWidget {
  const _Viewer({required this.photos, required this.initial});

  final List<Photo> photos;
  final int initial;

  @override
  State<_Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<_Viewer> {
  late final _pager = PageController(initialPage: widget.initial);
  late int _index = widget.initial;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pager,
              itemCount: widget.photos.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => InteractiveViewer(
                maxScale: 4,
                child: Center(
                  child: Image(
                    image: widget.photos[i].provider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: 'Close',
                    ),
                    const Spacer(),
                    if (widget.photos.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          '${_index + 1} / ${widget.photos.length}',
                          style: OdysseyType.sans(
                            13,
                            color: Colors.white,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
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
