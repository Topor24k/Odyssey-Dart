import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/odyssey_theme.dart';

/// A photograph: one bundled with the app, or one picked from the phone.
@immutable
class Photo {
  /// A photo in assets/photos, by file name without the extension.
  const Photo(String this.name) : bytes = null;

  /// A photo picked from the phone's gallery.
  const Photo.picked(Uint8List this.bytes) : name = null;

  final String? name;
  final Uint8List? bytes;

  bool get isPicked => bytes != null;

  ImageProvider get provider => bytes != null
      ? MemoryImage(bytes!)
      : AssetImage('assets/photos/$name.jpg');

  @override
  bool operator ==(Object other) =>
      other is Photo && other.name == name && identical(other.bytes, bytes);

  @override
  int get hashCode => Object.hash(name, identityHashCode(bytes));
}

/// The photos that ship with Odyssey, from Wikimedia Commons. Who took each
/// one, and its licence, is in lib/data/photo_credits.dart.
abstract final class Photos {
  // Hà Giang
  static const haGiangPeak = Photo('hagiang_peak');
  static const maPiLengRidge = Photo('mapileng_ridge');
  static const maPiLengParapet = Photo('mapileng_parapet');
  static const quanBaRoad = Photo('quanba_road');
  static const quanBaValley = Photo('quanba_valley');
  static const nhoQueGorge = Photo('nhoque_gorge');
  static const haGiangFog = Photo('hagiang_fog');
  static const duGiaFields = Photo('dugia_fields');
  static const dongVanHairpin = Photo('dongvan_hairpin');
  static const dongVanPeaks = Photo('dongvan_peaks');

  // Elsewhere in Vietnam
  static const eggCoffee = Photo('egg_coffee');
  static const bunCha = Photo('bun_cha');
  static const vanMieu = Photo('van_mieu');
  static const haLongBay = Photo('halong_bay');
  static const trangAn = Photo('trang_an');
  static const lanHa = Photo('lan_ha');
  static const hoiAnLanterns = Photo('hoian_lanterns');
  static const hoiAnStreet = Photo('hoian_street');

  // The Philippines
  static const kayanganLake = Photo('kayangan_lake');
  static const coronLagoon = Photo('coron_lagoon');
  static const coronBanca = Photo('coron_banca');
  static const bancaShallows = Photo('banca_shallows');
  static const batadTerraces = Photo('batad_terraces');
  static const batadVillage = Photo('batad_village');

  // Indonesia
  static const rinjaniDawn = Photo('rinjani_dawn');
  static const segaraAnak = Photo('segara_anak');
  static const rinjaniRim = Photo('rinjani_rim');

  // Thailand, Laos, Cambodia, Malaysia
  static const paiCanyon = Photo('pai_canyon');
  static const maeHongSonRoad = Photo('maehongson_road');
  static const pakbengBoats = Photo('pakbeng_boats');
  static const mekongSunset = Photo('mekong_sunset');
  static const luangPrabang = Photo('luang_prabang');
  static const kuangSi = Photo('kuang_si');
  static const bengMealeaTrees = Photo('bengmealea_trees');
  static const bengMealeaRuins = Photo('bengmealea_ruins');
  static const penangHawker = Photo('penang_hawker');
  static const georgeTown = Photo('georgetown_shophouse');

  /// Covers to choose from when you write something without a photo of
  /// your own.
  static const covers = [
    haGiangPeak,
    trangAn,
    kayanganLake,
    batadTerraces,
    hoiAnLanterns,
    segaraAnak,
    luangPrabang,
    paiCanyon,
    kuangSi,
    lanHa,
    duGiaFields,
    bengMealeaTrees,
  ];

  /// A cover that suits [text] well enough until you pick one.
  static Photo coverFor(String text) =>
      covers[text.hashCode.abs() % covers.length];
}

/// Fills its box with [photo], cropped to cover, fading in once decoded.
///
/// [width] is roughly how wide the photo shows, in logical pixels; small
/// thumbnails decode small, so a list of them stays light.
class PhotoImage extends StatelessWidget {
  const PhotoImage(
    this.photo, {
    super.key,
    this.width,
    this.alignment = Alignment.center,
    this.background = AppColors.tile,
  });

  final Photo photo;
  final double? width;
  final Alignment alignment;

  /// Shown until the photo has loaded.
  final Color background;

  static int? _decodeWidth(double logical, double ratio) {
    final px = logical * ratio;
    for (final bucket in const [160, 320, 640, 960]) {
      if (px <= bucket) return bucket;
    }
    return null; // Full size.
  }

  /// The image a [PhotoImage] of this [width] loads, e.g. to precache it.
  static ImageProvider providerFor(
    BuildContext context,
    Photo photo, {
    double? width,
  }) {
    final shown = width ?? MediaQuery.sizeOf(context).width;
    final decode = _decodeWidth(shown, MediaQuery.devicePixelRatioOf(context));
    return ResizeImage.resizeIfNeeded(decode, null, photo.provider);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: Image(
        image: providerFor(context, photo, width: width),
        fit: BoxFit.cover,
        alignment: alignment,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        frameBuilder: (context, child, frame, synchronous) => synchronous
            ? child
            : AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOut,
                child: child,
              ),
        errorBuilder: (context, _, _) => const Center(
          child: Icon(Icons.landscape_outlined, color: AppColors.muted),
        ),
      ),
    );
  }
}

/// Opens the phone's gallery. Null if nothing was picked or the gallery
/// could not be opened.
Future<Photo?> pickPhoto(BuildContext context) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return null;
    return Photo.picked(await file.readAsBytes());
  } on PlatformException catch (e) {
    debugPrint('Photo picker failed: $e');
    messenger?.showSnackBar(
      const SnackBar(content: Text('Couldn\'t open your photos.')),
    );
    return null;
  }
}

/// A row of covers to choose from, led by "From your phone".
class CoverPicker extends StatelessWidget {
  const CoverPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.picked,
  });

  final Photo selected;
  final ValueChanged<Photo> onChanged;

  /// The photo you picked from your phone, shown first once there is one.
  final Photo? picked;

  @override
  Widget build(BuildContext context) {
    final options = [?picked, ...Photos.covers];
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == 0) {
            return _PhoneTile(
              onTap: () async {
                final photo = await pickPhoto(context);
                if (photo != null) onChanged(photo);
              },
            );
          }
          final photo = options[i - 1];
          final on = photo == selected;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(photo);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 76,
              padding: EdgeInsets.all(on ? 3 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: on ? AppColors.ink : AppColors.line,
                  width: on ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(on ? 10 : 13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PhotoImage(photo, width: 76),
                    if (on)
                      const Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: CircleAvatar(
                            radius: 9,
                            backgroundColor: AppColors.ink,
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhoneTile extends StatelessWidget {
  const _PhoneTile({required this.onTap});

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
          width: 76,
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
                'Your photo',
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
