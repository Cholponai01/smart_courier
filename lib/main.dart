import 'package:flutter/material.dart';
import 'package:smart_courier/app.dart';
import 'package:smart_courier/core/di/injection.dart';
import 'package:smart_courier/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();
  runApp(const SmartCourierApp());
}
