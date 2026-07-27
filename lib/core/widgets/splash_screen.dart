import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.navigateToPath('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.auto_stories, size: 64, color: Colors.white),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                const SizedBox(height: 24),
                const Text('VisionNote AI', style: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.02))
                    .animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),
                const Text('Transform documents into knowledge', style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.white70))
                    .animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 48),
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
                    .animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
