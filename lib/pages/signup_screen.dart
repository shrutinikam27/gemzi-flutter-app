// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController repassCtrl = TextEditingController();

  bool _isLoading = false;

  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color gold = const Color(0xFFD4AF37);

  // 🔐 Password validation
  bool _isStrongPassword(String password) {
    final regex = RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*])(?=.*[a-zA-Z]).{6,}$');
    return regex.hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Top Image
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/auth/log.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Bottom Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.70,
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 25),

                    _inputField("Full Name", Icons.person, nameCtrl),
                    const SizedBox(height: 15),

                    _inputField("Email", Icons.email, emailCtrl),
                    const SizedBox(height: 15),

                    _inputField("Password", Icons.lock, passCtrl,
                        obscure: true),
                    const SizedBox(height: 15),

                    _inputField("Confirm Password", Icons.lock, repassCtrl,
                        obscure: true),

                    const SizedBox(height: 25),

                    // SIGNUP BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _signupUser,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Sign Up",
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // LOGIN LINK
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          "Already have an account? Login",
                          style: TextStyle(color: gold),
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

  // 🔥 SIGNUP FUNCTION
  Future<void> _signupUser() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();
    final confirmPassword = repassCtrl.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match");
      return;
    }

    if (!_isStrongPassword(password)) {
      _showError("Password must be strong");
      return;
    }

    try {
      setState(() => _isLoading = true);

      // 🔐 Firebase Auth
      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCred.user;

      // 📦 Firestore
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "name": name,
        "email": email,
        "createdAt": DateTime.now(),
      });

      if (!mounted) return;

      // ✅ Navigate to success screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SignupSuccessScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Signup failed");
    } catch (e) {
      _showError("Something went wrong");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: gold),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
