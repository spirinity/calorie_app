import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_profile.dart';
import '../models/food_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('calorie_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // The version is now 2. This is correct.
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    // This creates the tables from scratch with the new column
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        height REAL NOT NULL,
        weight REAL NOT NULL,
        gender TEXT NOT NULL,
        activityLevel TEXT NOT NULL,
        goal TEXT NOT NULL,
        customCalorieGoal INTEGER,
        profileImagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE food_entries (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        calories INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        imagePath TEXT
      )
    ''');
  }

  // This handles upgrading from an old version
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE user_profile ADD COLUMN profileImagePath TEXT');
    }
  }

  // User Profile CRUD
  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await instance.database;
    await db.delete('user_profile');
    await db.insert('user_profile', profile.toJson());
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await instance.database;
    final maps = await db.query('user_profile');
    if (maps.isNotEmpty) {
      return UserProfile.fromJson(maps.first);
    } else {
      return null;
    }
  }

  // Food Entry CRUD
  Future<void> saveFoodEntry(FoodEntry entry) async {
    final db = await instance.database;
    await db.insert('food_entries', entry.toJson());
  }

  Future<void> deleteFoodEntry(String id) async {
    final db = await instance.database;
    await db.delete(
      'food_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<FoodEntry>> getTodayEntries() async {
    final db = await instance.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).millisecondsSinceEpoch;

    final result = await db.query(
      'food_entries',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [startOfDay, endOfDay],
    );

    return result.map((json) => FoodEntry.fromJson(json)).toList();
  }

  Future<List<FoodEntry>> getEntriesForMonth(DateTime month) async {
    final db = await instance.database;
    final startOfMonth = DateTime(month.year, month.month, 1).millisecondsSinceEpoch;
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;

    final result = await db.query(
      'food_entries',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [startOfMonth, endOfMonth],
      orderBy: 'timestamp DESC',
    );

    return result.map((json) => FoodEntry.fromJson(json)).toList();
  }

}