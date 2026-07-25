import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_courier/core/logging/app_logger.dart';

Future<void> configureFirestore(FirebaseFirestore firestore) async {
  firestore.settings = const Settings(persistenceEnabled: true);

  try {
    await firestore.enableNetwork();
    AppLogger.debug('Firestore network enabled', tag: 'Firestore');
  } catch (error, stackTrace) {
    AppLogger.error(
      'Could not enable Firestore network: $error',
      tag: 'Firestore',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
