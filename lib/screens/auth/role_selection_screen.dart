import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../models/app_user.dart';

/// Step 1 of registration: pick Customer or Tailor.
/// The chosen role is passed to [RegisterScreen] via `extra`.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.chooseRole,
                    style: theme.textTheme.headlineMedium,
                  ).animate().fadeIn(duration: 350.ms).moveY(begin: 12),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'You can only pick this once per account.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSizes.xl),
                  _RoleCard(
                    icon: Icons.checkroom_outlined,
                    title: AppStrings.roleCustomerTitle,
                    body: AppStrings.roleCustomerBody,
                    onTap: () => context.push(
                      Routes.register,
                      extra: UserRole.customer,
                    ),
                  ).animate(delay: 120.ms).fadeIn().moveY(begin: 16),
                  const SizedBox(height: AppSizes.md),
                  _RoleCard(
                    icon: Icons.content_cut_outlined,
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
      color: theme.cardTheme.color ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusCard),
            border: Border.all(color: AppColors.stitch),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(AppSizes.radiusField),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSizes.xs),
                    Text(body, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
