import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

import 'package:garden_flow/utility/app_colors.dart';
import 'package:garden_flow/utility/alert.dart';
import 'package:garden_flow/utility/toast.dart';

import 'package:garden_flow/utility/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPage();
}

class _ChangePasswordPage extends State<ChangePasswordPage> {
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: AppColors.accentColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                  controller: oldPassword,
                  decoration: InputDecoration(
                    labelText: 'Enter your old password',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your old password";
                    } else if (value.length < 6) {
                      return "Your password is too short 6 character is minimum";
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: newPassword,
                  decoration: InputDecoration(
                    labelText: 'Enter your new password',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your new password";
                    } else if (value.length < 6) {
                      return "Your password is too short 6 character is minimum";
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: confirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Retype your new password',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please repeat your new password";
                    } else if (value != newPassword.text) {
                      return "Your password didn't match";
                    }
                    return null;
                  },
                  obscureText: true,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // Get the current user
                        User? user = Auth().currentUser;
                        if (user != null) {
                          AuthCredential credential = EmailAuthProvider.credential(email: user.email ?? "", password: oldPassword.text.trim());
                          bool reauthenticated = await Auth().reauthenticateWithCredential(context, user, credential);
                          if (reauthenticated) {
                            await user.updatePassword(newPassword.text.trim());
                            if (context.mounted) {
                              await Alert.show(context, "Notice", "You've just changed your password");
                            }
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Toast.show(context, e.toString());
                        }
                      }
                    }
                  },
                  style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all<Size>(const Size(200, 60)),
                    backgroundColor: WidgetStateProperty.all<Color>(AppColors.primaryColor),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CircularPercentageBar extends StatelessWidget {
  final double percentage;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final TextStyle valueTextStyle;

  const CircularPercentageBar({
    Key? key,
    required this.percentage,
    this.strokeWidth = 10.0,
    this.backgroundColor = Colors.grey,
    this.progressColor = AppColors.primaryColor,
    this.valueTextStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.accentColor,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircularPercentageBarPainter(
        percentage: percentage,
        strokeWidth: strokeWidth,
        backgroundColor: backgroundColor,
        progressColor: progressColor,
      ),
      child: Center(
        child: Text(
          '${percentage.toStringAsFixed(0)}%',
          style: valueTextStyle,
        ),
      ),
    );
  }
}

class _CircularPercentageBarPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  _CircularPercentageBarPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 70.0;
    const double startAngle = -math.pi / 2;
    final double sweepAngle = 2 * math.pi * (percentage / 100);

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Percentage bar
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
