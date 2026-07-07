import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Initializes Firebase when configuration is available.
Future<void> initializeFirebaseIfConfigured() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization skipped: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
