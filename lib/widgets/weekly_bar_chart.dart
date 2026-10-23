import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    this.goal,
    this.highlightIndex,
    this.height = 180,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final double? goal;
  final int? highlightIndex;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxValue = [...values, goal ?? 0].fold<double>(0, math.max);
    final maxY = maxValue <= 0 ? 10.0 : maxValue * 1.2;

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length)
                    return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: i == highlightIndex
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: i == highlightIndex
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          extraLinesData: goal == null
              ? null
              : ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: goal!,
                      color: color.withValues(alpha: 0.6),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                    ),
                  ],
                ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                    formatNumber(rod.toY.round()),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    width: 18,
                    color: highlightIndex == null || i == highlightIndex
                        ? color
                        : color.withValues(alpha: 0.4),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
