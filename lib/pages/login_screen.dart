import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/auth_service.dart';
import '../services/google_auth.dart';
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

  // --- Theme Colors ---
  final Color richGold = const Color(0xFFD4AF37);
  final Color deepTeal = const Color(0xFF0F2F2B);
  final Color emerald = const Color(0xFF2E7D32);
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
                image: AssetImage("assets/auth/2.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    deepTeal.withOpacity(0.8),
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
                  const SizedBox(height: 50),
                  
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: richGold.withOpacity(0.5), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: richGold.withOpacity(0.15),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "assets/auth/log.png",
                              color: Colors.white,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "GEMZI",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "PURE GOLD INVESTMENTS",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 4,
                              color: richGold.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Glassmorphic Card
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 480,
                      borderRadius: 30,
                      blur: 15,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.02),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          richGold.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Welcome Back",
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              "Sign in to continue your investments",
                              style: TextStyle(color: Colors.white60, fontSize: 13),
                            ),
                            const SizedBox(height: 35),

                            _inputField("Email Address", Icons.alternate_email_rounded, emailCtrl),
                            const SizedBox(height: 20),
                            _inputField("Secure Password", Icons.lock_outline_rounded, passCtrl, obscure: true),

                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(color: richGold, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),

                            const Spacer(),

                            // SIGN IN BUTTON
                            GestureDetector(
                              onTap: _isLoading ? null : _loginUser,
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(colors: [richGold, const Color(0xFFB8860B)]),
                                  boxShadow: [
                                    BoxShadow(color: richGold.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                                  ],
                                ),
                                child: Center(
                                  child: _isLoading
                                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text("SIGN IN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // GOOGLE BUTTON
                            GestureDetector(
                              onTap: _loginWithGoogle,
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white10),
                                  color: Colors.white.withOpacity(0.05),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/auth/google.png", height: 22),
                                    const SizedBox(width: 12),
                                    const Text("Continue with Google", style: TextStyle(color: Colors.white, fontSize: 14)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  FadeIn(
                    delay: const Duration(milliseconds: 1200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ", style: TextStyle(color: Colors.white60)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                          },
                          child: Text("Register Now", style: TextStyle(color: richGold, fontWeight: FontWeight.bold)),
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

  Future<void> _loginUser() async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please enter all details");
      return;
    }

    try {
      setState(() => _isLoading = true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GemziHome()));
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Login failed");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      setState(() => _isLoading = true);
      
      final user = await GoogleAuthService.signInWithGoogle();

      if (user != null && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GemziHome()));
      }
    } catch (e) {
      debugPrint("Google login error: $e");
      _showError("Google login failed: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  Widget _inputField(String hint, IconData icon, TextEditingController controller, {bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
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
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
