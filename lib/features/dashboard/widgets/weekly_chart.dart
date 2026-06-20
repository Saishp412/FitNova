import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';

class WeeklyChart extends StatefulWidget {
  WeeklyChart({super.key});

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  int _weekOffset = 0; // 0 = current week, 1 = last week, etc.

  String _formatDateIso(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return SizedBox.shrink();

    final today = DateTime.now();
    // Calculate the end date based on offset.
    // If _weekOffset is 0, end date is today. If 1, end date is today - 7 days.
    final endDate = today.subtract(Duration(days: 7 * _weekOffset));
    final startDate = endDate.subtract(Duration(days: 6));
    
    // We need to fetch meals for the 7 days between startDate and endDate.
    // So we fetch where date >= startDate AND date <= endDate.
    final startDateString = _formatDateIso(startDate);
    final endDateString = _formatDateIso(endDate);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('logged_meals')
          .where('date', isGreaterThanOrEqualTo: startDateString)
          .where('date', isLessThanOrEqualTo: endDateString)
          .snapshots(),
      builder: (context, snapshot) {
        final Map<String, int> mealsPerDay = {};
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final date = data['date'] as String? ?? '';
            if (date.isNotEmpty) {
              mealsPerDay[date] = (mealsPerDay[date] ?? 0) + 1;
            }
          }
        }

        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final startMonth = months[startDate.month - 1];
        final endMonth = months[endDate.month - 1];
        final dateRangeText = '${startDate.day} $startMonth - ${endDate.day} $endMonth';

        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          dateRangeText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium!.color!,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: AppTheme.primaryAccent),
                        onPressed: () {
                          setState(() {
                            _weekOffset++; // Go back in time
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right, 
                          color: AppTheme.primaryAccent
                        ),
                        onPressed: () {
                          setState(() {
                            _weekOffset--; // Go forward in time
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final dayDate = startDate.add(Duration(days: index));
                  final dayIso = _formatDateIso(dayDate);
                  final mealsLogged = mealsPerDay[dayIso] ?? 0;
                  
                  // Highlight if it's strictly "today" in real life
                  final isRealToday = dayDate.year == today.year && dayDate.month == today.month && dayDate.day == today.day;
                  
                  // Calculate height percentage based on max 5 meals a day
                  final double heightPercent = (mealsLogged / 5.0).clamp(0.0, 1.0);

                  return Column(
                    children: [
                      Container(
                        width: 24,
                        height: 120, // Max height
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: 24,
                          height: 120 * heightPercent,
                          decoration: BoxDecoration(
                            color: isRealToday ? AppTheme.primaryAccent : AppTheme.primaryAccent.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '${dayDate.day}\n${months[dayDate.month - 1]}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isRealToday ? FontWeight.bold : FontWeight.normal,
                          color: isRealToday ? AppTheme.primaryAccent : Theme.of(context).textTheme.bodyMedium!.color!,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
