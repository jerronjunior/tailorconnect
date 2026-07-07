import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/validators.dart';
import '../../models/app_user.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';

/// Email/password + Google login on a brand-gradient background with a
/// frosted glass form card.
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
                child: Column(
                  children: [
                    // Brand mark
                    const Icon(Icons.content_cut,
                            color: AppColors.threadGoldLight, size: 44)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      AppStrings.appName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: Colors.white),
                    ),
                    Text(
                      AppStrings.tagline,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: AppSizes.xl),

                    GlassCard(
                      child: Form(
                        key: _formKey,
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Theme(
                                // Glass card sits on a dark gradient, so the
                                // form uses light-on-dark styling locally.
                                data: _glassFieldTheme(context),
                                child: Column(
                                  children: [
                                    AppTextField(
                                      label: AppStrings.email,
                                      controller: _emailController,
                                      hint: 'you@example.com',
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      validator: Validators.email,
                                      prefixIcon: Icons.mail_outline,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.email
                                      ],
                                    ),
                                    const SizedBox(height: AppSizes.md),
                                    AppTextField(
                                      label: AppStrings.password,
                                      controller: _passwordController,
                                      obscure: true,
                                      validator: (v) => (v == null || v.isEmpty)
                                          ? 'Password is required'
                                          : null,
                                      prefixIcon: Icons.lock_outline,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [
                                        AutofillHints.password
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSizes.sm),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: AppColors.threadGold,
                                      side: const BorderSide(
                                          color: Colors.white70),
                                      onChanged: (v) => setState(
                                          () => _rememberMe = v ?? false),
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.sm),
                                  const Text(
                                    AppStrings.rememberMe,
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => context
                                            .push(Routes.forgotPassword),
                                    child: const Text(
                                      AppStrings.forgotPassword,
                                      style: TextStyle(
                                        color: AppColors.threadGoldLight,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSizes.md),
                              PrimaryButton(
                                label: AppStrings.login,
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
                    ).animate().fadeIn(delay: 150.ms).moveY(begin: 24),

                    const SizedBox(height: AppSizes.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppStrings.noAccount,
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.push(Routes.roleSelection),
                          child: const Text(
                            AppStrings.register,
                            style: TextStyle(
                              color: AppColors.threadGoldLight,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }

  /// Field styling tuned for the frosted card on the dark gradient.
  ThemeData _glassFieldTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: Colors.white.withOpacity(0.08),
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIconColor: Colors.white54,
        suffixIconColor: Colors.white54,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusField),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
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
        Expanded(child: Divider(color: Colors.white.withOpacity(0.25))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text('or', style: TextStyle(color: Colors.white54)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.25))),
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
        side: BorderSide(color: Colors.white.withOpacity(0.4)),
        minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusButton),
        ),
      ),
      icon: const Icon(Icons.g_mobiledata, size: 30),
      label: const Text(AppStrings.continueWithGoogle),
    );
  }
}
