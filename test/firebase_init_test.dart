import 'package:flutter_test/flutter_test.dart';
import 'package:tailorconnect/core/utils/firebase_init.dart';

void main() {
  test('initializing Firebase without configuration does not throw', () async {
    await expectLater(initializeFirebaseIfConfigured(), completes);
  });
}
