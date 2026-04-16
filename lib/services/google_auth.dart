import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId: '945540945656-r8qoib7hvbilc9n8nar13u2tf04hivav.apps.googleusercontent.com', // Android Client ID specifically mapped
    serverClientId: '945540945656-b7nqk1pn5od32vshfn73kb00jt0dct99.apps.googleusercontent.com',
  );

  // 🔵 GOOGLE SIGN-IN
  static Future<User?> signInWithGoogle() async {
    try {
      log("🔥 Google Sign-In Started");

      // STEP 0: Force Sign-Out to reset account picker (VERY IMPORTANT)
      try {
        await _googleSignIn.signOut();
      } catch(e) {
        log("⚠️ Google signOut before signIn failed: $e");
      }

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
      final userDoc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "name": user.displayName ?? "Gemzi User",
          "email": user.email,
          "photo": user.photoURL,
          "provider": "google",
          "createdAt": FieldValue.serverTimestamp(),
          "weight": "0", // Default for weight-based engine
        }, SetOptions(merge: true));
        log("✅ New Firestore user created");
      } else {
        log("✅ Existing user logged in");
      }

      return user;
    } catch (e) {
      log("❌ Google Sign-In Error: $e");
      rethrow;
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
