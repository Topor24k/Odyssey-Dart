import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../data/sample.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../../widgets/motion.dart';
import '../../widgets/photo.dart';
import '../app_shell.dart';
import '../compose_sheet.dart';
import '../routes.dart';

/// Your days as a travel journal: your own plans and the events you've
/// joined, day by day down a timeline — the days ahead, or the ones behind.
///
/// A plan stays a plan until you've been; then you can write it up as a
/// journal entry. Taking a plan off the schedule never deletes what you
/// wrote. Taking off an event still to come means leaving it; one that's
/// over stays in your joined events.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const _horizonDays = 30;
  static const _lookBackDays = 90;

  final _store = AppStore.instance;
  int _filter = 0;

  bool get _past => _filter == 3;

  bool _passes(PlanItem item) => switch (_filter) {
    1 => item.eventId == null,
    2 => item.eventId != null,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final now = DateTime.now();
        final days = <(DateTime, List<PlanItem>)>[];
        if (_past) {
          for (var d = 1; d <= _lookBackDays; d++) {
            final day = Sample.today.subtract(Duration(days: d));
            final items = _store.itemsOn(day);
            if (items.isNotEmpty) days.add((day, items));
          }
        } else {
          for (var d = 0; d <= _horizonDays; d++) {
            final day = Sample.today.add(Duration(days: d));
            final items = _store.itemsOn(day).where(_passes).toList();
            if (items.isNotEmpty) days.add((day, items));
          }
        }
        final upNext = _past
            ? null
            : days
                  .expand((g) => g.$2)
                  .where((i) => i.end.isAfter(now))
                  .firstOrNull;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScreenHeader(
                        title: 'Schedule',
                        subtitle: _past
                            ? 'Where you\'ve been'
                            : 'Your days ahead',
                        trailing: RoundIconButton(
                          icon: Icons.add,
                          tooltip: 'Add a plan',
                          onTap: () => _showAddPlan(context),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Segmented(
                        options: const ['All', 'Plans', 'Events', 'Past'],
                        selected: _filter,
                        onChanged: (i) => setState(() => _filter = i),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            if (days.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                  child: Column(
                    children: [
                      Musing(
                        _past
                            ? 'Nothing behind you yet.\nGo somewhere.'
                            : 'Nothing planned yet.\nWander a little.',
                      ),
                      const SizedBox(height: 18),
                      OutlinedButton.icon(
                        onPressed: () => _showAddPlan(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add a plan'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: const BorderSide(color: AppColors.line),
                          backgroundColor: AppColors.card,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                  itemCount: days.length,
                  itemBuilder: (context, i) => Reveal(
                    key: ValueKey('${days[i].$1}-$_filter'),
                    index: i,
                    child: _DayGroup(
                      day: days[i].$1,
                      items: days[i].$2,
                      upNext: upNext,
                      last: i == days.length - 1,
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: navClearance(context))),
          ],
        );
      },
    );
  }
}

/// One day on the timeline: a dated dot, then its entries.
class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.day,
    required this.items,
    required this.upNext,
    required this.last,
  });

  final DateTime day;
  final List<PlanItem> items;
  final PlanItem? upNext;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Rail(
          dot: true,
          lineBelow: true,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(
                  '${weekdayShort(day).toUpperCase()} · ${stampLabel(day)}',
                  style: OdysseyType.caps(10.5, color: AppColors.ink),
                ),
                const SizedBox(width: 10),
                Text(
                  relativeDay(day),
                  style: OdysseyType.display(
                    15,
                    italic: true,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
        for (var i = 0; i < items.length; i++)
          _Rail(
            lineBelow: !(last && i == items.length - 1),
            child: _Entry(item: items[i], upNext: items[i] == upNext),
          ),
      ],
    );
  }
}

/// The timeline rail beside an entry: a hairline, with a dot for days.
class _Rail extends StatelessWidget {
  const _Rail({required this.child, this.dot = false, this.lineBelow = true});

