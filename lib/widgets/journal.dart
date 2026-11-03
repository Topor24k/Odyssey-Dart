import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/odyssey_theme.dart';

/// Small uppercase monospace label that heads a block, like a survey stamp.
class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key, this.color = OdysseyColors.brass});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: OdysseyType.mono(10, color: color, letterSpacing: 2),
      );
}

/// Masthead for each of the five pillar tabs.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.kicker,
    required this.title,
    required this.subtitle,
  });

  final String kicker;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Kicker(kicker),
                const Spacer(),
                const Icon(Icons.explore_outlined,
                    size: 18, color: OdysseyColors.brass),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: OdysseyType.display(40, height: 1.05)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: OdysseyType.prose(16.5,
                    italic: true, color: OdysseyColors.inkSoft)),
            const SizedBox(height: 14),
            const OrnamentRule(),
          ],
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.kicker,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(22, 28, 22, 12),
  });

  final String kicker;
  final String title;
  final String? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Kicker(kicker),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(title,
                    style: OdysseyType.display(26, weight: FontWeight.w600)),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(trailing!.toUpperCase(),
                      style: OdysseyType.mono(9.5, letterSpacing: 1.4)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
}

/// A hairline rule with a brass diamond at its centre.
class OrnamentRule extends StatelessWidget {
  const OrnamentRule({super.key, this.color = OdysseyColors.rule});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 0.8, color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(width: 5, height: 5, color: OdysseyColors.brass),
          ),
        ),
        Expanded(child: Container(height: 0.8, color: color)),
      ],
    );
  }
}

/// A companion's initials in a brass-ringed obsidian seal.
class Monogram extends StatelessWidget {
  const Monogram(this.companion, {super.key, this.size = 44});

  final Companion companion;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          MonogramSeal(initials: companion.initials, size: size),
          if (companion.verified && size >= 36)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * 0.34,
                height: size * 0.34,
                decoration: BoxDecoration(
                  color: OdysseyColors.brass,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: OdysseyColors.parchment, width: 1.5),
                ),
                child: Icon(Icons.check,
                    size: size * 0.2, color: OdysseyColors.parchment),
              ),
            ),
        ],
      ),
    );
  }
}

class MonogramSeal extends StatelessWidget {
  const MonogramSeal({
    super.key,
    required this.initials,
    this.size = 44,
    this.background = OdysseyColors.forest,
  });

  final String initials;
  final double size;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(
          color: OdysseyColors.brass,
          width: size > 30 ? 1.2 : 0.8,
        ),
      ),
      child: Text(
        initials,
        style: OdysseyType.display(
          size * 0.38,
          color: OdysseyColors.brassLight,
          weight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

/// Five diamonds, filled up to [level].
class DifficultyMeter extends StatelessWidget {
  const DifficultyMeter(this.level, {super.key, this.size = 7});

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Padding(
            padding: EdgeInsets.only(right: size * 0.55),
            child: Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: i <= level ? OdysseyColors.brass : null,
                  border: Border.all(color: OdysseyColors.brass, width: 0.9),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Labelled readouts in mono on obsidian — the field telemetry panel.
class TelemetryPanel extends StatelessWidget {
  const TelemetryPanel({super.key, required this.cells, this.footer});

  final List<(String label, String value)> cells;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: OdysseyColors.forest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OdysseyColors.brass.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: OdysseyColors.brassLight,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Kicker('Expedition telemetry',
                  color: OdysseyColors.brassLight),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cell = (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  for (final (label, value) in cells)
                    SizedBox(
                      // Long readouts take the full row.
                      width: value.length > 22 ? constraints.maxWidth : cell,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label.toUpperCase(),
                              style: OdysseyType.mono(8.5,
                                  color: OdysseyColors.brass,
                                  letterSpacing: 1.8)),
                          const SizedBox(height: 3),
                          Text(value,
                              style: OdysseyType.mono(12.5,
                                  color: OdysseyColors.parchment,
                                  letterSpacing: 0.4)),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          if (footer != null) ...[const SizedBox(height: 14), footer!],
        ],
      ),
    );
  }
}

/// A row of pill filters.
class FilterRow extends StatelessWidget {
  const FilterRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.icons,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;
  final List<IconData?>? icons;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == selected;
          final icon = icons?[i];
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? OdysseyColors.forest
                    : OdysseyColors.parchment.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? OdysseyColors.forest : OdysseyColors.rule,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        size: 14,
                        color: active
                            ? OdysseyColors.brassLight
                            : OdysseyColors.inkSoft),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    options[i].toUpperCase(),
                    style: OdysseyType.mono(
                      10,
                      color: active
                          ? OdysseyColors.parchment
                          : OdysseyColors.ink,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: OdysseyColors.parchmentDeep,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: OdysseyColors.rule, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: OdysseyColors.brass),
            const SizedBox(width: 5),
          ],
          Text(text,
              style: OdysseyType.mono(9.5,
                  color: OdysseyColors.ink, letterSpacing: 0.6)),
        ],
      ),
    );
  }
}

/// Dark pill laid over plates.
class PlateBadge extends StatelessWidget {
  const PlateBadge(this.text, {super.key, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: OdysseyColors.forest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: OdysseyColors.brassLight.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: OdysseyColors.brassLight),
            const SizedBox(width: 6),
          ],
          Text(text.toUpperCase(),
              style: OdysseyType.mono(9,
                  color: OdysseyColors.parchment, letterSpacing: 1.4)),
        ],
      ),
    );
  }
}

class JournalButton extends StatelessWidget {
  const JournalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = filled ? OdysseyColors.parchment : OdysseyColors.forest;
    return Material(
      color: filled
          ? (enabled ? OdysseyColors.forest : OdysseyColors.inkSoft)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: filled
            ? BorderSide.none
            : const BorderSide(color: OdysseyColors.brass),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 17,
                    color: filled ? OdysseyColors.brassLight : fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: OdysseyType.mono(11,
                      color: fg, weight: FontWeight.w500, letterSpacing: 1.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular translucent button for use over plates.
class PlateIconButton extends StatelessWidget {
  const PlateIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: OdysseyColors.forest.withValues(alpha: 0.55),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          icon: Icon(icon, size: 20, color: OdysseyColors.parchment),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// Icon + label + value line used in logistics and itinerary blocks.
class InfoLine extends StatelessWidget {
  const InfoLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 15, color: OdysseyColors.brass),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(label.toUpperCase(),
                  style: OdysseyType.mono(9, letterSpacing: 1.4)),
            ),
          ),
          Expanded(
            child: Text(value,
                style: OdysseyType.display(15.5, color: OdysseyColors.ink)),
          ),
        ],
      ),
    );
  }
}

String shortMonth(int month) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][month - 1];

String longMonth(int month) => const [
      'January', 'February', 'March', 'April', 'May', 'June', //
      'July', 'August', 'September', 'October', 'November', 'December',
    ][month - 1];

/// "6 – 10 Dec 2026", or "30 Jan – 2 Feb 2027" across months.
String formatDateRange(DateTime start, DateTime end) {
  if (start.month == end.month && start.year == end.year) {
    return '${start.day} – ${end.day} ${shortMonth(end.month)} ${end.year}';
  }
  return '${start.day} ${shortMonth(start.month)} – '
      '${end.day} ${shortMonth(end.month)} ${end.year}';
}
