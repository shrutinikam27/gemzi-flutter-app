// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'signup_screen.dart';
import 'homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool _isLoading = false;

  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);
  final Color textLight = const Color(0xFFFFFFFF);
  final Color textSubdued = const Color(0xFFB8D1CD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [darkBg, surfaceDark, darkBg],
              ),
            ),
          ),

          // IMAGE
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.40,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/auth/log.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // OVERLAY
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, surfaceDark],
                ),
              ),
            ),
          ),

          // LOGIN CARD
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 5,
                        width: 60,
                        decoration: BoxDecoration(
                          color: richGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: textLight,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Login to continue your jewellery journey",
                      style: TextStyle(color: textSubdued),
                    ),

                    const SizedBox(height: 30),

                    _inputField(
                        "Email Address", Icons.email_outlined, emailCtrl),

                    const SizedBox(height: 16),

                    _inputField("Password", Icons.lock_outline, passCtrl,
                        obscure: true),

                    const SizedBox(height: 25),

                    // EMAIL LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: richGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _isLoading ? null : _loginUser,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Sign In",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // GOOGLE LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: richGold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _loginWithGoogle,
                        child: Text(
                          "Continue with Google",
                          style: TextStyle(color: textLight),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          "Don't have an account? Register Now",
                          style: TextStyle(
                            color: richGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ EMAIL LOGIN WITH FIRESTORE FIX
  Future<void> _loginUser() async {
    log("LOGIN BUTTON TAPPED - email: \${emailCtrl.text.trim()}");
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showPopup("Error", "Please enter both email & password.");
      return;
    }

    try {
      setState(() => _isLoading = true);

      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCred.user;

      // 🔥 CREATE USER DATA IF NOT EXISTS
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      if (!doc.exists) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "name": user.displayName ?? "User",
          "email": user.email,
        });
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GemziHome()),
      );
    } on FirebaseAuthException catch (e) {
      _showPopup("Login Failed", e.message ?? "Login failed.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ✅ GOOGLE LOGIN WITH FIRESTORE SAVE
  Future<void> _loginWithGoogle() async {
    log("GOOGLE LOGIN BUTTON TAPPED");
    try {
      setState(() => _isLoading = true);

      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCred.user;

      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "name": user.displayName ?? "User",
        "email": user.email,
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GemziHome()),
      );
    } catch (e) {
      _showPopup("Google Login Error", e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
      String hint, IconData icon, TextEditingController controller,
      {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: darkBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: richGold.withOpacity(0.4)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: textLight),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: richGold),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: textSubdued),
        ),
      ),
    );
  }
}
