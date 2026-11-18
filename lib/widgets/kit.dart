import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../data/models.dart';
import '../theme/odyssey_theme.dart';
import 'contours.dart';
import 'motion.dart';

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

/// "08:00".
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

/// "NOV 20".
String stampLabel(DateTime d) =>
    '${shortMonth(d.month).toUpperCase()} ${d.day}';

/// "Today", "Tomorrow", "Yesterday", "In 9 days".
String relativeDay(DateTime d) {
  final days = DateUtils.dateOnly(d)
      .difference(DateUtils.dateOnly(DateTime.now()))
      .inDays;
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  if (days == -1) return 'Yesterday';
  if (days < 0) return '${-days} days ago';
  return 'In $days days';
}

/// "N 21.03° · E 105.85°".
String coordLabel(double lat, double lng, {int digits = 2}) =>
    '${lat >= 0 ? 'N' : 'S'} ${lat.abs().toStringAsFixed(digits)}° · '
    '${lng >= 0 ? 'E' : 'W'} ${lng.abs().toStringAsFixed(digits)}°';

// Brand ──────────────────────────────────────────────────────────────────

/// The ODYSSEY wordmark in wide-set capitals.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.size = 21, this.color = AppColors.ink});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'ODYSSEY',
      style: OdysseyType.display(
        size,
        color: color,
        weight: FontWeight.w500,
        letterSpacing: size * 0.32,
        height: 1,
      ),
    );
  }
}

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

/// Small tracked capitals, optionally led by a teal dot.
class FieldTag extends StatelessWidget {
  const FieldTag(
    this.text, {
    super.key,
    this.color = AppColors.muted,
    this.dot = false,
  });

  final String text;
  final Color color;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
        ],
        Flexible(
          child: Text(
            text.toUpperCase(),
            style: OdysseyType.caps(10, color: color),
          ),
        ),
      ],
    );
  }
}

/// A small diamond.
class Diamond extends StatelessWidget {
  const Diamond({super.key, this.size = 6, this.color = AppColors.ink});

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

/// A short hairline, as under a title on a printed page.
class OrnamentRule extends StatelessWidget {
  const OrnamentRule({super.key, this.width = 40});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(width: width, height: 1, color: AppColors.muted);
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

/// "8 Days | 6 Places | 142 Moments": icon, figure and label, divided.
class StatsStrip extends StatelessWidget {
  const StatsStrip(this.stats, {super.key});

  final List<(IconData, String, String)> stats;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const VerticalDivider(width: 1, color: AppColors.line),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(stats[i].$1, size: 18, color: AppColors.ink),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats[i].$2,
                          style: OdysseyType.sans(
                            17,
                            color: AppColors.ink,
                            weight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          stats[i].$3,
                          style: OdysseyType.sans(11.5, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Structure ──────────────────────────────────────────────────────────────

/// A round icon button: warm white, or deep teal when [dark].
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

  /// Shows a small dot, e.g. unread notifications.
  final bool badge;
  final double size;

  /// A disc behind the icon; otherwise just the icon.
  final bool filled;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Press(
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
                          border: Border.all(
                            color: AppColors.canvas,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A serif title over small tracked capitals, at the top of a tab.
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
                  weight: FontWeight.w500,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 6),
              Text(subtitle.toUpperCase(), style: OdysseyType.caps(10)),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// A serif section title with an optional count or chevron link.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.onAction,
    this.trailingText,
  });

  final String title;
  final VoidCallback? onAction;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAction,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: OdysseyType.display(
                  23,
                  color: AppColors.ink,
                  weight: FontWeight.w500,
                  height: 1.1,
                ),
              ),
            ),
            if (trailingText != null)
              Text(trailingText!.toUpperCase(), style: OdysseyType.caps(9.5)),
            if (onAction != null)
              const Icon(Icons.chevron_right, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}

/// Tracked-capital text tabs with a teal underline that slides to the
/// selected one.
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
              padding: const EdgeInsets.only(right: 22),
              child: Semantics(
                button: true,
                selected: i == selected,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (i == selected) return;
                    HapticFeedback.selectionClick();
                    onChanged(i);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: OdysseyType.caps(
                            10.5,
                            color: i == selected
                                ? AppColors.ink
                                : AppColors.muted,
                            weight: i == selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          child: Text(options[i].toUpperCase()),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          height: 2,
                          width: i == selected ? 22 : 0,
                          color: AppColors.ink,
                        ),
                      ],
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

/// A warm white card with a soft shadow. It sinks a little when tapped.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = AppColors.card,
    this.onTap,
    this.radius = 16,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Press(
      enabled: onTap != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F1D3C37),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: const BorderSide(color: AppColors.line, width: 0.6),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
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

/// A thin rounded progress bar that eases to its value.
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
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0, 1)),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => FractionallySizedBox(
                widthFactor: v,
                child: ColoredBox(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small capitals label pill, e.g. "STORY" or a place name.
class StatusPill extends StatelessWidget {
  const StatusPill(
    this.text, {
    super.key,
    this.dot = AppColors.sageInk,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OdysseyType.caps(
                9.5,
                color: foreground,
                letterSpacing: 1.4,
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
          Text(label!.toUpperCase(), style: OdysseyType.caps(10)),
          const SizedBox(height: 7),
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
            focusedBorder: border(AppColors.ink, 1.3),
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
                        textColor: AppColors.sage,
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
        if (store.hasEnded(event)) {
          // Over: the host has marked who was there.
          return _PillAction(
            label: going ? 'Attended' : 'Ended',
            icon: going ? Icons.verified_outlined : Icons.history,
            dark: false,
            compact: compact,
            onTap: () => ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    going
                        ? 'You were there — ${store.person(event.hostId).firstName} marked you as attended.'
                        : 'This event is over.',
                  ),
                ),
              ),
          );
        }
        return _PillAction(
          label: going ? 'Going' : 'Join',
          icon: going ? Icons.check : Icons.add,
          dark: !going,
          compact: compact,
          onTap: () {
            HapticFeedback.lightImpact();
            store.toggleJoin(event.id);
            final joined = store.isJoined(event.id);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    joined
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
    return Press(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutBack,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: Tween(begin: 0.85, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Material(
          key: ValueKey(label),
          color: dark ? AppColors.ink : AppColors.sage,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 13 : 18,
                vertical: compact ? 7 : 11,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: compact ? 14 : 17, color: fg),
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
      ),
    );
  }
}