  final Widget child;
  final bool dot;
  final bool lineBelow;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 22,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (lineBelow)
                  Positioned(
                    top: dot ? 8 : 0,
                    bottom: 0,
                    child: Container(width: 1, color: AppColors.line),
                  ),
                if (dot)
                  Positioned(
                    top: 2,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.ink, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.item, required this.upNext});

  final PlanItem item;
  final bool upNext;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final people = [for (final id in item.peopleIds) store.person(id)];
    final event = item.eventId == null ? null : store.event(item.eventId!);
    final photo = event?.photo ?? item.photo;
    final written = item.journalId == null
        ? null
        : store.entry(item.journalId!);
    final attended = event != null && store.attended(event);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: AppCard(
        color: upNext ? AppColors.sage : AppColors.card,
        padding: const EdgeInsets.fromLTRB(14, 8, 6, 14),
        // An event opens in full; a plan opens its details and actions.
        onTap: event != null
            ? () => openEvent(context, event)
            : () => _showPlan(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${clockLabel(item.start)} · ${durationLabel(item.length)}'
                      .toUpperCase(),
                  style: OdysseyType.caps(9.5),
                ),
                const Spacer(),
                if (upNext)
                  const StatusPill(
                    'Up next',
                    background: AppColors.card,
                    foreground: AppColors.sageInk,
                  )
                else if (attended)
                  const StatusPill(
                    'Attended',
                    icon: Icons.verified_outlined,
                    background: AppColors.sage,
                    foreground: AppColors.sageInk,
                  )
                else if (event != null)
                  StatusPill(
                    event.kind.label,
                    icon: event.kind.icon,
                    background: AppColors.tile,
                  )
                else if (written != null)
                  const StatusPill(
                    'In journal',
                    icon: Icons.menu_book_outlined,
                    background: AppColors.tile,
                  ),
                IconButton(
                  onPressed: () => event != null
                      ? _showEventActions(context, item, event)
                      : _showPlan(context, item),
                  icon: const Icon(Icons.more_horiz, size: 20),
                  color: AppColors.muted,
                  tooltip: 'More',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: OdysseyType.display(
                      20,
                      color: AppColors.ink,
                      weight: FontWeight.w500,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.place,
                    style: OdysseyType.sans(13, color: AppColors.body),
                  ),
                  if (photo != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: PhotoImage(photo),
                      ),
                    ),
                  ],
                  if (item.note != null && upNext) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.note!,
                      style: OdysseyType.display(
                        16,
                        italic: true,
                        color: AppColors.body,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (people.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        AvatarStack(people, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          people.length == 1
                              ? 'With ${people.first.firstName}'
                              : 'With ${people.first.firstName} '
                                    '+${people.length - 1}',
                          style: OdysseyType.sans(12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ],
                  if (written != null) ...[
                    const SizedBox(height: 12),
                    _InlineLink(
                      icon: Icons.menu_book_outlined,
                      label: 'Read what you wrote',
                      onTap: () => openEntry(context, written),
                    ),
                  ] else if (store.canWriteUp(item)) ...[
                    const SizedBox(height: 12),
                    _InlineLink(
                      icon: Icons.edit_outlined,
                      label: 'You\'ve been — write about it',
                      strong: true,
                      onTap: () => _writeUp(context, item),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small pill link inside a schedule card.
class _InlineLink extends StatelessWidget {
  const _InlineLink({
    required this.icon,
    required this.label,
    required this.onTap,
    this.strong = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final fg = strong ? Colors.white : AppColors.sageInk;
    return Material(
      color: strong ? AppColors.ink : AppColors.sage,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: OdysseyType.sans(
                  12.5,
                  color: fg,
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

/// Turns a plan you've been on into a journal entry: a story or a note,
/// shared or kept as a private draft.
void _writeUp(BuildContext context, PlanItem item) {
  showWriteSheet(context, from: item, chooseKind: true, share: false);
}

/// Asks before taking something off the schedule. True if confirmed.
Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      backgroundColor: AppColors.canvas,
      title: Text(
        title,
        style: OdysseyType.display(
          24,
          color: AppColors.ink,
          weight: FontWeight.w500,
        ),
      ),
      content: Text(
        body,
        style: OdysseyType.sans(14, color: AppColors.body, height: 1.45),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(false),
          child: Text(
            'Cancel',
            style: OdysseyType.sans(14, color: AppColors.ink),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(true),
          child: Text(
            action,
            style: OdysseyType.sans(
              14,
              color: AppColors.alert,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  return ok ?? false;
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Takes a plan off the schedule, after asking. What you wrote stays.
Future<void> _removePlan(BuildContext context, PlanItem item) async {
  final written = item.journalId != null;
  final ok = await _confirm(
    context,
    title: 'Remove from schedule?',
    body: written
        ? '“${item.title}” comes off your schedule. What you wrote about it '
              'stays in your journal — delete it from the Journal tab if you '
              'want it gone.'
        : '“${item.title}” comes off your schedule.',
    action: 'Remove',
  );
  if (!ok || !context.mounted) return;
  HapticFeedback.mediumImpact();
  AppStore.instance.removePlan(item.id);
  _toast(context, 'Removed from your schedule.');
}

/// Takes an event off the schedule, after asking: leaving it if it's still
/// to come, or just tidying the calendar if it's over.
Future<void> _removeEvent(BuildContext context, TripEvent event) async {
  final store = AppStore.instance;
  final ended = store.hasEnded(event);
  final ok = await _confirm(
    context,
    title: ended ? 'Remove from calendar?' : 'Leave this event?',
    body: ended
        ? 'You attended “${event.title}”. It comes off your calendar but '
              'stays in your joined events.'
        : 'Taking “${event.title}” off your schedule means leaving it, and '
              'your place goes to someone else.',
    action: ended ? 'Remove' : 'Leave',
  );
  if (!ok || !context.mounted) return;
  HapticFeedback.mediumImpact();
  final left = store.removeEventFromSchedule(event.id);
  _toast(
    context,
    left
        ? 'You left ${event.title}.'
        : 'Off your calendar — still in your joined events.',
  );
}

void _showEventActions(BuildContext context, PlanItem item, TripEvent event) {
  final ended = AppStore.instance.hasEnded(event);
  showModalBottomSheet<void>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: OdysseyType.display(
                24,
                color: AppColors.ink,
                weight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _SheetAction(
              icon: Icons.open_in_new,
              label: 'View event',
              onTap: () {
                Navigator.of(sheet).pop();
                openEvent(context, event);
              },
            ),
            _SheetAction(
              icon: ended ? Icons.event_busy_outlined : Icons.logout,
              label: ended ? 'Remove from calendar' : 'Leave event',
              danger: true,
              onTap: () {
                Navigator.of(sheet).pop();
                _removeEvent(context, event);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.alert : AppColors.ink;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: OdysseyType.sans(15, color: color, weight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}

/// A plan's details, and what you can do with it: write it up once you've
/// been, read what you wrote, or take it off the schedule.
void _showPlan(BuildContext context, PlanItem item) {
  final store = AppStore.instance;
  final people = [for (final id in item.peopleIds) store.person(id)];
  final written = item.journalId == null ? null : store.entry(item.journalId!);
  final canWrite = store.canWriteUp(item);
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
            Text(
              '${weekdayShort(item.start)} · ${stampLabel(item.start)} · '
                      '${relativeDay(item.start)}'
                  .toUpperCase(),
              style: OdysseyType.caps(10),
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: OdysseyType.display(
                26,
                color: AppColors.ink,
                weight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _DetailLine(
              Icons.schedule,
              '${timeLabel(item.start)} – ${timeLabel(item.end)} · '
              '${durationLabel(item.length)}',
            ),
            _DetailLine(Icons.place_outlined, item.place),
            if (item.note != null) _DetailLine(Icons.notes, item.note!),
            if (people.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  AvatarStack(people, size: 30, max: 5),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      people.map((p) => p.firstName).join(', '),
                      style: OdysseyType.sans(13, color: AppColors.body),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            if (written != null)
              _WideButton(
                icon: Icons.menu_book_outlined,
                label: 'Open journal entry',
                onTap: () {
                  Navigator.of(sheet).pop();
                  openEntry(context, written);
                },
              )
            else if (canWrite)
              _WideButton(
                icon: Icons.edit_outlined,
                label: 'Turn into a journal entry',
                dark: true,
                onTap: () {
                  Navigator.of(sheet).pop();
                  _writeUp(context, item);
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.tile,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_clock_outlined,
                      size: 18,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Just a plan for now. Once you\'ve been, you can turn '
                        'it into a journal entry with photos.',
                        style: OdysseyType.sans(
                          12.5,
                          color: AppColors.body,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(sheet).pop();
                  _removePlan(context, item);
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove from schedule'),
                style: TextButton.styleFrom(foregroundColor: AppColors.alert),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _WideButton extends StatelessWidget {
  const _WideButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.dark = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.ink;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: dark ? AppColors.ink : AppColors.card,
        shape: StadiumBorder(
          side: dark
              ? BorderSide.none
              : const BorderSide(color: AppColors.line),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: OdysseyType.sans(
                    14.5,
                    color: fg,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: OdysseyType.sans(14, color: AppColors.body, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

void _showAddPlan(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AddPlanSheet(),
  );
}

class _AddPlanSheet extends StatefulWidget {
  const _AddPlanSheet();

  @override
  State<_AddPlanSheet> createState() => _AddPlanSheetState();
}

class _AddPlanSheetState extends State<_AddPlanSheet> {
  final _title = TextEditingController();
  final _place = TextEditingController();
  DateTime _day = Sample.today;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  PlanKind _kind = PlanKind.travel;

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    super.dispose();
  }

  void _save() {
    final store = AppStore.instance;
    store.addPlan(
      PlanItem(
        id: store.newId('plan'),
        title: _title.text.trim(),
        kind: _kind,
        start: _day.add(Duration(hours: _time.hour, minutes: _time.minute)),
        length: const Duration(hours: 1),
        place: _place.text.trim().isEmpty
            ? 'Somewhere new'
            : _place.text.trim(),
      ),
    );
    HapticFeedback.mediumImpact();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text('Added to ${dayLabel(_day)}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _title.text.trim().isNotEmpty;
    Widget picker(IconData icon, String label, VoidCallback onTap) => Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: OdysseyType.sans(14, color: AppColors.ink),
              ),
            ),
          ],
        ),
      ),
    );

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
                'Add a plan',
                style: OdysseyType.display(
                  26,
                  color: AppColors.ink,
                  weight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              SoftField(
                controller: _title,
                hint: 'What are you doing?',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              SoftField(
                controller: _place,
                hint: 'Where?',
                icon: Icons.place_outlined,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  picker(
                    Icons.calendar_today_outlined,
                    dayLabel(_day),
                    () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _day,
                        firstDate: Sample.today,
                        lastDate: Sample.today.add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _day = picked);
                    },
                  ),
                  const SizedBox(width: 10),
                  picker(Icons.schedule, _time.format(context), () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _time,
                    );
                    if (picked != null) setState(() => _time = picked);
                  }),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final k in PlanKind.values.where(
                    (k) => k != PlanKind.event,
                  ))
                    ChoiceChip(
                      label: Text(k.label),
                      avatar: Icon(k.icon, size: 16),
                      selected: k == _kind,
                      onSelected: (_) {
                        setState(() => _kind = k);
                      },
                      showCheckmark: false,
                      selectedColor: AppColors.sage,
                      backgroundColor: AppColors.card,
                      side: const BorderSide(color: AppColors.line),
                      labelStyle: OdysseyType.sans(13, color: AppColors.ink),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  disabledBackgroundColor: AppColors.line,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: ready ? _save : null,
                child: Text(
                  'Add to schedule',
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
