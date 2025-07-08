import '../models/food_entry.dart';
import 'database_helper.dart';

class FoodService {
  static Future<void> saveFoodEntry(FoodEntry entry) async {
    await DatabaseHelper.instance.saveFoodEntry(entry);
  }

  static Future<List<FoodEntry>> getTodayEntries() async {
    return await DatabaseHelper.instance.getTodayEntries();
  }

  static Future<int> getTodayTotalCalories() async {
    final todayEntries = await getTodayEntries();
    return todayEntries.fold<int>(0, (sum, entry) => sum + entry.calories);
  }

  static Future<int> getTodayMealCount() async {
    final todayEntries = await getTodayEntries();
    return todayEntries.length;
  }

  static Future<void> deleteFoodEntry(String id) async {
    await DatabaseHelper.instance.deleteFoodEntry(id);
  }

}