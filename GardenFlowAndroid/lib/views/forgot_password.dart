import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import 'package:garden_flow/utility/app_colors.dart';
import 'package:garden_flow/utility/alert.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPage();
}

class _ForgotPasswordPage extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool validateEmail(String email) {
    return EmailValidator.validate(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: <Widget>[
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 60.0),
                      Image.asset(
                        'resources/logo.png',
                        width: 75,
                        height: 75,
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Ex. yourname@plpasig.edu.ph',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 10.0,
                          ),
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
                            return "Please enter your email";
                          } else if (!validateEmail(value)) {
                            return "Please enter your valid email";
                          }
                          //else if (!value.endsWith("@plpasig.edu.ph")) {
                          //   return "Please enter valid email extension";
                          // }
                          return null; // Return null if the input is valid
                        },
                      ),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var result = await sendEmail(_emailController.text);
                            if (result) {
                              if (context.mounted) {
                                await Alert.show(context, "Notice", "Please check your email we've send the link to change your password");
                              }
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            } else {
                              if (context.mounted) {
                                await Alert.show(context, "Oops!", "Invalid Email");
                              }
                            }
                          }
                        },
                        style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all<Size>(const Size(200, 50)),
                            backgroundColor: WidgetStateProperty.all<Color>(AppColors.primaryColor),
                            foregroundColor: WidgetStateProperty.all<Color>(Colors.white)),
                        child: const Text('Submit'),
                      ),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all<Size>(const Size(200, 50)),
                            backgroundColor: WidgetStateProperty.all<Color>(AppColors.accentColor),
                            foregroundColor: WidgetStateProperty.all<Color>(Colors.white)),
                        child: const Text('Back'),
                      ),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> sendEmail(String email) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }
}
