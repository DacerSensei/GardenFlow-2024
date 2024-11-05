import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widget_tree.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const WidgetTree()));
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            decoration:
                const BoxDecoration(gradient: LinearGradient(colors: [Colors.blue, Colors.purple], begin: Alignment.topRight, end: Alignment.bottomLeft)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Icon(Icons.edit, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Garden Monitoring",
                style: TextStyle(color: Colors.white, fontSize: 32),
              )
            ])));
  }
}
