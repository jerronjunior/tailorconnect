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
import '../../widgets/luxury_button.dart';

class _OnboardPage {
  const _OnboardPage(this.imageUrl, this.title, this.body);
  final String imageUrl;
  final String title;
  final String body;
}

const _pages = [
  _OnboardPage(
    'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?q=80&w=800&auto=format&fit=crop',
    AppStrings.onboardTitle1,
    AppStrings.onboardBody1,
  ),
  _OnboardPage(
    'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?q=80&w=800&auto=format&fit=crop',
    AppStrings.onboardTitle2,
    AppStrings.onboardBody2,
  ),
  _OnboardPage(
    'https://images.unsplash.com/photo-1589465885857-44ed64637158?q=80&w=800&auto=format&fit=crop',
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
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final page = _pages[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    page.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  // Dark gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.darkBackground.withOpacity(0.3),
                          AppColors.darkBackground.withOpacity(0.8),
                          AppColors.darkBackground,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.goldAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            .animate(key: ValueKey('title$i'))
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.3),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        )
                            .animate(key: ValueKey('body$i'), delay: 200.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: 120), // Space for indicator and button
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: TextButton(
                  onPressed: _finish,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black45,
                  ),
                  child: const Text('SKIP', style: TextStyle(letterSpacing: 1.2)),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: AppSizes.xl,
            left: AppSizes.xl,
            right: AppSizes.xl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: const ExpandingDotsEffect(
                    dotHeight: 6,
                    dotWidth: 8,
                    activeDotColor: AppColors.goldAccent,
                    dotColor: Colors.white24,
                  ),
                ),
                const SizedBox(height: AppSizes.xl),
                LuxuryButton(
                  text: _isLast ? AppStrings.getStarted : AppStrings.next,
                  onPressed: () {
                    if (_isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutQuart,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
