import 'package:flutter/material.dart';

class Messenger {
  static showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red));
  }

  static showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.green));
  }

  static showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(seconds: 10),
        content: Text(message),
        backgroundColor: Colors.yellow));
  }
}