import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/scene.dart';
import 'models.dart';

/// The sample world the app opens on. Dates are relative to today, so the
/// schedule always has something on this week.
abstract final class Sample {
  static final DateTime today = DateUtils.dateOnly(DateTime.now());

  static DateTime at(int dayOffset, int hour, [int minute = 0]) =>
      today.add(Duration(days: dayOffset, hours: hour, minutes: minute));

  static const people = <Person>[
    Person(
      id: 'p-mai',
      name: 'Mai Thảo Nguyễn',
      handle: '@maithao',
      base: 'Hà Giang, Vietnam',
      bio:
          'Highland rider. I have ridden the Hà Giang loop in every month of '
          'the year — ask me which ones to avoid.',
      tint: Color(0xFF6F8A74),
      style: 'Highland rider',
      stories: 12,
      trips: 41,
      friends: 318,
      mutuals: 6,
      cover: SceneMotif.karst,
    ),
    Person(
      id: 'p-paeng',
      name: 'Rafael Dizon',
      handle: '@paeng',
      base: 'Coron, Philippines',
      bio:
          'Banca builder turned island skipper. Knows which lagoons empty out '
          'after four o\'clock.',
      tint: Color(0xFF5E7F96),
      style: 'Island sailor',
      stories: 7,
      trips: 28,
      friends: 204,
      mutuals: 3,
      cover: SceneMotif.islands,
    ),
    Person(
      id: 'p-ayu',
      name: 'Ayu Larasati',
      handle: '@ayu.summits',
      base: 'Lombok, Indonesia',
      bio:
          'Rinjani guide and porter-rights advocate. Ginger coffee at 2 a.m. '
          'is a love language.',
      tint: Color(0xFF9A7A5B),
      style: 'Volcano guide',
      stories: 6,
      trips: 33,
      friends: 271,
      mutuals: 2,
      cover: SceneMotif.volcano,
    ),
    Person(
      id: 'p-khamla',
      name: 'Khamla Phommachanh',
      handle: '@khamla',
      base: 'Luang Prabang, Laos',
      bio: 'Boatman\'s son. I map the Mekong\'s sandbars every dry season.',
      tint: Color(0xFF7C8E68),
      style: 'River keeper',
      stories: 9,
      trips: 19,
      friends: 142,
      mutuals: 1,
      cover: SceneMotif.river,
    ),
    Person(
      id: 'p-dara',
      name: 'Dara Chenda',
      handle: '@dara.walks',
      base: 'Siem Reap, Cambodia',
      bio: 'Ethnographer. Dawn walks to the temples nobody else gets up for.',
      tint: Color(0xFFA0685A),
      style: 'Culture seeker',
      stories: 21,
      trips: 15,
      friends: 388,
      mutuals: 4,
      cover: SceneMotif.temple,
    ),
    Person(
      id: 'p-niran',
      name: 'Niran Wongsakul',
      handle: '@niran.maps',
      base: 'Chiang Mai, Thailand',
      bio: 'Cartographer. I ride every route twice before I share it.',
      tint: Color(0xFF55605A),
      style: 'Cartographer',
      stories: 8,
      trips: 57,
      friends: 512,
      mutuals: 5,
      cover: SceneMotif.karst,
    ),
    Person(
      id: 'p-hana',
      name: 'Hana Aziz',
      handle: '@hana.eats',
      base: 'Penang, Malaysia',
      bio:
          'Street-food archivist. Midnight hawker stalls and the families '
          'behind them.',
      tint: Color(0xFFB0835E),
      style: 'Food wanderer',
      stories: 26,
      trips: 11,
      friends: 640,
      mutuals: 7,
      cover: SceneMotif.lanterns,
    ),
    Person(
      id: 'p-joel',
      name: 'Joel Dulnuan',
      handle: '@joel.terraces',
      base: 'Banaue, Philippines',
      bio: 'Ifugao farmer and trail steward. Please stay on the dikes.',
      tint: Color(0xFF6E7F5A),
      style: 'Terrace steward',
      stories: 5,
      trips: 22,
      friends: 97,
      mutuals: 2,
      cover: SceneMotif.terraces,
    ),
    Person(
      id: 'p-lea',
      name: 'Léa Fontaine',
      handle: '@lea.slow',
      base: 'Hội An, Vietnam',
      bio:
          'Slow traveller on a one-year loop. Collecting recipes, not '
          'stamps.',
      tint: Color(0xFF8B7D96),
      style: 'Slow traveller',
      stories: 4,
      trips: 9,
      friends: 76,
      mutuals: 1,
      cover: SceneMotif.lanterns,
    ),
  ];

