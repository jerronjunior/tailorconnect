import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Business profile stored at `tailors/{uid}` (public read).
class TailorProfile extends Equatable {
  const TailorProfile({
    required this.uid,
    required this.businessName,
    this.description = '',
    this.logoUrl,
    this.coverUrl,
    this.portfolioUrls = const [],
    this.services = const [],
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.experienceYears = 0,
    this.isVerified = false,
    this.isAvailable = true,
    this.city,
    this.geo,
  });

  final String uid;
  final String businessName;
  final String description;
  final String? logoUrl;
  final String? coverUrl;
  final List<String> portfolioUrls;
  final List<String> services;
  final double ratingAvg;
  final int ratingCount;
  final int experienceYears;
  final bool isVerified;
  final bool isAvailable;
  final String? city;
  final GeoPoint? geo;

  factory TailorProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return TailorProfile(
      uid: doc.id,
      businessName: d['businessName'] as String? ?? '',
      description: d['description'] as String? ?? '',
      logoUrl: d['logoUrl'] as String?,
      coverUrl: d['coverUrl'] as String?,
      portfolioUrls: List<String>.from(d['portfolioUrls'] as List? ?? const []),
      services: List<String>.from(d['services'] as List? ?? const []),
      ratingAvg: (d['ratingAvg'] as num?)?.toDouble() ?? 0,
      ratingCount: d['ratingCount'] as int? ?? 0,
      experienceYears: d['experienceYears'] as int? ?? 0,
      isVerified: d['isVerified'] as bool? ?? false,
      isAvailable: d['isAvailable'] as bool? ?? true,
      city: d['city'] as String?,
      geo: d['geo'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() => {
        'businessName': businessName,
        'description': description,
        'logoUrl': logoUrl,
        'coverUrl': coverUrl,
        'portfolioUrls': portfolioUrls,
        'services': services,
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
        'experienceYears': experienceYears,
        'isVerified': isVerified,
        'isAvailable': isAvailable,
        'city': city,
        'geo': geo,
      };

  @override
  List<Object?> get props => [uid, businessName, ratingAvg, ratingCount];
}
