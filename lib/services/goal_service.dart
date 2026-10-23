import 'package:shared_preferences/shared_preferences.dart';

import '../models/goals.dart';

class GoalService {
  static const _kSteps = 'goal_steps';
  static const _kCalories = 'goal_calories';
  static const _kMinutes = 'goal_minutes';

  Future<Goals> load() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = Goals();
    return Goals(
      steps: prefs.getInt(_kSteps) ?? defaults.steps,
      calories: prefs.getInt(_kCalories) ?? defaults.calories,
      activeMinutes: prefs.getInt(_kMinutes) ?? defaults.activeMinutes,
    );
  }

  Future<void> save(Goals goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSteps, goals.steps);
    await prefs.setInt(_kCalories, goals.calories);
    await prefs.setInt(_kMinutes, goals.activeMinutes);
  }
}