import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/validators.dart';
import '../../models/app_user.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/premium_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/luxury_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;

  static const _rememberKey = 'remembered_email';

  @override
  void initState() {
    super.initState();
    _restoreRememberedEmail();
  }

  Future<void> _restoreRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_rememberKey);
    if (saved != null && mounted) {
      _emailController.text = saved;
    }
  }

  Future<void> _persistRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString(_rememberKey, _emailController.text.trim());
    } else {
      await prefs.remove(_rememberKey);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await _persistRememberMe();
    final ok = await ref.read(authControllerProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );
    if (!ok && mounted) _showError();
  }

  Future<void> _googleSignIn() async {
    final ok = await ref
        .read(authControllerProvider.notifier)
        .googleSignIn(UserRole.customer);
    if (!ok && mounted) _showError();
  }

  void _showError() {
    final error = ref.read(authControllerProvider).error;
    if (error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Dark Gradient
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1556228578-0d85b1a4d571?q=80&w=800&auto=format&fit=crop'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.darkBackground.withOpacity(0.5),
                  AppColors.darkBackground.withOpacity(0.9),
                  AppColors.darkBackground,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
                  child: Column(
                    children: [
                      // Brand mark
                      const Icon(LucideIcons.scissors, color: AppColors.goldAccent, size: 48)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        AppStrings.appName.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate().fadeIn(delay: 200.ms),
                      Text(
                        AppStrings.tagline,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.goldAccentLight,
                              letterSpacing: 1.5,
                            ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: AppSizes.xl),

                      GlassCard(
                        blur: 24,
                        opacity: 0.1,
                        child: Form(
                          key: _formKey,
                          child: AutofillGroup(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PremiumTextField(
                                  hintText: AppStrings.email,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.email,
                                  prefixIcon: LucideIcons.mail,
                                ),
                                const SizedBox(height: AppSizes.md),
                                PremiumTextField(
                                  hintText: AppStrings.password,
                                  controller: _passwordController,
                                  isPassword: true,
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Password is required'
                                      : null,
                                  prefixIcon: LucideIcons.lock,
                                ),
                                const SizedBox(height: AppSizes.sm),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: AppColors.goldAccent,
                                        checkColor: AppColors.darkBackground,
                                        side: const BorderSide(color: Colors.white54),
                                        onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    const Text(
                                      AppStrings.rememberMe,
                                      style: TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: isLoading ? null : () => context.push(Routes.forgotPassword),
                                      child: const Text(
                                        AppStrings.forgotPassword,
                                        style: TextStyle(color: AppColors.goldAccent, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSizes.md),
                                LuxuryButton(
                                  text: AppStrings.login,
                                  isLoading: isLoading,
                                  onPressed: _submit,
                                ),
                                const SizedBox(height: AppSizes.md),
                                const _OrDivider(),
                                const SizedBox(height: AppSizes.md),
                                _GoogleButton(
                                  onPressed: isLoading ? null : _googleSignIn,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms).moveY(begin: 30),

                      const SizedBox(height: AppSizes.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            AppStrings.noAccount,
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: isLoading ? null : () => context.push(Routes.roleSelection),
                            child: const Text(
                              AppStrings.register,
                              style: TextStyle(
                                color: AppColors.goldAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text('or', style: TextStyle(color: Colors.white54)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.15))),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        ),
      ),
      icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.white),
      label: const Text('CONTINUE WITH GOOGLE', style: TextStyle(letterSpacing: 1.2)),
    );
  }
}
