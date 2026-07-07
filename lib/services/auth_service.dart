import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';

/// Wraps Firebase Auth + the `users/{uid}` account document.
///
/// All auth flows funnel through here so screens never touch Firebase
/// directly (Repository pattern).
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance,
        _google = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final GoogleSignIn _google;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  /// Email/password registration. Creates the auth user, the account
  /// document, and (for tailors) a starter business profile, then sends a
  /// verification email.
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
    String? businessName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(fullName);
    await user.sendEmailVerification();

    final appUser = AppUser(
      uid: user.uid,
      email: email.trim(),
      fullName: fullName.trim(),
      role: role,
      phone: phone?.trim(),
    );

    final batch = _db.batch();
    batch.set(_users.doc(user.uid), appUser.toMap());
    if (role == UserRole.tailor) {
      batch.set(_db.collection('tailors').doc(user.uid), {
        'businessName': businessName?.trim() ?? fullName.trim(),
        'description': '',
        'portfolioUrls': <String>[],
        'services': <String>[],
        'ratingAvg': 0,
        'ratingCount': 0,
        'experienceYears': 0,
        'isVerified': false,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return appUser;
  }

  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _fetchAppUser(cred.user!.uid);
  }

  /// Google sign-in. First-time Google users get a `users` document with
  /// the [defaultRole]; the role-selection screen should run before this
  /// for new accounts.
  Future<AppUser?> signInWithGoogle({
    UserRole defaultRole = UserRole.customer,
  }) async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final cred = await _auth.signInWithCredential(
      GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      ),
    );
    final user = cred.user!;

    final existing = await _users.doc(user.uid).get();
    if (!existing.exists) {
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? '',
        fullName: user.displayName ?? '',
        role: defaultRole,
        photoUrl: user.photoURL,
        emailVerified: true,
      );
      await _users.doc(user.uid).set(appUser.toMap());
      return appUser;
    }
    return AppUser.fromDoc(existing);
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  Future<AppUser?> _fetchAppUser(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc.exists ? AppUser.fromDoc(doc) : null;
  }

  /// Live stream of the signed-in user's account document.
  Stream<AppUser?> watchUser(String uid) => _users
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromDoc(doc) : null);

  /// Converts FirebaseAuthException codes into user-friendly messages.
  static String friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' =>
          'Email or password is incorrect.',
        'email-already-in-use' =>
          'An account already exists with this email. Try logging in.',
        'weak-password' => 'That password is too weak. Use 8+ characters.',
        'invalid-email' => 'That email address looks invalid.',
        'too-many-requests' =>
          'Too many attempts. Wait a moment and try again.',
        'network-request-failed' =>
          'No connection. Check your internet and try again.',
        _ => 'Something went wrong. Please try again.',
      };
    }
    return 'Something went wrong. Please try again.';
  }
}