  /// Already your friends when you first sign in.
  static const friendIds = {'p-mai', 'p-hana', 'p-niran'};

  static final posts = <Post>[
    const InvitePost(
      id: 'post-invite-highpass',
      authorId: 'p-mai',
      ago: '1h',
      likes: 24,
      comments: 6,
      eventId: 'e-highpass',
      note:
          'Three seats left for the high pass ride — buckwheat is still in '
          'bloom. Who\'s in?',
    ),
    const StoryPost(
      id: 'post-story-mapileng',
      authorId: 'p-mai',
      ago: '3h',
      likes: 182,
      comments: 31,
      title: 'The Fog Does Not Lift at Mã Pí Lèng',
      excerpt:
          'Four days on the Hà Giang loop, where the road is cut into '
          'the limestone and the clouds keep their own schedule.',
      place: 'Hà Giang, Vietnam',
      motif: SceneMotif.karst,
      seed: 3,
      readMinutes: 6,
      paragraphs: [
        'We left Hà Giang City at six, before the trucks, with two litres of '
            'fuel strapped behind the seat because the map promised a station '
            'at Yên Minh and the map has lied to me before.',
        'By the second morning the road had narrowed to a single lane of '
            'patched asphalt pinned to the cliff. Hmong children waved from '
            'doorways cut into the slope; a grandmother sold us boiled eggs '
            'and refused change.',
        'Mã Pí Lèng did not show itself. We arrived into a fog so complete '
            'that the Nho Quế River, eight hundred metres below, existed only '
            'as a sound. We waited an hour on the stone parapet, sharing '
            'sunflower seeds with a family from Lào Cai. It never cleared. I '
            'have stopped thinking of that as a loss.',
        'Ride it Quản Bạ first, Mã Pí Lèng third, so the hardest roads come '
            'once your hands have learned the bike. Carry cash for the whole '
            'loop and budget a spare day for weather.',
      ],
    ),
    const TextPost(
      id: 'post-text-hana',
      authorId: 'p-hana',
      ago: '5h',
      likes: 96,
      comments: 14,
      text:
          'Uncle Lim has fried char kway teow over the same charcoal brazier '
          'for 41 years. One plate at a time, because "the wok forgets." Go '
          'after 10 p.m. and bring small notes.',
      place: 'George Town, Penang',
    ),
    const StoryPost(
      id: 'post-story-calamianes',
      authorId: 'p-paeng',
      ago: 'Yesterday',
      likes: 241,
      comments: 40,
      title: 'Six Islands and a Broken Outrigger',
      excerpt:
          'Sailing the Calamianes on a family banca — and the afternoon '
          'we spent lashing bamboo together on a beach with no name.',
      place: 'Coron, Philippines',
      motif: SceneMotif.islands,
      seed: 4,
      readMinutes: 5,
      paragraphs: [
        'The banca is called the Tala — "star" — and it is twelve metres of '
            'marine plywood, bamboo and conviction. We pushed off from Coron '
            'town at first light with the tide.',
        'The islands come at you one after another: limestone fists rising '
            'from water so clear the reef seems to float beneath the hull.',
        'On the third afternoon the starboard outrigger cracked against a '
            'swell. Nobody panicked. We spent two hours splinting bamboo in '
            'the shade of a tamarind tree. It was the best afternoon of the '
            'trip.',
      ],
    ),
    const InvitePost(
      id: 'post-invite-angkor',
      authorId: 'p-dara',
      ago: 'Yesterday',
      likes: 58,
      comments: 9,
      eventId: 'e-angkor',
      note:
          'Dawn at the temples nobody gets up for. Small group, quiet '
          'voices, coffee after.',
    ),
    const TextPost(
      id: 'post-text-niran',
      authorId: 'p-niran',
      ago: '2d',
      likes: 133,
      comments: 22,
      text:
          'Route 1095 to Pai: 762 curves, and I counted every one. New GPX '
          'up for the Mae Hong Son loop — fuel at Mae Malai, leave before 8 '
          'to beat the minivans.',
      place: 'Mae Hong Son, Thailand',
    ),
    const StoryPost(
      id: 'post-story-rinjani',
      authorId: 'p-ayu',
      ago: '3d',
      likes: 310,
      comments: 52,
      title: 'Before Dawn on the Rim of Rinjani',
      excerpt:
          'Three days around Lombok\'s great caldera, measured in '
          'switchbacks, porters\' songs and the slow arrival of light.',
      place: 'Lombok, Indonesia',
      motif: SceneMotif.volcano,
      seed: 6,
      readMinutes: 7,
      paragraphs: [
        '"Small steps, every step." The summit push is three hours of scree '
            'that slides back half a pace for every pace you climb.',
        'At 3,300 metres the wind arrived and we turned around without '
            'discussion. Two hours later we watched the sun come up out of '
            'the Bali Sea and light the smoking cone in the lake below.',
        'Ask your operator, directly, what they pay their porters.',
      ],
    ),
  ];

