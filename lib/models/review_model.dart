import 'package:cloud_firestore/cloud_firestore.dart';

/// Review document stored at `reviews/{reviewId}` (public read).
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.tailorId,
    required this.customerId,
    this.orderId,
    required this.rating,
    this.comment = '',
    this.createdAt,
  });

  final String id;
  final String tailorId;
  final String customerId;
  final String? orderId;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  factory ReviewModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return ReviewModel(
      id: doc.id,
      tailorId: d['tailorId'] as String? ?? '',
      customerId: d['customerId'] as String? ?? '',
      orderId: d['orderId'] as String?,
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      comment: d['comment'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
