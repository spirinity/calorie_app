import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';
import 'profile_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? userProfile;
  Map<String, dynamic> healthStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    
    final profile = await UserService.getUserProfile();
    final stats = await UserService.getHealthStats();
    
    setState(() {
      userProfile = profile;
      healthStats = stats;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userProfile == null
              ? _buildWelcomeScreen()
              : _buildProfileContent(),
    );
  }

  Widget _buildWelcomeScreen() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            size: 80,
            color: Theme.of(context).primaryColor.withOpacity(0.7),
          ),
          SizedBox(height: 24),
          Text(
            'Welcome to Calorie Tracker!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Let\'s set up your profile to get personalized calorie recommendations based on your goals and lifestyle.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _navigateToSetup,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add),
                  SizedBox(width: 8),
                  Text(
                    'Set Up Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          _buildProfileHeader(),
          
          SizedBox(height: 24),
          
          // Health stats
          _buildHealthStatsSection(),
          
          SizedBox(height: 24),
          
          // Calorie goal section
          _buildCalorieGoalSection(),
          
          SizedBox(height: 24),
          
          // Personal information
          _buildPersonalInfoSection(),
          
          SizedBox(height: 24),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProfile!.name.isNotEmpty ? userProfile!.name : 'User',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${userProfile!.age} years old • ${userProfile!.gender.toUpperCase()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    UserService.getGoalDescription(userProfile!.goal),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Stats',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'BMI',
                healthStats['bmi'].toStringAsFixed(1),
                healthStats['bmiCategory'],
                Icons.monitor_weight,
                _getBMIColor(),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'BMR',
                '${healthStats['bmr'].round()}',
                'kcal/day',
                Icons.local_fire_department,
                Colors.orange[600]!,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'TDEE',
                '${healthStats['tdee'].round()}',
                'kcal/day',
                Icons.fitness_center,
                Colors.blue[600]!,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Weight',
                '${userProfile!.weight.toStringAsFixed(1)}',
                'kg',
                Icons.scale,
                Colors.green[600]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieGoalSection() {
    final recommendedCalories = healthStats['recommendedCalories'];
    final currentGoal = userProfile!.activeCalorieGoal;
    final isUsingCustomGoal = userProfile!.customCalorieGoal != null;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.track_changes,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Daily Calorie Goal',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$currentGoal',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                  TextSpan(
                    text: ' kcal',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 8),
            
            Text(
              isUsingCustomGoal ? 'Custom goal' : 'Recommended goal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isUsingCustomGoal ? Colors.blue[600] : Colors.green[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            
            if (isUsingCustomGoal) ...[
              SizedBox(height: 4),
              Text(
                'Recommended: $recommendedCalories kcal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            _buildInfoRow('Height', '${userProfile!.height.toStringAsFixed(0)} cm', Icons.height),
            _buildInfoRow('Weight', '${userProfile!.weight.toStringAsFixed(1)} kg', Icons.monitor_weight),
            _buildInfoRow('Activity Level', UserService.getActivityLevelDescription(userProfile!.activityLevel), Icons.directions_run),
            _buildInfoRow('Goal', UserService.getGoalDescription(userProfile!.goal), Icons.flag),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _navigateToSetup,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _showCustomGoalDialog,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.track_changes, color: Theme.of(context).primaryColor),
                SizedBox(width: 8),
                Text(
                  'Custom Calorie Goal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getBMIColor() {
    final bmi = healthStats['bmi'];
    if (bmi < 18.5) return Colors.blue[600]!;
    if (bmi < 25) return Colors.green[600]!;
    if (bmi < 30) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  void _navigateToSetup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileSetupScreen(existingProfile: userProfile),
      ),
    );
    
    if (result == true) {
      _loadUserData();
    }
  }

  void _showCustomGoalDialog() {
  String customGoal = '';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Custom Calorie Goal'),
      content: TextField(
        onChanged: (value) {
          customGoal = value;
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter custom goal (kcal)',
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (customGoal.isNotEmpty) {
              final parsedGoal = int.tryParse(customGoal);
              if (parsedGoal != null && parsedGoal > 0) {
                // TODO: save the custom goal value
                print('Saving custom goal: $parsedGoal');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid number')),
                );
                return;
              }
            }
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    ),
  );
}
}