import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserRole { customer, tailor }

extension UserRoleX on UserRole {
  String get value => name;
  static UserRole fromString(String? raw) =>
      raw == 'tailor' ? UserRole.tailor : UserRole.customer;
}

/// Core account document stored at `users/{uid}`.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.photoUrl,
    this.emailVerified = false,
    this.fcmToken,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phone;
  final String? photoUrl;
  final bool emailVerified;
  final String? fcmToken;
  final DateTime? createdAt;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      role: UserRoleX.fromString(data['role'] as String?),
      phone: data['phone'] as String?,
      photoUrl: data['photoUrl'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
      fcmToken: data['fcmToken'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'fullName': fullName,
        'role': role.value,
        'phone': phone,
        'photoUrl': photoUrl,
        'emailVerified': emailVerified,
        'fcmToken': fcmToken,
        'createdAt': createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(createdAt!),
      };

  AppUser copyWith({
    String? fullName,
    String? phone,
    String? photoUrl,
    bool? emailVerified,
    String? fcmToken,
  }) =>
      AppUser(
        uid: uid,
        email: email,
        fullName: fullName ?? this.fullName,
        role: role,
        phone: phone ?? this.phone,
        photoUrl: photoUrl ?? this.photoUrl,
        emailVerified: emailVerified ?? this.emailVerified,
        fcmToken: fcmToken ?? this.fcmToken,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props =>
      [uid, email, fullName, role, phone, photoUrl, emailVerified, fcmToken];
}
