import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';

/// Wraps the `orders/{orderId}` collection for tailor-side order management.
class OrderService {
  OrderService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  /// Live stream of every order assigned to [tailorUid], newest first.
  ///
  /// Sorted client-side rather than via `.orderBy()` so this doesn't need a
  /// composite Firestore index on (tailorId, createdAt).
  Stream<List<OrderModel>> watchTailorOrders(String tailorUid) {
    return _orders.where('tailorId', isEqualTo: tailorUid).snapshots().map((snap) {
      final orders = snap.docs.map(OrderModel.fromDoc).toList();
      orders.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return orders;
    });
  }

  /// Updates [orderId]'s status and appends an entry to its status history.
  Future<void> updateStatus(String orderId, OrderStatus status, {String? note}) {
    return _orders.doc(orderId).update({
      'status': status.name,
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': status.name,
          'timestamp': Timestamp.now(),
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      ]),
    });
  }
}
