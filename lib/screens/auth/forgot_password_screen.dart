import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/premium_text_field.dart';
import '../../widgets/luxury_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(_emailController.text);

    if (!mounted) return;
    if (ok) {
      setState(() => _sent = true);
    } else {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.toString() ?? 'Could not send email.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(leading: const BackButton(color: Colors.white)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              child: _sent ? _buildSent(theme, context) : _buildForm(theme, isLoading),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.resetPassword, 
            style: theme.textTheme.headlineMedium?.copyWith(color: AppColors.goldAccent)
          ).animate().fadeIn().moveY(begin: 12),
          const SizedBox(height: AppSizes.sm),
          Text(
            AppStrings.resetPasswordHint, 
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)
          ),
          const SizedBox(height: AppSizes.lg),
          PremiumTextField(
            hintText: AppStrings.email,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: LucideIcons.mail,
            validator: Validators.email,
          ),
          const SizedBox(height: AppSizes.xl),
          LuxuryButton(
            text: AppStrings.sendResetLink,
            isLoading: isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSent(ThemeData theme, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(LucideIcons.mailCheck, size: 72, color: AppColors.goldAccent)
            .animate()
            .scale(begin: const Offset(0.6, 0.6), curve: Curves.elasticOut, duration: 600.ms),
        const SizedBox(height: AppSizes.lg),
        Text(
          'Check your inbox',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          'We sent a password reset link to ${_emailController.text.trim()}. Follow the link to set a new password, then log in again.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: AppSizes.xl),
        LuxuryButton(
          text: 'BACK TO LOG IN',
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
