class Goals {
  const Goals({
    this.steps = 10000,
    this.calories = 500,
    this.activeMinutes = 30,
  });

  final int steps;
  final int calories;
  final int activeMinutes;

  Goals copyWith({int? steps, int? calories, int? activeMinutes}) {
    return Goals(
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      activeMinutes: activeMinutes ?? this.activeMinutes,
    );
  }
}
