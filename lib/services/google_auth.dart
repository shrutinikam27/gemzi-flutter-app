import 'dart:developer'; // ✅ REQUIRED for using log()

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  static Future<User?> signInWithGoogle() async {
    try {
      // Google popup sign-in
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in in Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user == null) return null;

      // Save user to Firestore
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "name": user.displayName,
        "email": user.email,
        "photo": user.photoURL,
        "provider": "google",
        "createdAt": DateTime.now(),
      }, SetOptions(merge: true));

      return user;
    } catch (e) {
      log("Google Sign-In Error: $e"); // ✅ Now works
      return null;
    }
  }
}