  static final events = <TripEvent>[
    TripEvent(
      id: 'e-coffee',
      title: 'Coffee & Route Planning',
      kind: EventKind.gathering,
      place: 'Old Quarter, Hà Nội',
      start: at(0, 8),
      length: const Duration(hours: 1),
      hostId: 'p-niran',
      attendeeIds: const ['p-mai', 'p-lea'],
      capacity: 12,
      motif: SceneMotif.lanterns,
      seed: 31,
      summary:
          'Egg coffee and paper maps. Bring the route you\'re dreaming '
          'about and leave with fuel stops, homestays and a riding buddy.',
      highlights: const [
        'Offline-map setup help',
        'Fuel and cash planning for the north',
        'Meet riders heading the same way',
      ],
    ),
    TripEvent(
      id: 'e-foodwalk',
      title: 'Old Quarter Street Food Walk',
      kind: EventKind.gathering,
      place: 'Hoàn Kiếm, Hà Nội',
      start: at(0, 18, 30),
      length: const Duration(hours: 2, minutes: 30),
      hostId: 'p-hana',
      attendeeIds: const ['p-lea', 'p-dara', 'p-khamla'],
      capacity: 10,
      motif: SceneMotif.lanterns,
      seed: 13,
      summary:
          'Seven stalls, three generations of cooks, one very full '
          'evening. Small notes and an empty stomach required.',
      highlights: const [
        'Bún chả at the family stall since 1965',
        'Phở cuốn and the story behind it',
        'Egg coffee to finish',
      ],
    ),
    TripEvent(
      id: 'e-angkor',
      title: 'Angkor Dawn Photo Walk',
      kind: EventKind.gathering,
      place: 'Beng Mealea, Siem Reap',
      start: at(6, 5),
      length: const Duration(hours: 3),
      hostId: 'p-dara',
      attendeeIds: const ['p-hana', 'p-joel'],
      capacity: 8,
      motif: SceneMotif.temple,
      seed: 12,
      summary:
          'A jungle-claimed temple before the tour buses, with a village '
          'elder who played in these ruins as a boy.',
      highlights: const [
        'Sunrise through the collapsed galleries',
        'Oral histories from the village',
        'Breakfast with the maintenance crew',
      ],
    ),
    TripEvent(
      id: 'e-highpass',
      title: 'Hà Giang High Pass Ride',
      kind: EventKind.expedition,
      place: 'Hà Giang, Vietnam',
      start: at(9, 7),
      length: const Duration(days: 4),
      hostId: 'p-mai',
      attendeeIds: const ['p-niran', 'p-dara', 'p-hana', 'p-joel'],
      capacity: 8,
      motif: SceneMotif.karst,
      seed: 71,
      summary:
          'Four days over the Đồng Văn plateau, timed for the last of '
          'the buckwheat bloom, with homestays in Hmong villages.',
      highlights: const [
        'Mã Pí Lèng Pass and the Nho Quế gorge',
        'Sủng Là valley homestays',
        'Bikes, fuel and homestays shared',
      ],
    ),
    TripEvent(
      id: 'e-flotilla',
      title: 'Calamianes Coastal Flotilla',
      kind: EventKind.expedition,
      place: 'Coron, Philippines',
      start: at(16, 6),
      length: const Duration(days: 5),
      hostId: 'p-paeng',
      attendeeIds: const ['p-hana', 'p-joel', 'p-khamla', 'p-ayu'],
      capacity: 10,
      motif: SceneMotif.islands,
      seed: 77,
      summary:
          'Three family bancas sailing in company from Coron to El Nido, '
          'camping on community-managed beaches.',
      highlights: const [
        'Kayangan Lake after the day boats leave',
        'Beach camps in Linapacan',
        'Reef-safe snorkelling with the crew',
      ],
    ),
    TripEvent(
      id: 'e-rinjani',
      title: 'Rinjani Rim Traverse',
      kind: EventKind.expedition,
      place: 'Lombok, Indonesia',
      start: at(24, 6),
      length: const Duration(days: 3),
      hostId: 'p-ayu',
      attendeeIds: const ['p-mai', 'p-paeng', 'p-niran'],
      capacity: 8,
      motif: SceneMotif.volcano,
      seed: 89,
      summary:
          'The great caldera crossing with fairly paid porters and a '
          'pack-out pledge for every gram of rubbish.',
      highlights: const [
        'Sunrise from the crater rim',
        'Hot springs at Segara Anak',
        'Acclimatisation night in Senaru',
      ],
    ),
  ];

