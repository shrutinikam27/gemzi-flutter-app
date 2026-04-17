import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';

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

  // --- Theme Colors ---
  final Color richGold = const Color(0xFFD4AF37);
  final Color deepTeal = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepTeal,
      body: Stack(
        children: [
          // Background Image with Dark Overlay
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/auth/1.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    deepTeal.withValues(alpha: 0.8),
                    deepTeal,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                   const SizedBox(height: 40),
                  
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            height: 220,
                            width: 220,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                              border: Border.all(color: richGold.withValues(alpha: 0.3), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: richGold.withValues(alpha: 0.1),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                "assets/auth/gemzi_logo.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                       ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Glassmorphic Card
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 580,
                      borderRadius: 30,
                      blur: 15,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          richGold.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Create Account",
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "Start your gold investment journey today",
                              style: TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                            const SizedBox(height: 30),

                            _inputField("Full Name", Icons.person_outline_rounded, nameCtrl),
                            const SizedBox(height: 18),
                            _inputField("Email Address", Icons.alternate_email_rounded, emailCtrl),
                            const SizedBox(height: 18),
                            _inputField("Create Password", Icons.lock_outline_rounded, passCtrl, obscure: true),
                            const SizedBox(height: 18),
                            _inputField("Confirm Password", Icons.lock_reset_rounded, repassCtrl, obscure: true),

                            const Spacer(),

                            // SIGN UP BUTTON
                            GestureDetector(
                              onTap: _isLoading ? null : _signupUser,
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(colors: [richGold, const Color(0xFFB8860B)]),
                                  boxShadow: [
                                    BoxShadow(color: richGold.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text("CREATE ACCOUNT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  FadeIn(
                    delay: const Duration(milliseconds: 1200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ", style: TextStyle(color: Colors.white60)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text("Login Here", style: TextStyle(color: richGold, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signupUser() async {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();
    final confirmPassword = repassCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError("Please fill all fields");
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match");
      return;
    }

    try {
      setState(() => _isLoading = true);
      final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance.collection("users").doc(userCred.user!.uid).set({
        "name": name,
        "email": email,
        "createdAt": DateTime.now(),
      });
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupSuccessScreen()));
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Signup failed");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  Widget _inputField(String hint, IconData icon, TextEditingController controller, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: richGold, size: 20),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
