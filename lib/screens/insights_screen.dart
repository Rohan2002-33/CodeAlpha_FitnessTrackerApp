import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/activity_provider.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/weekly_line_chart.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _weekOffset = 0; // 0 = this week, -1 = last week ...

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();
    final scheme = Theme.of(context).colorScheme;
    final goals = provider.goals;
    final now = DateTime.now();
    final anchor = DateTime(now.year, now.month, now.day + _weekOffset * 7);
    final week = provider.weekSummaries(anchor);
    final isCurrent = _weekOffset == 0;

    final fmt = DateFormat('d MMM');
    final rangeLabel =
        '${fmt.format(week.first.date)} – ${fmt.format(week.last.date)}';

    final totalSteps = week.fold<int>(0, (s, d) => s + d.steps);
    final totalCalories = week.fold<int>(0, (s, d) => s + d.calories);
    final totalMinutes = week.fold<int>(0, (s, d) => s + d.minutes);
    final totalWorkouts = week.fold<int>(0, (s, d) => s + d.workouts);
    final stepGoalDays = week
        .where((d) => d.steps >= goals.steps && d.steps > 0)
        .length;
    final best = week.reduce((a, b) => b.steps > a.steps ? b : a);

    final mix = provider.minutesByType(anchor).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final mixTotal = mix.fold<int>(0, (s, e) => s + e.value);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          const Text(
            'Insights',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Previous week',
                  onPressed: () => setState(() => _weekOffset--),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        isCurrent ? 'This week' : rangeLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (isCurrent)
                        Text(
                          rangeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Next week',
                  onPressed: isCurrent
                      ? null
                      : () => setState(() => _weekOffset++),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.directions_walk_rounded,
                  label: 'Total steps',
                  value: formatNumber(totalSteps),
                  color: AppColors.steps,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Calories burned',
                  value: formatNumber(totalCalories),
                  color: AppColors.calories,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.timer_rounded,
                  label: 'Active minutes',
                  value: formatNumber(totalMinutes),
                  color: AppColors.minutes,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.fitness_center_rounded,
                  label: 'Workouts',
                  value: '$totalWorkouts',
                  color: AppColors.seed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                _InsightRow(
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.calories,
                  text: best.steps == 0
                      ? 'No steps logged this week yet'
                      : 'Best day: ${DateFormat('EEEE').format(best.date)} with ${formatNumber(best.steps)} steps',
                ),
                const SizedBox(height: 14),
                _InsightRow(
                  icon: Icons.flag_rounded,
                  color: AppColors.minutes,
                  text: 'Step goal reached on $stepGoalDays of 7 days',
                ),
                const SizedBox(height: 14),
                _InsightRow(
                  icon: Icons.speed_rounded,
                  color: AppColors.steps,
                  text:
                      'Daily average: ${formatNumber(totalSteps ~/ 7)} steps · ${formatNumber(totalCalories ~/ 7)} kcal',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ChartCard(
            title: 'Steps',
            subtitle: 'Dashed line = daily goal',
            child: WeeklyBarChart(
              values: week.map((d) => d.steps.toDouble()).toList(),
              labels: weekdayLabels,
              color: AppColors.steps,
              goal: goals.steps.toDouble(),
              highlightIndex: isCurrent ? now.weekday - 1 : null,
            ),
          ),
          const SizedBox(height: 14),
          _ChartCard(
            title: 'Calories burned',
            subtitle: 'kcal per day',
            child: WeeklyLineChart(
              values: week.map((d) => d.calories.toDouble()).toList(),
              labels: weekdayLabels,
              color: AppColors.calories,
            ),
          ),
          const SizedBox(height: 14),
          _ChartCard(
            title: 'Active minutes',
            subtitle: 'Dashed line = daily goal',
            child: WeeklyBarChart(
              values: week.map((d) => d.minutes.toDouble()).toList(),
              labels: weekdayLabels,
              color: AppColors.minutes,
              goal: goals.activeMinutes.toDouble(),
              highlightIndex: isCurrent ? now.weekday - 1 : null,
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activity mix',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                if (mix.isEmpty)
                  Text(
                    'Log a workout to see how your time is split.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  )
                else
                  for (final m in mix)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(m.key.icon, size: 18, color: m.key.color),
                              const SizedBox(width: 8),
                              Text(
                                m.key.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${m.value} min',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: m.value / mixTotal,
                              minHeight: 8,
                              color: m.key.color,
                              backgroundColor: m.key.color.withValues(
                                alpha: 0.15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