  /// Events you have already joined when you first sign in.
  static const joinedEventIds = {'e-coffee', 'e-foodwalk'};

  /// Your own travel plan: a few days in Hà Nội, then the Hà Giang loop.
  static final plans = <PlanItem>[
    PlanItem(
      id: 'pl-bike',
      title: 'Rent a semi-automatic',
      kind: PlanKind.task,
      start: at(0, 10, 30),
      length: const Duration(hours: 1),
      place: 'Old Quarter, Hà Nội',
    ),
    PlanItem(
      id: 'pl-pack',
      title: 'Pack for Hà Giang',
      kind: PlanKind.task,
      start: at(0, 14),
      length: const Duration(hours: 2),
      place: 'Guesthouse',
      note:
          'Rain shell, warm layer, offline maps for Hà Giang province. '
          'Cash: 3,000,000 VND in small notes.',
    ),
    PlanItem(
      id: 'pl-temple',
      title: 'Temple of Literature',
      kind: PlanKind.travel,
      start: at(1, 9),
      length: const Duration(hours: 2),
      place: 'Đống Đa, Hà Nội',
    ),
    PlanItem(
      id: 'pl-bus',
      title: 'Sleeper bus to Hà Giang',
      kind: PlanKind.travel,
      start: at(1, 20),
      length: const Duration(hours: 7),
      place: 'Mỹ Đình bus station',
      note: 'Bottom bunk, booked. Bring a jacket — the air-con is arctic.',
    ),
    PlanItem(
      id: 'pl-ride1',
      title: 'Ride: Hà Giang → Yên Minh',
      kind: PlanKind.ride,
      start: at(2, 8),
      length: const Duration(hours: 5),
      place: 'QL4C via Quản Bạ',
      peopleIds: ['p-mai'],
    ),
    PlanItem(
      id: 'pl-lunch',
      title: 'Lunch at Heaven\'s Gate',
      kind: PlanKind.food,
      start: at(2, 13, 30),
      length: const Duration(hours: 1),
      place: 'Quản Bạ',
    ),
    PlanItem(
      id: 'pl-stay1',
      title: 'Homestay check-in',
      kind: PlanKind.stay,
      start: at(2, 17),
      length: const Duration(hours: 1),
      place: 'Yên Minh',
    ),
    PlanItem(
      id: 'pl-ride2',
      title: 'Ride: Yên Minh → Đồng Văn',
      kind: PlanKind.ride,
      start: at(3, 7, 30),
      length: const Duration(hours: 4),
      place: 'via Sủng Là valley',
      peopleIds: ['p-mai'],
    ),
    PlanItem(
      id: 'pl-pass',
      title: 'Mã Pí Lèng Pass',
      kind: PlanKind.ride,
      start: at(4, 8),
      length: const Duration(hours: 3),
      place: 'Đồng Văn → Mèo Vạc',
      note: 'Fog is common before 10:00 — no rush. Walk the parapet trail.',
      peopleIds: ['p-mai'],
    ),
  ];

