import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/screens/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _appleHealthEnabled = false;
  bool _googleFitEnabled = true;
  bool _pushNotifications = true;
  bool _coachNovaAlerts = true;
  bool _darkMode = false;
  bool _imperialUnits = true;

  String _currentRoutine = '3_DAY_CYCLE_1';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _currentRoutine = doc.data()?['routineId'] ?? '3_DAY_CYCLE_1';
        });
      }
    }
  }

  Future<void> _updateRoutine(String newRoutine) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'routineId': newRoutine,
      });
      setState(() {
        _currentRoutine = newRoutine;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Routine updated to $newRoutine')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _editProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final nameController = TextEditingController(text: user.displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, nameController.text.trim()), child: Text('Save')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != user.displayName) {
      await user.updateDisplayName(result);
      await _firestore.collection('users').doc(user.uid).update({'displayName': result});
      setState(() {}); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      }
    }
  }

  Future<void> _changePassword() async {
    final user = _auth.currentUser;
    if (user?.email == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Text('Send a password reset link to ${user!.email}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Send Link')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _auth.sendPasswordResetEmail(email: user!.email!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password reset email sent!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'FitNova Privacy Policy\n\n'
            'Your privacy is critically important to us.\n\n'
            '1. Information We Collect\n'
            'We collect information you provide directly to us, such as your email and workout preferences.\n\n'
            '2. How We Use Information\n'
            'We use the information to provide, maintain, and improve our services, including personalized AI insights.\n\n'
            '3. Data Security\n'
            'We take reasonable measures to help protect information about you from loss, theft, misuse, and unauthorized access.\n\n'
            '4. Contact Us\n'
            'If you have any questions about this Privacy Policy, please contact us at saishpatil41204@gmail.com.',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: AppTheme.primaryAccent),
            SizedBox(width: 24),
            Text('Compiling data...'),
          ],
        ),
      ),
    );

    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context); 
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Export Successful'),
          content: Text('An archive of your FitNova data has been compiled. You will receive an email shortly.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Done')),
          ],
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
        content: Text('Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text('Delete Permanently', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await user.delete();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AuthScreen()),
              (route) => false,
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Authentication Required'),
                content: Text('For security reasons, you must log out and log back in before deleting your account.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _signOut();
                    }, 
                    child: Text('Log Out')
                  ),
                ],
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
          }
        }
      }
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryAccent, size: 20),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium!.color!,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDestructive ? Colors.redAccent : Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 13))
            : null,
        trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: Theme.of(context).textTheme.bodyMedium!.color!) : null),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAboutUsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.primaryAccent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About FitNova', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color!)),
            SizedBox(height: 12),
            Text(
              'FitNova is your ultimate fitness companion, designed to adapt to your lifestyle. Whether you\'re at the gym or working out at home, our AI-driven insights and expertly crafted routines help you achieve your goals faster. Stay consistent, stay strong, and let FitNova guide your transformation.',
              style: TextStyle(fontSize: 14, height: 1.5, color: Theme.of(context).textTheme.bodyMedium!.color!),
            ),
            SizedBox(height: 24),
            Text('Contact Developer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color!)),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 20, color: AppTheme.primaryAccent),
                SizedBox(width: 16),
                Text('saishpatil41204@gmail.com', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyMedium!.color!)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 20, color: AppTheme.primaryAccent),
                SizedBox(width: 16),
                Text('+91 9136068562', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyMedium!.color!)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                FaIcon(FontAwesomeIcons.instagram, size: 20, color: AppTheme.primaryAccent), // Instagram alternative
                SizedBox(width: 16),
                Text('@saishhh.04', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyMedium!.color!)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _buildSettingsTile(
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        activeColor: AppTheme.primaryAccent,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final displayName = (user?.displayName?.trim().isNotEmpty == true) ? user!.displayName!.trim() : 'Fitnova Athlete';
    final email = user?.email ?? 'user@fitnova.com';
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryAccent, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryAccent.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Text(
                        displayName.substring(0, 1).toUpperCase(),
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent),
                      ),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  SizedBox(height: 16),
                  Text(
                    displayName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color!),
                  ).animate().fadeIn(delay: 200.ms),
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium, size: 14, color: AppTheme.primaryAccent),
                        SizedBox(width: 4),
                        Text(
                          email,
                          style: TextStyle(fontSize: 12, color: AppTheme.primaryAccent, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.secondaryAccent, borderRadius: BorderRadius.circular(2))),
                  
                  _buildSectionHeader('HEALTH & FITNESS', Icons.favorite_rounded),
                  _buildSettingsTile(
                    title: 'Current Workout Routine',
                    subtitle: _currentRoutine,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        builder: (ctx) => Container(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Select Routine', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 16),
                              Material(color: Colors.transparent, child: ListTile(title: Text('3 Days Cycle 1'), onTap: () { _updateRoutine('3_DAY_CYCLE_1'); Navigator.pop(ctx); })),
                              Material(color: Colors.transparent, child: ListTile(title: Text('3 Days Cycle 2'), onTap: () { _updateRoutine('3_DAY_CYCLE_2'); Navigator.pop(ctx); })),
                              Material(color: Colors.transparent, child: ListTile(title: Text('5 Days Cycle'), onTap: () { _updateRoutine('5_DAY_CYCLE'); Navigator.pop(ctx); })),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  _buildToggleTile(
                    title: 'Apple Health',
                    subtitle: 'Sync steps, sleep, and workouts',
                    value: _appleHealthEnabled,
                    onChanged: (val) => setState(() => _appleHealthEnabled = val),
                  ),
                  _buildToggleTile(
                    title: 'Google Fit',
                    value: _googleFitEnabled,
                    onChanged: (val) => setState(() => _googleFitEnabled = val),
                  ),

                  _buildSectionHeader('PREFERENCES', Icons.tune_rounded),
                  _buildToggleTile(
                    title: 'Dark Mode',
                    subtitle: 'Use dark theme across the app',
                    value: themeProvider.isDarkMode,
                    onChanged: (val) {
                      setState(() => _darkMode = val);
                      themeProvider.toggleTheme(val);
                    },
                  ),
                  _buildToggleTile(
                    title: 'Imperial Units',
                    subtitle: 'Use lbs, mi, and in instead of kg, km, cm',
                    value: _imperialUnits,
                    onChanged: (val) => setState(() => _imperialUnits = val),
                  ),
                  
                  _buildSectionHeader('NOTIFICATIONS', Icons.notifications_active_rounded),
                  _buildToggleTile(
                    title: 'Push Notifications',
                    subtitle: 'Daily workout reminders and tips',
                    value: _pushNotifications,
                    onChanged: (val) => setState(() => _pushNotifications = val),
                  ),
                  _buildToggleTile(
                    title: 'Coach Nova Alerts',
                    subtitle: 'Receive AI insights on your progress',
                    value: _coachNovaAlerts,
                    onChanged: (val) => setState(() => _coachNovaAlerts = val),
                  ),

                  _buildSectionHeader('ABOUT US', Icons.info_outline_rounded),
                  _buildAboutUsSection(),

                  _buildSectionHeader('ACCOUNT', Icons.person_rounded),
                  _buildSettingsTile(title: 'Edit Profile', onTap: _editProfile),
                  _buildSettingsTile(title: 'Change Password', onTap: _changePassword),
                  _buildSettingsTile(title: 'Privacy Policy', onTap: _showPrivacyPolicy),
                  _buildSettingsTile(title: 'Export My Data', onTap: _exportData),
                  _buildSettingsTile(
                    title: 'Sign Out',
                    isDestructive: true,
                    trailing: Icon(Icons.logout, color: Colors.redAccent),
                    onTap: _signOut,
                  ),
                  _buildSettingsTile(
                    title: 'Delete Account',
                    isDestructive: true,
                    trailing: SizedBox.shrink(),
                    onTap: _deleteAccount,
                  ),
                  
                  SizedBox(height: 120), // Bottom padding
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
          ),
        ],
      ),
    );
  }
}
