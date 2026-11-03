import 'package:latlong2/latlong.dart';

import 'models.dart';

/// The field atlas: every companion, waypoint, route, story and expedition
/// the app ships with.
abstract final class Atlas {
  static Companion companion(String id) =>
      companions.firstWhere((c) => c.id == id);

  static Waypoint waypoint(String id) =>
      waypoints.firstWhere((w) => w.id == id);

  static RoutePlan route(String id) => routes.firstWhere((r) => r.id == id);

  static List<Waypoint> waypointsOf(RoutePlan route) =>
      [for (final id in route.waypointIds) waypoint(id)];

  static List<RoutePlan> routesThrough(String waypointId) =>
      [for (final r in routes) if (r.waypointIds.contains(waypointId)) r];

  static const companions = <Companion>[
    Companion(
      id: 'c-mai',
      name: 'Mai Thảo Nguyễn',
      role: 'Highland Rider',
      base: 'Hà Giang, Vietnam',
      bio:
          'Grew up between the Lô River and the Đồng Văn plateau and has ridden '
          'the northern loop in every month of the year — including the ones '
          'she advises against.',
      specialties: ['Motorbike passes', 'Hmong homestays', 'Monsoon riding'],
      languages: ['Vietnamese', 'English', 'Some Hmong'],
      routesLogged: 41,
      storiesWritten: 12,
      yearsOnRoad: 9,
    ),
    Companion(
      id: 'c-paeng',
      name: 'Rafael Dizon',
      role: 'Island Sailor',
      base: 'Coron, Palawan, Philippines',
      bio:
          'Paeng to everyone on the pier. A third-generation banca builder '
          'turned expedition skipper who knows which lagoons empty of tour '
          'boats after four o\'clock.',
      specialties: ['Outrigger navigation', 'Reef etiquette', 'Island camps'],
      languages: ['Filipino', 'Cuyonon', 'English'],
      routesLogged: 28,
      storiesWritten: 7,
      yearsOnRoad: 14,
    ),
    Companion(
      id: 'c-ayu',
      name: 'Ayu Larasati',
      role: 'Volcano Guide',
      base: 'Senaru, Lombok, Indonesia',
      bio:
          'Licensed Rinjani guide and porter-rights advocate. Starts every '
          'summit push with the same prayer and the same thermos of ginger '
          'coffee.',
      specialties: ['Caldera treks', 'Sasak culture', 'Leave-no-trace'],
      languages: ['Indonesian', 'Sasak', 'English'],
      routesLogged: 33,
      storiesWritten: 6,
      yearsOnRoad: 11,
    ),
    Companion(
      id: 'c-khamla',
      name: 'Khamla Phommachanh',
      role: 'River Keeper',
      base: 'Luang Prabang, Laos',
      bio:
          'A boatman\'s son who maps the sandbars and moorings of the Upper '
          'Mekong each dry season, when the river quietly rewrites itself.',
      specialties: ['Mekong navigation', 'Village moorings', 'Lao kitchens'],
      languages: ['Lao', 'Thai', 'English', 'French'],
      routesLogged: 19,
      storiesWritten: 9,
      yearsOnRoad: 16,
    ),
    Companion(
      id: 'c-dara',
      name: 'Dara Chenda',
      role: 'Cultural Ethnographer',
      base: 'Siem Reap, Cambodia',
      bio:
          'Documents the living rituals around Angkor\'s outlying temples and '
          'leads walking surveys with village elders as co-authors.',
      specialties: ['Khmer heritage', 'Oral histories', 'Walking surveys'],
      languages: ['Khmer', 'English', 'French'],
      routesLogged: 15,
      storiesWritten: 21,
      yearsOnRoad: 12,
    ),
    Companion(
      id: 'c-niran',
      name: 'Niran Wongsakul',
      role: 'Cartographer',
      base: 'Chiang Mai, Thailand',
      bio:
          'Draws hand-inked route sheets for the Mae Hong Son mountains and '
          'verifies every GPX track by riding it twice.',
      specialties: ['GPX verification', 'Northern passes', 'Field sketching'],
      languages: ['Thai', 'English'],
      routesLogged: 57,
      storiesWritten: 8,
      yearsOnRoad: 18,
    ),
    Companion(
      id: 'c-hana',
      name: 'Hana Aziz',
      role: 'Street-Food Archivist',
      base: 'George Town, Penang, Malaysia',
      bio:
          'Records the recipes and family histories of midnight hawker stalls '
          'before the last generation of cooks retires.',
      specialties: ['Night markets', 'Hawker histories', 'Heritage alleys'],
      languages: ['Malay', 'English', 'Hokkien'],
      routesLogged: 11,
      storiesWritten: 26,
      yearsOnRoad: 7,
    ),
    Companion(
      id: 'c-joel',
      name: 'Joel Dulnuan',
      role: 'Terrace Steward',
      base: 'Banaue, Ifugao, Philippines',
      bio:
          'Ifugao farmer and trail steward who repairs terrace walls between '
          'guiding — and asks every visitor to stay on the dikes.',
      specialties: ['Terrace trails', 'Ifugao heritage', 'Homestay hosting'],
      languages: ['Tuwali', 'Ilocano', 'Filipino', 'English'],
      routesLogged: 22,
      storiesWritten: 5,
      yearsOnRoad: 13,
    ),
  ];

