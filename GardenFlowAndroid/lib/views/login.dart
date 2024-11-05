import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:garden_flow/utility/app_colors.dart';
import 'package:garden_flow/utility/local_connectivity.dart';
import 'package:garden_flow/utility/toast.dart';
import 'package:garden_flow/utility/device_info.dart';
import 'package:garden_flow/utility/alert.dart';
import 'package:garden_flow/utility/firestore_database.dart';
import 'package:garden_flow/utility/firebase_auth.dart';

import 'package:garden_flow/views/forgot_password.dart';
import 'package:garden_flow/views/register.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  bool isLogin = true;
  late Future<void> initialization;
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> signIn() async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      await Auth().signInWithEmailPassword(email: email, password: password);
    } catch (e) {
      Toast.show(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      String imei = await DeviceInformation.getIMEI();
      if (imei.isNotEmpty) {
        await Alert.show(context, "Unique Identifier", imei);
        final firestoreService = FirestoreService();
        if (!await LocalConnectivity.checkConnectivity()) {
          print("no connect");
          exit(0);
        }
        List<Map<String, dynamic>>? imeiList;
        try {
          imeiList = await firestoreService.getIMEIList();
        } catch (e) {
          print("hello");
          exit(0);
        }
        if (imeiList == null) {
          print("hi");
          exit(0);
        }
        for (var element in imeiList) {
          if (element["imeiNumber"] == imei) {
            return;
          }
        }
        exit(0);
      } else {
        exit(0);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 60.0),
              Image.asset(
                'resources/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 40.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  signIn();
                },
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all<Size>(const Size(200, 60)),
                  backgroundColor: WidgetStateProperty.all<Color>(AppColors.primaryColor),
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(color: AppColors.accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
