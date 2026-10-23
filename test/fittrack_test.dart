import 'package:fittrack/core/constants.dart';
import 'package:fittrack/models/activity_entry.dart';
import 'package:fittrack/models/day_summary.dart';
import 'package:fittrack/providers/theme_provider.dart';
import 'package:fittrack/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final day = DateTime(2026, 10, 23);

  test('DaySummary adds up all entries of a day', () {
    final entries = [
      ActivityEntry(
        type: ActivityType.running,
        durationMin: 30,
        calories: 300,
        steps: 4000,
        date: day,
      ),
      ActivityEntry(
        type: ActivityType.yoga,
        durationMin: 45,
        calories: 150,
        date: day,
      ),
    ];

    final s = DaySummary.fromEntries(day, entries);

    expect(s.steps, 4000);
    expect(s.calories, 450);
    expect(s.minutes, 75);
    expect(s.workouts, 2);
  });

  test('ActivityEntry survives a map round trip', () {
    final original = ActivityEntry(
      id: 7,
      type: ActivityType.cycling,
      durationMin: 60,
      calories: 520,
      steps: 0,
      date: day,
      note: 'Evening ride',
    );

    final copy = ActivityEntry.fromMap(original.toMap());

    expect(copy.id, 7);
    expect(copy.type, ActivityType.cycling);
    expect(copy.calories, 520);
    expect(copy.note, 'Evening ride');
    expect(copy.date, day);
  });

  test('startOfWeek returns Monday', () {
    // 23 Oct 2026 is a Friday.
    expect(startOfWeek(day), DateTime(2026, 10, 19));
  });

  test('ThemeProvider defaults to system and updates theme mode', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ThemeProvider();
    await provider.init();
    expect(provider.themeMode, ThemeMode.system);

    await provider.setThemeMode(ThemeMode.dark);
    expect(provider.themeMode, ThemeMode.dark);

    await provider.setThemeMode(ThemeMode.light);
    expect(provider.themeMode, ThemeMode.light);
  });
}
