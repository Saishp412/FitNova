import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/screens/auth_screen.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen({super.key});

  Future<void> _getStarted(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main Scrollable Content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 140),
              children: [
                // Hero Section
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.secondaryAccent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryAccent.withAlpha(50),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ]
                    ),
                    child: Center(
                      child: Icon(Icons.fitness_center, size: 60, color: AppTheme.primaryAccent)
                          .animate()
                          .scale(duration: 800.ms, curve: Curves.easeOutBack),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms),
                
                const SizedBox(height: 32),
                
                Text(
                  'FitNova',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 16),
                
                Text(
                  'Your Ultimate AI Fitness Companion.\nElevate training. Track progress. Achieve greatness.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(200),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 64),
                
                // Feature Header
                Text(
                  'POWERFUL FEATURES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.secondaryAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: 24),
                
                // Feature Cards
                _buildFeatureCard(
                  context,
                  icon: Icons.psychology,
                  title: 'Coach Nova AI',
                  description: 'Get personalized, data-driven advice from our advanced GPT-powered fitness coach.',
                  delay: 700,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.fitness_center,
                  title: 'Smart Workouts',
                  description: 'Follow expertly crafted 3-day and 5-day cycle routines with detailed video cues.',
                  delay: 800,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.restaurant,
                  title: 'Custom Nutrition',
                  description: 'Dynamic macro tracking tailored to your diet, whether Vegan, Keto, or Omnivore.',
                  delay: 900,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.insights,
                  title: 'Advanced Analytics',
                  description: 'Visualize your progress with weekly heatmaps, charts, and downloadable PDF reports.',
                  delay: 1000,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.dark_mode,
                  title: 'Premium Design',
                  description: 'A beautiful, state-of-the-art dark mode interface built for speed and aesthetics.',
                  delay: 1100,
                ),
                
              ],
            ),
          ),
          
          // Sticky Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withAlpha(200),
                    border: Border(
                      top: BorderSide(color: AppTheme.primaryAccent.withAlpha(50), width: 1),
                    )
                  ),
                  child: SafeArea(
                    top: false,
                    child: ElevatedButton(
                      onPressed: () => _getStarted(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: AppTheme.primaryAccent.withAlpha(100),
                      ),
                      child: Text(
                        'GET STARTED NOW',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 1.5,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ).animate().scale(delay: 1200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required String description, required int delay}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryAccent.withAlpha(30), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, curve: Curves.easeOutCubic);
  }
}
