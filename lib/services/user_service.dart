import '../models/user_profile.dart';

class UserService {
  static UserProfile? _userProfile;

  static Future<UserProfile?> getUserProfile() async {
    // Simulate async operation
    await Future.delayed(Duration(milliseconds: 100));
    return _userProfile;
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    // Simulate async operation
    await Future.delayed(Duration(milliseconds: 100));
    _userProfile = profile;
  }

  static Future<bool> hasUserProfile() async {
    final profile = await getUserProfile();
    return profile != null;
  }

  static Future<int> getCurrentCalorieGoal() async {
    final profile = await getUserProfile();
    if (profile != null) {
      return profile.activeCalorieGoal;
    }
    return 2500; // Default fallback
  }

  static Future<void> updateCalorieGoal(int? customGoal) async {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(customCalorieGoal: customGoal);
    }
  }

  static Future<Map<String, dynamic>> getHealthStats() async {
    final profile = await getUserProfile();
    if (profile == null) {
      return {
        'bmi': 0.0,
        'bmiCategory': 'Unknown',
        'bmr': 0.0,
        'tdee': 0.0,
        'recommendedCalories': 2500,
      };
    }

    return {
      'bmi': profile.bmi,
      'bmiCategory': profile.bmiCategory,
      'bmr': profile.bmr,
      'tdee': profile.tdee,
      'recommendedCalories': profile.recommendedCalorieGoal,
    };
  }

  static String getActivityLevelDescription(String level) {
    switch (level) {
      case 'sedentary':
        return 'Little to no exercise';
      case 'light':
        return 'Light exercise 1-3 days/week';
      case 'moderate':
        return 'Moderate exercise 3-5 days/week';
      case 'active':
        return 'Heavy exercise 6-7 days/week';
      case 'very_active':
        return 'Very heavy exercise, physical job';
      default:
        return 'Unknown activity level';
    }
  }

  static String getGoalDescription(String goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Lose weight (500 cal deficit)';
      case 'maintain':
        return 'Maintain current weight';
      case 'gain_weight':
        return 'Gain weight (300 cal surplus)';
      default:
        return 'Unknown goal';
    }
  }
}