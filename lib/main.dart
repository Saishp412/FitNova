import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/dashboard/screens/main_layout_screen.dart';
import 'features/onboarding/screens/landing_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, 
    );
  } catch (e) {
    debugPrint('Firebase not configured yet: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  
  // For Testing: Clear preferences so the Landing Screen always shows first
  // await prefs.clear(); // REMOVED: Caused users to log in every time
  
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
  
  Widget initialScreen;
  if (isFirstTime) {
    initialScreen = LandingScreen();
  } else if (isLoggedIn) {
    initialScreen = MainLayoutScreen();
  } else {
    initialScreen = AuthScreen();
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: prefs),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: FitNovaApp(initialScreen: initialScreen),
    ),
  );
}

class FitNovaApp extends StatelessWidget {
  final Widget initialScreen;
  
  FitNovaApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'FitNova',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: initialScreen,
    );
  }
}
