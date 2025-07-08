import 'package:flutter/material.dart';
import '../services/food_service.dart';
import '../services/user_service.dart';
import '../models/food_entry.dart';
import '../models/user_profile.dart';
import '../widgets/calorie_progress_card.dart';
import '../widgets/meal_count_card.dart';
import '../widgets/recent_meals_list.dart';
import 'add_food_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onRefreshNeeded;

  const HomeScreen({Key? key, this.onRefreshNeeded}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalCalories = 0;
  int targetCalories = 2500;
  int mealCount = 0;
  List<FoodEntry> todayEntries = [];
  UserProfile? userProfile;
  bool isLoading = true;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      // Load all data in parallel for better performance
      final results = await Future.wait([
        FoodService.getTodayTotalCalories(),
        FoodService.getTodayMealCount(),
        FoodService.getTodayEntries(),
        UserService.getCurrentCalorieGoal(),
        UserService.getUserProfile(),
      ]);
      
      final calories = results[0] as int;
      final meals = results[1] as int;
      final entries = results[2] as List<FoodEntry>;
      final goal = results[3] as int;
      final profile = results[4] as UserProfile?;
      
      setState(() {
        totalCalories = calories;
        targetCalories = goal;
        mealCount = meals;
        todayEntries = entries;
        userProfile = profile;
        userName = profile?.name ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Error loading data: ${e.toString()}');
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getMotivationalMessage() {
    final remaining = targetCalories - totalCalories;
    if (remaining > 0) {
      return 'You have $remaining kcal remaining for today';
    } else if (remaining == 0) {
      return 'Perfect! You\'ve reached your daily goal!';
    } else {
      return 'You\'ve exceeded your goal by ${remaining.abs()} kcal. i love bubby';
    }
  }

  Color _getProgressColor() {
    final progress = totalCalories / targetCalories;
    if (progress <= 0.8) return Colors.green;
    if (progress <= 1.0) return Colors.orange;
    return Colors.red;
  }

  Future<void> _navigateToAddFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddFoodScreen()),
    );
    
    if (result == true) {
      await _loadData();
      _showSuccessSnackBar('Food entry added successfully!');
    }
  }

  Future<void> _navigateToProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
    
    if (result == true) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calorie Tracker',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message with user name
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isNotEmpty 
                                ? '${_getGreeting()}, $userName!'
                                : '${_getGreeting()}!',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _getFormattedDate(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          if (userProfile != null) ...[
                            SizedBox(height: 8),
                            Text(
                              _getMotivationalMessage(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _getProgressColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Enhanced goal summary card
                    Card(
                      elevation: 2,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: InkWell(
                        onTap: _navigateToProfile,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daily Goal: $targetCalories kcal',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      userProfile?.customCalorieGoal != null 
                                          ? 'Custom goal • Tap to view profile'
                                          : userProfile != null 
                                              ? 'Recommended goal • Tap to view profile'
                                              : 'Default goal • Tap to set up profile',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(context).primaryColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Enhanced stats cards with better styling
                    Row(
                      children: [
                        Expanded(
                          child: CalorieProgressCard(
                            totalCalories: totalCalories,
                            targetCalories: targetCalories,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: MealCountCard(mealCount: mealCount),
                        ),
                      ],
                    ),
                    
                    // Add progress summary card if user has profile
                    if (userProfile != null) ...[
                      SizedBox(height: 12),
                      _buildProgressSummaryCard(),
                    ],
                    
                    SizedBox(height: 24),
                    
                    // Recent meals section with improved header
                    if (todayEntries.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today\'s Meals',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${todayEntries.length} ${todayEntries.length == 1 ? 'entry' : 'entries'}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _navigateToAddFood,
                            icon: Icon(Icons.add, size: 16),
                            label: Text('Add Meal'),
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      RecentMealsList(
                      entries: todayEntries,
                      onRefresh: _loadData, // Pass the callback here
                  ),
                    ] else ...[
                      _buildEmptyState(),
                    ],
                    
                    // Add some bottom padding for FAB
                    SizedBox(height: 80),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddFood,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add, size: 24),
        label: Text(
          'Add Food',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildProgressSummaryCard() {
    final progress = totalCalories / targetCalories;
    final remaining = targetCalories - totalCalories;
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Progress',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _getProgressColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalCalories kcal consumed',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  remaining > 0 ? '$remaining kcal left' : '${remaining.abs()} kcal over',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getProgressColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No meals logged today',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            userName.isNotEmpty 
                ? 'Hey $userName! Ready to start tracking your first meal?'
                : 'Tap the button below to add your first meal of the day',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddFood,
            icon: Icon(Icons.add),
            label: Text('Add Your First Meal'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
          SizedBox(height: 16),
          if (userProfile == null)
            TextButton.icon(
              onPressed: _navigateToProfile,
              icon: Icon(Icons.person_add, size: 16),
              label: Text('Set up your profile first'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}