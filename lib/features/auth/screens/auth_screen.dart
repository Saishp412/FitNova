import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../dashboard/screens/main_layout_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  
  bool isLogin = true;
  bool isLoading = false;
  bool isObscured = true;

  // Password Rules
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasNumber = false;
  bool passwordsMatch = true;

  late final AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePasswordMatch);
    
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  void _validatePassword() {
    final pass = _passwordController.text;
    setState(() {
      hasMinLength = pass.length >= 8;
      hasUppercase = pass.contains(RegExp(r'[A-Z]'));
      hasNumber = pass.contains(RegExp(r'[0-9]'));
    });
    _validatePasswordMatch();
  }

  void _validatePasswordMatch() {
    setState(() {
      if (_confirmPasswordController.text.isEmpty) {
        passwordsMatch = true;
      } else {
        passwordsMatch = _passwordController.text == _confirmPasswordController.text;
      }
    });
  }

  bool _isSignUpValid() {
    if (_nameController.text.trim().isEmpty) return false;
    if (_emailController.text.trim().isEmpty) return false;
    if (!hasMinLength || !hasUppercase || !hasNumber) return false;
    if (!passwordsMatch || _passwordController.text != _confirmPasswordController.text) return false;
    return true;
  }

  bool _isLoginValid() {
    return _emailController.text.trim().isNotEmpty && _passwordController.text.isNotEmpty;
  }

  Future<void> _submit() async {
    if (isLogin && !_isLoginValid()) return;
    if (!isLogin && !_isSignUpValid()) return;

    setState(() => isLoading = true);
    
    try {
      if (isLogin) {
        final userCredential = await _authService.signInWithEmail(_emailController.text, _passwordController.text);
        
        if (mounted && userCredential != null && userCredential.user != null) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
          final userData = userDoc.data();
          
          if (userData != null && userData.containsKey('onboardingData')) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainLayoutScreen()));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => OnboardingScreen()));
          }
        }
      } else {
        await _authService.signUpWithEmail(_emailController.text, _passwordController.text, _nameController.text);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account created successfully! Please log in.'), backgroundColor: Colors.green),
          );
          setState(() {
            isLogin = true;
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = e.message ?? 'An error occurred';
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          errorMessage = 'Credentials do not match. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red.shade800),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated Background Orbs (Softened for the beige theme)
          AnimatedBuilder(
            animation: _bgAnimController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.1 + math.sin(_bgAnimController.value * 2 * math.pi) * 50,
                    left: MediaQuery.of(context).size.width * 0.1 + math.cos(_bgAnimController.value * 2 * math.pi) * 50,
                    child: Container(
                      width: 300, height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryAccent.withAlpha(20),
                        boxShadow: [BoxShadow(color: AppTheme.primaryAccent.withAlpha(20), blurRadius: 100, spreadRadius: 50)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.1 + math.cos(_bgAnimController.value * 2 * math.pi) * 50,
                    right: MediaQuery.of(context).size.width * 0.1 + math.sin(_bgAnimController.value * 2 * math.pi) * 50,
                    child: Container(
                      width: 250, height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.secondaryAccent.withAlpha(20),
                        boxShadow: [BoxShadow(color: AppTheme.secondaryAccent.withAlpha(20), blurRadius: 100, spreadRadius: 50)],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Icon(Icons.fitness_center, size: 64, color: AppTheme.primaryAccent)
                      .animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 16),
                    Text(
                      'FitNova',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                    const SizedBox(height: 48),

                    // Glassmorphic Card (Light version)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface.withAlpha(200),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: AppTheme.secondaryAccent.withAlpha(100), width: 1.5),
                            boxShadow: [
                              BoxShadow(color: AppTheme.primaryAccent.withAlpha(20), blurRadius: 30, spreadRadius: -5),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Custom Toggle Switch
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(color: AppTheme.secondaryAccent.withAlpha(50)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => isLogin = true),
                                        behavior: HitTestBehavior.opaque,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          decoration: BoxDecoration(
                                            color: isLogin ? AppTheme.primaryAccent : Colors.transparent,
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Login',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isLogin ? Theme.of(context).colorScheme.surface : Theme.of(context).textTheme.bodyMedium!.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => isLogin = false),
                                        behavior: HitTestBehavior.opaque,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          decoration: BoxDecoration(
                                            color: !isLogin ? AppTheme.primaryAccent : Colors.transparent,
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: !isLogin ? Theme.of(context).colorScheme.surface : Theme.of(context).textTheme.bodyMedium!.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Form Fields
                              AnimatedSize(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOutBack,
                                child: Column(
                                  children: [
                                    if (!isLogin) ...[
                                      _buildInputField(
                                        controller: _nameController,
                                        icon: Icons.person_outline,
                                        hintText: 'Full Name',
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    _buildInputField(
                                      controller: _emailController,
                                      icon: Icons.email_outlined,
                                      hintText: 'Email Address',
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInputField(
                                      controller: _passwordController,
                                      icon: Icons.lock_outline,
                                      hintText: 'Password',
                                      obscureText: isObscured,
                                      suffixIcon: IconButton(
                                        icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Theme.of(context).textTheme.bodyMedium!.color),
                                        onPressed: () => setState(() => isObscured = !isObscured),
                                      ),
                                    ),
                                    if (!isLogin) ...[
                                      const SizedBox(height: 16),
                                      _buildInputField(
                                        controller: _confirmPasswordController,
                                        icon: Icons.lock_reset,
                                        hintText: 'Confirm Password',
                                        obscureText: isObscured,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildPasswordRules(),
                                    ],
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Submit Button
                              ElevatedButton(
                                onPressed: (isLogin ? _isLoginValid() : _isSignUpValid()) && !isLoading ? _submit : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryAccent,
                                  disabledBackgroundColor: AppTheme.primaryAccent.withAlpha(50),
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.surface))
                                    : Text(
                                        isLogin ? 'WELCOME BACK' : 'CREATE ACCOUNT',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: (isLogin ? _isLoginValid() : _isSignUpValid()) ? Theme.of(context).colorScheme.surface : Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(150),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Text Links
                              Center(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLogin = !isLogin),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).textTheme.bodyMedium!.color,
                                        ),
                                        children: [
                                          TextSpan(text: isLogin ? "Don't have an account? " : "Already have an account? "),
                                          TextSpan(
                                            text: isLogin ? 'Sign up' : 'Log in',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondaryAccent.withAlpha(100), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: 16),
        onChanged: (_) => setState(() {}), // Trigger rebuild for button validation
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Theme.of(context).textTheme.bodyMedium!.color),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(150)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPasswordRules() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondaryAccent.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Password Requirements:', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildRuleRow('At least 8 characters', hasMinLength),
          const SizedBox(height: 4),
          _buildRuleRow('At least 1 uppercase letter', hasUppercase),
          const SizedBox(height: 4),
          _buildRuleRow('At least 1 number', hasNumber),
          const SizedBox(height: 4),
          _buildRuleRow('Passwords match', passwordsMatch && _confirmPasswordController.text.isNotEmpty),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String text, bool isValid) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isValid ? Colors.green : Colors.transparent,
            border: Border.all(color: isValid ? Colors.green : Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(100)),
          ),
          child: Icon(Icons.check, size: 12, color: isValid ? Colors.white : Colors.transparent),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isValid ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).textTheme.bodyMedium!.color,
            fontSize: 12,
            decoration: isValid ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}
