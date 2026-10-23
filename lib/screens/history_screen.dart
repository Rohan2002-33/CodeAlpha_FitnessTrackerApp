import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/activity_entry.dart';
import '../providers/activity_provider.dart';
import '../utils/date_utils.dart';
import '../utils/formatters.dart';
import '../widgets/activity_tile.dart';
import '../widgets/empty_state.dart';
import 'add_edit_activity_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  ActivityType? _filter;

  void _onDismissed(ActivityEntry entry) {
    final provider = context.read<ActivityProvider>();
    provider.deleteEntry(entry.id!);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Activity deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => provider.restoreEntry(entry),
          ),
        ),
      );
  }

  Widget _chip(ActivityType? type, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == type,
        onSelected: (_) => setState(() => _filter = type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();
    final scheme = Theme.of(context).colorScheme;

    final all = provider.entries;
    final items =
        _filter == null ? all : all.where((e) => e.type == _filter).toList();

    final groups = <DateTime, List<ActivityEntry>>{};
    for (final e in items) {
      groups.putIfAbsent(dateOnly(e.date), () => []).add(e);
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          const Text(
            'History',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${items.length} ${items.length == 1 ? 'activity' : 'activities'}'
            '${_filter == null ? '' : ' · ${_filter!.label}'}',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip(null, 'All'),
                for (final t in ActivityType.values) _chip(t, t.label),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            EmptyState(
              icon: Icons.history_rounded,
              title: _filter == null ? 'Nothing logged yet' : 'No ${_filter!.label} activities',
              message: _filter == null
                  ? 'Your logged workouts will show up here.'
                  : 'Try another filter or log a new activity.',
            )
          else
            for (final group in groups.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 10),
                child: Row(
                  children: [
                    Text(
                      friendlyDate(group.key),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      '${formatNumber(group.value.fold<int>(0, (s, e) => s + e.calories))} kcal',
                      style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              for (final e in group.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: ValueKey('activity-${e.id}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _onDismissed(e),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: scheme.error,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(Icons.delete_rounded, color: scheme.onError),
                    ),
                    child: ActivityTile(
                      entry: e,
                      onTap: () => openActivityForm(context, entry: e),
                    ),
                  ),
                ),
            ],
        ],
      ),
    );
  }
}