  static final mapStories = <MapStory>[
    const MapStory(
      id: 'm-mapileng',
      authorId: 'p-mai',
      title: 'Fog on Mã Pí Lèng',
      note:
          'Waited an hour on the parapet. It never cleared, and it was '
          'still the best hour of the loop.',
      place: 'Mã Pí Lèng Pass, Vietnam',
      point: LatLng(23.2315, 105.4078),
      motif: SceneMotif.karst,
      seed: 3,
      likes: 182,
      ago: '3h',
    ),
    const MapStory(
      id: 'm-pai',
      authorId: 'p-niran',
      title: '762 curves to Pai',
      note: 'Fuel at Mae Malai. Leave before eight.',
      place: 'Pai, Thailand',
      point: LatLng(19.3591, 98.4422),
      motif: SceneMotif.karst,
      seed: 37,
      likes: 133,
      ago: '2d',
    ),
    const MapStory(
      id: 'm-pakbeng',
      authorId: 'p-khamla',
      title: 'Slow boat, morning fog',
      note: 'Monks walking the alms round in perfect silence.',
      place: 'Pakbeng, Laos',
      point: LatLng(19.8936, 101.1336),
      motif: SceneMotif.river,
      seed: 2,
      likes: 88,
      ago: '4d',
    ),
    const MapStory(
      id: 'm-bengmealea',
      authorId: 'p-dara',
      title: 'Where the trees are winning',
      note: 'An hour alone with the gibbons before the buses.',
      place: 'Beng Mealea, Cambodia',
      point: LatLng(13.4762, 104.2383),
      motif: SceneMotif.temple,
      seed: 3,
      likes: 120,
      ago: '1w',
    ),
    const MapStory(
      id: 'm-batad',
      authorId: 'p-joel',
      title: 'A wall rebuilt in an afternoon',
      note:
          'The mountain moves a little every rainy season. We move after '
          'it.',
      place: 'Batad, Philippines',
      point: LatLng(16.9693, 121.1080),
      motif: SceneMotif.terraces,
      seed: 4,
      likes: 76,
      ago: '5d',
    ),
    const MapStory(
      id: 'm-coron',
      authorId: 'p-paeng',
      title: 'Kayangan after four',
      note: 'The day boats leave and the lagoon goes quiet.',
      place: 'Coron, Philippines',
      point: LatLng(11.9530, 120.2310),
      motif: SceneMotif.islands,
      seed: 12,
      likes: 241,
      ago: '1d',
    ),
    const MapStory(
      id: 'm-penang',
      authorId: 'p-hana',
      title: 'Midnight in the five-foot ways',
      note: 'Char kway teow, one plate at a time.',
      place: 'George Town, Malaysia',
      point: LatLng(5.4145, 100.3292),
      motif: SceneMotif.lanterns,
      seed: 7,
      likes: 96,
      ago: '5h',
    ),
    const MapStory(
      id: 'm-rinjani',
      authorId: 'p-ayu',
      title: 'Sunrise from the rim',
      note: 'We didn\'t make the summit. We made the sunrise.',
      place: 'Mount Rinjani, Indonesia',
      point: LatLng(-8.3935, 116.4590),
      motif: SceneMotif.volcano,
      seed: 6,
      likes: 310,
      ago: '3d',
    ),
    const MapStory(
      id: 'm-hoian',
      authorId: 'p-lea',
      title: 'Lantern hour in Hội An',
      note: 'Cao lầu from a grandmother who wouldn\'t share the recipe.',
      place: 'Hội An, Vietnam',
      point: LatLng(15.8801, 108.3380),
      motif: SceneMotif.lanterns,
      seed: 24,
      likes: 54,
      ago: '6d',
    ),
  ];
}