  static const waypoints = <Waypoint>[
    // Hà Giang, Vietnam
    Waypoint(
      id: 'w-hagiang',
      name: 'Hà Giang City',
      kind: WaypointKind.town,
      point: LatLng(22.8233, 104.9836),
      elevationM: 120,
      surface: Surface.switchbackAsphalt,
      place: 'Hà Giang, Vietnam',
      note: 'Rental yards, the permit office and the last reliable ATM.',
    ),
    Waypoint(
      id: 'w-quanba',
      name: 'Quản Bạ Heaven\'s Gate',
      kind: WaypointKind.pass,
      point: LatLng(23.0660, 104.9960),
      elevationM: 1100,
      surface: Surface.switchbackAsphalt,
      place: 'Hà Giang, Vietnam',
      note: 'Twin "Fairy Mountain" view; tea stalls at the top of the pass.',
    ),
    Waypoint(
      id: 'w-yenminh',
      name: 'Yên Minh',
      kind: WaypointKind.town,
      point: LatLng(23.1218, 105.1428),
      elevationM: 650,
      surface: Surface.switchbackAsphalt,
      place: 'Hà Giang, Vietnam',
      note: 'Fuel and the last trustworthy mechanic before the plateau.',
    ),
    Waypoint(
      id: 'w-sungla',
      name: 'Sủng Là Valley',
      kind: WaypointKind.homestay,
      point: LatLng(23.2340, 105.2350),
      elevationM: 1200,
      surface: Surface.gravel,
      place: 'Hà Giang, Vietnam',
      note: 'Earthen Hmong homesteads; buckwheat flowers Oct–Nov.',
    ),
    Waypoint(
      id: 'w-dongvan',
      name: 'Đồng Văn Old Quarter',
      kind: WaypointKind.town,
      point: LatLng(23.2780, 105.3615),
      elevationM: 1000,
      surface: Surface.switchbackAsphalt,
      place: 'Hà Giang, Vietnam',
      note: 'Sunday market; the fuel station closes at 21:00.',
    ),
    Waypoint(
      id: 'w-mapileng',
      name: 'Mã Pí Lèng Pass',
      kind: WaypointKind.pass,
      point: LatLng(23.2315, 105.4078),
      elevationM: 1200,
      surface: Surface.switchbackAsphalt,
      place: 'Hà Giang, Vietnam',
      note: 'Fog common before 10:00. Parapet trail above the Nho Quế gorge.',
    ),
    Waypoint(
      id: 'w-meovac',
      name: 'Mèo Vạc',
      kind: WaypointKind.town,
      point: LatLng(23.1600, 105.4070),
      elevationM: 1100,
      surface: Surface.switchbackAsphalt,
      place: 'Hà Giang, Vietnam',
      note: 'Family homestays around a lively Sunday market.',
    ),
    Waypoint(
      id: 'w-dugia',
      name: 'Du Già Village',
      kind: WaypointKind.homestay,
      point: LatLng(22.9320, 105.2010),
      elevationM: 600,
      surface: Surface.gravel,
      place: 'Hà Giang, Vietnam',
      note: 'Stilt homestays by the river; waterfall swim 2 km south.',
    ),
    // Mae Hong Son, Thailand
    Waypoint(
      id: 'w-chiangmai',
      name: 'Chiang Mai',
      kind: WaypointKind.town,
      point: LatLng(18.7883, 98.9853),
      elevationM: 310,
      surface: Surface.switchbackAsphalt,
      place: 'Chiang Mai, Thailand',
      note: 'Bike rental, gear shops and route-sheet printing.',
    ),
    Waypoint(
      id: 'w-pai',
      name: 'Pai',
      kind: WaypointKind.town,
      point: LatLng(19.3591, 98.4422),
      elevationM: 510,
      surface: Surface.switchbackAsphalt,
      place: 'Mae Hong Son, Thailand',
      note: 'Where the 762 curves of Route 1095 finally let go.',
    ),
    Waypoint(
      id: 'w-soppong',
      name: 'Tham Lod Cave River',
      kind: WaypointKind.viewpoint,
      point: LatLng(19.5640, 98.2780),
      elevationM: 650,
      surface: Surface.forestDirt,
      place: 'Mae Hong Son, Thailand',
      note: 'Bamboo rafts through the cave; swifts pour out at dusk.',
    ),
    Waypoint(
      id: 'w-maehongson',
      name: 'Mae Hong Son',
      kind: WaypointKind.town,
      point: LatLng(19.3020, 97.9654),
      elevationM: 270,
      surface: Surface.switchbackAsphalt,
      place: 'Mae Hong Son, Thailand',
      note: 'Lakeside temples, fuel and ATMs.',
    ),
    Waypoint(
      id: 'w-chongkham',
      name: 'Wat Chong Kham',
      kind: WaypointKind.temple,
      point: LatLng(19.3010, 97.9690),
      elevationM: 270,
      surface: Surface.switchbackAsphalt,
      place: 'Mae Hong Son, Thailand',
      note: 'Shan-style temple reflected in Jong Kham lake at dawn.',
    ),
    Waypoint(
      id: 'w-maesariang',
      name: 'Mae Sariang',
      kind: WaypointKind.town,
      point: LatLng(18.1667, 97.9333),
      elevationM: 330,
      surface: Surface.switchbackAsphalt,
      place: 'Mae Hong Son, Thailand',
      note: 'Riverside teak houses and a quiet evening market.',
    ),
    Waypoint(
      id: 'w-inthanon',
      name: 'Doi Inthanon Summit',
      kind: WaypointKind.summit,
      point: LatLng(18.5883, 98.4867),
      elevationM: 2565,
      surface: Surface.switchbackAsphalt,
      place: 'Chiang Mai, Thailand',
      note: 'Thailand\'s highest point — near freezing at dawn in January.',
    ),
    // Calamianes, Philippines
    Waypoint(
      id: 'w-coron',
      name: 'Coron Town Pier',
      kind: WaypointKind.mooring,
      point: LatLng(11.9986, 120.2043),
      elevationM: 0,
      surface: Surface.waterway,
      place: 'Busuanga, Philippines',
      note: 'Find family bancas at the market pier the evening before.',
    ),
    Waypoint(
      id: 'w-kayangan',
      name: 'Kayangan Lake',
      kind: WaypointKind.viewpoint,
      point: LatLng(11.9530, 120.2310),
      elevationM: 20,
      surface: Surface.forestDirt,
      place: 'Coron Island, Philippines',
      note: 'Short climb to the lagoon view; arrive after 16:00.',
    ),
    Waypoint(
      id: 'w-culion',
      name: 'Culion',
      kind: WaypointKind.town,
      point: LatLng(11.8890, 120.0190),
      elevationM: 10,
      surface: Surface.waterway,
      place: 'Culion, Philippines',
      note: 'Former leprosarium with a moving museum; ice and fuel.',
    ),
    Waypoint(
      id: 'w-linapacan',
      name: 'Linapacan Islands',
      kind: WaypointKind.campsite,
      point: LatLng(11.4700, 119.8700),
      elevationM: 0,
      surface: Surface.waterway,
      place: 'Palawan, Philippines',
      note: 'Community beach camps; the clearest water in the archipelago.',
    ),
    Waypoint(
      id: 'w-elnido',
      name: 'El Nido',
      kind: WaypointKind.town,
      point: LatLng(11.1956, 119.4075),
      elevationM: 0,
      surface: Surface.waterway,
      place: 'Palawan, Philippines',
      note: 'End of the crossing. ATMs often run dry — bring cash.',
    ),
    // Komodo, Indonesia
    Waypoint(
      id: 'w-labuanbajo',
      name: 'Labuan Bajo Harbour',
      kind: WaypointKind.mooring,
      point: LatLng(-8.4964, 119.8877),
      elevationM: 0,
      surface: Surface.waterway,
      place: 'Flores, Indonesia',
      note: 'Phinisi berths; national park fees paid here in cash.',
    ),
    Waypoint(
      id: 'w-kanawa',
      name: 'Kanawa Island',
      kind: WaypointKind.campsite,
      point: LatLng(-8.4990, 119.7610),
      elevationM: 0,
      surface: Surface.waterway,
      place: 'Komodo NP, Indonesia',
      note: 'Simple beach bungalows; turtles feed off the jetty at dusk.',
    ),
    Waypoint(
      id: 'w-padar',
      name: 'Padar Island Ridge',
      kind: WaypointKind.viewpoint,
      point: LatLng(-8.6540, 119.5800),
      elevationM: 200,
      surface: Surface.gravel,
      place: 'Komodo NP, Indonesia',
      note: 'Thirty-minute sunrise climb to the three-bay view.',
    ),
    Waypoint(
      id: 'w-lohliang',
      name: 'Loh Liang Ranger Post',
      kind: WaypointKind.mooring,
      point: LatLng(-8.5600, 119.4960),
      elevationM: 5,
      surface: Surface.forestDirt,
      place: 'Komodo NP, Indonesia',
      note: 'Ranger-led walks only; the dragons are most active early.',
    ),
    Waypoint(
      id: 'w-pinkbeach',
      name: 'Pantai Merah',
      kind: WaypointKind.mooring,
      point: LatLng(-8.6050, 119.5100),
      elevationM: 0,
      surface: Surface.waterway,
      place: 'Komodo NP, Indonesia',
      note: 'Pink sand; snorkel the reef drop-off at high tide.',
    ),
    // Upper Mekong, Laos
    Waypoint(
      id: 'w-huayxai',
      name: 'Huay Xai Pier',
      kind: WaypointKind.mooring,
      point: LatLng(20.2758, 100.4139),
      elevationM: 380,
      surface: Surface.waterway,
      place: 'Bokeo, Laos',
      note: 'Slow boats leave when full — usually around 11:00.',
    ),
    Waypoint(
      id: 'w-pakbeng',
      name: 'Pakbeng',
      kind: WaypointKind.mooring,
      point: LatLng(19.8936, 101.1336),
      elevationM: 330,
      surface: Surface.waterway,
      place: 'Oudomxay, Laos',
      note: 'Overnight river town; silent alms round at dawn.',
    ),
    Waypoint(
      id: 'w-pakou',
      name: 'Pak Ou Caves',
      kind: WaypointKind.temple,
      point: LatLng(20.0508, 102.2167),
      elevationM: 300,
      surface: Surface.waterway,
      place: 'Luang Prabang, Laos',
      note: 'Thousands of Buddha images in two caves above the river.',
    ),
    Waypoint(
      id: 'w-luangprabang',
      name: 'Luang Prabang',
      kind: WaypointKind.town,
      point: LatLng(19.8856, 102.1347),
      elevationM: 300,
      surface: Surface.waterway,
      place: 'Luang Prabang, Laos',
      note: 'Journey\'s end: night market, temples and Kuang Si falls.',
    ),
    // Lombok & Bali, Indonesia
    Waypoint(
      id: 'w-sembalun',
      name: 'Sembalun',
      kind: WaypointKind.town,
      point: LatLng(-8.3606, 116.5300),
      elevationM: 1156,
      surface: Surface.forestDirt,
      place: 'Lombok, Indonesia',
      note: 'Savanna trailhead; register at the park office.',
    ),
    Waypoint(
      id: 'w-pelawangan',
      name: 'Pelawangan Sembalun',
      kind: WaypointKind.campsite,
      point: LatLng(-8.3935, 116.4590),
      elevationM: 2639,
      surface: Surface.forestDirt,
      place: 'Lombok, Indonesia',
      note: 'Crater-rim camp; wind shelters on the eastern side.',
    ),
    Waypoint(
      id: 'w-rinjani',
      name: 'Rinjani Summit',
      kind: WaypointKind.summit,
      point: LatLng(-8.4115, 116.4573),
      elevationM: 3726,
      surface: Surface.scree,
      place: 'Lombok, Indonesia',
      note: 'Scree ascent. Turn around by 07:00 regardless of position.',
    ),
    Waypoint(
      id: 'w-segaraanak',
      name: 'Segara Anak Lake',
      kind: WaypointKind.campsite,
      point: LatLng(-8.4060, 116.4080),
      elevationM: 2008,
      surface: Surface.forestDirt,
      place: 'Lombok, Indonesia',
      note: 'Hot springs on the shore; Barujari cone smoking in the lake.',
    ),
    Waypoint(
      id: 'w-senaru',
      name: 'Senaru',
      kind: WaypointKind.homestay,
      point: LatLng(-8.3070, 116.4040),
      elevationM: 600,
      surface: Surface.forestDirt,
      place: 'Lombok, Indonesia',
      note: 'Trailhead village — acclimatise here for a night.',
    ),
    Waypoint(
      id: 'w-toya',
      name: 'Toya Bungkah',
      kind: WaypointKind.homestay,
      point: LatLng(-8.2560, 115.4010),
      elevationM: 1050,
      surface: Surface.forestDirt,
      place: 'Bali, Indonesia',
      note: 'Lakeside hot springs; guides gather here at 03:30.',
    ),
    Waypoint(
      id: 'w-batur',
      name: 'Mount Batur Summit',
      kind: WaypointKind.summit,
      point: LatLng(-8.2420, 115.3750),
      elevationM: 1717,
      surface: Surface.scree,
      place: 'Bali, Indonesia',
      note: 'Steam vents near the rim — guides cook breakfast eggs in them.',
    ),
    // Story locations
    Waypoint(
      id: 'w-batad',
      name: 'Batad Amphitheatre',
      kind: WaypointKind.homestay,
      point: LatLng(16.9693, 121.1080),
      elevationM: 940,
      surface: Surface.forestDirt,
      place: 'Ifugao, Philippines',
      note: 'Two-thousand-year-old stone terraces. Stay on the dikes.',
    ),
    Waypoint(
      id: 'w-bengmealea',
      name: 'Beng Mealea',
      kind: WaypointKind.temple,
      point: LatLng(13.4762, 104.2383),
      elevationM: 55,
      surface: Surface.forestDirt,
      place: 'Siem Reap, Cambodia',
      note: 'Jungle-claimed 12th-century temple; arrive at opening.',
    ),
    Waypoint(
      id: 'w-chewjetty',
      name: 'Chew Jetty',
      kind: WaypointKind.homestay,
      point: LatLng(5.4128, 100.3398),
      elevationM: 2,
      surface: Surface.waterway,
      place: 'Penang, Malaysia',
      note: 'Clan houses on stilts over the strait; quiet after 21:00.',
    ),
  ];

