import 'package:flutter/material.dart';

enum ActivityType {
  walking('Walking', Icons.directions_walk_rounded, Color(0xFF3B82F6)),
  running('Running', Icons.directions_run_rounded, Color(0xFFEF4444)),
  cycling('Cycling', Icons.directions_bike_rounded, Color(0xFF10B981)),
  gym('Gym', Icons.fitness_center_rounded, Color(0xFF8B5CF6)),
  yoga('Yoga', Icons.self_improvement_rounded, Color(0xFFEC4899)),
  swimming('Swimming', Icons.pool_rounded, Color(0xFF06B6D4)),
  hiit('HIIT', Icons.bolt_rounded, Color(0xFFF59E0B)),
  other('Other', Icons.sports_score_rounded, Color(0xFF64748B));

  const ActivityType(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  static ActivityType fromName(String name) {
    return ActivityType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => ActivityType.other,
    );
  }
}