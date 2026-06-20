import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';

class HydrationCard extends StatelessWidget {
  HydrationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return SizedBox.shrink();

    final today = DateTime.now();
    final todayIso = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('daily_tracking')
          .doc(todayIso)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final int glassesDrunk = data?['waterIntake'] ?? 0;
        const int dailyGoal = 8;

        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1),
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
                    child: Text(
                      'Hydration',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$glassesDrunk/$dailyGoal',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(dailyGoal, (index) {
                  final isDrunk = index < glassesDrunk;
                  return GestureDetector(
                    onTap: () {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('daily_tracking')
                          .doc(todayIso)
                          .set({
                        'waterIntake': index + 1,
                      }, SetOptions(merge: true));
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 48,
                      width: 32,
                      decoration: BoxDecoration(
                        color: isDrunk ? Colors.blue.shade400 : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: isDrunk
                          ? Icon(Icons.water_drop, color: Colors.white, size: 20).animate().scale()
                          : SizedBox.shrink(),
                    ),
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
