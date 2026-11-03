import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/atlas.dart';
import '../../data/geo.dart';
import '../../data/models.dart';
import '../../data/odyssey_store.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/companion_widgets.dart';
import '../../widgets/cover_flow.dart';
import '../../widgets/journal.dart';
import '../../widgets/landscape_plate.dart';
import '../navigation.dart';

const _numerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII'];

/// A single chronicle: plate, telemetry, the memoir itself, archival plates
/// in cover flow and the reader inquiries beneath.
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key, required this.story, this.heroTag});

  final Story story;
  final String? heroTag;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final _store = OdysseyStore.instance;
  final _inquiry = TextEditingController();
  int _plate = 0;

  Story get story => widget.story;

  @override
  void dispose() {
    _inquiry.dispose();
    super.dispose();
  }

  void _send(Companion author) {
    final text = _inquiry.text.trim();
    if (text.isEmpty) return;
    _store.postInquiry(story.id, text);
    _inquiry.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Inquiry sent to ${author.name.split(' ').first}.'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final author = Atlas.companion(story.authorId);
    final plate = LandscapePlate(story.cover);
    return Scaffold(
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) => CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: 380,
              backgroundColor: OdysseyColors.forest,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              automaticallyImplyLeading: false,
              leading: PlateIconButton(
                icon: Icons.arrow_back,
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              actions: [
                PlateIconButton(
                  icon: _store.isSaved(story.id)
                      ? Icons.bookmark
                      : Icons.bookmark_outline,
                  tooltip: 'Save to journal',
                  onPressed: () => _store.toggleSaved(story.id),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.heroTag == null
                        ? plate
                        : Hero(tag: widget.heroTag!, child: plate),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x66141D15), Colors.transparent],
                          stops: [0, 0.35],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      bottom: 18,
                      child: Kicker('Plate I — ${story.cover.caption}',
                          color: OdysseyColors.parchment),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Kicker('${story.country} · ${story.region}'),
                    const SizedBox(height: 8),
                    Text(story.title,
                        style: OdysseyType.display(34,
                            weight: FontWeight.w600, height: 1.06)),
                    const SizedBox(height: 10),
                    Text(story.dek,
                        style: OdysseyType.prose(18.5,
                            italic: true, color: OdysseyColors.inkSoft)),
                    const SizedBox(height: 18),
                    _Byline(author: author, story: story),
                    const SizedBox(height: 22),
                    TelemetryPanel(
                      cells: [
                        ('Latitude', formatLat(story.location.latitude)),
                        ('Longitude', formatLng(story.location.longitude)),
                        ('Elevation', formatElevation(story.elevationM)),
                        ('Filed', story.published),
                        ('Climate', story.climate),
                        ('Season', story.season),
                      ],
                      footer: _LocateButton(
                        onTap: () => showOnMap(
                          context,
                          MapFocus.point(story.location, story.title),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    for (var i = 0; i < 2; i++) _Paragraph(story.paragraphs[i], lead: i == 0),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeading(
                kicker: 'Archival photography',
                title: 'Plates from the field',
                trailing: '${story.plates.length} plates',
              ),
            ),
            SliverToBoxAdapter(
              child: CoverFlow(
                height: 270,
                viewportFraction: 0.7,
                itemCount: story.plates.length,
                onPageChanged: (i) => setState(() => _plate = i),
                itemBuilder: (context, i, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LandscapePlate(story.plates[i]),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 2, 22, 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    'PLATE ${_numerals[_plate + 1]} — '
                    '${story.plates[_plate].caption.toUpperCase()}',
                    key: ValueKey(_plate),
                    textAlign: TextAlign.center,
                    style: OdysseyType.mono(9.5, letterSpacing: 1.6),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Column(
                  children: [
                    for (final p in story.paragraphs.skip(2)) _Paragraph(p),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                child: _AuthorCard(author: author),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeading(
                kicker: 'Reader inquiries',
                title: 'Ask the author',
                trailing: '${_store.inquiriesFor(story).length} notes',
              ),
            ),
            SliverList.list(
              children: [
                for (final q in _store.inquiriesFor(story)) _InquiryTile(q),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    22, 8, 10, 28 + MediaQuery.paddingOf(context).bottom),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inquiry,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        style: OdysseyType.prose(16.5),
                        decoration: InputDecoration(
                          hintText: 'Ask about road conditions, seasons…',
                          hintStyle: OdysseyType.prose(16.5,
                              italic: true, color: OdysseyColors.inkSoft),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: OdysseyColors.rule),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: OdysseyColors.brass),
                          ),
                        ),
                        onSubmitted: (_) => _send(author),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Send inquiry',
                      icon: const Icon(Icons.send_outlined,
                          color: OdysseyColors.brass),
                      onPressed: () => _send(author),
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

class _Byline extends StatelessWidget {
  const _Byline({required this.author, required this.story});

  final Companion author;
  final Story story;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showCompanionSheet(context, author),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Monogram(author, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(author.name,
                    style: OdysseyType.display(18, weight: FontWeight.w600)),
                Text(
                  '${author.role.toUpperCase()} · ${story.published.toUpperCase()}'
                  ' · ${story.readMinutes} MIN',
                  style: OdysseyType.mono(9, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocateButton extends StatelessWidget {
  const _LocateButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.my_location,
              size: 15, color: OdysseyColors.brassLight),
          const SizedBox(width: 8),
          Text('LOCATE ON THE MAP',
              style: OdysseyType.mono(10,
                  color: OdysseyColors.brassLight, letterSpacing: 1.8)),
          const Spacer(),
          const Icon(Icons.arrow_forward,
              size: 15, color: OdysseyColors.brassLight),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text, {this.lead = false});

  final String text;

  /// Sets the opening words in small capitals, as a printed memoir would.
  final bool lead;

  @override
  Widget build(BuildContext context) {
    final style = OdysseyType.prose(18.5);
    Widget body = Text(text, style: style);
    if (lead) {
      final words = text.split(' ');
      final opening = words.take(4).join(' ');
      body = Text.rich(TextSpan(children: [
        TextSpan(
          text: opening.toUpperCase(),
          style: style.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontSize: 16,
            color: OdysseyColors.forest,
          ),
        ),
        TextSpan(text: ' ${words.skip(4).join(' ')}', style: style),
      ]));
    }
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: body);
  }
}

class _AuthorCard extends StatelessWidget {
  const _AuthorCard({required this.author});

  final Companion author;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OdysseyColors.parchmentDeep,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OdysseyColors.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Kicker('About the author'),
          const SizedBox(height: 10),
          Row(
            children: [
              Monogram(author, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => showCompanionSheet(context, author),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author.name,
                          style: OdysseyType.display(19,
                              weight: FontWeight.w600)),
                      Text(author.role.toUpperCase(),
                          style: OdysseyType.subtitle(11.5,
                              color: OdysseyColors.brass, letterSpacing: 2)),
                    ],
                  ),
                ),
              ),
              ConnectButton(author),
            ],
          ),
          const SizedBox(height: 10),
          Text(author.bio,
              style: OdysseyType.prose(15.5, color: OdysseyColors.inkSoft)),
        ],
      ),
    );
  }
}

class _InquiryTile extends StatelessWidget {
  const _InquiryTile(this.inquiry);

  final Inquiry inquiry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(inquiry.fromAuthor ? 40 : 22, 0, 22, 12),
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
      decoration: BoxDecoration(
        color: inquiry.fromAuthor
            ? OdysseyColors.parchmentDeep
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color:
                inquiry.fromAuthor ? OdysseyColors.brass : OdysseyColors.rule,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(inquiry.author,
                  style: OdysseyType.mono(10,
                      color: OdysseyColors.ink, weight: FontWeight.w500)),
              if (inquiry.fromAuthor) ...[
                const SizedBox(width: 8),
                Text('AUTHOR',
                    style: OdysseyType.mono(8,
                        color: OdysseyColors.brass, letterSpacing: 1.6)),
              ],
              const Spacer(),
              Text(inquiry.when, style: OdysseyType.mono(9)),
            ],
          ),
          const SizedBox(height: 4),
          Text(inquiry.message, style: OdysseyType.prose(16)),
        ],
      ),
    );
  }
}
