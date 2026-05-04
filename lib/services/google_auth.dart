import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  // 🟢 Configuration
  // Split initialization to avoid passing incompatible parameters to different platforms
  static final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          clientId: '945540945656-b7nqk1pn5od32vshfn73kb00jt0dct99.apps.googleusercontent.com',
          scopes: ['email', 'profile'],
        )
      : GoogleSignIn(
          // For Mobile (Android/iOS), Firebase handles clientId automatically via google-services.json.
          // Explicitly declaring it can cause DEVELOPER_ERROR mismatches.
          scopes: ['email', 'profile'],
        );

  // 🔵 GOOGLE SIGN-IN
  static Future<User?> signInWithGoogle() async {
    try {
      log("🔥 Google Sign-In Started (Stable Mode)");

      // 🌐 WEB-OPTIMIZED FLOW
      if (kIsWeb) {
        log("🌐 Using Firebase Auth Web Popup...");
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        final user = userCredential.user;
        
        if (user != null) {
          log("✅ Web Login Success: ${user.uid}");
          await _syncUserToFirestore(user);
        }
        return user;
      }

      // 📱 MOBILE FLOW (Android/iOS)
      // STEP 0: Clean cache
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      await Future.delayed(const Duration(milliseconds: 500));
      log("🧹 Cache cleared");

      // STEP 1: Pick account
      log("📱 Triggering account picker...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        log("⚠️ User cancelled Google Sign-In");
        return null;
      }

      // STEP 2: Get tokens and login to Firebase
      log("🔑 Retrieving auth tokens...");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        log("✅ Mobile Login Success: ${user.uid}");
        await _syncUserToFirestore(user);
      }

      return user;
    } catch (e) {
      log("❌ Google Sign-In Error: $e");
      rethrow;
    }
  }

  // Helper to keep logic clean
  static Future<void> _syncUserToFirestore(User user) async {
    try {
      log("💾 Syncing user data to Firestore...");
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "name": user.displayName ?? "Gemzi User",
        "email": user.email,
        "photo": user.photoURL,
        "provider": "google",
        "lastLogin": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      log("✅ Firestore sync successful");
    } catch (e) {
      log("⚠️ Firestore sync failed: $e");
    }
  }

  // 🚪 FULL SIGN-OUT
  static Future<void> signOut() async {
    try {
      log("🔥 Google Sign-Out Started");

      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();

      log("✅ Google Sign-Out Success");
    } catch (e) {
      log("❌ Google Sign-Out Error: $e");
      rethrow;
    }
  }
}
