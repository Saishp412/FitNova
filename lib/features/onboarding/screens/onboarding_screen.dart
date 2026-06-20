import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/screens/main_layout_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'What is your primary fitness goal?',
      'options': ['Weight Loss', 'Muscle Gain', 'Strength', 'General Fitness'],
    },
    {
      'title': 'What is your current fitness level?',
      'options': ['Beginner', 'Intermediate', 'Advanced'],
    },
    {
      'title': 'What is your biological sex?',
      'options': ['Male', 'Female', 'Other'],
    },
    {
      'title': 'How old are you?',
      'isInput': true,
      'hint': 'Age (e.g. 24)'
    },
    {
      'title': 'How tall are you?',
      'isInput': true,
      'hint': 'Height in cm (e.g. 175)'
    },
    {
      'title': 'What is your current weight?',
      'isInput': true,
      'hint': 'Weight in kg (e.g. 70)'
    },
    {
      'title': 'What is your target weight?',
      'isInput': true,
      'hint': 'Weight in kg (e.g. 65)'
    },
    {
      'title': 'How many days a week can you commit?',
      'options': ['1-2 Days', '3-4 Days', '5-6 Days', 'Everyday'],
    },
    {
      'title': 'What is your dietary preference?',
      'options': ['Omnivore (Any)', 'Vegetarian', 'Vegan', 'Lactose Intolerant'],
    },
    {
      'title': 'Where do you primarily workout?',
      'options': ['Home', 'Gym'],
    },
  ];

  final Map<String, dynamic> _answers = {};
  bool _isSaving = false;

  void _nextPage(String? selectedOption) async {
    final currentQ = _questions[_currentIndex];
    
    // Save answer
    if (selectedOption != null && selectedOption != 'Input') {
      _answers[currentQ['title']] = selectedOption;
    } else {
      // In a real app, we'd grab the text from a controller here.
      // For this step, we'll just mock the input since it's a structural update.
      _answers[currentQ['title']] = 'User Input'; 
    }

    if (_currentIndex == _questions.length - 1) {
      setState(() => _isSaving = true);
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        
        final mode = selectedOption == 'Gym' ? 'gym' : 'home';
        await prefs.setString('workoutMode', mode);
        
        final dietPref = _answers['What is your dietary preference?'] ?? 'Omnivore (Any)';
        await prefs.setString('dietPreference', dietPref);
        
        // Save to Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'onboardingData': _answers,
            'workoutMode': mode,
            'dietPreference': dietPref,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainLayoutScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving data: $e')));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    } else {
      _pageController.nextPage(duration: 300.ms, curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(24.0),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                backgroundColor: Theme.of(context).colorScheme.surface,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryAccent),
                borderRadius: BorderRadius.circular(8),
                minHeight: 8,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          q['title'],
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn().slideY(begin: 0.2),
                        SizedBox(height: 48),
                        if (q['isInput'] == true)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(hintText: q['hint']),
                              ).animate().fadeIn(delay: 200.ms),
                              SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () => _nextPage('Input'),
                                child: Text('CONTINUE'),
                              ).animate().fadeIn(delay: 300.ms),
                            ],
                          )
                        else
                          ...List.generate((q['options'] as List).length, (optIndex) {
                            final option = q['options'][optIndex];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: InkWell(
                                onTap: () => _nextPage(option),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.2)),
                                  ),
                                  child: Text(
                                    option,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: (200 + (optIndex * 100)).ms).slideX(begin: 0.1);
                          }),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
