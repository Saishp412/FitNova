import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/screens/auth_screen.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isGymMode = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('workoutMode') ?? 'gym';
    setState(() {
      isGymMode = mode == 'gym';
      isLoading = false;
    });
  }

  Future<void> _toggleMode() async {
    setState(() {
      isGymMode = !isGymMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workoutMode', isGymMode ? 'gym' : 'home');
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isGymMode ? 'GYM MODE' : 'HOME MODE',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: isGymMode ? AppTheme.primaryAccent : AppTheme.secondaryAccent),
        ).animate(key: ValueKey(isGymMode)).fadeIn().slideX(),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz, color: Theme.of(context).textTheme.bodyLarge!.color!),
            onPressed: _toggleMode,
            tooltip: 'Toggle Mode',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).textTheme.bodyLarge!.color!),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGreetingCard().animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
            SizedBox(height: 32),
            Text(
              'Today\'s Plan',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 200.ms),
            SizedBox(height: 16),
            isGymMode ? _buildGymPlan() : _buildHomePlan(),
            SizedBox(height: 32),
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 400.ms),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Streak', '4 Days', Icons.local_fire_department, Colors.orange).animate().fadeIn(delay: 500.ms).scale()),
                SizedBox(width: 16),
                Expanded(child: _buildStatCard('Volume', '12k kg', Icons.fitness_center, AppTheme.primaryAccent).animate().fadeIn(delay: 600.ms).scale()),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Weekly Nutrition Progress',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 700.ms),
            SizedBox(height: 16),
            _buildWeeklyProgress().animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: isGymMode ? AppTheme.primaryAccent : AppTheme.secondaryAccent,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        icon: Icon(Icons.play_arrow),
        label: Text('START WORKOUT', style: TextStyle(fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 800.ms),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGymMode 
              ? [AppTheme.primaryAccent.withValues(alpha: 0.2), Theme.of(context).scaffoldBackgroundColor]
              : [AppTheme.secondaryAccent.withValues(alpha: 0.2), Theme.of(context).scaffoldBackgroundColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isGymMode ? AppTheme.primaryAccent : AppTheme.secondaryAccent).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Good Morning, Athlete!', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
          SizedBox(height: 8),
          Text(
            isGymMode ? 'Ready to lift heavy today?' : 'Time to sweat it out at home.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildGymPlan() {
    return Column(
      children: [
        _buildWorkoutCard('Push Day', 'Chest, Shoulders, Triceps', '60 Min', Icons.fitness_center),
      ],
    ).animate(key: ValueKey('gym')).fadeIn().slideX(begin: 0.1);
  }

  Widget _buildHomePlan() {
    return Column(
      children: [
        _buildWorkoutCard('HIIT Cardio', 'Full Body Burn', '25 Min', Icons.directions_run),
      ],
    ).animate(key: ValueKey('home')).fadeIn().slideX(begin: -0.1);
  }

  Widget _buildWorkoutCard(String title, String subtitle, String duration, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).textTheme.bodyLarge!.color!),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).textTheme.bodyLarge!.color!)),
                SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 14)),
              ],
            ),
          ),
          Text(duration, style: TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20)),
          SizedBox(height: 4),
          Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!)),
        ],
      ),
    );
  }

  String _formatDateIso(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Widget _buildWeeklyProgress() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return SizedBox();

    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: 6));
    final startDateString = _formatDateIso(startDate);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('logged_meals')
          .where('date', isGreaterThanOrEqualTo: startDateString)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final Map<String, int> mealsPerDay = {};
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final date = data['date'] as String? ?? '';
          if (date.isNotEmpty) {
            mealsPerDay[date] = (mealsPerDay[date] ?? 0) + 1;
          }
        }

        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayDate = startDate.add(Duration(days: index));
              final dayIso = _formatDateIso(dayDate);
              final mealsLogged = mealsPerDay[dayIso] ?? 0;
              final isToday = index == 6; // index 6 is today since we started at today - 6

              return Column(
                children: [
                  Text('${dayDate.day} ${months[dayDate.month - 1]}', style: TextStyle(color: isToday ? AppTheme.primaryAccent : Theme.of(context).textTheme.bodyMedium!.color!, fontWeight: isToday ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                  SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: mealsLogged > 0 ? AppTheme.primaryAccent : Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: isToday ? AppTheme.primaryAccent : Colors.transparent, width: 1.5),
                    ),
                    child: Center(
                      child: mealsLogged > 0 
                          ? Text('$mealsLogged', style: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold, fontSize: 12))
                          : Text('${dayDate.day}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 12)),
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
