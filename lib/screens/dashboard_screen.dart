import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/day_summary.dart';
import '../models/goals.dart';
import '../providers/activity_provider.dart';
import '../utils/formatters.dart';
import '../widgets/activity_tile.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/metric_progress_bar.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_bar_chart.dart';
import 'add_edit_activity_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final goals = provider.goals;
    final today = provider.summaryFor(now);
    final week = provider.weekSummaries(now);
    final recent = provider.entries.take(4).toList();

    final weekSteps = week.fold<int>(0, (s, d) => s + d.steps);
    final activeDays = week.where((d) => d.workouts > 0).length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          _Header(streak: provider.streak),
          const SizedBox(height: 20),
          _TodayCard(summary: today, goals: goals),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.fitness_center_rounded,
                  label: 'Workouts today',
                  value: '${today.workouts}',
                  color: AppColors.seed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.directions_walk_rounded,
                  label: 'Steps this week',
                  value: formatNumber(weekSteps),
                  color: AppColors.steps,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.event_available_rounded,
                  label: 'Active days',
                  value: '$activeDays / 7',
                  color: AppColors.minutes,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'This week'),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily steps',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Average ${formatNumber(weekSteps ~/ 7)} per day',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatNumber(weekSteps),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.steps,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                WeeklyBarChart(
                  values: week.map((d) => d.steps.toDouble()).toList(),
                  labels: weekdayLabels,
                  color: AppColors.steps,
                  goal: goals.steps.toDouble(),
                  highlightIndex: now.weekday - 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Recent activity',
            actionLabel: 'See all',
            onAction: recent.isEmpty ? null : onSeeAll,
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            const EmptyState(
              icon: Icons.directions_run_rounded,
              title: 'No activity yet',
              message: 'Tap “Log activity” to record your first workout.',
            )
          else
            for (final e in recent)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ActivityTile(
                  entry: e,
                  showDate: true,
                  onTap: () => openActivityForm(context, entry: e),
                ),
              ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, d MMMM').format(now),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                greeting(now),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        if (streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.calories.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: AppColors.calories,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak day${streak == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.calories,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.summary, required this.goals});

  final DaySummary summary;
  final Goals goals;

  @override
  Widget build(BuildContext context) {
    final double stepsProgress =
        goals.steps == 0 ? 0.0 : summary.steps / goals.steps;
    final remaining = math.max(0, goals.steps - summary.steps);
    final percent = (stepsProgress * 100).clamp(0, 100).round();

    return AppCard(
      gradient: AppColors.brand,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              ProgressRing(
                progress: stepsProgress,
                size: 128,
                strokeWidth: 12,
                color: Colors.white,
                trackColor: Colors.white.withValues(alpha: 0.2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'of goal',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Steps today',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatNumber(summary.steps),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      remaining == 0
                          ? 'Goal reached. Great work!'
                          : '${formatNumber(remaining)} to go · goal ${formatNumber(goals.steps)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          MetricProgressBar(
            onGradient: true,
            icon: Icons.local_fire_department_rounded,
            label: 'Calories burned',
            value: summary.calories,
            goal: goals.calories,
            unit: 'kcal',
            color: AppColors.calories,
          ),
          const SizedBox(height: 16),
          MetricProgressBar(
            onGradient: true,
            icon: Icons.timer_rounded,
            label: 'Active minutes',
            value: summary.minutes,
            goal: goals.activeMinutes,
            unit: 'min',
            color: AppColors.minutes,
          ),
        ],
      ),
    );
  }
}