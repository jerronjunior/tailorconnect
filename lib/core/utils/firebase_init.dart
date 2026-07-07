import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase when configuration is available.
///
/// This app does not ship with generated Firebase options, so startup should
/// remain resilient in development and local preview builds.
Future<void> initializeFirebaseIfConfigured() async {
  try {
    await Firebase.initializeApp();
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization skipped: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
