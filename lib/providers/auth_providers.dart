import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

/// ---- Dependency injection ------------------------------------------------

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Raw Firebase auth state (null = signed out).
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges,
);

/// The signed-in user's `users/{uid}` document, kept live.
final appUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return Stream.value(null);
  return ref.watch(authServiceProvider).watchUser(auth.uid);
});

/// Whether onboarding has been completed on this device.
final onboardingSeenProvider =
    StateNotifierProvider<OnboardingSeenNotifier, bool>(
  (ref) => OnboardingSeenNotifier(),
);

class OnboardingSeenNotifier extends StateNotifier<bool> {
  OnboardingSeenNotifier() : super(false) {
    _load();
  }

  static const _key = 'onboarding_seen';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}

/// ---- Auth controller (login / register / reset state machine) -------------

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._ref) : super(const AsyncData(null));

  final Ref _ref;
  AuthService get _service => _ref.read(authServiceProvider);

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(AuthService.friendlyError(e), st);
      return false;
    }
  }

  Future<bool> login(String email, String password) =>
      _run(() => _service.signInWithEmail(email: email, password: password));

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? businessName,
  }) =>
      _run(
        () => _service.registerWithEmail(
          email: email,
          password: password,
          fullName: fullName,
          role: role,
          phone: phone,
          businessName: businessName,
        ),
      );

  Future<bool> googleSignIn(UserRole defaultRole) =>
      _run(() => _service.signInWithGoogle(defaultRole: defaultRole));

  Future<bool> resetPassword(String email) =>
      _run(() => _service.sendPasswordReset(email));

  Future<void> signOut() => _service.signOut();
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref),
);
