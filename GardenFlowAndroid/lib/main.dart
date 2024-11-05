import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:garden_flow/splash_screen.dart';

import 'package:garden_flow/utility/local_notification.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalNotification.init();
  tz.initializeTimeZones();
  var detroit = tz.getLocation('Asia/Manila');
  tz.setLocalLocation(detroit);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(primaryColor: Colors.orange), home: const SplashScreen());
  }
}
