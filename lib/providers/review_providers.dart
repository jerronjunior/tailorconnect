import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';
import 'auth_providers.dart';

final reviewServiceProvider = Provider<ReviewService>((ref) => ReviewService());

/// Every review left for the signed-in tailor, newest first.
final tailorReviewsProvider = StreamProvider<List<ReviewModel>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(reviewServiceProvider).watchTailorReviews(uid);
});
