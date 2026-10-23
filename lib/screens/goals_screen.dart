import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/goals.dart';
import '../providers/activity_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late int _steps;
  late int _calories;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    final g = context.read<ActivityProvider>().goals;
    _steps = g.steps;
    _calories = g.calories;
    _minutes = g.activeMinutes;
  }

  bool _changed(Goals saved) =>
      _steps != saved.steps ||
      _calories != saved.calories ||
      _minutes != saved.activeMinutes;

  Future<void> _save() async {
    await context.read<ActivityProvider>().updateGoals(
      Goals(steps: _steps, calories: _calories, activeMinutes: _minutes),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Goals saved')));
  }

  void _reset() {
    const d = Goals();
    setState(() {
      _steps = d.steps;
      _calories = d.calories;
      _minutes = d.activeMinutes;
    });
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'Every logged activity will be permanently removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<ActivityProvider>().clearAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('All data deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<ActivityProvider>().goals;
    final themeProvider = context.watch<ThemeProvider>();
    final scheme = Theme.of(context).colorScheme;
    final changed = _changed(saved);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const Text(
            'Daily goals',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Set targets that fit your routine.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          _GoalSlider(
            icon: Icons.directions_walk_rounded,
            color: AppColors.steps,
            title: 'Steps',
            unit: 'steps',
            value: _steps,
            min: 2000,
            max: 30000,
            step: 500,
            onChanged: (v) => setState(() => _steps = v),
          ),
          const SizedBox(height: 12),
          _GoalSlider(
            icon: Icons.local_fire_department_rounded,
            color: AppColors.calories,
            title: 'Calories burned',
            unit: 'kcal',
            value: _calories,
            min: 100,
            max: 2000,
            step: 50,
            onChanged: (v) => setState(() => _calories = v),
          ),
          const SizedBox(height: 12),
          _GoalSlider(
            icon: Icons.timer_rounded,
            color: AppColors.minutes,
            title: 'Active minutes',
            unit: 'min',
            value: _minutes,
            min: 10,
            max: 180,
            step: 5,
            onChanged: (v) => setState(() => _minutes = v),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: changed ? _save : null,
            child: const Text('Save goals'),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _reset, child: const Text('Reset to defaults')),
          const SizedBox(height: 24),
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette_outlined, color: scheme.primary),
                    const SizedBox(width: 12),
                    const Text(
                      'Theme mode',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {themeProvider.themeMode},
                    onSelectionChanged: (set) =>
                        themeProvider.setThemeMode(set.first),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: _confirmClear,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.delete_forever_rounded, color: scheme.error),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delete all activity data',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: scheme.error,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Removes every logged activity from this device',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Text(
              'FitTrack v1.0.0 · App for tracking fitness activities',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalSlider extends StatelessWidget {
  const _GoalSlider({
    required this.icon,
    required this.color,
    required this.title,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String unit;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${formatNumber(value)} $unit',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              overlayColor: color.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: (max - min) ~/ step,
              onChanged: (v) =>
                  onChanged(min + ((v - min) / step).round() * step),
            ),
          ),
        ],
      ),
    );
  }
}
