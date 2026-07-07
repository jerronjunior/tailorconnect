import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/app_user.dart';
import '../../providers/auth_providers.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/role_selection_screen.dart';
import '../../screens/home/customer_home_screen.dart';
import '../../screens/home/tailor_home_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/splash/splash_screen.dart';

/// Route names — always navigate via these constants.
abstract final class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const roleSelection = '/role-selection';
  static const forgotPassword = '/forgot-password';
  static const customerHome = '/customer';
  static const tailorHome = '/tailor';
}

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever auth or onboarding state changes.
  final authState = ref.watch(authStateProvider);
  final appUser = ref.watch(appUserProvider);
  final onboardingSeen = ref.watch(onboardingSeenProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    redirect: (context, state) {
      final loggingRelated = {
        Routes.login,
        Routes.register,
        Routes.roleSelection,
        Routes.forgotPassword,
      }.contains(state.matchedLocation);

      // Stay on splash while auth is resolving.
      if (authState.isLoading) return null;

      final signedIn = authState.valueOrNull != null;

      if (!signedIn) {
        if (!onboardingSeen && state.matchedLocation == Routes.splash) {
          return Routes.onboarding;
        }
        if (loggingRelated || state.matchedLocation == Routes.onboarding) {
          return null;
        }
        return Routes.login;
      }

      // Signed in: route by role once the user document is available.
      final role = appUser.valueOrNull?.role;
      if (role == null) return null; // still loading user doc
      final home =
          role == UserRole.tailor ? Routes.tailorHome : Routes.customerHome;
      if (loggingRelated ||
          state.matchedLocation == Routes.splash ||
          state.matchedLocation == Routes.onboarding) {
        return home;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.login,
        pageBuilder: (_, state) => _fade(state, const LoginScreen()),
      ),
      GoRoute(
        path: Routes.roleSelection,
        pageBuilder: (_, state) => _fade(state, const RoleSelectionScreen()),
      ),
      GoRoute(
        path: Routes.register,
        pageBuilder: (_, state) => _fade(
          state,
          RegisterScreen(role: state.extra as UserRole? ?? UserRole.customer),
        ),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        pageBuilder: (_, state) => _fade(state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: Routes.customerHome,
        builder: (_, __) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: Routes.tailorHome,
        builder: (_, __) => const TailorHomeScreen(),
      ),
    ],
  );
});

/// Soft cross-fade used between auth screens.
CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}
