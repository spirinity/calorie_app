import 'package:flutter/material.dart';

class CalorieProgressCard extends StatelessWidget {
  final int totalCalories;
  final int targetCalories;

  const CalorieProgressCard({
    Key? key,
    required this.totalCalories,
    required this.targetCalories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = targetCalories > 0 ? totalCalories / targetCalories : 0.0;
    final progressClamped = progress.clamp(0.0, 1.0);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange[600],
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Calories',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressClamped,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getProgressColor(progress),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Calories text
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$totalCalories',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' / $targetCalories',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 4),
            
            Text(
              '${(progress * 100).toInt()}% of daily goal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) {
      return Colors.green;
    } else if (progress < 0.8) {
      return Colors.orange;
    } else if (progress <= 1.0) {
      return Colors.red[400]!;
    } else {
      return Colors.red[700]!;
    }
  }
}