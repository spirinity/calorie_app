import 'package:flutter/material.dart';
import '../services/goal_service.dart';

class GoalDashboardScreen extends StatefulWidget {
  @override
  _GoalDashboardScreenState createState() => _GoalDashboardScreenState();
}

class _GoalDashboardScreenState extends State<GoalDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();
  
  int currentGoal = 2500;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentGoal();
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentGoal() async {
    setState(() => isLoading = true);
    
    final goal = await GoalService.getDailyCalorieGoal();
    
    setState(() {
      currentGoal = goal;
      _caloriesController.text = goal.toString();
      isLoading = false;
    });
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final newGoal = int.parse(_caloriesController.text.trim());
      await GoalService.setDailyCalorieGoal(newGoal);
      
      setState(() => currentGoal = newGoal);
      
      _showSuccessSnackBar('Goal updated successfully!');
      
    } catch (e) {
      _showErrorSnackBar('Error saving goal: ${e.toString()}');
    } finally {
      setState(() => isSaving = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Goal Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current goal display card
                    Card(
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
                                  size: 28,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Current Daily Goal',
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
                              'per day',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Goal setting section
                    Text(
                      'Update Your Goal',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    Text(
                      'Set your daily calorie intake goal to track your progress effectively.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Calorie goal input
                    TextFormField(
                      controller: _caloriesController,
                      decoration: InputDecoration(
                        labelText: 'Daily Calorie Goal',
                        hintText: '2500',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.local_fire_department),
                        suffixText: 'kcal',
                        helperText: 'Recommended: 1800-2500 kcal for adults',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a calorie goal';
                        }
                        final calories = int.tryParse(value.trim());
                        if (calories == null) {
                          return 'Please enter a valid number';
                        }
                        if (calories < 800) {
                          return 'Goal should be at least 800 kcal';
                        }
                        if (calories > 5000) {
                          return 'Goal should be less than 5000 kcal';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 24),

                    // Quick goal buttons
                    Text(
                      'Quick Goals',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickGoalChip(1800, 'Weight Loss'),
                        _buildQuickGoalChip(2200, 'Maintenance'),
                        _buildQuickGoalChip(2500, 'Active'),
                        _buildQuickGoalChip(2800, 'Muscle Gain'),
                      ],
                    ),

                    SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _saveGoal,
                        child: isSaving
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Saving...'),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save),
                                  SizedBox(width: 8),
                                  Text(
                                    'Update Goal',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Additional info card
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[600],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Tips for Setting Goals',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• Consider your activity level and lifestyle\n'
                              '• Consult with a healthcare provider for personalized advice\n'
                              '• Adjust your goal based on your progress and results',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickGoalChip(int calories, String label) {
    final isSelected = calories.toString() == _caloriesController.text;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _caloriesController.text = calories.toString();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor 
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$calories',
              style: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}