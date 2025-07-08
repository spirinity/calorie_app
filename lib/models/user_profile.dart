class UserProfile {
  final String name;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final String gender; // 'male' or 'female'
  final String activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final String goal; // 'lose_weight', 'maintain', 'gain_weight'
  final int? customCalorieGoal;

  UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    this.customCalorieGoal,
  });

  // Calculate BMR using Mifflin-St Jeor Equation
  double get bmr {
    if (gender.toLowerCase() == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  double get tdee {
    double activityMultiplier;
    switch (activityLevel) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'active':
        activityMultiplier = 1.725;
        break;
      case 'very_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2;
    }
    return bmr * activityMultiplier;
  }

  // Calculate recommended calorie goal based on weight goal
  int get recommendedCalorieGoal {
    double baseCalories = tdee;
    
    switch (goal) {
      case 'lose_weight':
        return (baseCalories - 500).round(); // 500 calorie deficit for ~1lb/week loss
      case 'maintain':
        return baseCalories.round();
      case 'gain_weight':
        return (baseCalories + 300).round(); // 300 calorie surplus for weight gain
      default:
        return baseCalories.round();
    }
  }

  // Get the active calorie goal (custom or recommended)
  int get activeCalorieGoal {
    return customCalorieGoal ?? recommendedCalorieGoal;
  }

  // Calculate BMI
  double get bmi {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'activityLevel': activityLevel,
      'goal': goal,
      'customCalorieGoal': customCalorieGoal,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      age: json['age'] ?? 25,
      height: json['height']?.toDouble() ?? 170.0,
      weight: json['weight']?.toDouble() ?? 70.0,
      gender: json['gender'] ?? 'male',
      activityLevel: json['activityLevel'] ?? 'moderate',
      goal: json['goal'] ?? 'maintain',
      customCalorieGoal: json['customCalorieGoal'],
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    double? height,
    double? weight,
    String? gender,
    String? activityLevel,
    String? goal,
    int? customCalorieGoal,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      customCalorieGoal: customCalorieGoal,
    );
  }
}