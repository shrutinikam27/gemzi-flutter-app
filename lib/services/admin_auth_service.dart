import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Hardcoded admin credentials — change these to your real admin email
  static const String _adminEmail = "admin@gemzi.com"; // ← change this

  // Password is verified via Firebase Auth — just ensure this email is 
  // registered in Firebase Auth console with your chosen password.

  /// Signs in and verifies the email matches the admin whitelist.
  static Future<UserCredential> signInAsAdmin(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // Check if the signed-in email is on the admin whitelist
    if (credential.user?.email?.toLowerCase() != _adminEmail.toLowerCase()) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'permission-denied',
        message: 'This account does not have admin privileges.',
      );
    }

    return credential;
  }

  static Future<void> signOut() => _auth.signOut();

  static User? get currentUser => _auth.currentUser;
}
