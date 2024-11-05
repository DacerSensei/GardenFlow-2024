import 'package:flutter/material.dart';

class Toast {
  static void show(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
