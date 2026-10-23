import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/activity_entry.dart';
import '../models/day_summary.dart';
import '../models/goals.dart';
import '../services/database_service.dart';
import '../services/goal_service.dart';
import '../utils/date_utils.dart';

class ActivityProvider extends ChangeNotifier {
  ActivityProvider({DatabaseService? db, GoalService? goalService})
      : _db = db ?? DatabaseService.instance,
        _goalService = goalService ?? GoalService();

  final DatabaseService _db;
  final GoalService _goalService;

  List<ActivityEntry> _entries = [];
  Goals _goals = const Goals();
  bool _loading = true;
  String? _error;

  bool get isLoading => _loading;
  String? get error => _error;
  Goals get goals => _goals;

  /// Newest first.
  List<ActivityEntry> get entries => List.unmodifiable(_entries);

  Future<void> init() async {
    try {
      _goals = await _goalService.load();
      _entries = await _db.getAll();
    } catch (e) {
      _error = 'Could not load your data.\n$e';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> _reload() async {
    _entries = await _db.getAll();
    notifyListeners();
  }

  // ---- CRUD ----

  Future<void> addEntry(ActivityEntry entry) async {
    await _db.insert(entry);
    await _reload();
  }

  Future<void> updateEntry(ActivityEntry entry) async {
    await _db.update(entry);
    await _reload();
  }

  Future<void> deleteEntry(int id) async {
    // Optimistic: remove from UI first so Dismissible leaves the tree at once.
    _entries = _entries.where((e) => e.id != id).toList();
    notifyListeners();
    try {
      await _db.delete(id);
    } catch (_) {
      await _reload();
      rethrow;
    }
  }

  Future<void> restoreEntry(ActivityEntry entry) => addEntry(entry);

  Future<void> clearAll() async {
    await _db.clear();
    await _reload();
  }

  // ---- Goals ----

  Future<void> updateGoals(Goals goals) async {
    await _goalService.save(goals);
    _goals = goals;
    notifyListeners();
  }

  // ---- Queries ----

  List<ActivityEntry> entriesOn(DateTime day) =>
      _entries.where((e) => isSameDay(e.date, day)).toList();

  DaySummary summaryFor(DateTime day) =>
      DaySummary.fromEntries(day, entriesOn(day));

  /// Seven summaries, Monday to Sunday, for the week containing [anyDay].
  List<DaySummary> weekSummaries(DateTime anyDay) {
    final start = startOfWeek(anyDay);
    return List.generate(
      7,
      (i) => summaryFor(DateTime(start.year, start.month, start.day + i)),
    );
  }

  Map<ActivityType, int> minutesByType(DateTime anyDay) {
    final start = startOfWeek(anyDay);
    final end = DateTime(start.year, start.month, start.day + 7);
    final result = <ActivityType, int>{};
    for (final e in _entries) {
      if (!e.date.isBefore(start) && e.date.isBefore(end)) {
        result.update(
          e.type,
          (v) => v + e.durationMin,
          ifAbsent: () => e.durationMin,
        );
      }
    }
    return result;
  }

  /// Consecutive days with at least one activity, ending today (or yesterday).
  int get streak {
    final days = _entries.map((e) => dateOnly(e.date)).toSet();
    var cursor = dateOnly(DateTime.now());
    if (!days.contains(cursor)) {
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return count;
  }
}