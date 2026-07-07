import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1556228578-0d85b1a4d571?q=80&w=600&auto=format&fit=crop'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 3D-like floating icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.luxuryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldAccent.withOpacity(0.5),
                      blurRadius: 50,
                      spreadRadius: 10,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  )
                ),
                child: const Icon(
                  LucideIcons.scissors,
                  size: 56,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .moveY(begin: -8, end: 8, duration: 2.seconds, curve: Curves.easeInOut)
                  .then()
                  .shimmer(duration: 2.seconds, color: Colors.white54),
              
              const SizedBox(height: 40),
              
              Text(
                AppStrings.appName.toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.goldAccent,
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
              ).animate().fadeIn(duration: 800.ms, delay: 300.ms).slideY(
                    begin: 0.2,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 12),
              const Text(
                AppStrings.tagline,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w300,
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
