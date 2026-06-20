import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import 'home_dashboard.dart';
import '../../explore/screens/explore_screen.dart';
import '../../analytics/screens/ai_analytics_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeDashboard(
        onProfileTap: () => setState(() => _currentIndex = 3),
      ),
      ExploreScreen(),
      AiAnalyticsScreen(),
      ProfileScreen(),
    ];

    final List<_NavItem> navItems = const [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
      _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore'),
      _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Analytics'),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FloatingNavBar(
              currentIndex: _currentIndex,
              navItems: navItems,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> navItems;
  final void Function(int) onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.navItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: UnconstrainedBox(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withAlpha(150),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppTheme.primaryAccent.withAlpha(30),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(navItems.length * 2 - 1, (i) {
                  if (i.isOdd) return const SizedBox(width: 8); // Reduced width to fit 4 items better
                  final index = i ~/ 2;
                  final item = navItems[index];
                  final isActive = currentIndex == index;
                  return _NavButton(
                    icon: item.icon,
                    activeIcon: item.activeIcon,
                    label: item.label,
                    isActive: isActive,
                    onTap: () => onTap(index),
                  );
                }),
              ),
            ),
          ),
        ),
      ).animate().slideY(begin: 1.0, duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryAccent.withAlpha(40) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? AppTheme.primaryAccent : Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(150),
                size: 24,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: AppTheme.primaryAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ).animate().fadeIn(duration: 250.ms).slideX(begin: 0.2),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
