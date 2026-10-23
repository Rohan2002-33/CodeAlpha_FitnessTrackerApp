import '../utils/date_utils.dart';
import 'activity_entry.dart';

class DaySummary {
  const DaySummary({
    required this.date,
    this.steps = 0,
    this.calories = 0,
    this.minutes = 0,
    this.workouts = 0,
  });

  final DateTime date;
  final int steps;
  final int calories;
  final int minutes;
  final int workouts;

  factory DaySummary.fromEntries(
    DateTime date,
    Iterable<ActivityEntry> entries,
  ) {
    var steps = 0;
    var calories = 0;
    var minutes = 0;
    var workouts = 0;
    for (final e in entries) {
      steps += e.steps;
      calories += e.calories;
      minutes += e.durationMin;
      workouts++;
    }
    return DaySummary(
      date: dateOnly(date),
      steps: steps,
      calories: calories,
      minutes: minutes,
      workouts: workouts,
    );
  }
}
