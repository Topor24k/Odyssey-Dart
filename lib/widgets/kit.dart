import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../theme/odyssey_theme.dart';
import 'contours.dart';

// Formatting ─────────────────────────────────────────────────────────────

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String monthName(int month) => _months[month - 1];
String shortMonth(int month) => _months[month - 1].substring(0, 3);
String weekdayShort(DateTime d) => _weekdays[d.weekday - 1];

/// "8:00 AM".
String timeLabel(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
}

/// "08:00" — the field-log clock used on the schedule.
String clockLabel(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "1h 15m", "45 min", "4 days".
String durationLabel(Duration d) {
  if (d.inDays >= 1) return '${d.inDays} ${d.inDays == 1 ? 'day' : 'days'}';
  if (d.inHours == 0) return '${d.inMinutes} min';
  final m = d.inMinutes % 60;
  return m == 0 ? '${d.inHours}h' : '${d.inHours}h ${m}m';
}

/// "Thu, 20 Nov".
String dayLabel(DateTime d) =>
    '${weekdayShort(d)}, ${d.day} ${shortMonth(d.month)}';

/// "Today", "Tomorrow", "In 9 days".
String relativeDay(DateTime d) {
  final days = DateUtils.dateOnly(d)
      .difference(DateUtils.dateOnly(DateTime.now()))
      .inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  if (days < 0) return '${-days} days ago';
  return 'In $days days';
}

/// "N 21.03° · E 105.85°".
String coordLabel(double lat, double lng, {int digits = 2}) =>
    '${lat >= 0 ? 'N' : 'S'} ${lat.abs().toStringAsFixed(digits)}° · '
    '${lng >= 0 ? 'E' : 'W'} ${lng.abs().toStringAsFixed(digits)}°';

// People ─────────────────────────────────────────────────────────────────

/// A round initials avatar in the person's own tint.
class Avatar extends StatelessWidget {
  const Avatar(this.person, {super.key, this.size = 40, this.border});

  final Person person;
  final double size;

  /// Draws a ring around the avatar, e.g. to separate stacked avatars.
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(person.tint, Colors.white, 0.18)!, person.tint],
        ),
        border: border == null
            ? null
            : Border.all(color: border!, width: size > 40 ? 3 : 2),
      ),
      child: Text(
        person.initials,
        style: OdysseyType.sans(
          size * 0.36,
          color: Colors.white,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Overlapping avatars, e.g. who's coming along.
class AvatarStack extends StatelessWidget {
  const AvatarStack(this.people, {super.key, this.size = 26, this.max = 3});

  final List<Person> people;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = people.take(max).toList();
    final overlap = size * 0.34;
    return SizedBox(
      width: shown.isEmpty ? 0 : size + (shown.length - 1) * (size - overlap),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Avatar(shown[i], size: size, border: AppColors.card),
            ),
        ],
      ),
    );
  }
}

// Odyssey motifs ─────────────────────────────────────────────────────────

/// A small field-journal tag: a brass diamond and monospace small caps,
/// like a survey stamp in the margin.
class FieldTag extends StatelessWidget {
  const FieldTag(
    this.text, {
    super.key,
    this.color = AppColors.muted,
    this.diamond = true,
  });

  final String text;
  final Color color;
  final bool diamond;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (diamond) ...[const Diamond(size: 5), const SizedBox(width: 7)],
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: OdysseyType.mono(10, color: color, letterSpacing: 1.6),
          ),
        ),
      ],
    );
  }
}

/// A small brass diamond.
class Diamond extends StatelessWidget {
  const Diamond({super.key, this.size = 6, this.color = AppColors.brass});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785398,
      child: Container(width: size, height: size, color: color),
    );
  }
}

/// A line in Odyssey's literary voice, for empty states and sign-offs.
class Musing extends StatelessWidget {
  const Musing(
    this.text, {
    super.key,
    this.align = TextAlign.center,
    this.size = 19,
  });

  final String text;
  final TextAlign align;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: OdysseyType.display(
        size,
        italic: true,
        color: AppColors.muted,
        height: 1.3,
      ),
    );
  }
}

