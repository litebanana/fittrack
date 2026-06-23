import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    ));
    _scaleAnim =
        Tween<double>(begin: 0.5, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.elasticOut),
    ));
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.status == AuthStatus.authenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: const Text(
                    'FitTrack',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Fitness Journey',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 60),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
