import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFFE74C3C),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ),
  );
}

void showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF17453F),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Text(message, style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK", style: TextStyle(color: Color(0xFFD4AF37))),
        ),
      ],
    ),
  );
}

String getErrorMessage(dynamic error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'network-request-failed' => 'No internet connection',
      'user-not-found' => 'No account with this email',
      'wrong-password' => 'Wrong password',
      'email-already-in-use' => 'Email already registered',
      'invalid-email' => 'Invalid email address',
      _ => error.message ?? 'Authentication failed',
    };
  }
  if (error.toString().contains('SocketException') ||
      error.toString().contains('TimeoutException')) {
    return 'No internet connection. Please check your network.';
  }
  return error.toString().contains('API Error')
      ? 'Unable to fetch gold rates. Please try again.'
      : 'Something went wrong. Please try again.';
}

void logError(String tag, dynamic error, [StackTrace? stackTrace]) {
  developer.log(error.toString(), name: tag, stackTrace: stackTrace);
}
