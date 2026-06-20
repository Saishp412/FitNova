import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class WorkoutCard extends StatelessWidget {
  final String title;
  final int durationMinutes;
  final String difficulty;
  final VoidCallback onTap;

  WorkoutCard({
    super.key,
    required this.title,
    required this.durationMinutes,
    required this.difficulty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: EdgeInsets.only(right: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                difficulty.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.primaryAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Spacer(),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color!,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: Theme.of(context).textTheme.bodyMedium!.color!),
                SizedBox(width: 4),
                Text(
                  '$durationMinutes min',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_forward, size: 20, color: AppTheme.primaryAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
