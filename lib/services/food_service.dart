import 'dart:convert';
import '../models/food_entry.dart';

class FoodService {
  static List<FoodEntry> _foodEntries = [];

  static Future<List<FoodEntry>> getFoodEntries() async {
    // Simulate async operation
    await Future.delayed(Duration(milliseconds: 100));
    return List.from(_foodEntries);
  }

  static Future<void> saveFoodEntry(FoodEntry entry) async {
    // Simulate async operation
    await Future.delayed(Duration(milliseconds: 100));
    _foodEntries.add(entry);
  }

  static Future<List<FoodEntry>> getTodayEntries() async {
    final allEntries = await getFoodEntries();
    final today = DateTime.now();
    
    return allEntries.where((entry) {
      return entry.timestamp.year == today.year &&
             entry.timestamp.month == today.month &&
             entry.timestamp.day == today.day;
    }).toList();
  }

  static Future<int> getTodayTotalCalories() async {
    final todayEntries = await getTodayEntries();
    return todayEntries.fold<int>(0, (sum, entry) => sum + entry.calories);
  }

  static Future<int> getTodayMealCount() async {
    final todayEntries = await getTodayEntries();
    return todayEntries.length;
  }
}