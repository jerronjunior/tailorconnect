import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// Animated splash. Navigation away from here is handled entirely by the
/// GoRouter redirect (auth state + onboarding flag), so this screen only
/// needs to look good while auth resolves.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo mark: a spool of thread rendered with layered circles.
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.threadGold.withOpacity(0.45),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.content_cut_rounded,
                  size: 44,
                  color: AppColors.indigoDeep,
                ),
              )
                  .animate()
                  .scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.6, 0.6),
                  )
                  .then()
                  .shimmer(duration: 1200.ms, color: Colors.white38),
              const SizedBox(height: 28),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
              ).animate(delay: 250.ms).fadeIn(duration: 500.ms).slideY(
                    begin: 0.3,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 8),
              const Text(
                AppStrings.tagline,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  letterSpacing: 1.2,
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
