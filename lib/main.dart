import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_courier/app.dart';
import 'package:smart_courier/core/di/injection.dart';
import 'package:smart_courier/core/firebase/firestore_bootstrap.dart';
import 'package:smart_courier/core/map/dgis_map_service.dart';
import 'package:smart_courier/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureFirestore(FirebaseFirestore.instance);
  await initDependencies();
  await sl<DgisMapService>().initialize();
  runApp(const SmartCourierApp());
}
