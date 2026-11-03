import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../data/sample.dart';
import '../../theme/odyssey_theme.dart';
import '../../widgets/kit.dart';
import '../app_shell.dart';
import '../routes.dart';

/// Your days: a week strip and a timeline of your own travel plans and the
/// events you've joined.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const _origin = 500;

  final _store = AppStore.instance;
  final _weeks = PageController(initialPage: _origin);
  DateTime _selected = Sample.today;
  int _filter = 0;

  DateTime get _thisWeek =>
      Sample.today.subtract(Duration(days: Sample.today.weekday - 1));

  DateTime _weekStart(int page) =>
      _thisWeek.add(Duration(days: (page - _origin) * 7));

  int _pageFor(DateTime day) =>
      _origin +
      (DateUtils.dateOnly(day).difference(_thisWeek).inDays / 7).floor();

  @override
  void dispose() {
    _weeks.dispose();
    super.dispose();
  }

  void _select(DateTime day) {
    HapticFeedback.selectionClick();
    setState(() => _selected = DateUtils.dateOnly(day));
    final page = _pageFor(day);
    if (_weeks.hasClients && _weeks.page?.round() != page) {
      _weeks.animateToPage(
        page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: Sample.today.subtract(const Duration(days: 365)),
      lastDate: Sample.today.add(const Duration(days: 365)),
    );
    if (picked != null) _select(picked);
  }

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
        final items = _store.itemsOn(_selected).where(_passes).toList();
        final now = DateTime.now();
        final focus = DateUtils.isSameDay(_selected, now)
            ? items.where((i) => i.start.add(i.length).isAfter(now)).firstOrNull
            : null;

        return Stack(
          children: [
            const Positioned(
              top: 0,
              right: -60,
              width: 280,
              height: 300,
              child: ContourPatch(seed: 5, opacity: 0.07),
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScreenHeader(
                            title: 'Schedule',
                            subtitle: 'Your route, day by day.',
                            trailing: RoundIconButton(
                              icon: Icons.calendar_month_outlined,
                              tooltip: 'Pick a date',
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              InkWell(
                                onTap: _pickDate,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${monthName(_selected.month)} '
                                        '${_selected.year}',
                                        style: OdysseyType.display(
                                          23,
                                          color: AppColors.ink,
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.ink,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              FieldTag(
                                '${items.length} '
                                '${items.length == 1 ? 'entry' : 'entries'}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 80,
                            child: PageView.builder(
                              controller: _weeks,
                              onPageChanged: (page) {
                                final start = _weekStart(page);
                                if (_selected.isBefore(start) ||
                                    !_selected.isBefore(
                                      start.add(const Duration(days: 7)),
                                    )) {
                                  setState(
                                    () => _selected = start.add(
                                      Duration(days: _selected.weekday - 1),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context, page) {
                                final start = _weekStart(page);
                                return Row(
                                  children: [
                                    for (var d = 0; d < 7; d++)
                                      Expanded(
                                        child: _DayCell(
                                          day: start.add(Duration(days: d)),
                                          selected: DateUtils.isSameDay(
                                            start.add(Duration(days: d)),
                                            _selected,
                                          ),
                                          busy: _store.hasItemsOn(
                                            start.add(Duration(days: d)),
                                          ),
                                          onTap: _select,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Divider(),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Segmented(
                                  options: const ['All', 'My plans', 'Events'],
                                  selected: _filter,
                                  onChanged: (i) => setState(() => _filter = i),
                                ),
                              ),
                              const SizedBox(width: 8),
                              RoundIconButton(
                                icon: Icons.add,
                                tooltip: 'Add a plan',
                                size: 40,
                                onTap: () => _showAddPlan(context, _selected),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${relativeDay(_selected)} · ${dayLabel(_selected)}',
                            style: OdysseyType.sans(
                              13,
                              color: AppColors.muted,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: _EmptyDay(
                      onAdd: () => _showAddPlan(context, _selected),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.separated(
                      itemCount: items.length,
                      itemBuilder: (context, i) => _TimelineRow(
                        item: items[i],
                        focused: items[i] == focus,
                      ),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SizedBox(height: navClearance(context) + 12),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.busy,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool busy;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.isSameDay(day, DateTime.now());
    final fg = selected ? Colors.white : AppColors.ink;
    return Semantics(
      button: true,
      selected: selected,
      label: dayLabel(day),
      child: GestureDetector(
        onTap: () => onTap(day),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.ink
                : (today ? AppColors.card : Colors.transparent),
            borderRadius: BorderRadius.circular(14),
            border: today && !selected
                ? Border.all(color: AppColors.line)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekdayShort(day),
                style: OdysseyType.sans(
                  12.5,
                  color: selected ? Colors.white70 : AppColors.muted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${day.day}',
                style: OdysseyType.sans(17, color: fg, weight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: busy
                      ? (selected ? AppColors.brassLight : AppColors.brass)
                      : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item, required this.focused});

  final PlanItem item;

  /// The item happening now or next, drawn in sage.
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final people = [for (final id in item.peopleIds) store.person(id)];
    final meta = item.eventId == null
        ? '${item.kind.label} · ${durationLabel(item.length)}'
        : 'Event · ${durationLabel(item.length)}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Text(
              clockLabel(item.start),
              style: OdysseyType.mono(
                12.5,
                color: AppColors.body,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
        Expanded(
          child: AppCard(
            color: focused ? AppColors.sage : AppColors.card,
            onTap: () => _showDetails(context, item),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconTile(
                      item.kind.icon,
                      size: 38,
                      background: focused
                          ? Colors.white.withValues(alpha: 0.55)
                          : AppColors.tile,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (item.eventId != null) ...[
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.sageInk,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 7),
                              ],
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: OdysseyType.sans(
                                    14.5,
                                    color: AppColors.ink,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            meta,
                            style: OdysseyType.sans(12, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    if (people.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      AvatarStack(people, size: 24),
                    ],
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ],
                ),
                if (item.note != null && focused) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.note!,
                      style: OdysseyType.sans(
                        13,
                        color: AppColors.body,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        children: [
          const Musing('A free day.\nWander a little.', size: 22),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add a plan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              side: const BorderSide(color: AppColors.line),
              backgroundColor: AppColors.card,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: OdysseyType.sans(14, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

void _showDetails(BuildContext context, PlanItem item) {
  final store = AppStore.instance;
  final people = [for (final id in item.peopleIds) store.person(id)];
  final end = item.start.add(item.length);
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
            Row(
              children: [
                IconTile(item.kind.icon, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: OdysseyType.sans(
                      19,
                      color: AppColors.ink,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailLine(
              Icons.schedule,
              item.length.inDays >= 1
                  ? '${dayLabel(item.start)} · ${durationLabel(item.length)}'
                  : '${timeLabel(item.start)} – ${timeLabel(end)} · '
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
            if (item.eventId != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(sheet).pop();
                    openEvent(context, store.event(item.eventId!));
                  },
                  child: Text(
                    'View event',
                    style: OdysseyType.sans(
                      14,
                      color: Colors.white,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
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

void _showAddPlan(BuildContext context, DateTime day) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AddPlanSheet(day: day),
  );
}

class _AddPlanSheet extends StatefulWidget {
  const _AddPlanSheet({required this.day});

  final DateTime day;

  @override
  State<_AddPlanSheet> createState() => _AddPlanSheetState();
}

class _AddPlanSheetState extends State<_AddPlanSheet> {
  final _title = TextEditingController();
  final _place = TextEditingController();
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
        start: widget.day.add(
          Duration(hours: _time.hour, minutes: _time.minute),
        ),
        length: const Duration(hours: 1),
        place: _place.text.trim().isEmpty
            ? 'Somewhere new'
            : _place.text.trim(),
      ),
    );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text('Added to ${dayLabel(widget.day)}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _title.text.trim().isNotEmpty;
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
                'Add to ${dayLabel(widget.day)}',
                style: OdysseyType.sans(
                  20,
                  color: AppColors.ink,
                  weight: FontWeight.w700,
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
                      onSelected: (_) => setState(() => _kind = k),
                      showCheckmark: false,
                      selectedColor: AppColors.sage,
                      backgroundColor: AppColors.card,
                      side: const BorderSide(color: AppColors.line),
                      labelStyle: OdysseyType.sans(13, color: AppColors.ink),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              AppCard(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (picked != null) setState(() => _time = picked);
                },
                child: Row(
                  children: [
                    const Icon(Icons.schedule, color: AppColors.muted),
                    const SizedBox(width: 10),
                    Text(
                      'Starts at ${_time.format(context)}',
                      style: OdysseyType.sans(14.5, color: AppColors.ink),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppColors.muted),
                  ],
                ),
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
