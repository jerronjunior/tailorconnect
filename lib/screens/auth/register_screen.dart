import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../models/app_user.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Step 2 of registration. Fields adapt to the role chosen on the
/// role-selection screen — tailors additionally provide a business name.
/// On success a verification email is sent and the router redirects to the
/// correct home based on the created `users/{uid}` document.
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
            'Account created. We sent you a verification email — '
            'please confirm it soon.',
          ),
        ),
      );
      // Router redirect handles navigation once the users doc streams in.
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
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(_isTailor ? 'Tailor account' : 'Customer account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isTailor
                          ? 'Set up your shop'
                          : 'Let’s get you measured up',
                      style: theme.textTheme.headlineMedium,
                    ).animate().fadeIn().moveY(begin: 12),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      _isTailor
                          ? 'You can complete your full business profile after signing in.'
                          : 'Create an account to browse tailors and place orders.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppTextField(
                      label: AppStrings.fullName,
                      controller: _nameController,
                      hint: 'Jane Doe',
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          Validators.required(v, label: 'Full name'),
                      autofillHints: const [AutofillHints.name],
                    ),
                    if (_isTailor) ...[
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        label: AppStrings.businessName,
                        controller: _businessController,
                        hint: 'Stitch & Co.',
                        prefixIcon: Icons.storefront_outlined,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            Validators.required(v, label: 'Business name'),
                      ),
                    ],
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      label: AppStrings.email,
                      controller: _emailController,
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      label: AppStrings.phone,
                      controller: _phoneController,
                      hint: '+1 555 000 0000',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      textInputAction: TextInputAction.next,
                      validator: Validators.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      label: AppStrings.password,
                      controller: _passwordController,
                      obscure: true,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.next,
                      validator: Validators.password,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      label: AppStrings.confirmPassword,
                      controller: _confirmController,
                      obscure: true,
                      prefixIcon: Icons.lock_outline,
                      textInputAction: TextInputAction.done,
                      validator: (v) => Validators.confirmPassword(
                        v,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    PrimaryButton(
                      label: AppStrings.register,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      'By creating an account you agree to our Terms of '
                      'Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
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
