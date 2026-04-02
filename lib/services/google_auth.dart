import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // 🔵 GOOGLE SIGN-IN
  static Future<User?> signInWithGoogle() async {
    try {
      log("🔥 Google Sign-In Started");

      // STEP 1: Pick account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        log("⚠️ User cancelled Google Sign-In");
        return null;
      }

      log("✅ Selected account: ${googleUser.email}");

      // STEP 2: Get auth tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // STEP 3: Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // STEP 4: Firebase login
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user == null) {
        throw Exception("User is null after Google sign-in");
      }

      log("✅ Firebase Login Success: ${user.uid}");

      // STEP 5: Save to Firestore
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "name": user.displayName,
        "email": user.email,
        "photo": user.photoURL,
        "provider": "google",
        "createdAt": DateTime.now(),
      }, SetOptions(merge: true));

      log("✅ Firestore user saved");

      return user;
    } catch (e) {
      log("❌ Google Sign-In Error: $e");
      rethrow; // 🔥 IMPORTANT (don’t hide error)
    }
  }

  // 🚪 FULL SIGN-OUT (VERY IMPORTANT)
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
