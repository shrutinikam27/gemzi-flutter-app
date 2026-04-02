import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/admin_auth_service.dart';
import '../screens/admin/admin_navigation_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final Color darkBg = const Color(0xFF0A1F1C);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF1B6B5A);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [darkBg, const Color(0xFF0F2F2B), const Color(0xFF17453F).withOpacity(0.5)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: emerald.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: gold.withOpacity(0.4), width: 1.5),
                              ),
                              child: Icon(Icons.diamond_rounded, color: gold, size: 44),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "GEMZI",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "ADMIN PORTAL",
                              style: TextStyle(
                                fontSize: 12,
                                color: gold.withOpacity(0.8),
                                letterSpacing: 4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 56),
                      const Text(
                        "Sign In",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        "Access restricted to authorized admins only",
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.45)),
                      ),
                      const SizedBox(height: 32),
                      _buildInputField("Email Address", Icons.email_rounded, emailCtrl),
                      const SizedBox(height: 16),
                      _buildInputField("Password", Icons.lock_rounded, passCtrl, isPassword: true),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gold,
                            foregroundColor: Colors.black,
                            elevation: 8,
                            shadowColor: gold.withOpacity(0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _isLoading ? null : _loginUser,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                                )
                              : const Text(
                                  "Sign In",
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                        ),
                      ),
                      const Spacer(),
                      Center(
                        child: Text(
                          "© 2025 Gemzi. All rights reserved.",
                          style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
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

    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await AdminAuthService.signInAsAdmin(email, password);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminNavigationScreen()),
      );
    } on FirebaseAuthException catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Access Denied"), backgroundColor: Colors.redAccent));
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Unauthorized Access"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField(String hint, IconData icon, TextEditingController controller, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePass : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: emerald, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 20),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                )
              : null,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
        ),
      ),
    );
  }
}
