import '../core/constants.dart';

class ActivityEntry {
  const ActivityEntry({
    this.id,
    required this.type,
    required this.durationMin,
    required this.calories,
    this.steps = 0,
    required this.date,
    this.note = '',
  });

  final int? id;
  final ActivityType type;
  final int durationMin;
  final int calories;
  final int steps;
  final DateTime date;
  final String note;

  ActivityEntry copyWith({
    int? id,
    ActivityType? type,
    int? durationMin,
    int? calories,
    int? steps,
    DateTime? date,
    String? note,
  }) {
    return ActivityEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      durationMin: durationMin ?? this.durationMin,
      calories: calories ?? this.calories,
      steps: steps ?? this.steps,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'type': type.name,
        'duration_min': durationMin,
        'calories': calories,
        'steps': steps,
        'date': date.millisecondsSinceEpoch,
        'note': note,
      };

  factory ActivityEntry.fromMap(Map<String, Object?> map) {
    return ActivityEntry(
      id: map['id'] as int?,
      type: ActivityType.fromName(map['type'] as String),
      durationMin: map['duration_min'] as int,
      calories: map['calories'] as int,
      steps: map['steps'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: (map['note'] as String?) ?? '',
    );
  }
}