  static const routes = <RoutePlan>[
    RoutePlan(
      id: 'r-hagiang',
      name: 'Hà Giang Loop',
      region: 'Hà Giang',
      country: 'Vietnam',
      mode: TravelMode.motorbike,
      difficulty: 3,
      season: 'Oct–Dec for buckwheat and dry roads; Mar–Apr for clear air.',
      vehicle:
          '110–125cc semi-automatic or manual. Full-face helmet. Check brakes '
          'every morning.',
      cash:
          'Carry about 3,000,000 VND in small notes. ATMs only in Hà Giang '
          'City and Đồng Văn.',
      connectivity:
          'Viettel 4G on most passes; dead zones in the Nho Quế gorge. '
          'Download offline maps.',
      summary:
          'The classic northern loop over the Đồng Văn karst plateau — '
          'hand-built stone terraces, Hmong market towns and the Mã Pí Lèng '
          'pass above the Nho Quế gorge.',
      plate: Plate(PlateMotif.karst, 41, 'The Đồng Văn plateau'),
      keeperId: 'c-mai',
      days: [
        RouteDay(
          title: 'Into the Fairy Mountains',
          from: 'Hà Giang City',
          to: 'Yên Minh',
          distanceKm: 100,
          gainM: 1450,
          surface: Surface.switchbackAsphalt,
          fuel: 'Tam Sơn (km 45)',
          rest: 'Yên Minh — family guesthouse by the pine forest',
          notes:
              'Stop at Quản Bạ Heaven\'s Gate for the twin-peak view. The pine '
              'pass after Tam Sơn is the best riding of the day.',
        ),
        RouteDay(
          title: 'Onto the Plateau',
          from: 'Yên Minh',
          to: 'Đồng Văn',
          distanceKm: 90,
          gainM: 1200,
          surface: Surface.switchbackAsphalt,
          fuel: 'Yên Minh before departure',
          rest: 'Đồng Văn — Hmong homestay in the old quarter',
          notes:
              'Detour into Sủng Là valley for the earthen homesteads. The '
              'Lũng Cú flag tower adds 50 km round trip.',
        ),
        RouteDay(
          title: 'Mã Pí Lèng',
          from: 'Đồng Văn',
          to: 'Mèo Vạc',
          distanceKm: 40,
          gainM: 600,
          surface: Surface.switchbackAsphalt,
          fuel: 'Đồng Văn (closes 21:00)',
          rest: 'Mèo Vạc — homestay off the market square',
          notes:
              'Short distance, long day. Walk the parapet trail, then descend '
              'to the Nho Quế by boat if the water is high.',
        ),
        RouteDay(
          title: 'The Long Way Down',
          from: 'Mèo Vạc',
          to: 'Hà Giang City',
          distanceKm: 160,
          gainM: 1900,
          surface: Surface.gravel,
          fuel: 'Mậu Duệ (km 50) — fill completely',
          rest: 'Du Già stilt homestay (optional extra night)',
          notes:
              'Fourteen kilometres of gravel near Mậu Duệ after rain. Take the '
              'descents in second gear.',
        ),
      ],
      waypointIds: [
        'w-hagiang',
        'w-quanba',
        'w-yenminh',
        'w-sungla',
        'w-dongvan',
        'w-mapileng',
        'w-meovac',
        'w-dugia',
        'w-hagiang',
      ],
    ),
    RoutePlan(
      id: 'r-maehongson',
      name: 'Mae Hong Son Loop',
      region: 'Mae Hong Son',
      country: 'Thailand',
      mode: TravelMode.motorbike,
      difficulty: 3,
      season: 'Nov–Feb — cool, dry and clear.',
      vehicle:
          '150cc or larger for the Doi Inthanon climb. Route 1095 alone has '
          '762 curves.',
      cash:
          'ATMs in every overnight town. Keep 3,000 THB for national park '
          'fees.',
      connectivity: 'Good 4G except in the deep valleys west of Pai.',
      summary:
          'Northern Thailand\'s mountain circuit: the famous curves to Pai, '
          'cave rivers near Soppong, riverside Mae Sariang and a dawn climb to '
          'the country\'s highest summit.',
      plate: Plate(PlateMotif.karst, 37, 'Mist over the Pai valley'),
      keeperId: 'c-niran',
      days: [
        RouteDay(
          title: 'The 762 Curves',
          from: 'Chiang Mai',
          to: 'Pai',
          distanceKm: 135,
          gainM: 1900,
          surface: Surface.switchbackAsphalt,
          fuel: 'Mae Malai junction',
          rest: 'Pai — bamboo bungalows by the river',
          notes: 'Leave by 08:00 to beat the minivans down the 1095.',
        ),
        RouteDay(
          title: 'Cave River Country',
          from: 'Pai',
          to: 'Mae Hong Son',
          distanceKm: 110,
          gainM: 1600,
          surface: Surface.switchbackAsphalt,
          fuel: 'Soppong',
          rest: 'Mae Hong Son — lakeside guesthouse',
          notes:
              'Raft through Tham Lod cave, and wait at the mouth at dusk for '
              'the swifts.',
        ),
        RouteDay(
          title: 'Teak Towns',
          from: 'Mae Hong Son',
          to: 'Mae Sariang',
          distanceKm: 165,
          gainM: 1300,
          surface: Surface.switchbackAsphalt,
          fuel: 'Khun Yuam',
          rest: 'Mae Sariang — riverside teak house',
          notes:
              'Sunflower fields at Khun Yuam in November; the quietest riding '
              'of the loop.',
        ),
        RouteDay(
          title: 'To the Roof of Thailand',
          from: 'Mae Sariang',
          to: 'Doi Inthanon',
          distanceKm: 150,
          gainM: 2400,
          surface: Surface.switchbackAsphalt,
          fuel: 'Mae Chaem',
          rest: 'Mae Chaem — Karen homestay',
          notes:
              'The summit road gains 2,000 m in 40 km. Check brakes and pack '
              'layers before the climb.',
        ),
        RouteDay(
          title: 'Home Through the Valleys',
          from: 'Doi Inthanon',
          to: 'Chiang Mai',
          distanceKm: 100,
          gainM: 300,
          surface: Surface.switchbackAsphalt,
          fuel: 'Chom Thong',
          rest: 'Chiang Mai',
          notes:
              'Sunrise on the summit, then Wachirathan falls on the way down.',
        ),
      ],
      waypointIds: [
        'w-chiangmai',
        'w-pai',
        'w-soppong',
        'w-maehongson',
        'w-maesariang',
        'w-inthanon',
        'w-chiangmai',
      ],
    ),
    RoutePlan(
      id: 'r-calamianes',
      name: 'Coron to El Nido by Banca',
      region: 'Calamianes',
      country: 'Philippines',
      mode: TravelMode.banca,
      difficulty: 2,
      season: 'Feb–May for the calmest seas.',
      vehicle:
          'Family-run banca with sound outriggers and a life jacket for '
          'every passenger.',
      cash:
          'Small peso notes for community beach fees. El Nido ATMs often run '
          'dry.',
      connectivity:
          'No signal after Culion for most of the crossing. Leave your route '
          'with someone ashore.',
      summary:
          'Five days island-hopping through limestone lagoons, community '
          'beach camps and reef shallows between Busuanga and northern '
          'Palawan.',
      plate: Plate(PlateMotif.islands, 44, 'Limestone islets, Linapacan'),
      keeperId: 'c-paeng',
      days: [
        RouteDay(
          title: 'Lagoons of Coron',
          from: 'Coron Town',
          to: 'Kayangan Lake',
          distanceKm: 22,
          gainM: 0,
          surface: Surface.waterway,
          fuel: 'Coron pier — ice and water',
          rest: 'Beach camp near Kayangan',
          notes: 'Swim Barracuda Lake late, after the day boats have left.',
        ),
        RouteDay(
          title: 'Culion Passage',
          from: 'Kayangan Lake',
          to: 'Culion',
          distanceKm: 35,
          gainM: 0,
          surface: Surface.waterway,
          fuel: 'Culion town',
          rest: 'Culion — pension house by the fort',
          notes: 'Visit the Culion museum: a sobering, essential history.',
        ),
        RouteDay(
          title: 'Into Linapacan',
          from: 'Culion',
          to: 'Linapacan',
          distanceKm: 60,
          gainM: 0,
          surface: Surface.waterway,
          fuel: 'None — carry two days of water',
          rest: 'Community beach camp',
          notes: 'Snorkel the inshore reef at slack tide.',
        ),
        RouteDay(
          title: 'Open Water',
          from: 'Linapacan',
          to: 'Cadlao Island',
          distanceKm: 70,
          gainM: 0,
          surface: Surface.waterway,
          fuel: 'None',
          rest: 'Island camp',
          notes: 'The longest crossing. Leave at first light, before the chop.',
        ),
        RouteDay(
          title: 'Landfall',
          from: 'Cadlao Island',
          to: 'El Nido',
          distanceKm: 12,
          gainM: 0,
          surface: Surface.waterway,
          fuel: 'El Nido',
          rest: 'El Nido town',
          notes: 'Arrive before noon to arrange onward transport.',
        ),
      ],
      waypointIds: [
        'w-coron',
        'w-kayangan',
        'w-culion',
        'w-linapacan',
        'w-elnido',
      ],
    ),
    RoutePlan(
      id: 'r-komodo',
      name: 'Komodo by Phinisi',
      region: 'Flores',
      country: 'Indonesia',
      mode: TravelMode.phinisi,
      difficulty: 2,
      season: 'Apr–Nov, the dry season.',
      vehicle:
          'Licensed phinisi with a registered crew. Ask to see the life rafts '
          'and radio.',
      cash: 'Park fees in rupiah cash; ATMs only in Labuan Bajo.',
      connectivity: 'Patchy near the islands; none in the southern bays.',
      summary:
          'Three days sailing the national park: ridge-top sunrise on Padar, '
          'ranger walks among the dragons and the pink sands of Pantai Merah.',
      plate: Plate(PlateMotif.islands, 52, 'Padar at first light'),
      keeperId: 'c-ayu',
      days: [
        RouteDay(
          title: 'Out of Labuan Bajo',
          from: 'Labuan Bajo',
          to: 'Kanawa Island',
          distanceKm: 15,
          gainM: 0,
          surface: Surface.waterway,
          fuel: 'Labuan Bajo harbour',
          rest: 'Aboard, anchored off Kanawa',
          notes: 'Snorkel the jetty reef at dusk; turtles feed here.',
        ),
        RouteDay(
          title: 'Padar & the Dragons',
          from: 'Kanawa Island',
          to: 'Loh Liang',
          distanceKm: 55,
          gainM: 200,
          surface: Surface.waterway,
          fuel: 'None',
          rest: 'Aboard, Loh Liang bay',
          notes:
              'Padar ridge at sunrise (thirty-minute climb), then a ranger walk '
              'on Komodo by 09:00.',
        ),
        RouteDay(
          title: 'Pink Sand Return',
          from: 'Loh Liang',
          to: 'Labuan Bajo',
          distanceKm: 60,
          gainM: 0,
          surface: Surface.waterway,
          fuel: 'Labuan Bajo',
          rest: 'Labuan Bajo',
          notes: 'Currents near Batu Bolong are strong — snorkel with the crew.',
        ),
      ],
      waypointIds: [
        'w-labuanbajo',
        'w-kanawa',
        'w-padar',
        'w-lohliang',
        'w-pinkbeach',
        'w-labuanbajo',
      ],
    ),
    RoutePlan(
      id: 'r-mekong',
      name: 'Upper Mekong Slow Boat',
      region: 'Bokeo to Luang Prabang',
      country: 'Laos',
      mode: TravelMode.slowBoat,
      difficulty: 1,
      season: 'Nov–Feb, when the water runs low and clear.',
      vehicle: 'Public slow boat. Bring a cushion.',
      cash:
          'Lao kip only on board. ATMs at Huay Xai and Pakbeng are '
          'unreliable.',
      connectivity: 'Signal near villages only.',
      summary:
          'Two unhurried days down the Mekong between forested hills and '
          'roadless villages, with a night in the river town of Pakbeng.',
      plate: Plate(PlateMotif.river, 47, 'Morning fog, Pakbeng'),
      keeperId: 'c-khamla',
      days: [
        RouteDay(
          title: 'Downriver to Pakbeng',
          from: 'Huay Xai',
          to: 'Pakbeng',
          distanceKm: 160,
          gainM: 0,
          surface: Surface.waterway,
          fuel: 'Snacks at Huay Xai market',
          rest: 'Pakbeng — riverside guesthouse',
          notes: 'Board early for the forward seats; the stern is loud.',
        ),
        RouteDay(
          title: 'Pak Ou and the Royal City',
          from: 'Pakbeng',
          to: 'Luang Prabang',
          distanceKm: 170,
          gainM: 0,
          surface: Surface.waterway,
          fuel: 'Pakbeng bakery at 06:30',
          rest: 'Luang Prabang',
          notes: 'Ask to stop at Pak Ou caves; finish by tuk-tuk if you linger.',
        ),
      ],
      waypointIds: ['w-huayxai', 'w-pakbeng', 'w-pakou', 'w-luangprabang'],
    ),
    RoutePlan(
      id: 'r-rinjani',
      name: 'Rinjani Rim Traverse',
      region: 'Lombok',
      country: 'Indonesia',
      mode: TravelMode.trek,
      difficulty: 5,
      season: 'Apr–Dec. The park closes Jan–Mar for the rains.',
      vehicle: 'On foot, with a licensed guide and fairly paid porters.',
      cash: 'Park fee and porter tips in rupiah; no ATM in Sembalun.',
      connectivity: 'Signal on the rim; none at the lake.',
      summary:
          'The great caldera crossing: savanna to the crater rim, a pre-dawn '
          'summit push, a night by the lake\'s hot springs and a long forest '
          'descent to Senaru.',
      plate: Plate(PlateMotif.volcano, 58, 'Barujari from the rim'),
      keeperId: 'c-ayu',
      days: [
        RouteDay(
          title: 'Savanna to the Rim',
          from: 'Sembalun',
          to: 'Pelawangan Sembalun',
          distanceKm: 11,
          gainM: 1500,
          surface: Surface.forestDirt,
          fuel: 'Water at Pos 2 and Pos 3',
          rest: 'Rim camp',
          notes:
              'Hot savanna until Pos 3, then the "hill of regret" climbs '
              '500 m in under 2 km.',
        ),
        RouteDay(
          title: 'Summit & the Lake',
          from: 'Pelawangan Sembalun',
          to: 'Segara Anak',
          distanceKm: 13,
          gainM: 1100,
          surface: Surface.scree,
          fuel: 'Spring water at the lake',
          rest: 'Lake camp by the hot springs',
          notes: 'Summit start 02:00. Turn around at 07:00 regardless.',
        ),
        RouteDay(
          title: 'Forest Descent',
          from: 'Segara Anak',
          to: 'Senaru',
          distanceKm: 11,
          gainM: 650,
          surface: Surface.forestDirt,
          fuel: 'Water at Pos 3 (Senaru side)',
          rest: 'Senaru homestay',
          notes:
              'A steep climb out of the caldera, then a long forest descent. '
              'Poles essential.',
        ),
      ],
      waypointIds: [
        'w-sembalun',
        'w-pelawangan',
        'w-rinjani',
        'w-segaraanak',
        'w-senaru',
      ],
    ),
    RoutePlan(
      id: 'r-batur',
      name: 'Mount Batur Sunrise',
      region: 'Bali',
      country: 'Indonesia',
      mode: TravelMode.trek,
      difficulty: 2,
      season: 'Year-round; clearest Apr–Oct.',
      vehicle: 'On foot. A local guide is required by the community.',
      cash: 'Guide fees in rupiah; small notes for the summit coffee stall.',
      connectivity: 'Good signal throughout.',
      summary:
          'A short pre-dawn climb up an active volcano to watch the sun rise '
          'over Lake Batur and Mount Agung.',
      plate: Plate(PlateMotif.volcano, 63, 'Agung beyond the caldera'),
      keeperId: 'c-ayu',
      days: [
        RouteDay(
          title: 'Headlamps to the Crater',
          from: 'Toya Bungkah',
          to: 'Batur Summit',
          distanceKm: 8,
          gainM: 670,
          surface: Surface.scree,
          fuel: 'Water from your homestay',
          rest: 'Toya Bungkah hot springs, afternoon',
          notes:
              'Start at 03:30. Descend by the crater-rim loop past the steam '
              'vents.',
        ),
      ],
      waypointIds: ['w-toya', 'w-batur', 'w-toya'],
    ),
  ];

