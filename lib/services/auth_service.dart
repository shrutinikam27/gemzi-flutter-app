// ignore_for_file: avoid_print

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'google_auth.dart';

class AuthService {
  // 🔒 Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔄 Auth State Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 👤 Current User
  User? get currentUser => _auth.currentUser;

  // 🔐 LOGIN
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print("🔥 LOGIN STARTED: $email");

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("✅ LOGIN SUCCESS: ${result.user?.uid}");
      return result;
    } on FirebaseAuthException catch (e) {
      print("❌ LOGIN ERROR: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("❌ UNKNOWN LOGIN ERROR: $e");
      rethrow;
    }
  }

  // 📝 SIGNUP
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print("🔥 SIGNUP STARTED: $email");

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("✅ SIGNUP SUCCESS: ${result.user?.uid}");
      return result;
    } on FirebaseAuthException catch (e) {
      print("❌ SIGNUP ERROR: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("❌ UNKNOWN SIGNUP ERROR: $e");
      rethrow;
    }
  }

  // 🔵 GOOGLE SIGN-IN
  Future<User?> signInWithGoogle() async {
    try {
      print("🔥 GOOGLE SIGN-IN STARTED");

      final user = await GoogleAuthService.signInWithGoogle();

      print("✅ GOOGLE SIGN-IN SUCCESS: ${user?.uid}");
      return user;
    } catch (e) {
      print("❌ GOOGLE SIGN-IN ERROR: $e");
      rethrow;
    }
  }

  // 🚪 LOGOUT
  Future<void> signOut() async {
    try {
      print("🔥 LOGOUT STARTED");

      await _auth.signOut();

      print("✅ LOGOUT SUCCESS");
    } catch (e) {
      print("❌ LOGOUT ERROR: $e");
      rethrow;
    }
  }
}
