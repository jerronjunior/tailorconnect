import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../models/app_user.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.chooseRole,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.goldAccent,
                    ),
                  ).animate().fadeIn(duration: 350.ms).moveY(begin: 12),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'You can only pick this once per account.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _RoleCard(
                    icon: LucideIcons.shirt,
                    title: AppStrings.roleCustomerTitle,
                    body: AppStrings.roleCustomerBody,
                    onTap: () => context.push(
                      Routes.register,
                      extra: UserRole.customer,
                    ),
                  ).animate(delay: 120.ms).fadeIn().moveY(begin: 16),
                  const SizedBox(height: AppSizes.md),
                  _RoleCard(
                    icon: LucideIcons.scissors,
                    title: AppStrings.roleTailorTitle,
                    body: AppStrings.roleTailorBody,
                    onTap: () => context.push(
                      Routes.register,
                      extra: UserRole.tailor,
                    ),
                  ).animate(delay: 220.ms).fadeIn().moveY(begin: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        splashColor: AppColors.goldAccent.withOpacity(0.1),
        highlightColor: AppColors.goldAccent.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceHighlight,
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.luxuryGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusField),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.goldAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: AppSizes.xs),
                    Text(body, style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    )),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: AppColors.goldAccentLight),
            ],
          ),
        ),
      ),
    );
  }
}