  static const stories = <Story>[
    Story(
      id: 's-mapileng',
      title: 'The Fog Does Not Lift at Mã Pí Lèng',
      dek:
          'Four days on the Hà Giang loop, where the road is cut into the '
          'limestone and the clouds keep their own schedule.',
      authorId: 'c-mai',
      region: 'Hà Giang',
      country: 'Vietnam',
      published: '28 Oct 2026',
      readMinutes: 11,
      location: LatLng(23.2315, 105.4078),
      elevationM: 1200,
      climate: 'Subtropical highland · 9–22 °C',
      season: 'Oct–Dec · buckwheat bloom, dry roads',
      cover: Plate(PlateMotif.karst, 3, 'Mã Pí Lèng, before the fog'),
      plates: [
        Plate(PlateMotif.karst, 11, 'Switchbacks above the Nho Quế'),
        Plate(PlateMotif.terraces, 5, 'Buckwheat terraces, Sủng Là'),
        Plate(PlateMotif.karst, 21, 'Heaven\'s Gate, Quản Bạ'),
        Plate(PlateMotif.river, 8, 'The Nho Quế gorge'),
      ],
      paragraphs: [
        'We left Hà Giang City at six, before the trucks, with two litres of '
            'fuel strapped behind the seat because the map promised a station '
            'at Yên Minh and the map has lied to me before. The first climb to '
            'Quản Bạ is gentle — a warm-up the mountains allow you before they '
            'start asking questions.',
        'By the second morning the road had narrowed to a single lane of '
            'patched asphalt pinned to the cliff. Hmong children waved from '
            'doorways cut into the slope; a grandmother sold us boiled eggs '
            'and refused change. The plateau is grey stone stacked into walls '
            'by hand, each terrace holding perhaps a dozen stalks of corn. '
            'Nothing about it is easy, and everything about it is deliberate.',
        'Mã Pí Lèng did not show itself. We arrived into a fog so complete '
            'that the Nho Quế River, eight hundred metres below, existed only '
            'as a sound. We waited an hour on the stone parapet with a family '
            'from Lào Cai, sharing sunflower seeds and guessing at the view. '
            'It never cleared. I have stopped thinking of that as a loss.',
        'Practical notes, since you will ask: ride it the way we did — Quản '
            'Bạ first, Mã Pí Lèng third — so the hardest roads come once your '
            'hands have learned the bike. Carry cash for the whole loop and '
            'budget a spare day for weather. The homestay in Lũng Cú with the '
            'blue gate will dry your boots by the kitchen fire if you ask.',
      ],
      inquiries: [
        Inquiry(
          author: 'Tomás R.',
          message:
              'Was the road past Mèo Vạc paved in late October? Planning the '
              'same loop on a semi-automatic.',
          when: '2 days ago',
        ),
        Inquiry(
          author: 'Mai Thảo Nguyễn',
          message:
              'Paved to Mèo Vạc, then 14 km of gravel near Mậu Duệ after the '
              'rains. A semi-auto is fine — take the descent in second gear.',
          when: '2 days ago',
          fromAuthor: true,
        ),
        Inquiry(
          author: 'Ingrid S.',
          message:
              'Did you need a local guide at the checkpoint near Lũng Cú? '
              'Reading mixed reports.',
          when: '5 hours ago',
        ),
      ],
    ),
    Story(
      id: 's-calamianes',
      title: 'Six Islands and a Broken Outrigger',
      dek:
          'Sailing the Calamianes on a family banca — and the afternoon we '
          'spent lashing bamboo together on a beach with no name.',
      authorId: 'c-paeng',
      region: 'Calamianes',
      country: 'Philippines',
      published: '14 Oct 2026',
      readMinutes: 9,
      location: LatLng(11.6800, 119.9600),
      elevationM: 0,
      climate: 'Tropical maritime · 26–32 °C',
      season: 'Feb–May · dry season, calmest seas',
      cover: Plate(PlateMotif.islands, 4, 'The Tala off Culion'),
      plates: [
        Plate(PlateMotif.islands, 12, 'Reef shallows, Banana Island'),
        Plate(PlateMotif.karst, 31, 'Limestone walls, Kayangan'),
        Plate(PlateMotif.islands, 19, 'The beach with no name'),
        Plate(PlateMotif.islands, 27, 'Night camp, Linapacan'),
      ],
      paragraphs: [
        'Paeng\'s banca is called the Tala — "star" — and it is twelve metres '
            'of marine plywood, bamboo and conviction. We loaded rice, a '
            'cooler of ice, two jerrycans of water and a box of calamansi, and '
            'pushed off from Coron town at first light with the tide.',
        'The islands come at you one after another: limestone fists rising '
            'from water so clear the reef seems to float a metre beneath the '
            'hull. At Banana Island we swam before breakfast. At a cove Paeng '
            'would only describe as "my uncle\'s place" we ate grilled squid '
            'with our hands while his cousin mended a net.',
        'On the third afternoon the starboard outrigger cracked against a '
            'swell. Nobody panicked. Paeng steered for the nearest beach, '
            'produced a coil of nylon cord and a bolo knife, and we spent two '
            'hours splinting bamboo in the shade of a tamarind tree. It was '
            'the best afternoon of the trip.',
        'Plan five days, not four. Bring cash in small notes for island fees, '
            'a dry bag for everything, and reef-safe sunscreen — several '
            'community-managed beaches now check. Signal disappears after '
            'Culion, so tell someone ashore your route.',
      ],
      inquiries: [
        Inquiry(
          author: 'Ana P.',
          message:
              'How did you find a family-run banca rather than a tour '
              'operator?',
          when: '1 week ago',
        ),
        Inquiry(
          author: 'Rafael Dizon',
          message:
              'Ask at the Coron market pier the evening before — and look for '
              'boats whose names are painted by hand.',
          when: '6 days ago',
          fromAuthor: true,
        ),
      ],
    ),
    Story(
      id: 's-rinjani',
      title: 'Before Dawn on the Rim of Rinjani',
      dek:
          'Three days around Lombok\'s great caldera, measured in switchbacks, '
          'porters\' songs and the slow arrival of light over Segara Anak.',
      authorId: 'c-ayu',
      region: 'Lombok',
      country: 'Indonesia',
      published: '30 Sep 2026',
      readMinutes: 13,
      location: LatLng(-8.3935, 116.4590),
      elevationM: 2639,
      climate: 'Tropical alpine · 2–18 °C on the rim',
      season: 'Apr–Dec · park closed Jan–Mar',
      cover: Plate(PlateMotif.volcano, 6, 'The rim at 05:40'),
      plates: [
        Plate(PlateMotif.volcano, 15, 'Headlamps on the summit ridge'),
        Plate(PlateMotif.volcano, 29, 'Barujari smoking in the lake'),
        Plate(PlateMotif.terraces, 17, 'Farmland at Senaru'),
      ],
      paragraphs: [
        'Ayu woke us at two with ginger coffee and a single instruction: '
            '"Small steps, every step." The summit push from Pelawangan is '
            'three hours of volcanic scree that slides back half a pace for '
            'every pace you climb. Headlamps above us wound up the ridge like '
            'a slow constellation.',
        'We did not make the summit. At 3,300 metres the wind arrived from '
            'the south, and Ayu turned us around without discussion or '
            'apology. Two hours later, sitting on the rim with numb fingers, '
            'we watched the sun come up out of the Bali Sea and light the '
            'smoking cone of Barujari in the lake below.',
        'The porters carry thirty kilograms on bamboo poles in rubber '
            'sandals, and they sing on the descent. Ayu\'s cooperative pays '
            'them a fixed wage whether or not clients summit, and packs out '
            'every scrap of rubbish — the rim camps are noticeably cleaner on '
            'their side of the ridge.',
        'Acclimatise for a night in Senaru. Bring proper gloves, a down layer '
            'and trekking poles, and rent nothing at the trailhead you '
            'haven\'t tested. Ask your operator, directly, what they pay their '
            'porters.',
      ],
      inquiries: [
        Inquiry(
          author: 'Leah M.',
          message:
              'Is the Senaru–Sembalun traverse doable in two nights for '
              'reasonably fit hikers?',
          when: '3 weeks ago',
        ),
        Inquiry(
          author: 'Ayu Larasati',
          message:
              'Yes, but you\'ll skip the hot springs. Three nights and your '
              'knees will thank you on the descent.',
          when: '3 weeks ago',
          fromAuthor: true,
        ),
      ],
    ),
    Story(
      id: 's-mekong',
      title: 'Two Days on the Slow Boat',
      dek:
          'From Huay Xai to Luang Prabang at the river\'s own pace — sandbars, '
          'moorings and a village that sells the best sticky rice in Laos.',
      authorId: 'c-khamla',
      region: 'Upper Mekong',
      country: 'Laos',
      published: '12 Sep 2026',
      readMinutes: 10,
      location: LatLng(19.8936, 101.1336),
      elevationM: 330,
      climate: 'Tropical monsoon · 18–32 °C',
      season: 'Nov–Feb · cool, low, clear water',
      cover: Plate(PlateMotif.river, 2, 'Below Pakbeng'),
      plates: [
        Plate(PlateMotif.river, 14, 'A sandbar that moved in March'),
        Plate(PlateMotif.river, 22, 'Fog on the far bank'),
        Plate(PlateMotif.temple, 9, 'Pak Ou caves'),
      ],
      paragraphs: [
        'The boat leaves Huay Xai when it is full, which is a time rather '
            'than a number. Ours was long and low and painted green, with car '
            'seats bolted to the floor and a family\'s living quarters at the '
            'stern — rice cooker, hammock, a grandmother napping through all '
            'of it.',
        'The Mekong here is wide and brown and in no hurry. Khamla keeps a '
            'notebook of every sandbar between Bokeo and Luang Prabang, and '
            'he pointed out channels that had moved since March. Children ran '
            'along the banks to meet us at villages without roads, selling '
            'bananas and crisp sheets of river weed.',
        'We slept at Pakbeng, a single street of guesthouses that exists '
            'entirely because of this river. At dawn the fog sat on the water '
            'so thickly that the far bank disappeared, and monks walked the '
            'street collecting alms in perfect silence.',
        'Buy your ticket at the pier, not online. Bring a cushion, snacks and '
            'a book — or better, nothing, and watch. The second day is the '
            'longer one; ask to be dropped at Pak Ou if you would rather '
            'finish by tuk-tuk.',
      ],
      inquiries: [
        Inquiry(
          author: 'Sam O.',
          message:
              'Do the boats still run on schedule with the dam works '
              'downstream?',
          when: '1 month ago',
        ),
        Inquiry(
          author: 'Khamla Phommachanh',
          message:
              'They run, but times shift with water releases. Ask at the pier '
              'office the afternoon before.',
          when: '1 month ago',
          fromAuthor: true,
        ),
      ],
    ),
    Story(
      id: 's-penang',
      title: 'Midnight in the Five-Foot Ways',
      dek:
          'George Town after dark: clan jetties, charcoal woks and the last '
          'hawkers keeping family recipes alive past midnight.',
      authorId: 'c-hana',
      region: 'Penang',
      country: 'Malaysia',
      published: '2 Oct 2026',
      readMinutes: 8,
      location: LatLng(5.4145, 100.3292),
      elevationM: 3,
      climate: 'Equatorial · 25–32 °C',
      season: 'Dec–Feb · driest evenings',
      cover: Plate(PlateMotif.lanterns, 7, 'Lebuh Chulia, 23:40'),
      plates: [
        Plate(PlateMotif.lanterns, 13, 'The char kway teow brazier'),
        Plate(PlateMotif.lanterns, 24, 'Clan house lanterns'),
        Plate(PlateMotif.islands, 33, 'Chew Jetty at low tide'),
      ],
      paragraphs: [
        'The five-foot ways are the covered walkways that run beneath George '
            'Town\'s shophouses, and after ten at night they belong to the '
            'cooks. Hana met us on Lebuh Chulia with a list of eleven stalls '
            'and a warning that we would not reach the end of it.',
        'Uncle Lim has fried char kway teow over the same charcoal brazier '
            'for forty-one years. He cooks one plate at a time and will not '
            'double the batch, because "the wok forgets." Two doors down, a '
            'granddaughter now runs the lor bak stall her grandmother opened; '
            'she has started writing the recipes down for the first time.',
        'We ended at Chew Jetty, where the clan houses stand on stilts over '
            'the strait and the lanterns hang so low you duck beneath them. A '
            'family was still awake, playing cards beneath a single bulb, and '
            'they invited us to sit. Nobody spoke much of anyone\'s language. '
            'It did not matter.',
        'Go late and go hungry. Carry small notes — most stalls are cash '
            'only. Be quiet on the jetties, because people live there, and '
            'ask before photographing anyone at work.',
      ],
      inquiries: [
        Inquiry(
          author: 'Priya D.',
          message: 'Are the Lebuh Chulia stalls open on Mondays?',
          when: '4 days ago',
        ),
        Inquiry(
          author: 'Hana Aziz',
          message:
              'Most rest on Monday or Tuesday, and it changes stall by stall. '
              'Thursday to Sunday is safest.',
          when: '3 days ago',
          fromAuthor: true,
        ),
      ],
    ),
    Story(
      id: 's-batad',
      title: 'Terraces Above the Cloud Line',
      dek:
          'Walking the Batad amphitheatre with a steward who repairs its stone '
          'walls by hand — and asks you to stay on the dikes.',
      authorId: 'c-joel',
      region: 'Ifugao',
      country: 'Philippines',
      published: '19 Aug 2026',
      readMinutes: 9,
      location: LatLng(16.9693, 121.1080),
      elevationM: 940,
      climate: 'Tropical highland · 15–26 °C',
      season: 'Feb–May planting · Jun–Jul golden harvest',
      cover: Plate(PlateMotif.terraces, 4, 'The Batad amphitheatre'),
      plates: [
        Plate(PlateMotif.terraces, 16, 'A wall rebuilt in an afternoon'),
        Plate(PlateMotif.terraces, 26, 'Late light on the paddies'),
        Plate(PlateMotif.river, 30, 'The pool below Tappiya Falls'),
      ],
      paragraphs: [
        'Batad sits in a bowl of terraces so steep and so complete that the '
            'first sight of it stops conversation. The walls are stone, '
            'centuries old in places, and they leak, and someone has to fix '
            'them. Today that someone was Joel, and we were his help.',
        'We carried flat stones down from a collapsed section, passing them '
            'hand to hand along the dike. Joel set each one with a tap of his '
            'palm, checking the angle by eye. "The mountain moves a little '
            'every rainy season," he said. "We move a little after it."',
        'In the afternoon we walked to Tappiya Falls and swam in water so '
            'cold it rang in our teeth. On the climb back the terraces caught '
            'the late light and turned to green glass, one level reflecting '
            'the next, all the way up into the cloud.',
        'Stay at least two nights; the walk in from the saddle is steep. Keep '
            'to the dikes, never the paddy walls, and pay the environmental '
            'fee at the registration hut — it funds exactly this kind of '
            'repair.',
      ],
      inquiries: [
        Inquiry(
          author: 'Mateo V.',
          message:
              'Can visitors help with wall repairs, or was that a special '
              'arrangement?',
          when: '2 months ago',
        ),
        Inquiry(
          author: 'Joel Dulnuan',
          message:
              'Ask your homestay. Some families welcome help in the dry months '
              '— come ready to get muddy, and to listen.',
          when: '2 months ago',
          fromAuthor: true,
        ),
      ],
    ),
    Story(
      id: 's-bengmealea',
      title: 'The Quiet Hour at Beng Mealea',
      dek:
          'Seventy kilometres from Angkor Wat, a jungle temple where the trees '
          'are still winning — and the villagers who look after it.',
      authorId: 'c-dara',
      region: 'Siem Reap',
      country: 'Cambodia',
      published: '6 Aug 2026',
      readMinutes: 7,
      location: LatLng(13.4762, 104.2383),
      elevationM: 55,
      climate: 'Tropical savanna · 22–34 °C',
      season: 'Nov–Feb · cool and dry',
      cover: Plate(PlateMotif.temple, 3, 'The eastern gopura'),
      plates: [
        Plate(PlateMotif.temple, 12, 'Strangler figs on the gallery'),
        Plate(PlateMotif.temple, 20, 'The causeway at six'),
        Plate(PlateMotif.river, 25, 'The moat, rainy season'),
      ],
      paragraphs: [
        'Beng Mealea was built in the twelfth century and then, for most of '
            'the centuries since, left to the forest. Strangler figs pour over '
            'its galleries like candle wax. Whole towers have folded into '
            'rubble that you cross on wooden walkways, the stones still carved '
            'with lotus and naga.',
        'Dara brought us at six, before the buses from Siem Reap, with an '
            'elder from the nearby village who had played in these ruins as a '
            'boy. He showed us where his grandfather planted rice in the outer '
            'moat, and the gallery where families sheltered during the war.',
        'For an hour we had the temple to ourselves. Gibbons called somewhere '
            'east of the moat. Light came through the collapsed roof in narrow '
            'gold bars, and the only other sound was a woman sweeping leaves '
            'from the causeway, as her family has done for three generations.',
        'Go early or go late. The Angkor pass does not cover Beng Mealea, so '
            'buy the separate ticket at the gate, and hire a guide from the '
            'village cooperative near the entrance — their fees support the '
            'temple\'s maintenance crew.',
      ],
      inquiries: [
        Inquiry(
          author: 'Hugo B.',
          message: 'Can this be combined with Koh Ker in a single day?',
          when: '3 months ago',
        ),
        Inquiry(
          author: 'Dara Chenda',
          message:
              'With an early start and a driver, yes. Koh Ker deserves the '
              'afternoon light.',
          when: '3 months ago',
          fromAuthor: true,
        ),
      ],
    ),
  ];

