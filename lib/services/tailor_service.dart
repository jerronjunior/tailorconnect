import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/tailor_profile.dart';

/// Wraps the `tailors/{uid}` business profile document and its storage
/// assets (logo, cover, portfolio photos).
class TailorService {
  TailorService({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('tailors').doc(uid);

  /// Live stream of the signed-in tailor's business profile.
  Stream<TailorProfile?> watchProfile(String uid) => _doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? TailorProfile.fromDoc(doc) : null);

  Future<void> updateProfile(String uid, Map<String, dynamic> changes) =>
      _doc(uid).update(changes);

  Future<void> addPortfolioUrl(String uid, String url) => _doc(uid).update({
        'portfolioUrls': FieldValue.arrayUnion([url]),
      });

  Future<void> removePortfolioUrl(String uid, String url) =>
      _doc(uid).update({
        'portfolioUrls': FieldValue.arrayRemove([url]),
      });

  /// Uploads [file] to `tailors/{uid}/{name}` and returns its download URL.
  Future<String> uploadImage(String uid, File file, String name) async {
    final ref = _storage.ref('tailors/$uid/$name');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
