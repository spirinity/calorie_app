class GoalService {
  static int _dailyCalorieGoal = 2500; // Default goal

  static Future<int> getDailyCalorieGoal() async {
    // Simulate async operation
    await Future.delayed(Duration(milliseconds: 50));
    return _dailyCalorieGoal;
  }

  static Future<void> setDailyCalorieGoal(int goal) async {
    // Simulate async operation
    await Future.delayed(Duration(milliseconds: 100));
    _dailyCalorieGoal = goal;
  }

  static Future<Map<String, dynamic>> getGoalProgress(int currentCalories) async {
    final goal = await getDailyCalorieGoal();
    final progress = goal > 0 ? currentCalories / goal : 0.0;
    final remaining = goal - currentCalories;
    
    return {
      'goal': goal,
      'current': currentCalories,
      'progress': progress,
      'remaining': remaining,
      'percentage': (progress * 100).toInt(),
    };
  }

  static Future<String> getGoalStatus(int currentCalories) async {
    final goal = await getDailyCalorieGoal();
    final progress = currentCalories / goal;
    
    if (progress < 0.3) {
      return 'Just getting started';
    } else if (progress < 0.6) {
      return 'Making progress';
    } else if (progress < 0.9) {
      return 'Almost there';
    } else if (progress <= 1.0) {
      return 'Goal achieved!';
    } else {
      return 'Over goal';
    }
  }
}