/// A hairline rule broken by a brass diamond.
class OrnamentRule extends StatelessWidget {
  const OrnamentRule({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Diamond(size: 5),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}

/// Faint topographic contour lines, for a quiet corner of a page.
class ContourPatch extends StatelessWidget {
  const ContourPatch({
    super.key,
    this.seed = 3,
    this.color = AppColors.ink,
    this.opacity = 0.06,
  });

  final int seed;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ContourPainter(seed, color.withValues(alpha: opacity)),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _ContourPainter extends CustomPainter {
  _ContourPainter(this.seed, this.color);

  final int seed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    for (final ring in contourRings(size, seed: seed)) {
      canvas.drawPath(
        ring.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ring.isIndex ? 1.1 : 0.7
          ..color = ring.isIndex
              ? color
              : color.withValues(alpha: color.a * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_ContourPainter old) =>
      old.seed != seed || old.color != color;
}

// Structure ──────────────────────────────────────────────────────────────

/// A round icon button: parchment-white, or obsidian when [dark].
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.badge = false,
    this.size = 44,
    this.filled = true,
    this.dark = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  /// Shows a small brass dot, e.g. unread notifications.
  final bool badge;
  final double size;

  /// A disc behind the icon; otherwise just the icon.
  final bool filled;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: dark
            ? AppColors.ink
            : (filled ? AppColors.card : Colors.transparent),
        shape: CircleBorder(
          side: filled && !dark
              ? const BorderSide(color: AppColors.line)
              : BorderSide.none,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: size * 0.48,
                  color: dark ? Colors.white : AppColors.ink,
                ),
                if (badge)
                  Positioned(
                    top: size * 0.2,
                    right: size * 0.22,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.alert,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.canvas, width: 1.5),
                      ),
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

/// A serif title and a quiet subtitle, at the top of a tab.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: OdysseyType.display(
                  36,
                  color: AppColors.ink,
                  weight: FontWeight.w600,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: OdysseyType.sans(13.5, color: AppColors.muted),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// A serif section title with an optional count or link.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.action,
    this.onAction,
    this.trailingText,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: OdysseyType.display(
              23,
              color: AppColors.ink,
              weight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
        if (trailingText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              trailingText!.toUpperCase(),
              style: OdysseyType.mono(10, color: AppColors.muted),
            ),
          ),
        if (action != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  Text(
                    action!.toUpperCase(),
                    style: OdysseyType.mono(10, color: AppColors.body),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: AppColors.body,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A row of pill tabs, labelled in monospace small caps.
class Segmented extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Semantics(
                button: true,
                selected: i == selected,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onChanged(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: i == selected ? AppColors.ink : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: i == selected ? AppColors.ink : AppColors.line,
                      ),
                    ),
                    child: Text(
                      options[i].toUpperCase(),
                      style: OdysseyType.mono(
                        10.5,
                        color: i == selected ? Colors.white : AppColors.body,
                        weight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A warm white rounded card with a hairline border.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = AppColors.card,
    this.onTap,
    this.radius = 18,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// A soft rounded square holding an icon.
class IconTile extends StatelessWidget {
  const IconTile(
    this.icon, {
    super.key,
    this.size = 40,
    this.background = AppColors.tile,
    this.color = AppColors.ink,
  });

  final IconData icon;
  final double size;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

/// A thin rounded progress bar.
class ThinProgress extends StatelessWidget {
  const ThinProgress(
    this.value, {
    super.key,
    this.color = AppColors.ink,
    this.track = AppColors.line,
    this.height = 4,
  });

  final double value;
  final Color color;
  final Color track;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: ColoredBox(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small label pill, e.g. "STORY" or a place name.
class StatusPill extends StatelessWidget {
  const StatusPill(
    this.text, {
    super.key,
    this.dot = AppColors.brass,
    this.background = AppColors.card,
    this.foreground = AppColors.body,
    this.icon,
  });

  final String text;
  final Color dot;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 12, color: foreground)
          else
            Diamond(size: 5, color: dot),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OdysseyType.mono(
                9.5,
                color: foreground,
                weight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A soft white text field for the in-app forms.
class SoftField extends StatelessWidget {
  const SoftField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.minLines = 1,
    this.maxLines = 1,
    this.icon,
    this.onChanged,
    this.textCapitalization = TextCapitalization.sentences,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final int minLines;
  final int maxLines;
  final IconData? icon;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: OdysseyType.mono(10, color: AppColors.muted),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          style: OdysseyType.sans(15, color: AppColors.ink, height: 1.45),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: OdysseyType.sans(15, color: AppColors.muted),
            filled: true,
            fillColor: AppColors.card,
            prefixIcon: icon == null
                ? null
                : Icon(icon, size: 19, color: AppColors.muted),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            enabledBorder: border(AppColors.line),
            focusedBorder: border(AppColors.brass, 1.3),
          ),
        ),
      ],
    );
  }
}

// Shared actions ─────────────────────────────────────────────────────────

/// Add → Requested → Friends.
class FriendButton extends StatelessWidget {
  const FriendButton(this.person, {super.key, this.compact = false});

  final Person person;

  /// A smaller pill for lists.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final status = store.statusOf(person.id);
        final (label, icon, dark) = switch (status) {
          FriendStatus.none => ('Add', Icons.person_add_alt_1_outlined, true),
          FriendStatus.requested => ('Requested', Icons.schedule, false),
          FriendStatus.friends => ('Friends', Icons.check, false),
        };
        return _PillAction(
          label: label,
          icon: icon,
          dark: dark,
          compact: compact,
          onTap: () {
            HapticFeedback.lightImpact();
            switch (status) {
              case FriendStatus.none:
                store.addFriend(person.id);
              case FriendStatus.requested:
                break;
              case FriendStatus.friends:
                store.removeFriend(person.id);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('Removed ${person.firstName} as a friend.'),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: AppColors.brassLight,
                        onPressed: () => store.addFriend(person.id),
                      ),
                    ),
                  );
            }
          },
        );
      },
    );
  }
}

/// Join → Going, for an event.
class JoinButton extends StatelessWidget {
  const JoinButton(this.event, {super.key, this.compact = true});

  final TripEvent event;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final going = store.isJoined(event.id);
        return _PillAction(
          label: going ? 'Going' : 'Join',
          icon: going ? Icons.check : Icons.add,
          dark: !going,
          compact: compact,
          onTap: () {
            HapticFeedback.lightImpact();
            store.toggleJoin(event.id);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    store.isJoined(event.id)
                        ? 'You\'re going — added to your schedule.'
                        : 'You left ${event.title}.',
                  ),
                ),
              );
          },
        );
      },
    );
  }
}

class _PillAction extends StatelessWidget {
  const _PillAction({
    required this.label,
    required this.icon,
    required this.dark,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool dark;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.ink;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Material(
        key: ValueKey(label),
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
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 18,
              vertical: compact ? 7 : 11,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: compact ? 14 : 17,
                  color: dark ? AppColors.brassLight : fg,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: OdysseyType.sans(
                    compact ? 12.5 : 14,
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
