import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/primary_button.dart';

class _OnboardPage {
  const _OnboardPage(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const _pages = [
  _OnboardPage(
    Icons.storefront_rounded,
    AppStrings.onboardTitle1,
    AppStrings.onboardBody1,
  ),
  _OnboardPage(
    Icons.straighten_rounded,
    AppStrings.onboardTitle2,
    AppStrings.onboardBody2,
  ),
  _OnboardPage(
    Icons.local_shipping_rounded,
    AppStrings.onboardTitle3,
    AppStrings.onboardBody3,
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _pages.length - 1;

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).markSeen();
    if (mounted) context.go(Routes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(AppStrings.skip),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppColors.indigo.withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 80,
                            color: AppColors.indigo,
                          ),
                        ).animate(key: ValueKey('icon$i')).scale(
                              duration: 450.ms,
                              curve: Curves.easeOutBack,
                              begin: const Offset(0.8, 0.8),
                            ),
                        const SizedBox(height: AppSizes.xl),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        )
                            .animate(key: ValueKey('title$i'))
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                            .animate(key: ValueKey('body$i'), delay: 120.ms)
                            .fadeIn(duration: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: AppColors.threadGold,
                dotColor: AppColors.stitch,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: PrimaryButton(
                label: _isLast ? AppStrings.getStarted : AppStrings.next,
                onPressed: () {
                  if (_isLast) {
                    _finish();
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
