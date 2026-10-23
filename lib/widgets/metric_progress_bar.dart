import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class MetricProgressBar extends StatelessWidget {
  const MetricProgressBar({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
    this.onGradient = false,
  });

  final IconData icon;
  final String label;
  final int value;
  final int goal;
  final String unit;
  final Color color;
  final bool onGradient;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = onGradient ? Colors.white : scheme.onSurface;
    final subColor = onGradient ? Colors.white70 : scheme.onSurfaceVariant;
    final barColor = onGradient ? Colors.white : color;
    final track = onGradient
        ? Colors.white.withValues(alpha: 0.2)
        : scheme.surfaceContainerHighest;
    final double progress = goal <= 0
        ? 0.0
        : (value / goal).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: onGradient ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              '${formatNumber(value)} / ${formatNumber(goal)} $unit',
              style: TextStyle(color: subColor, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: track,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
        ),
      ],
    );
  }
}
