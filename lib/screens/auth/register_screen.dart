import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/app_user.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/premium_text_field.dart';
import '../../widgets/luxury_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool get _isTailor => widget.role == UserRole.tailor;

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ref.read(authControllerProvider.notifier).register(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _nameController.text,
          role: widget.role,
          phone: _phoneController.text,
          businessName: _isTailor ? _businessController.text : null,
        );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created. We sent you a verification email — please confirm it soon.',
          ),
        ),
      );
    } else {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.toString() ?? 'Registration failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Text(
          _isTailor ? 'Tailor account' : 'Customer account',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isTailor ? 'Set up your shop' : 'Let’s get you measured up',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: AppColors.goldAccent,
                      ),
                    ).animate().fadeIn().moveY(begin: 12),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      _isTailor
                          ? 'You can complete your full business profile after signing in.'
                          : 'Create an account to browse tailors and place orders.',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    PremiumTextField(
                      hintText: AppStrings.fullName,
                      controller: _nameController,
                      prefixIcon: LucideIcons.user,
                      validator: (v) => Validators.required(v, label: 'Full name'),
                    ),
                    if (_isTailor) ...[
                      const SizedBox(height: AppSizes.md),
                      PremiumTextField(
                        hintText: AppStrings.businessName,
                        controller: _businessController,
                        prefixIcon: LucideIcons.store,
                        validator: (v) => Validators.required(v, label: 'Business name'),
                      ),
                    ],
                    const SizedBox(height: AppSizes.md),
                    PremiumTextField(
                      hintText: AppStrings.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: LucideIcons.mail,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppSizes.md),
                    PremiumTextField(
                      hintText: AppStrings.phone,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: LucideIcons.phone,
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: AppSizes.md),
                    PremiumTextField(
                      hintText: AppStrings.password,
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: LucideIcons.lock,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: AppSizes.md),
                    PremiumTextField(
                      hintText: AppStrings.confirmPassword,
                      controller: _confirmController,
                      isPassword: true,
                      prefixIcon: LucideIcons.checkSquare,
                      validator: (v) => Validators.confirmPassword(
                        v,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    LuxuryButton(
                      text: AppStrings.register,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'By creating an account you agree to our Terms of Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
