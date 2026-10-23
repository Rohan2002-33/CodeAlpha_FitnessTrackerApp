import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/activity_entry.dart';
import '../utils/formatters.dart';
import 'app_card.dart';

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.entry,
    this.onTap,
    this.showDate = false,
  });

  final ActivityEntry entry;
  final VoidCallback? onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final type = entry.type;
    final details = [
      '${entry.durationMin} min',
      '${formatNumber(entry.calories)} kcal',
      if (entry.steps > 0) '${formatNumber(entry.steps)} steps',
    ].join(' · ');

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(type.icon, color: type.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  details,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            showDate ? friendlyDate(entry.date) : DateFormat.jm().format(entry.date),
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}