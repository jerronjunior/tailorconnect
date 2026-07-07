import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/utils/firebase_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeFirebaseIfConfigured();
  await Hive.initFlutter();

  runApp(const ProviderScope(child: TailorConnectApp()));
}
