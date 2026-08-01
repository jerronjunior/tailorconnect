import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_model.dart';
import '../services/order_service.dart';
import 'auth_providers.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

/// Every order assigned to the signed-in tailor, newest first.
final tailorOrdersProvider = StreamProvider<List<OrderModel>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(orderServiceProvider).watchTailorOrders(uid);
});

/// One-off lookup of a customer's display name for an order card.
final customerNameProvider = FutureProvider.family<String, String>((ref, uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final name = doc.data()?['fullName'] as String?;
  return (name == null || name.trim().isEmpty) ? 'Customer' : name;
});
