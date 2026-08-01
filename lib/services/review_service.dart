import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review_model.dart';

/// Read access to the `reviews` collection for a tailor's own profile.
class ReviewService {
  ReviewService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _reviews => _db.collection('reviews');

  /// Live stream of every review left for [tailorUid], newest first.
  ///
  /// Sorted client-side rather than via `.orderBy()` so this doesn't need a
  /// composite Firestore index on (tailorId, createdAt).
  Stream<List<ReviewModel>> watchTailorReviews(String tailorUid) {
    return _reviews.where('tailorId', isEqualTo: tailorUid).snapshots().map((snap) {
      final reviews = snap.docs.map(ReviewModel.fromDoc).toList();
      reviews.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return reviews;
    });
  }
}
