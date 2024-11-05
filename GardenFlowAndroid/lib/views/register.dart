import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';

import 'package:garden_flow/utility/app_colors.dart';
import 'package:garden_flow/utility/toast.dart';
import 'package:garden_flow/utility/alert.dart';
import 'package:garden_flow/utility/firestore_database.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool agreeToTerms = false;

  void toggleTermsCheckbox(bool value) {
    setState(() {
      agreeToTerms = value;
    });
  }

  bool validateEmail(String email) {
    return EmailValidator.validate(email);
  }

  bool _isNumeric(String value) {
    return double.tryParse(value) != null;
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
                    const SizedBox(height: 40.0),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
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
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
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
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: _mobileNumberController,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
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
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your mobile number";
                        } else if (!_isNumeric(value)) {
                          return "Mobile number should contain only digits";
                        } else if (value.length != 11) {
                          return "Mobile number should be exactly 11 digits long";
                        }
                        return null; // Return null if the input is valid
                      },
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
                        } else if (!value.endsWith("@plpasig.edu.ph")) {
                          return "Please enter valid email extension";
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                      obscureText: true,
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        Checkbox(
                            value: agreeToTerms,
                            onChanged: (value) {
                              toggleTermsCheckbox(value!);
                            }),
                        const Flexible(
                          child: Text(
                            'I agree to the Terms of Services and Privacy Policy.',
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final firestoreService = FirestoreService();

                            final signUpSuccess = await firestoreService.signUp(_emailController.text.trim(), _passwordController.text.trim(),
                                _mobileNumberController.text.trim(), _firstNameController.text.trim(), _lastNameController.text.trim());

                            if (signUpSuccess) {
                              await Alert.show(context, "Congratulations", "Welcome to Watering System");
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            Toast.show(context, e.toString());
                          }
                        }
                      },
                      style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all<Size>(const Size(200, 50)),
                          backgroundColor: WidgetStateProperty.all<Color>(AppColors.primaryColor),
                          foregroundColor: WidgetStateProperty.all<Color>(Colors.white)),
                      child: const Text('Sign-up'),
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
        ],
      ),
    );
  }
}
