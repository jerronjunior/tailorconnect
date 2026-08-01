import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tailor_profile.dart';
import '../services/tailor_service.dart';
import 'auth_providers.dart';

final tailorServiceProvider = Provider<TailorService>((ref) => TailorService());

/// The signed-in tailor's `tailors/{uid}` business profile, kept live.
final tailorProfileProvider = StreamProvider<TailorProfile?>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(tailorServiceProvider).watchProfile(uid);
});