  static final expeditions = <Expedition>[
    Expedition(
      id: 'x-highpass',
      title: 'Hà Giang High Pass Ride',
      kind: 'Highland motorbike ride',
      region: 'Hà Giang, Vietnam',
      start: DateTime(2026, 12, 6),
      end: DateTime(2026, 12, 10),
      hostId: 'c-mai',
      capacity: 8,
      rosterIds: const ['c-niran', 'c-dara', 'c-hana', 'c-joel'],
      costShare: 'Est. US\$340 · bikes, fuel, homestays',
      meetingPoint: 'Hà Giang City · 07:00 at the rental yard',
      summary:
          'Five days over the Đồng Văn plateau, timed for the last of the '
          'buckwheat bloom, with a rest day among the earthen homesteads of '
          'Sủng Là.',
      plate: const Plate(PlateMotif.karst, 71, 'The plateau in December'),
      routeId: 'r-hagiang',
      checklist: const [
        ChecklistItem('Packing', 'Full-face helmet (or rent a certified one)'),
        ChecklistItem('Packing', 'Waterproof shell and overtrousers'),
        ChecklistItem('Packing', 'Warm mid-layer — nights reach 6 °C'),
        ChecklistItem('Packing', 'Head torch and power bank'),
        ChecklistItem('Vehicle', 'A1 licence + International Driving Permit'),
        ChecklistItem('Vehicle', 'Pre-ride brake and chain check'),
        ChecklistItem('Safety', 'Insurance that covers motorbike riding'),
        ChecklistItem('Safety', 'Offline maps for Hà Giang province'),
        ChecklistItem('Safety', 'Emergency contact shared with the host'),
        ChecklistItem('Visa & logistics', 'Vietnam e-visa approved'),
        ChecklistItem('Visa & logistics', '3,000,000 VND in small notes'),
        ChecklistItem('Visa & logistics', 'Overnight bus from Hà Nội booked'),
      ],
    ),
    Expedition(
      id: 'x-flotilla',
      title: 'Calamianes Coastal Flotilla',
      kind: 'Island sailing flotilla',
      region: 'Coron, Philippines',
      start: DateTime(2027, 1, 16),
      end: DateTime(2027, 1, 21),
      hostId: 'c-paeng',
      capacity: 10,
      rosterIds: const ['c-hana', 'c-joel', 'c-khamla', 'c-ayu', 'c-niran'],
      costShare: 'Est. US\$420 · bancas, crew, meals',
      meetingPoint: 'Coron market pier · 06:00',
      summary:
          'Three family bancas sailing in company from Coron to El Nido, '
          'camping on community-managed beaches along the way.',
      plate: const Plate(PlateMotif.islands, 77, 'Three bancas in company'),
      routeId: 'r-calamianes',
      checklist: const [
        ChecklistItem('Packing', 'Dry bag, 20 litres or larger'),
        ChecklistItem('Packing', 'Reef-safe sunscreen'),
        ChecklistItem('Packing', 'A snorkel mask that fits'),
        ChecklistItem('Packing', 'Sleeping sheet for beach camps'),
        ChecklistItem('Safety', 'Swim check with the skipper'),
        ChecklistItem('Safety', 'Seasickness tablets'),
        ChecklistItem('Safety', 'Insurance that covers water activities'),
        ChecklistItem('Visa & logistics', 'Flight to Busuanga (USU) booked'),
        ChecklistItem('Visa & logistics', 'Pesos in small notes'),
        ChecklistItem('Visa & logistics', 'Onward transport from El Nido'),
      ],
    ),
    Expedition(
      id: 'x-angkor',
      title: 'Angkor Hinterland Walking Survey',
      kind: 'Archaeological walking tour',
      region: 'Siem Reap, Cambodia',
      start: DateTime(2027, 2, 8),
      end: DateTime(2027, 2, 12),
      hostId: 'c-dara',
      capacity: 12,
      rosterIds: const ['c-mai', 'c-khamla', 'c-hana', 'c-niran', 'c-joel'],
      costShare: 'Est. US\$260 · guides, permits, village meals',
      meetingPoint: 'Siem Reap Old Market · 05:30',
      summary:
          'Five dawn walks to outlying temples with village elders, recording '
          'oral histories for the community archive.',
      plate: const Plate(PlateMotif.temple, 81, 'Koh Ker at dawn'),
      checklist: const [
        ChecklistItem('Packing', 'Long trousers and covered shoulders'),
        ChecklistItem('Packing', 'Sun hat and a 2-litre water bottle'),
        ChecklistItem('Packing', 'A notebook — you will be recording stories'),
        ChecklistItem('Safety', 'Stay on cleared paths; demining continues'),
        ChecklistItem('Safety', 'Oral rehydration salts'),
        ChecklistItem('Visa & logistics', 'Cambodia e-visa'),
        ChecklistItem('Visa & logistics', 'Beng Mealea and Koh Ker tickets'),
        ChecklistItem('Visa & logistics', 'US dollars in small notes'),
      ],
    ),
    Expedition(
      id: 'x-mekong',
      title: 'Mekong Homestay Exchange',
      kind: 'Cultural homestay exchange',
      region: 'Luang Prabang, Laos',
      start: DateTime(2027, 3, 5),
      end: DateTime(2027, 3, 11),
      hostId: 'c-khamla',
      capacity: 6,
      rosterIds: const ['c-dara', 'c-paeng'],
      costShare: 'Est. US\$300 · boat, homestays, cooking',
      meetingPoint: 'Huay Xai slow-boat pier · 10:00',
      summary:
          'Downriver by slow boat, then four nights with families in '
          'riverside villages — cooking, fishing and learning to weave.',
      plate: const Plate(PlateMotif.river, 85, 'A village mooring'),
      routeId: 'r-mekong',
      checklist: const [
        ChecklistItem('Packing', 'A small gift from home for host families'),
        ChecklistItem('Packing', 'Modest clothing for temple visits'),
        ChecklistItem('Packing', 'Mosquito repellent'),
        ChecklistItem('Safety', 'Water purification tablets'),
        ChecklistItem('Safety', 'Travel insurance'),
        ChecklistItem('Visa & logistics', 'Lao visa on arrival: USD + photo'),
        ChecklistItem('Visa & logistics', 'Kip for village purchases'),
      ],
    ),
    Expedition(
      id: 'x-rinjani',
      title: 'Rinjani Rim Traverse',
      kind: 'Volcano trek',
      region: 'Lombok, Indonesia',
      start: DateTime(2027, 4, 17),
      end: DateTime(2027, 4, 20),
      hostId: 'c-ayu',
      capacity: 8,
      rosterIds: const ['c-mai', 'c-paeng', 'c-niran'],
      costShare: 'Est. US\$280 · guide, porters, park fees',
      meetingPoint: 'Sembalun park office · 06:00',
      summary:
          'An opening-week traverse of the caldera, with porters on a fair '
          'fixed wage and a pack-out pledge for every gram of rubbish.',
      plate: const Plate(PlateMotif.volcano, 89, 'The rim camp'),
      routeId: 'r-rinjani',
      checklist: const [
        ChecklistItem('Packing', 'Down jacket and gloves'),
        ChecklistItem('Packing', 'Trekking poles'),
        ChecklistItem('Packing', 'Head torch and spare batteries'),
        ChecklistItem('Packing', 'Broken-in boots'),
        ChecklistItem('Safety', 'Acclimatisation night in Senaru'),
        ChecklistItem('Safety', 'Altitude and evacuation insurance'),
        ChecklistItem('Visa & logistics', 'Indonesia e-VOA'),
        ChecklistItem('Visa & logistics', 'Rupiah cash for park fees'),
      ],
    ),
  ];

  /// The five tenets every member of the circle signs up to.
  static const ethos = <(String, String)>[
    (
      'Depth over speed',
      'We value immersion, local dialogue and stillness over ticking off '
          'landmarks.',
    ),
    (
      'Firsthand truth',
      'Every story and route comes from lived experience — honest about '
          'delays, rough roads and remote realities.',
    ),
    (
      'Respect for land & culture',
      'Indigenous homestays, family-run kitchens and leave-no-trace '
          'stewardship come first.',
    ),
    (
      'Reliability in the wild',
      'We share the logistics that matter where connectivity ends: cash, '
          'fuel gaps, offline maps.',
    ),
    (
      'Human camaraderie',
      'We keep companionship safe and respectful for solo and overland '
          'wayfarers alike.',
    ),
  ];
}
