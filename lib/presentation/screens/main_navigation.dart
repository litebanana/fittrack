import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_provider.dart';
import '../../data/repositories/workout_provider.dart';
import '../../data/repositories/nutrition_measurement_provider.dart';
import 'home/home_screen.dart';
import 'workout/workout_screen.dart';
import 'progress/progress_screen.dart';
import 'nutrition/nutrition_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    HomeScreen(),
    WorkoutScreen(),
    ProgressScreen(),
    NutritionScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null) {
        context.read<WorkoutProvider>().loadWorkouts(userId);
        context.read<NutritionProvider>().loadTodayEntries(userId);
        context.read<MeasurementProvider>().loadMeasurements(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: const Border(
            top: BorderSide(color: AppTheme.surfaceLight, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.primary.withOpacity(0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Workout',
            ),
            NavigationDestination(
              icon: Icon(Icons.trending_up_outlined),
              selectedIcon: Icon(Icons.trending_up),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu),
              label: 'Nutrition',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
