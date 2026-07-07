import 'package:cloud_firestore/cloud_firestore.dart';

/// The full order lifecycle, in timeline order.
enum OrderStatus {
  placed,
  accepted,
  measurementConfirmed,
  cutting,
  stitching,
  qualityCheck,
  ready,
  outForDelivery,
  delivered,
  cancelled,
  rejected,
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.placed => 'Order placed',
        OrderStatus.accepted => 'Accepted',
        OrderStatus.measurementConfirmed => 'Measurement confirmed',
        OrderStatus.cutting => 'Cutting',
        OrderStatus.stitching => 'Stitching',
        OrderStatus.qualityCheck => 'Quality check',
        OrderStatus.ready => 'Ready',
        OrderStatus.outForDelivery => 'Out for delivery',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
        OrderStatus.rejected => 'Rejected',
      };

  static OrderStatus fromString(String? raw) => OrderStatus.values.firstWhere(
        (s) => s.name == raw,
        orElse: () => OrderStatus.placed,
      );
}

/// Order document stored at `orders/{orderId}`.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerId,
    required this.tailorId,
    required this.category,
    required this.clothingType,
    required this.status,
    this.measurementSnapshot = const {},
    this.referenceImageUrls = const [],
    this.fabric,
    this.color,
    this.notes = '',
    this.price,
    this.deliveryAddressId,
    this.statusHistory = const [],
    this.createdAt,
  });

  final String id;
  final String customerId;
  final String tailorId;
  final String category;
  final String clothingType;
  final OrderStatus status;

  /// Measurements copied onto the order at creation time so later edits to
  /// the profile don't change an in-progress order.
  final Map<String, double> measurementSnapshot;
  final List<String> referenceImageUrls;
  final String? fabric;
  final String? color;
  final String notes;
  final double? price;
  final String? deliveryAddressId;

  /// Each entry: {status, timestamp, note?, photoUrl?}
  final List<Map<String, dynamic>> statusHistory;
  final DateTime? createdAt;

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return OrderModel(
      id: doc.id,
      customerId: d['customerId'] as String? ?? '',
      tailorId: d['tailorId'] as String? ?? '',
      category: d['category'] as String? ?? '',
      clothingType: d['clothingType'] as String? ?? '',
      status: OrderStatusX.fromString(d['status'] as String?),
      measurementSnapshot:
          (d['measurementSnapshot'] as Map<String, dynamic>? ?? const {})
              .map((k, v) => MapEntry(k, (v as num).toDouble())),
      referenceImageUrls:
          List<String>.from(d['referenceImageUrls'] as List? ?? const []),
      fabric: d['fabric'] as String?,
      color: d['color'] as String?,
      notes: d['notes'] as String? ?? '',
      price: (d['price'] as num?)?.toDouble(),
      deliveryAddressId: d['deliveryAddressId'] as String?,
      statusHistory: List<Map<String, dynamic>>.from(
        d['statusHistory'] as List? ?? const [],
      ),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'tailorId': tailorId,
        'category': category,
        'clothingType': clothingType,
        'status': status.name,
        'measurementSnapshot': measurementSnapshot,
        'referenceImageUrls': referenceImageUrls,
        'fabric': fabric,
        'color': color,
        'notes': notes,
        'price': price,
        'deliveryAddressId': deliveryAddressId,
        'statusHistory': statusHistory,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
